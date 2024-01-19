
import 'dart:async';
import 'package:path/path.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:ibook/dao/map_position_dao.dart';
import 'package:ibook/model/map/map_position.dart';

part 'app_database.g.dart';

@Database(version: 1, entities: [MapPosition])
abstract class AppDatabase extends FloorDatabase{
  MapPositionDao get mapPositionDao;
}