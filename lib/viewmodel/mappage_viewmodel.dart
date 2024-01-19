
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:ibook/model/map/map_position.dart';
import 'package:ibook/repository/map_repository.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as map_tool;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ibook/util/utils.dart';

class MapPageViewModel with ChangeNotifier{
  final MapRepository mapRepository;
  MapPageViewModel({required this.mapRepository});

  static const defaultZoom = 15.0;
  static const CameraPosition kwangHwaMoon = CameraPosition(
    target: LatLng(37.571648599, 126.976372775),
    zoom: defaultZoom,
  );

  static const CameraPosition jejudo = CameraPosition(
    //bearing: 192.8334901395799,
      target: LatLng(33.361667, 126.529167),
      //tilt: 59.440717697143555,
      zoom: defaultZoom);

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  var isJeju = false;
  var mapType = MapType.hybrid;
  var _isMyLocationLoading = false;

  Future<void> loadMarksList() async{
    List<MapPosition> mapPositionList = await mapRepository.getMapPositionList();
    await Future.forEach(mapPositionList, (mapPosition) async{
      MarkerId markerId = MarkerId(mapPosition.id);
      var marker = await createMaker(markerId, LatLng(mapPosition.latitude, mapPosition.longitude));
      markers[markerId] = marker;
    });
    notifyListeners();
  }

  void changeMapType(){
    mapType = getDiffMapType();
    notifyListeners();
  }

  MapType getDiffMapType() {
    var type = MapType.values[Random().nextInt(MapType.values.length)];
    while (type == mapType || type == MapType.none) {
      type = MapType.values[Random().nextInt(MapType.values.length)];
    }
    return type;
  }

  void setMyLocationLoading(bool isLoading){
    _isMyLocationLoading = isLoading;
    notifyListeners();
  }

  bool isMyLocationLoading() => _isMyLocationLoading;

  Future addMarkerLongPressed(LatLng latlng) async {
    final MarkerId markerId = MarkerId(getRandomString(10));
    createMaker(markerId, latlng).then((marker) =>
    {
      markers[markerId] = marker,
      mapRepository.insertMapPosition(
          MapPosition(markerId.value, latlng.latitude, latlng.longitude)),
      notifyListeners()
    });

    //This is optional, it will zoom when the marker has been created
    //GoogleMapController controller = await _controller.future;
    //controller.animateCamera(CameraUpdate.newLatLngZoom(latlang, 17.0));
  }

  Future<Marker> createMaker(MarkerId markerId, LatLng latlng) async{
    List<geo.Placemark> placeMark = await geo.placemarkFromCoordinates(latlng.latitude, latlng.longitude, localeIdentifier: "ko");
    Marker marker = Marker(
        markerId: markerId,
        draggable: true,
        position: latlng, //With this parameter you automatically obtain latitude and longitude
        infoWindow: InfoWindow(
          title: "${placeMark.first.street}",
          snippet: 'place number : ${markers.length+1} ',
        ),
        icon: BitmapDescriptor.defaultMarker,
        onTap: (){
          mapRepository.deleteMapPosition(MapPosition(markerId.value, latlng.latitude, latlng.longitude));
          markers.remove(markerId);
          notifyListeners();
        }
    );
    return marker;
  }

  void checkingAddedPlace(LatLng pickPosition){
    markers.forEach((key, marker) {
      print("markers count = ${markers.length}, marker = $marker , key $key");
      final LatLng targetPosition = marker.position;
      final distance = map_tool.SphericalUtil.computeDistanceBetween(map_tool.LatLng(pickPosition.latitude, pickPosition.longitude),
          map_tool.LatLng(targetPosition.latitude, targetPosition.longitude)) / 1000.0;
      print("point distance $distance km.");
    });
  }

  Future<CameraPosition?> getCurrentLocation() async {
    LocationData? currentLocation;
    try {
      currentLocation = await Location().getLocation();
    } on Exception catch (e) {
      print(e);
      currentLocation = null;
    }
    if (currentLocation != null) {
      return CameraPosition(
          target:
          LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: MapPageViewModel.defaultZoom);
    } else {
      return null;
    }
  }

}