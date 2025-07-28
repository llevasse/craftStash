import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:sqflite/sqflite.dart';

Map<String, Stitch> _stitchesMap = {};
List<Yarn> _yarns = List.empty(growable: true);

Future<PatternPart> _createBody(int patternId, Database? db) async {
  PatternPart head = PatternPart(name: "Body", patternId: patternId);
  head.totalStitchNb = 108;
  head.partId = await insertPatternPartInDb(head, db);

  PatternRow r1 = PatternRow(
    partId: head.partId,
    startRow: 1,
    numberOfRows: 1,
    stitchesPerRow: 6,
    preview: "start with \${${_yarns.first.inPatternId}}, 6sc",
  );
  r1.rowId = await insertPatternRowInDb(r1, db);
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r1.rowId,
      repeatXTime: 1,
      stitchId: _stitchesMap["start color"]!.id,
      inPatternYarnId: _yarns.first.inPatternId,
      patternId: patternId,
    ),
    db,
  );
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r1.rowId,
      repeatXTime: 6,
      stitchId: _stitchesMap["sc"]!.id,
      patternId: patternId,
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
      patternId: patternId,
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
      patternId: patternId,
  );
  dr3.rowDetailId = await insertPatternRowDetailInDb(dr3, db);

  PatternRow r4 = PatternRow(
    partId: head.partId,
    startRow: 4,
    numberOfRows: 1,
    stitchesPerRow: 18,
    preview: "18sc, change color to \${${_yarns.last.inPatternId}}",
  );
  r4.rowId = await insertPatternRowInDb(r4, db);
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r4.rowId,
      repeatXTime: 18,
      stitchId: _stitchesMap["sc"]!.id,
      patternId: patternId,
    ),
    db,
  );
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r4.rowId,
      repeatXTime: 1,
      stitchId: _stitchesMap["color change"]!.id,
      inPatternYarnId: _yarns.last.inPatternId,
      patternId: patternId,
    ),
    db,
  );

  PatternRow r5 = PatternRow(
    partId: head.partId,
    startRow: 5,
    numberOfRows: 1,
    stitchesPerRow: 18,
    preview: "18sc, change color to \${${_yarns.first.inPatternId}}",
  );
  r5.rowId = await insertPatternRowInDb(r5, db);
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r5.rowId,
      repeatXTime: 18,
      stitchId: _stitchesMap["sc"]!.id,
      patternId: patternId,
    ),
    db,
  );
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r5.rowId,
      repeatXTime: 1,
      stitchId: _stitchesMap["color change"]!.id,
      inPatternYarnId: _yarns.first.inPatternId,
      patternId: patternId,
    ),
    db,
  );

  PatternRow r6 = PatternRow(
    partId: head.partId,
    startRow: 6,
    numberOfRows: 1,
    stitchesPerRow: 18,
    preview: "18sc, change color to \${${_yarns.last.inPatternId}}",
  );
  r6.rowId = await insertPatternRowInDb(r6, db);
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r6.rowId,
      repeatXTime: 18,
      stitchId: _stitchesMap["sc"]!.id,
    ),
    db,
  );
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r6.rowId,
      repeatXTime: 1,
      stitchId: _stitchesMap["color change"]!.id,
      inPatternYarnId: _yarns.last.inPatternId,
      patternId: patternId,
    ),
    db,
  );

  PatternRow r7 = PatternRow(
    partId: head.partId,
    startRow: 7,
    numberOfRows: 1,
    stitchesPerRow: 12,
    preview: "(sc, dec)x6",
  );
  r7.rowId = await insertPatternRowInDb(r7, db);
  PatternRowDetail dr7 = PatternRowDetail(
    rowId: r7.rowId,
    repeatXTime: 6,
    stitchId: _stitchesMap["(sc, dec)"]!.id,
      patternId: patternId,
  );
  dr7.rowDetailId = await insertPatternRowDetailInDb(dr7, db);

  PatternRow r8 = PatternRow(
    partId: head.partId,
    startRow: 8,
    numberOfRows: 1,
    stitchesPerRow: 6,
    preview: "6dec",
  );
  r8.rowId = await insertPatternRowInDb(r8, db);
  await insertPatternRowDetailInDb(
    PatternRowDetail(
      rowId: r8.rowId,
      repeatXTime: 6,
      stitchId: _stitchesMap["dec"]!.id,
    ),
    db,
  );

  return head;
}

Future<void> insertBeePattern([Database? db]) async {
  // print("insert jelly");
  List<Stitch> l = await getAllStitchesInDb(db);
  // print(l);
  for (Stitch s in l) {
    _stitchesMap.addAll({s.abreviation: s});
  }
  // print(_stitchesMap);
  craft.Pattern pattern = craft.Pattern(name: "Bee");
  pattern.totalStitchNb = 108;
  pattern.patternId = await craft.insertPatternInDb(pattern, db);
  _yarns = await getAllYarn(db);
  if (_yarns.isNotEmpty) {
    await craft.insertYarnInPattern(
      yarnId: _yarns.first.id,
      patternId: pattern.patternId,
      inPatternId: 1,
      db: db,
    );
    _yarns.first.inPatternId = 1;
    await craft.insertYarnInPattern(
      yarnId: _yarns.last.id,
      patternId: pattern.patternId,
      inPatternId: 2,
      db: db,
    );
    _yarns.last.inPatternId = 2;
  }
  pattern.parts.add(await _createBody(pattern.patternId, db));
  print("Bee created");
}
