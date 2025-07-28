import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:sqflite/sqflite.dart';

Future<void> dbUpgradeV2(Batch batch) async {
  batch.execute(
    '''CREATE TABLE IF NOT EXISTS wip(id INTEGER PRIMARY KEY, pattern_id INT, finished INT, stitch_done_nb INT, FOREIGN KEY (pattern_id) REFERENCES pattern(pattern_id) ON DELETE CASCADE)''',
  );
  batch.execute(
    '''CREATE TABLE IF NOT EXISTS wip_part(id INTEGER PRIMARY KEY, wip_id INT, part_id INT, finished INT, stitch_done_nb INT, made_x_time INT, current_row_number INT, current_row_index INT, current_stitch_number INT, FOREIGN KEY (wip_id) REFERENCES wip(id) ON DELETE CASCADE, FOREIGN KEY (part_id) REFERENCES pattern_part(part_id) ON DELETE CASCADE)''',
  );
  batch.execute(
    '''ALTER TABLE pattern ADD COLUMN total_stitch_nb INT DEFAULT 0''',
  );
  batch.execute(
    '''ALTER TABLE pattern_part ADD COLUMN total_stitch_nb INT DEFAULT 0''',
  );
  batch.execute('''ALTER TABLE stitch ADD COLUMN stitch_nb INT DEFAULT 1''');

  batch.execute(
    '''CREATE TABLE IF NOT EXISTS yarn_in_wip(id INTEGER PRIMARY KEY, wip_id INT, in_preview_id INT, yarn_id INT, FOREIGN KEY (wip_id) REFERENCES wip(id), FOREIGN KEY (yarn_id) REFERENCES yarn(id))''',
  );
  batch.execute('''ALTER TABLE yarn ADD COLUMN in_preview_id INT''');
  batch.execute('''ALTER TABLE yarn_in_pattern ADD COLUMN in_preview_id INT''');
  batch.execute('''ALTER TABLE pattern_row_detail ADD COLUMN pattern_id INT''');

  await batch.commit();

  // UPDATE pattern_part AND pattern table total_stitch_nb
  List<PatternPart> parts = await getAllPatternPart(withRow: true);
  Map<int, craft.Pattern> map = {};
  for (PatternPart part in parts) {
    for (PatternRow row in part.rows) {
      part.totalStitchNb += row.stitchesPerRow * row.numberOfRows;
    }
    await updatePatternPartInDb(part);
    if (!map.containsKey(part.patternId)) {
      map[part.patternId] = await craft.getPatternById(id: part.patternId);
    }
    map[part.patternId]?.totalStitchNb += part.totalStitchNb;
  }
  for (craft.Pattern pattern in map.values) {
    await craft.updatePatternInDb(pattern);
  }
}
