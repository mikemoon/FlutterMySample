
import 'package:floor/floor.dart';

@entity
class MapPosition{
  @primaryKey
  final String id;
  final double latitude;
  final double longitude;
  MapPosition(
      this.id,
      this.latitude,
      this.longitude
      );
}