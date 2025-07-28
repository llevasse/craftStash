import 'dart:async';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/class/yarns/brand.dart';
import 'package:craft_stash/class/yarns/material.dart';
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/main.dart';
import 'package:craft_stash/premadePatterns/bee.dart';
import 'package:craft_stash/premadePatterns/jellyfish.dart';
import 'package:craft_stash/premadeYarns/phildar.dart';
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
      version: 2,
      onConfigure: (db) async => {await db.execute('PRAGMA foreign_keys = ON')},
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''CREATE TABLE IF NOT EXISTS yarn(id INTEGER PRIMARY KEY, color INT, brand TEXT, material TEXT, color_name TEXT, min_hook REAL, max_hook REAL, thickness REAL, number_of_skeins INT, collection_id INT, in_pattern_id INT, hash INT, FOREIGN KEY (collection_id) REFERENCES yarn_collection(id))''',
    );

    await db.execute(
      '''CREATE TABLE IF NOT EXISTS brand(id INTEGER PRIMARY KEY, name TEXT UNIQUE, hash INT)''',
    );

    await db.execute(
      '''CREATE TABLE IF NOT EXISTS material(id INTEGER PRIMARY KEY, name TEXT UNIQUE, hash INT)''',
    );
    await db.execute(
      '''CREATE TABLE IF NOT EXISTS yarn_collection(id INTEGER PRIMARY KEY, brand TEXT, material TEXT, min_hook REAL, max_hook REAL, thickness REAL, name TEXT, hash INT)''',
    );

    await db.execute(
      '''CREATE TABLE IF NOT EXISTS pattern(pattern_id INTEGER PRIMARY KEY, name TEXT, assembly TEXT, hook_size REAL, note TEXT, total_stitch_nb INT, hash INT UNIQUE)''',
    );
    await db.execute(
      '''CREATE TABLE IF NOT EXISTS pattern_part(part_id INTEGER PRIMARY KEY, name TEXT, numbers_to_make INT, pattern_id INT, note TEXT, total_stitch_nb INT, FOREIGN KEY (pattern_id) REFERENCES pattern(pattern_id) ON DELETE CASCADE)''',
    );
    await db.execute(
      '''CREATE TABLE IF NOT EXISTS pattern_row(row_id INTEGER PRIMARY KEY, part_id INT, start_row INT, number_of_rows INT, stitches_count_per_row INT, in_same_stitch INT, preview TEXT, note TEXT, FOREIGN KEY (part_id) REFERENCES pattern_part(part_id) ON DELETE CASCADE)''',
    );
    await db.execute(
      '''CREATE TABLE IF NOT EXISTS stitch(id INTEGER PRIMARY KEY, sequence_id INT, abreviation TEXT, name TEXT, description TEXT, is_sequence INT, hidden INT, stitch_nb INT, hash INT, FOREIGN KEY (sequence_id) REFERENCES pattern_row(row_id) ON DELETE CASCADE)''',
    );
    await db.execute(
      '''CREATE TABLE IF NOT EXISTS pattern_row_detail(row_detail_id INTEGER PRIMARY KEY, row_id INT, stitch_id INT, repeat_x_time INT, in_row_order INT, yarn_id INT, FOREIGN KEY (row_id) REFERENCES pattern_row(row_id) ON DELETE CASCADE, FOREIGN KEY (stitch_id) REFERENCES stitch(id), FOREIGN KEY (yarn_id) REFERENCES yarn(id))''',
    );

    await db.execute(
      '''CREATE TABLE IF NOT EXISTS yarn_in_pattern(id INTEGER PRIMARY KEY, pattern_id INT, yarn_id INT, in_pattern_id INT, FOREIGN KEY (pattern_id) REFERENCES pattern(pattern_id), FOREIGN KEY (yarn_id) REFERENCES yarn(id))''',
    );
    await insertDefaultStitchesInDb(db);
    if (debug) {
      await insertPhildarYarn(db);
      await insertJellyFishPattern(db);
      await insertBeePattern(db);
    }

    await db.execute(
      '''CREATE TABLE IF NOT EXISTS wip(id INTEGER PRIMARY KEY, pattern_id INT, finished INT, stitch_done_nb INT, FOREIGN KEY (pattern_id) REFERENCES pattern(pattern_id) ON DELETE CASCADE)''',
    );
    await db.execute(
      '''CREATE TABLE IF NOT EXISTS wip_part(id INTEGER PRIMARY KEY, wip_id INT, part_id INT, finished INT, stitch_done_nb INT, made_x_time INT, current_row_number INT, current_row_index INT, current_stitch_number INT, FOREIGN KEY (wip_id) REFERENCES wip(id) ON DELETE CASCADE, FOREIGN KEY (part_id) REFERENCES pattern_part(part_id) ON DELETE CASCADE)''',
    );
    await db.execute(
      '''CREATE TABLE IF NOT EXISTS yarn_in_wip(id INTEGER PRIMARY KEY, wip_id INT, yarn_id INT, in_pattern_id INT, FOREIGN KEY (wip_id) REFERENCES wip(id), FOREIGN KEY (yarn_id) REFERENCES yarn(id))''',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Batch batch = db.batch();
    if (oldVersion < 2) {
      dbUpgradeV2(batch);
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
    await deleteDatabase(path);
    _db = null;
    database;
  }
}

class DatabaseDoesNotExistException implements Exception {
  DatabaseDoesNotExistException(this.cause);
  String cause;
}

class EntryAlreadyExist implements Exception {
  EntryAlreadyExist(this.table);
  String table;
  @override
  String toString() {
    return ("Entry in $table already exists");
  }
}

class DatabaseNoElementsMeetConditionException implements Exception {
  DatabaseNoElementsMeetConditionException(this.condition, this.table);
  String condition;
  String table;
  @override
  String toString() {
    return "No elements in table `$table` meets condition $condition";
  }
}
