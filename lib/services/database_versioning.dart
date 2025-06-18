import 'package:sqflite/sqflite.dart';

Future<void> dbV2(Batch batch) async {
  batch.execute(
    '''CREATE TABLE IF NOT EXISTS brand(id INTEGER PRIMARY KEY, name TEXT UNIQUE)''',
  );
  await batch.commit();
}

Future<void> dbV3(Batch batch) async {
  batch.execute(
    '''CREATE TABLE IF NOT EXISTS material(id INTEGER PRIMARY KEY, name TEXT UNIQUE)''',
  );
  await batch.commit();
}

Future<void> dbV4(Batch batch) async {
  batch.execute(
    '''CREATE TABLE IF NOT EXISTS yarn_collection(id INTEGER PRIMARY KEY, brand TEXT, material TEXT, min_hook REAL, max_hook REAL, thickness REAL)''',
  );
  await batch.commit();
}

Future<void> dbV5(Batch batch) async {
  batch.execute('''ALTER TABLE yarn_collection ADD COLUMN name TEXT''');
  await batch.commit();
}
