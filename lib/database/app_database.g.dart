// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  MapPositionDao? _mapPositionDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `MapPosition` (`id` TEXT NOT NULL, `latitude` REAL NOT NULL, `longitude` REAL NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  MapPositionDao get mapPositionDao {
    return _mapPositionDaoInstance ??=
        _$MapPositionDao(database, changeListener);
  }
}

class _$MapPositionDao extends MapPositionDao {
  _$MapPositionDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _mapPositionInsertionAdapter = InsertionAdapter(
            database,
            'MapPosition',
            (MapPosition item) => <String, Object?>{
                  'id': item.id,
                  'latitude': item.latitude,
                  'longitude': item.longitude
                }),
        _mapPositionDeletionAdapter = DeletionAdapter(
            database,
            'MapPosition',
            ['id'],
            (MapPosition item) => <String, Object?>{
                  'id': item.id,
                  'latitude': item.latitude,
                  'longitude': item.longitude
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MapPosition> _mapPositionInsertionAdapter;

  final DeletionAdapter<MapPosition> _mapPositionDeletionAdapter;

  @override
  Future<List<MapPosition>> getMapPositionList() async {
    return _queryAdapter.queryList('SELECT * FROM MapPosition',
        mapper: (Map<String, Object?> row) => MapPosition(row['id'] as String,
            row['latitude'] as double, row['longitude'] as double));
  }

  @override
  Future<void> insertMapPosition(MapPosition position) async {
    await _mapPositionInsertionAdapter.insert(
        position, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteMapPosition(MapPosition position) async {
    await _mapPositionDeletionAdapter.delete(position);
  }
}
