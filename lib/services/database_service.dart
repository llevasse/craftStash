import 'dart:async';
import 'package:craft_stash/class/brand.dart';
import 'package:craft_stash/class/material.dart';
import 'package:craft_stash/class/yarn.dart';
import 'package:craft_stash/class/yarn_collection.dart';
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
      version: 7,
      onConfigure: (db) async => {await db.execute('PRAGMA foreign_keys = ON')},
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    db.execute(
      '''CREATE TABLE IF NOT EXISTS yarn(id INTEGER PRIMARY KEY, color INT, brand TEXT, material TEXT, color_name TEXT, min_hook REAL, max_hook REAL, thickness REAL, number_of_skeins INT)''',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Batch batch = db.batch();
    if (oldVersion < 2) {
      dbV2(batch);
    }
    if (oldVersion < 3) {
      dbV3(batch);
    }
    if (oldVersion < 4) {
      dbV4(batch);
    }
    if (oldVersion < 5) {
      dbV5(batch);
    }
    if (oldVersion < 6) {
      dbV6(batch);
    }
    if (oldVersion < 7) {
      dbV7(batch);
    }
    batch.commit();
  }

  Future<void> clearDb() async {
    await removeAllYarnCollection();
    await removeAllYarn();
    await removeAllYarnMaterial();
    await removeAllBrand();
  }
}

class DatabaseDoesNotExistException implements Exception {
  DatabaseDoesNotExistException(this.cause);
  String cause;
}
