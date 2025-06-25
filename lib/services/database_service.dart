import 'dart:async';
import 'package:craft_stash/class/yarns/brand.dart';
import 'package:craft_stash/class/yarns/material.dart';
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/services/database_versioning.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbService {
  static final DbService _service = DbService._internal();
  factory DbService() => _service;
  DbService._internal();

  static Database? _db;
  Future<Database?> get database async {
    if (_db != null) {
      return _db;
    }
    _db = await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'db.db');

    return await openDatabase(
      path,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      version: 8,
      onConfigure: (db) async => {await db.execute('PRAGMA foreign_keys = ON')},
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    db.execute(
      '''CREATE TABLE IF NOT EXISTS yarn(id INTEGER PRIMARY KEY, color INT, brand TEXT, material TEXT, color_name TEXT, min_hook REAL, max_hook REAL, thickness REAL, number_of_skeins INT, collection_id INT DEFAULT -1, hash INT)''',
    );

    db.execute(
      '''CREATE TABLE IF NOT EXISTS brand(id INTEGER PRIMARY KEY, name TEXT UNIQUE, hash INT)''',
    );

    db.execute(
      '''CREATE TABLE IF NOT EXISTS material(id INTEGER PRIMARY KEY, name TEXT UNIQUE, hash INT)''',
    );
    db.execute(
      '''CREATE TABLE IF NOT EXISTS yarn_collection(id INTEGER PRIMARY KEY, brand TEXT, material TEXT, min_hook REAL, max_hook REAL, thickness REAL, name TEXT, hash INT)''',
    );

    db.execute(
      '''CREATE TABLE IF NOT EXISTS pattern(pattern_id INTEGER PRIMARY KEY, name TEXT, hash INT UNIQUE)''',
    );
    db.execute(
      '''CREATE TABLE IF NOT EXISTS pattern_part(part_id INTEGER PRIMARY KEY, name TEXT, numbers_to_make INT, pattern_id INT, FOREIGN KEY (pattern_id) REFERENCES pattern(pattern_id))''',
    );
    db.execute(
      '''CREATE TABLE IF NOT EXISTS pattern_row(row_id INTEGER PRIMARY KEY, part_id INT, part_detail_id INT, start_row INT, end_row INT, stitches_count_per_row INT, FOREIGN KEY (part_id) REFERENCES pattern_part(part_id), FOREIGN KEY (part_detail_id) REFERENCES pattern_row_detail(row_detail_id))''',
    );
    db.execute(
      '''CREATE TABLE IF NOT EXISTS pattern_row_detail(row_detail_id INTEGER PRIMARY KEY, row_id INT, stitch TEXT, repeat_x_time INT, color INT, has_subrow INT, FOREIGN KEY (row_id) REFERENCES pattern_row(row_id))''',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Batch batch = db.batch();
    if (oldVersion < 2) {
      await dbV2(batch);
    }
    if (oldVersion < 3) {
      await dbV3(batch);
    }
    if (oldVersion < 4) {
      await dbV4(batch);
    }
    if (oldVersion < 5) {
      await dbV5(batch);
    }
    if (oldVersion < 6) {
      await dbV6(batch);
    }
    if (oldVersion < 7) {
      await dbV7(batch);
    }
    if (oldVersion < 8) {
      await dbV8(batch);
    }
    batch.commit();
  }

  Future<void> clearDb() async {
    await removeAllYarnCollection();
    await removeAllYarn();
    await removeAllYarnMaterial();
    await removeAllBrand();
  }

  Future<void> recreateDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'db.db');
    print(path);
    await deleteDatabase(path);
    await _initDb();
  }
}

class DatabaseDoesNotExistException implements Exception {
  DatabaseDoesNotExistException(this.cause);
  String cause;
}
