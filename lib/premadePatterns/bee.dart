import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/data/repository/pattern/pattern_detail_repository.dart';
import 'package:craft_stash/data/repository/pattern/pattern_part_repository.dart';
import 'package:craft_stash/data/repository/pattern/pattern_repository.dart';
import 'package:craft_stash/data/repository/pattern/pattern_row_repository.dart';
import 'package:craft_stash/data/repository/stitch_repository.dart';
import 'package:craft_stash/data/repository/yarn/yarn_repository.dart';
import 'package:sqflite/sqflite.dart';

Map<String, Stitch> _stitchesMap = {};
List<Yarn> _yarns = List.empty(growable: true);

Future<PatternPart> _createBody(int patternId, Database? db) async {
  PatternPart head = PatternPart(name: "Body", patternId: patternId);
  head.totalStitchNb = 108;
  head.partId = await PatternPartRepository().insertPart(head, db);

  PatternRow r1 = PatternRow(
    partId: head.partId,
    startRow: 1,
    numberOfRows: 1,
    stitchesPerRow: 6,
    preview: "start with \${${_yarns.first.inPreviewId}}, 6sc",
  );
  r1.rowId = await PatternRowRepository().insertRow(patternRow: r1, db: db);
  await PatternDetailRepository().insertDetail(
    PatternRowDetail(
      rowId: r1.rowId,
      repeatXTime: 1,
      stitchId: _stitchesMap["start color"]!.id,
      inPatternYarnId: _yarns.first.inPreviewId,
      patternId: patternId,
    ),
    db,
  );
  await PatternDetailRepository().insertDetail(
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
  r2.rowId = await PatternRowRepository().insertRow(patternRow: r2, db: db);
  await PatternDetailRepository().insertDetail(
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
  r3.rowId = await PatternRowRepository().insertRow(patternRow: r3, db: db);
  PatternRowDetail dr3 = PatternRowDetail(
    rowId: r3.rowId,
    repeatXTime: 6,
    stitchId: _stitchesMap["(sc, inc)"]!.id,
    patternId: patternId,
  );
  dr3.rowDetailId = await PatternDetailRepository().insertDetail(dr3, db);

  PatternRow r4 = PatternRow(
    partId: head.partId,
    startRow: 4,
    numberOfRows: 1,
    stitchesPerRow: 18,
    preview: "18sc, change color to \${${_yarns.last.inPreviewId}}",
  );
  r4.rowId = await PatternRowRepository().insertRow(patternRow: r4, db: db);
  await PatternDetailRepository().insertDetail(
    PatternRowDetail(
      rowId: r4.rowId,
      repeatXTime: 18,
      stitchId: _stitchesMap["sc"]!.id,
      patternId: patternId,
    ),
    db,
  );
  await PatternDetailRepository().insertDetail(
    PatternRowDetail(
      rowId: r4.rowId,
      repeatXTime: 1,
      stitchId: _stitchesMap["color change"]!.id,
      inPatternYarnId: _yarns.last.inPreviewId,
      patternId: patternId,
    ),
    db,
  );

  PatternRow r5 = PatternRow(
    partId: head.partId,
    startRow: 5,
    numberOfRows: 1,
    stitchesPerRow: 18,
    preview: "18sc, change color to \${${_yarns.first.inPreviewId}}",
  );
  r5.rowId = await PatternRowRepository().insertRow(patternRow: r5, db: db);
  await PatternDetailRepository().insertDetail(
    PatternRowDetail(
      rowId: r5.rowId,
      repeatXTime: 18,
      stitchId: _stitchesMap["sc"]!.id,
      patternId: patternId,
    ),
    db,
  );
  await PatternDetailRepository().insertDetail(
    PatternRowDetail(
      rowId: r5.rowId,
      repeatXTime: 1,
      stitchId: _stitchesMap["color change"]!.id,
      inPatternYarnId: _yarns.first.inPreviewId,
      patternId: patternId,
    ),
    db,
  );

  PatternRow r6 = PatternRow(
    partId: head.partId,
    startRow: 6,
    numberOfRows: 1,
    stitchesPerRow: 18,
    preview: "18sc, change color to \${${_yarns.last.inPreviewId}}",
  );
  r6.rowId = await PatternRowRepository().insertRow(patternRow: r6, db: db);
  await PatternDetailRepository().insertDetail(
    PatternRowDetail(
      rowId: r6.rowId,
      repeatXTime: 18,
      stitchId: _stitchesMap["sc"]!.id,
    ),
    db,
  );
  await PatternDetailRepository().insertDetail(
    PatternRowDetail(
      rowId: r6.rowId,
      repeatXTime: 1,
      stitchId: _stitchesMap["color change"]!.id,
      inPatternYarnId: _yarns.last.inPreviewId,
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
  r7.rowId = await PatternRowRepository().insertRow(patternRow: r7, db: db);
  PatternRowDetail dr7 = PatternRowDetail(
    rowId: r7.rowId,
    repeatXTime: 6,
    stitchId: _stitchesMap["(sc, dec)"]!.id,
    patternId: patternId,
  );
  dr7.rowDetailId = await PatternDetailRepository().insertDetail(dr7, db);

  PatternRow r8 = PatternRow(
    partId: head.partId,
    startRow: 8,
    numberOfRows: 1,
    stitchesPerRow: 6,
    preview: "6dec",
  );
  r8.rowId = await PatternRowRepository().insertRow(patternRow: r8, db: db);
  await PatternDetailRepository().insertDetail(
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
  List<Stitch> l = await StitchRepository().getAllStitches(db);
  // print(l);
  for (Stitch s in l) {
    _stitchesMap.addAll({s.abreviation: s});
  }
  // print(_stitchesMap);
  craft.Pattern pattern = craft.Pattern(name: "Bee");
  pattern.totalStitchNb = 108;
  pattern.patternId = await PatternRepository().insertPattern(
    pattern: pattern,
    db: db,
  );
  _yarns = await YarnRepository().getAllYarn(db);
  if (_yarns.isNotEmpty) {
    await PatternRepository().insertYarnInPattern(
      yarnId: _yarns.first.id,
      patternId: pattern.patternId,
      inPreviewId: 1,
      db: db,
    );
    _yarns.first.inPreviewId = 1;
    await PatternRepository().insertYarnInPattern(
      yarnId: _yarns.last.id,
      patternId: pattern.patternId,
      inPreviewId: 2,
      db: db,
    );
    _yarns.last.inPreviewId = 2;
  }
  pattern.parts.add(await _createBody(pattern.patternId, db));
  print("Bee created");
}
