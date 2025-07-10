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
    numberOfRows: 1,
    stitchesPerRow: 6,
  );
  r1.rowId = await insertPatternRowInDb(r1);
  await insertPatternRowDetailInDb(
    PatternRowDetail(rowId: r1.rowId, repeatXTime: 6, stitch: "sc"),
  );

  PatternRow r2 = PatternRow(
    partId: head.partId,
    startRow: 2,
    numberOfRows: 1,
    stitchesPerRow: 12,
  );
  r2.rowId = await insertPatternRowInDb(r2);
  await insertPatternRowDetailInDb(
    PatternRowDetail(rowId: r2.rowId, repeatXTime: 6, stitch: "inc"),
  );

  PatternRow r3 = PatternRow(
    partId: head.partId,
    startRow: 3,
    numberOfRows: 1,
    stitchesPerRow: 18,
  );
  r3.rowId = await insertPatternRowInDb(r3);
  PatternRowDetail dr3 = PatternRowDetail(
    rowId: r3.rowId,
    repeatXTime: 3,
    stitch: "(1sc, inc)",
    hasSubrow: 1,
  );
  dr3.rowDetailId = await insertPatternRowDetailInDb(dr3);
  PatternRow r3Subrow = PatternRow(
    partId: head.partId,
    startRow: 0,
    numberOfRows: 0,
    stitchesPerRow: 3,
    partDetailId: dr3.rowDetailId,
  );
  r3Subrow.rowId = await insertPatternRowInDb(r3Subrow);
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r3Subrow.rowId,
      repeatXTime: 1,
      stitch: "sc",
      hasSubrow: 0,
    ),
  );
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r3Subrow.rowId,
      repeatXTime: 1,
      stitch: "inc",
      hasSubrow: 0,
    ),
  );

  PatternRow r4 = PatternRow(
    partId: head.partId,
    startRow: 4,
    numberOfRows: 2,
    stitchesPerRow: 18,
  );
  r4.rowId = await insertPatternRowInDb(r4);
  await insertPatternRowDetailInDb(
    PatternRowDetail(rowId: r4.rowId, repeatXTime: 18, stitch: "sc"),
  );

  PatternRow r6 = PatternRow(
    partId: head.partId,
    startRow: 6,
    numberOfRows: 1,
    stitchesPerRow: 9,
  );
  r6.rowId = await insertPatternRowInDb(r6);
  await insertPatternRowDetailInDb(
    PatternRowDetail(rowId: r6.rowId, repeatXTime: 9, stitch: "dec"),
  );

  return head;
}

Future<PatternPart> _createShortTentacles(int patternId) async {
  PatternPart short = PatternPart(
    name: "short tentacles",
    patternId: patternId,
    numbersToMake: 4,
  );
  short.partId = await insertPatternPartInDb(short);

  PatternRow r1 = PatternRow(
    partId: short.partId,
    startRow: 1,
    numberOfRows: 1,
    stitchesPerRow: 8,
  );
  r1.rowId = await insertPatternRowInDb(r1);
  await insertPatternRowDetailInDb(
    PatternRowDetail(rowId: r1.rowId, repeatXTime: 8, stitch: "ch"),
  );
  return (short);
}

Future<PatternPart> _createLongTentacles(int patternId) async {
  PatternPart long = PatternPart(
    name: "long tentacles",
    patternId: patternId,
    numbersToMake: 4,
  );
  long.partId = await insertPatternPartInDb(long);

  PatternRow r1 = PatternRow(
    partId: long.partId,
    startRow: 1,
    numberOfRows: 1,
    stitchesPerRow: 12,
  );
  r1.rowId = await insertPatternRowInDb(r1);
  await insertPatternRowDetailInDb(
    PatternRowDetail(rowId: r1.rowId, repeatXTime: 12, stitch: "ch"),
  );
  return (long);
}

Future<void> insertJellyFishPattern() async {
  craft.Pattern pattern = craft.Pattern(name: "Jellyfish");
  pattern.patternId = await craft.insertPatternInDb(pattern);
  pattern.parts.add(await _createHeadPart(pattern.patternId));
  pattern.parts.add(await _createShortTentacles(pattern.patternId));
  pattern.parts.add(await _createLongTentacles(pattern.patternId));
}
