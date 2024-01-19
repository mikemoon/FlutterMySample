import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothViewModel with ChangeNotifier{

  BluetoothViewModel(){
    //init();
  }

  late StreamSubscription<BluetoothAdapterState> btStateSubscription;
  late StreamSubscription<List<ScanResult>> btScanSubscription;
  late StreamSubscription<bool> scanningStateSubscription;
  List<ScanResult> _scanResultList = [];
  List<ScanResult> get scanResultList => _scanResultList;

  bool _isBlueToothSupport = false;
  bool get isBlueToothSupport => _isBlueToothSupport;
  BluetoothAdapterState _bluetoothState = BluetoothAdapterState.off;
  BluetoothAdapterState get bluetoothState => _bluetoothState;
  bool _isScanning = false;
  bool get isScanning => _isScanning;
  bool _hasScanned = false;
  bool get hasScanned => _hasScanned;
  bool _showScanFinishMsg = false;
  int deviceConnectErrorCode = 0;
  DeviceState? _connectDisConnectTarget;

  Future<void> init() async{
    _hasScanned = false;
    _isScanning = false;
    btStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      print("btState =  $state");
      _bluetoothState = state;
      notifyListeners();
    });

    btScanSubscription = FlutterBluePlus.scanResults.listen((result) {
      var previousResult = scanResultList;
      _scanResultList = result.where((device) => device.advertisementData.advName.isNotEmpty).toList();
      //print("bt device ${result[0].device.remoteId} ${result[0].device.platformName}");
      if(scanResultList.isNotEmpty && previousResult != scanResultList) {
        print("bt scan result~ ${result.length}");
        notifyListeners();
      }
    },
        onError: (e) => print(e));

    scanningStateSubscription = FlutterBluePlus.isScanning.listen((state) {
      print("bt scanning ${state} , device count = ${scanResultList.length}");
      if(isScanning && state == false){
        _hasScanned = true;
        setShowScanFinishMessage(true);
      }
      _isScanning = state;
      notifyListeners();
    });
    await checkingSupport();

    FlutterBluePlus.events.onConnectionStateChanged.listen((event) {
      print('BT device connection state : ${event.device} ${event.connectionState}');
      if(event.connectionState == BluetoothConnectionState.disconnected) {
        if(event.device.disconnectReason?.code != null){
          deviceConnectErrorCode = event.device.disconnectReason!.code!;
        }
      }
      _connectDisConnectTarget = null;
      notifyListeners();
    });
  }

  Future<void> checkingSupport() async {
    var isBtSupport = await FlutterBluePlus.isSupported;
    _isBlueToothSupport = isBtSupport;
    notifyListeners();
  }

  Future<void> turnOnBt() async{
    if(Platform.isAndroid){
      await FlutterBluePlus.turnOn();
    }
  }

  Future<void> startScan() async{
    try {
      // android is slow when asking for all advertisements,
      // so instead we only ask for 1/8 of them
      int divisor = Platform.isAndroid ? 8 : 1;
      await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 15), continuousUpdates: true, continuousDivisor: divisor);
      //FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      print('Start Scan Error $e');
    }
  }

  void setShowScanFinishMessage(bool isShow){
    _showScanFinishMsg = isShow;
  }

  bool isShowScanFinishMessage() => _showScanFinishMsg;

  void cancelSubscription(){
    btStateSubscription.cancel();
    btScanSubscription.cancel();
    scanningStateSubscription.cancel();
  }

  void setConnectDisConnectDevice(DeviceState? deviceState){
    _connectDisConnectTarget = deviceState;
    notifyListeners();
  }

  DeviceState? getDeviceConnectDisConnectTarget() => _connectDisConnectTarget;

  String getDeviceStateString(int deviceListIndex){
    String deviceStateBtnStr = "연결";
    if(_connectDisConnectTarget != null){
      if(_connectDisConnectTarget?.device == scanResultList[deviceListIndex].device){
        if(_connectDisConnectTarget?.isConnecting == true){
          deviceStateBtnStr = "연결중";
        }
        if(_connectDisConnectTarget?.isDisConnecting == true){
          deviceStateBtnStr = "해제중";
        }
      }
    }else if(scanResultList[deviceListIndex].device.isConnected){
      deviceStateBtnStr = "해제";
    }
    return deviceStateBtnStr;
  }

}

class DeviceState{
  DeviceState({required this.device, required this.isConnecting, required this.isDisConnecting});
  BluetoothDevice? device;
  bool isConnecting = false;
  bool isDisConnecting = false;
}