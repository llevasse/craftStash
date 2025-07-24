import 'package:sqflite/sqflite.dart';

Future<void> dbUpgradeV2(Batch batch) async {
  batch.execute(
    '''CREATE TABLE IF NOT EXISTS wip(id INTEGER PRIMARY KEY, pattern_id INT, finished INT, FOREIGN KEY (pattern_id) REFERENCES pattern(pattern_id) ON DELETE CASCADE)''',
  );
  batch.execute(
    '''CREATE TABLE IF NOT EXISTS wip_part(id INTEGER PRIMARY KEY, wip_id INT, part_id INT, finished INT, made_x_time INT, current_row_number INT, current_stitch_number INT, FOREIGN KEY (wip_id) REFERENCES wip(id) ON DELETE CASCADE, FOREIGN KEY (part_id) REFERENCES pattern_part(part_id) ON DELETE CASCADE)''',
  );
  await batch.commit();
}
