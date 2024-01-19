
import 'package:floor/floor.dart';
import 'package:ibook/model/map/map_position.dart';

@dao
abstract class MapPositionDao{
  @Query('SELECT * FROM MapPosition')
  Future<List<MapPosition>> getMapPositionList();

  @insert
  Future<void> insertMapPosition(MapPosition position);

  @delete
  Future<void> deleteMapPosition(MapPosition position);
}