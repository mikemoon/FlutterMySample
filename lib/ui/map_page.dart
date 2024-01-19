import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ibook/viewmodel/mappage_viewmodel.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class GoogleMapPage extends StatefulWidget {
  final MapPageViewModel mapPageViewModel;

  GoogleMapPage({required this.mapPageViewModel});

  @override
  State<GoogleMapPage> createState() => GoogleMapPageState();
}

class GoogleMapPageState extends State<GoogleMapPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  void initState() {
    enableBackgroundMode();
    super.initState();
    widget.mapPageViewModel.loadMarksList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.mapPageViewModel,
      child: Consumer<MapPageViewModel>(
        builder: (context, provider, child) {
          return Scaffold(
              body: Stack(
                children: [
                  GoogleMap(
                    mapType: provider.mapType,
                    initialCameraPosition: MapPageViewModel.kwangHwaMoon,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    onLongPress: (latLang) {
                      provider.addMarkerLongPressed(latLang);
                    },
                    markers: Set<Marker>.of(provider.markers.values),
                  ),
                  if (provider.markers.isNotEmpty)
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                            color: Colors.black12.withOpacity(0.3)),
                        constraints: BoxConstraints(maxHeight: 200),
                        child: ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (context, int index) {
                              Marker item =
                                  provider.markers.values.elementAt(index);
                              return ListTile(
                                title: Text("${item.infoWindow.title}",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                                onTap: () {
                                  goToTarget(CameraPosition(
                                      target: LatLng(item.position.latitude,
                                          item.position.longitude),
                                      zoom: MapPageViewModel.defaultZoom));
                                },
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(
                                      height: 2,
                                    ),
                            itemCount: provider.markers.length),
                      ),
                    ),
                  if (provider.isMyLocationLoading())
                    Container(
                      decoration:
                          BoxDecoration(color: Colors.black26.withOpacity(0.4)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('내위치 확인중...',
                                style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                    )
                ],
              ),
              floatingActionButton: Padding(
                  padding: const EdgeInsets.only(right: 50.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () => provider.changeMapType(),
                        label: Text('맵타입'),
                        icon: const Icon(Icons.map_outlined),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      FloatingActionButton.extended(
                        onPressed: () => {
                          provider.setMyLocationLoading(true),
                          provider
                              .getCurrentLocation()
                              .then((myCameraPosition) => {
                                    if (myCameraPosition != null)
                                      {
                                        goToTarget(myCameraPosition),
                                      },
                                    provider.setMyLocationLoading(false),
                                  })
                        },
                        label: Text("내위치로"),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      FloatingActionButton.extended(
                        onPressed: () => {
                          goToTarget(provider.isJeju
                              ? MapPageViewModel.kwangHwaMoon
                              : MapPageViewModel.jejudo),
                          setState(() {
                            provider.isJeju = !provider.isJeju;
                          })
                        },
                        label: provider.isJeju
                            ? Text('광화문으로 이동!')
                            : Text('제주도로 이동!'),
                        icon: const Icon(Icons.flight_land),
                      ),
                    ],
                  )));
        },
      ),
    );
  }

  Future<void> goToTarget(CameraPosition target) async {
    print("goTo###### ${target.target.latitude}");
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(target));
  }

  Future<bool> enableBackgroundMode() async {
    //for location permission
    var location = Location();
    bool bgModeEnabled = await location.isBackgroundModeEnabled();
    if (bgModeEnabled) {
      return true;
    } else {
      try {
        await location.enableBackgroundMode();
      } catch (e) {
        print(e.toString());
      }
      try {
        bgModeEnabled = await location.enableBackgroundMode();
      } catch (e) {
        print(e.toString());
      }
      return bgModeEnabled;
    }
  }
}
