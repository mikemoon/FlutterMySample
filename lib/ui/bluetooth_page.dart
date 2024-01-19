import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ibook/viewmodel/bluetooth_viewmodel.dart';
import 'package:provider/provider.dart';

class BluetoothPage extends StatefulWidget {
  final BluetoothViewModel viewModel;

  BluetoothPage({required this.viewModel});

  @override
  State<BluetoothPage> createState() => BluetoothPageState();
}

class BluetoothPageState extends State<BluetoothPage> {

  @override
  void initState() {
    super.initState();
    widget.viewModel.init().then((_) {
      print(
          "btPage init ${widget.viewModel.isBlueToothSupport}, ${widget.viewModel.bluetoothState}");
      if (widget.viewModel.isBlueToothSupport) {
        if (widget.viewModel.bluetoothState == BluetoothAdapterState.off) {
          widget.viewModel.turnOnBt();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    BuildContext? dialogContext;
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Consumer<BluetoothViewModel>(
        builder: (context, provider, child) {
          //스캔 종료 메시지
          if (provider.isShowScanFinishMessage() && !provider.isScanning) {
            Future.delayed(Duration.zero, () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Scan finished')));
            });
            provider.setShowScanFinishMessage(false);
          }

          //연결/연결해제 실패 메시지
          if(provider.deviceConnectErrorCode != 0){
            Future.delayed(Duration.zero, () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Device connect/disconnect failed, errCode : ${provider.deviceConnectErrorCode}')));
              provider.deviceConnectErrorCode = 0;
            });
          }

          //연결/연결해제 중 팝업 해제
          if(dialogContext != null && provider.getDeviceConnectDisConnectTarget() == null){
            Navigator.pop(dialogContext!);
            dialogContext = null;
          }

          if (!provider.isBlueToothSupport) {
            return Center(
              child: Text("This device is not support Bluetooth."),
            );
          } else {
            if (provider.isScanning && provider.scanResultList.isEmpty) {
              return Center(
                child: Text("Bluetooth device scanning..."),
              );
            } else if (!provider.hasScanned && !provider.isScanning && provider.scanResultList.isEmpty) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    provider.startScan();
                  },
                  child: Text('Start scan'),
                ),
              );
            } else if (!provider.isScanning &&
                provider.scanResultList.isEmpty) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Bluetooth device is not found."),
                  ElevatedButton(onPressed: () {}, child: Text("Retry scan"))
                ],
              ));
            } else {
              return Stack(
                children: [
                  ListView.separated(
                    itemCount: provider.scanResultList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(provider
                            .scanResultList[index].device.remoteId
                            .toString()),
                        subtitle: Text(provider
                            .scanResultList[index].advertisementData.advName),
                        trailing: ElevatedButton(child: Text(provider.getDeviceStateString(index)),onPressed:(){
                          if(provider.getDeviceConnectDisConnectTarget() != null)return;
                          BluetoothDevice device = provider.scanResultList[index].device;
                          if(device.isConnected){
                            provider.setConnectDisConnectDevice(DeviceState(device: device, isConnecting: false, isDisConnecting: true));
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context){
                                  dialogContext = context;
                              return showStateDialog("블루투스 해제중");
                            });
                            device.disconnect();
                          }else{
                            provider.setConnectDisConnectDevice(DeviceState(device: device, isConnecting: true, isDisConnecting: false));
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context){
                                  dialogContext = context;
                                  return showStateDialog("블루투스 연결중");
                                });
                            device.connect();
                          }
                        },),
                        onTap: (){

                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(
                      height: 2,
                    ),
                  ),
                  if(!provider.isScanning)
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 150, 10),
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(onPressed: () { provider.startScan(); }, child: Text("Scan"),),
                    ),
                  if (provider.isScanning)
                    Container(
                      decoration:
                          BoxDecoration(color: Colors.black26.withOpacity(0.4)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white,),
                            SizedBox(width: 10,),
                            Text('Scanning...',
                                style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                    )
                ],
              );
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(() {});
    widget.viewModel.cancelSubscription();
    super.dispose();
  }

  AlertDialog showStateDialog(String contentString){
    return AlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.black45,),
          SizedBox(width: 10,),
          Text(contentString,
              style: TextStyle(color: Colors.black45))
        ],
      ),
    );
  }
}
