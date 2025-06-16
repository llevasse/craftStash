import 'package:sqflite/sqflite.dart';

Future<void> dbV2(Batch batch) async {
  batch.execute(
    '''CREATE TABLE IF NOT EXISTS brand(id INTEGER PRIMARY KEY, name TEXT UNIQUE)''',
  );
  await batch.commit();
}
