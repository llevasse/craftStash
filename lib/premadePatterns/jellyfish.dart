import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:sqflite/sqflite.dart';

Map<String, Stitch> _stitchesMap = {};

Future<PatternPart> _createHeadPart(int patternId, Database? db) async {
  PatternPart head = PatternPart(name: "head", patternId: patternId);
  head.partId = await insertPatternPartInDb(head, db);

  PatternRow r1 = PatternRow(
    partId: head.partId,
    startRow: 1,
    numberOfRows: 1,
    stitchesPerRow: 6,
    preview: "6sc",
  );
  r1.rowId = await insertPatternRowInDb(r1, db);
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r1.rowId,
      repeatXTime: 6,
      stitchId: _stitchesMap["sc"]!.id,
    ),
    db,
  );

  PatternRow r2 = PatternRow(
    partId: head.partId,
    startRow: 2,
    numberOfRows: 1,
    stitchesPerRow: 12,
    preview: "6inc",
  );
  r2.rowId = await insertPatternRowInDb(r2, db);
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r2.rowId,
      repeatXTime: 6,
      stitchId: _stitchesMap["inc"]!.id,
    ),
    db,
  );

  PatternRow r3 = PatternRow(
    partId: head.partId,
    startRow: 3,
    numberOfRows: 1,
    stitchesPerRow: 18,
    preview: "(sc, inc)x6",
  );
  r3.rowId = await insertPatternRowInDb(r3, db);
  PatternRowDetail dr3 = PatternRowDetail(
    rowId: r3.rowId,
    repeatXTime: 6,
    stitchId: _stitchesMap["(sc, inc)"]!.id,
  );
  dr3.rowDetailId = await insertPatternRowDetailInDb(dr3, db);

  PatternRow r4 = PatternRow(
    partId: head.partId,
    startRow: 4,
    numberOfRows: 2,
    stitchesPerRow: 18,
    preview: "18sc",
  );
  r4.rowId = await insertPatternRowInDb(r4, db);
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r4.rowId,
      repeatXTime: 18,
      stitchId: _stitchesMap["sc"]!.id,
    ),
    db,
  );

  PatternRow r6 = PatternRow(
    partId: head.partId,
    startRow: 6,
    numberOfRows: 1,
    stitchesPerRow: 9,
    preview: "9dec",
  );
  r6.rowId = await insertPatternRowInDb(r6, db);
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r6.rowId,
      repeatXTime: 9,
      stitchId: _stitchesMap["dec"]!.id,
    ),
    db,
  );

  return head;
}

Future<PatternPart> _createShortTentacles(int patternId, Database? db) async {
  PatternPart short = PatternPart(
    name: "short tentacles",
    patternId: patternId,
    numbersToMake: 4,
  );
  short.partId = await insertPatternPartInDb(short, db);

  PatternRow r1 = PatternRow(
    partId: short.partId,
    startRow: 1,
    numberOfRows: 1,
    stitchesPerRow: 8,
    preview: "8ch",
  );
  r1.rowId = await insertPatternRowInDb(r1, db);
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r1.rowId,
      repeatXTime: 8,
      stitchId: _stitchesMap["ch"]!.id,
    ),
    db,
  );
  return (short);
}

Future<PatternPart> _createLongTentacles(int patternId, Database? db) async {
  PatternPart long = PatternPart(
    name: "long tentacles",
    patternId: patternId,
    numbersToMake: 4,
  );
  long.partId = await insertPatternPartInDb(long, db);

  PatternRow r1 = PatternRow(
    partId: long.partId,
    startRow: 1,
    numberOfRows: 1,
    stitchesPerRow: 12,
    preview: "12ch",
  );
  r1.rowId = await insertPatternRowInDb(r1, db);
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r1.rowId,
      repeatXTime: 12,
      stitchId: _stitchesMap["ch"]!.id,
    ),
    db,
  );
  return (long);
}

Future<void> insertJellyFishPattern([Database? db]) async {
  // print("insert jelly");
  List<Stitch> l = await getAllStitchesInDb(db);
  // print(l);
  for (Stitch s in l) {
    _stitchesMap.addAll({s.abreviation: s});
  }
  // print(_stitchesMap);
  craft.Pattern pattern = craft.Pattern(name: "Jellyfish");
  pattern.patternId = await craft.insertPatternInDb(pattern, db);
  List<Yarn> y = await getAllYarn(db);
  if (y.isNotEmpty) {
    await craft.insertYarnInPattern(y.first.id, pattern.patternId, db);
  }
  pattern.parts.add(await _createHeadPart(pattern.patternId, db));
  pattern.parts.add(await _createShortTentacles(pattern.patternId, db));
  pattern.parts.add(await _createLongTentacles(pattern.patternId, db));
  print("jelly created");
}
