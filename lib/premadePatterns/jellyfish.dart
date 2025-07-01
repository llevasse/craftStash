import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;

Future<PatternPart> _createHeadPart(int patternId) async {
  PatternPart head = PatternPart(name: "head", patternId: patternId);
  head.partId = await insertPatternPartInDb(head);

  PatternRow r1 = PatternRow(
    partId: head.partId,
    startRow: 1,
    endRow: 1,
    stitchesPerRow: 6,
  );
  r1.rowId = await insertPatternRowInDb(r1);
  await insertPatternRowDetailInDb(
    PatternRowDetail(rowId: r1.rowId, repeatXTime: 6, stitch: "sc"),
  );

  PatternRow r2 = PatternRow(
    partId: head.partId,
    startRow: 2,
    endRow: 1,
    stitchesPerRow: 12,
  );
  r2.rowId = await insertPatternRowInDb(r2);
  PatternRowDetail dr2 = PatternRowDetail(
    rowId: r2.rowId,
    repeatXTime: 3,
    stitch: "(1sc, inc)",
    hasSubrow: 1,
  );
  dr2.rowDetailId = await insertPatternRowDetailInDb(dr2);
  print("Row detail id ${dr2.rowDetailId}");
  PatternRow r2Subrow = PatternRow(
    partId: head.partId,
    startRow: 0,
    endRow: 0,
    stitchesPerRow: 3,
    partDetailId: dr2.rowDetailId,
  );
  r2Subrow.rowId = await insertPatternRowInDb(r2Subrow);
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r2Subrow.rowId,
      repeatXTime: 1,
      stitch: "sc",
      hasSubrow: 0,
    ),
  );
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r2Subrow.rowId,
      repeatXTime: 1,
      stitch: "inc",
      hasSubrow: 0,
    ),
  );

  return head;
}

Future<void> insertJellyFishPattern() async {
  craft.Pattern pattern = craft.Pattern(name: "Jellyfish");
  pattern.patternId = await craft.insertPatternInDb(pattern);
  pattern.parts.add(await _createHeadPart(pattern.patternId));
}
