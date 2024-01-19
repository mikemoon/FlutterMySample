
import 'package:ibook/dao/map_position_dao.dart';
import 'package:ibook/model/map/map_position.dart';

class MapRepository{
  final MapPositionDao mapPositionDao;

  const MapRepository({required this.mapPositionDao});

  Future<List<MapPosition>> getMapPositionList() async{
    return mapPositionDao.getMapPositionList();
  }

  Future<void> insertMapPosition(MapPosition mapPosition) async {
    mapPositionDao.insertMapPosition(mapPosition);
  }

  Future<void> deleteMapPosition(MapPosition mapPosition) async{
    mapPositionDao.deleteMapPosition(mapPosition);
  }
}