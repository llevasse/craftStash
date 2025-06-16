import 'dart:async';
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
    db.execute(
      '''CREATE TABLE IF NOT EXISTS yarn(id INTEGER PRIMARY KEY, color INT, brand TEXT, material TEXT, color_name TEXT, min_hook REAL, max_hook REAL, thickness REAL, number_of_skeins INT)''',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Batch batch = db.batch();
    if (oldVersion < 2) {
      dbV2(batch);
    }
    batch.commit();
  }
}

class DatabaseDoesNotExistException implements Exception {
  DatabaseDoesNotExistException(this.cause);
  String cause;
}
