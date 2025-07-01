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

Future<void> dbV6(Batch batch) async {
  batch.execute('''ALTER TABLE yarn ADD COLUMN collection_id INT DEFAULT -1''');
  await batch.commit();
}

Future<void> dbV7(Batch batch) async {
  batch.execute('''ALTER TABLE yarn ADD COLUMN hash INT''');
  batch.execute('''ALTER TABLE yarn_collection ADD COLUMN hash INT''');
  batch.execute('''ALTER TABLE brand ADD COLUMN hash INT''');
  batch.execute('''ALTER TABLE material ADD COLUMN hash INT''');
  await batch.commit();
}

Future<void> dbV8(Batch batch) async {
  batch.execute(
    '''CREATE TABLE IF NOT EXISTS pattern(pattern_id INTEGER PRIMARY KEY, name TEXT, hash INT UNIQUE)''',
  );
  batch.execute(
    '''CREATE TABLE IF NOT EXISTS pattern_part(part_id INTEGER PRIMARY KEY, pattern_id INT, name TEXT, numbers_to_make INT, FOREIGN KEY (pattern_id) REFERENCES pattern(pattern_id) ON DELETE CASCADE)''',
  );
  batch.execute(
    '''CREATE TABLE IF NOT EXISTS pattern_row(row_id INTEGER PRIMARY KEY, part_id INT, part_detail_id INT, start_row INT, number_of_rows INT, stitches_count_per_row INT, FOREIGN KEY (part_id) REFERENCES pattern_part(part_id) ON DELETE CASCADE, FOREIGN KEY (part_detail_id) REFERENCES pattern_row_detail(row_detail_id) ON DELETE CASCADE)''',
  );
  batch.execute(
    '''CREATE TABLE IF NOT EXISTS pattern_row_detail(row_detail_id INTEGER PRIMARY KEY, row_id INT, stitch TEXT, repeat_x_time INT, color INT, has_subrow INT, FOREIGN KEY (row_id) REFERENCES pattern_row(row_id) ON DELETE CASCADE)''',
  );
  await batch.commit();
}
