import 'dart:async';
import 'dart:math';
import 'package:craft_stash/data/repository/stitch_repository.dart';
import 'package:craft_stash/data/repository/yarn/brand_repository.dart';
import 'package:craft_stash/data/repository/yarn/collection_repository.dart';
import 'package:craft_stash/data/repository/yarn/material_repository.dart';
import 'package:craft_stash/data/repository/yarn/yarn_repository.dart';
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
      '''CREATE TABLE IF NOT EXISTS yarn(id INTEGER PRIMARY KEY, color INT, brand TEXT, material TEXT, color_name TEXT, min_hook REAL, max_hook REAL, thickness REAL, number_of_skeins INT, collection_id INT, in_preview_id INT, hash INT, FOREIGN KEY (collection_id) REFERENCES yarn_collection(id))''',
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
      '''CREATE TABLE IF NOT EXISTS stitch(id INTEGER PRIMARY KEY, sequence_id INT, abreviation TEXT, name TEXT, description TEXT, is_sequence INT, hidden INT, stitch_nb INT, nb_of_stitches_taken INT, hash INT, FOREIGN KEY (sequence_id) REFERENCES pattern_row(row_id) ON DELETE CASCADE)''',
    );
    await db.execute(
      '''CREATE TABLE IF NOT EXISTS pattern_row_detail(row_detail_id INTEGER PRIMARY KEY, pattern_id INT, row_id INT, stitch_id INT, repeat_x_time INT, in_row_order INT, yarn_id INT, FOREIGN KEY (row_id) REFERENCES pattern_row(row_id) ON DELETE CASCADE, FOREIGN KEY (stitch_id) REFERENCES stitch(id), FOREIGN KEY (yarn_id) REFERENCES yarn(id))''',
    );

    await db.execute(
      '''CREATE TABLE IF NOT EXISTS yarn_in_pattern(id INTEGER PRIMARY KEY, pattern_id INT, yarn_id INT, in_preview_id INT, FOREIGN KEY (pattern_id) REFERENCES pattern(pattern_id) ON DELETE CASCADE, FOREIGN KEY (yarn_id) REFERENCES yarn(id))''',
    );
    await StitchRepository().insertDefaultStitches(db);
    if (debug) {
      await insertPhildarYarn(db);
      await insertJellyFishPattern(db);
      await insertBeePattern(db);
    }

    await db.execute(
      '''CREATE TABLE IF NOT EXISTS wip(id INTEGER PRIMARY KEY, pattern_id INT, name TEXT, hook_size REAL, finished INT, stitch_done_nb INT, FOREIGN KEY (pattern_id) REFERENCES pattern(pattern_id) ON DELETE CASCADE)''',
    );
    await db.execute(
      '''CREATE TABLE IF NOT EXISTS wip_part(id INTEGER PRIMARY KEY, wip_id INT, part_id INT, finished INT, stitch_done_nb INT, made_x_time INT, current_row_number INT, current_row_index INT, current_stitch_number INT, FOREIGN KEY (wip_id) REFERENCES wip(id) ON DELETE CASCADE, FOREIGN KEY (part_id) REFERENCES pattern_part(part_id) ON DELETE CASCADE)''',
    );
    await db.execute(
      '''CREATE TABLE IF NOT EXISTS yarn_in_wip(id INTEGER PRIMARY KEY, wip_id INT, yarn_id INT, in_preview_id INT, FOREIGN KEY (wip_id) REFERENCES wip(id) ON DELETE CASCADE, FOREIGN KEY (yarn_id) REFERENCES yarn(id))''',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Batch batch = db.batch();
    if (oldVersion < 2) {
      dbUpgradeV2(batch);
    }
    if (oldVersion < 3) {
      dbUpgradeV3(batch);
    }
    batch.commit();
  }

  Future<void> clearDb() async {
    await CollectionRepository().removeAllYarnCollection();
    await YarnRepository().removeAllYarn();
    await MaterialRepository().removeAllMaterials();
    await BrandRepository().removeAllBrand();
  }

  Future<void> recreateDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'db.db');
    await deleteDatabase(path);
    _db = null;
    database;
  }

  Future<void> printDbTables({
    bool brand = false,
    bool material = false,
    bool pattern = false,
    bool patternPart = false,
    bool patternRow = false,
    bool patternRowDetail = false,
    bool stitch = false,
    bool wip = false,
    bool wipPart = false,
    bool yarn = false,
    bool yarnCollection = false,
    bool yarnInPattern = false,
    bool yarnInWip = false,
  }) async {
    List<String> tables = List.empty(growable: true);
    if (brand) tables.add('brand');
    if (material) tables.add('material');
    if (pattern) tables.add('pattern');
    if (patternPart) tables.add('pattern_part');
    if (patternRow) tables.add('pattern_row');
    if (patternRowDetail) tables.add('pattern_row_detail');
    if (stitch) tables.add('stitch');
    if (wip) tables.add('wip');
    if (wipPart) tables.add('wip_part');
    if (yarn) tables.add('yarn');
    if (yarnCollection) tables.add('yarn_collection');
    if (yarnInPattern) tables.add('yarn_in_pattern');
    if (yarnInWip) tables.add('yarn_in_wip');
    if (_db == null) return;
    int padding = 2;
    for (String table in tables) {
      List<Map<String, Object?>>? l = await _db?.query(table);
      if (l != null) {
        print("_________${table.toUpperCase()}_________\n");
        if (l.isEmpty) {
          print("Empty");
          continue;
        }
        StringBuffer tmp = StringBuffer("");
        Map<String, int> maxLengths = {};
        for (MapEntry<String, Object?> entry in l[0].entries) {
          maxLengths[entry.key] = entry.key.length;
        }

        for (Map<String, Object?> map in l) {
          for (MapEntry<String, Object?> entry in map.entries) {
            maxLengths[entry.key] = max(
              maxLengths[entry.key]!,
              entry.value.toString().length,
            );
          }
        }

        for (MapEntry<String, Object?> entry in l[0].entries) {
          tmp.write("|${entry.key.padRight(maxLengths[entry.key]! + padding)}");
        }
        print(tmp);
        tmp.clear();
        for (Map<String, Object?> map in l) {
          for (MapEntry<String, Object?> entry in map.entries) {
            tmp.write(
              "|${entry.value.toString().padRight(maxLengths[entry.key]! + padding)}",
            );
          }
          print(tmp);
          tmp.clear();
        }
      }
    }
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

class ElementIsUsedSomewhereElse implements Exception {
  ElementIsUsedSomewhereElse(this.table);
  String table;
  @override
  String toString() {
    return ("Element is used in $table");
  }
}
