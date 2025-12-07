import 'dart:async' show Future;
import 'dart:convert';
import 'package:craft_stash/data/repository/pattern/pattern_detail_repository.dart';
import 'package:craft_stash/data/repository/pattern/pattern_part_repository.dart';
import 'package:craft_stash/data/repository/pattern/pattern_repository.dart';
import 'package:craft_stash/data/repository/pattern/pattern_row_repository.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

import 'package:craft_stash/class/patterns/patterns.dart' as craft_pattern;
import 'package:craft_stash/class/patterns/pattern_part.dart' as craft_part;
import 'package:craft_stash/class/patterns/pattern_row.dart' as craft_row;
import 'package:craft_stash/class/patterns/pattern_row_detail.dart'
    as craft_details;

Future<String> loadAsset(String fileName) async {
  return await rootBundle.loadString('assets/$fileName');
}

Future<void> createFromJsons([Database? db]) async {
  dynamic obj = jsonDecode(await loadAsset("bee.json"));
  // print(obj.runtimeType);
  craft_pattern.Pattern pattern = await patternFromJson(obj: obj, db: db);
  print(pattern.toJson());
}

Future<craft_pattern.Pattern> patternFromJson({
  Database? db,
  required Map<String, dynamic> obj,
  bool withParts = true,
}) async {
  try {
    craft_pattern.Pattern pattern = craft_pattern.Pattern(
      name: obj['name'],
      note: obj['note'],
      hookSize: obj['hook_size'],
      totalStitchNb: obj['total_stitch_nb'],
    );
    pattern.patternId = await PatternRepository().insertPattern(
      pattern: pattern,
      db: db,
    );
    if (withParts == true && obj['parts'] != null) {
      obj['parts'].forEach((partObj) async {
        partObj['pattern_id'] = pattern.patternId;
        pattern.parts.add(await partFromJson(obj: partObj, db: db));
        // print("Add ${pattern.parts.last.toMap()}"),
      });
    }
    return pattern;
  } catch (e) {
    throw "Could not create pattern ($e)";
  }
}

Future<craft_part.PatternPart> partFromJson({
  Database? db,
  required Map<String, dynamic> obj,
  bool withRows = true,
}) async {
  try {
    craft_part.PatternPart part = craft_part.PatternPart(
      name: obj['name'],
      patternId: obj['pattern_id'],
      numbersToMake: obj['numbers_to_make'],
      note: obj['note'],
      totalStitchNb: obj['total_stitch_nb'],
    );
    part.partId = await PatternPartRepository().insertPart(part, db);
    if (withRows == true && obj['rows'] != null) {
      obj['rows'].forEach((rowObj) async {
        rowObj['part_id'] = part.partId;
        part.rows.add(await rowFromJson(obj: rowObj, db: db));
      });
    }
    return part;
  } catch (e) {
    throw "Could not create part ($e)";
  }
}

Future<craft_row.PatternRow> rowFromJson({
  Database? db,
  required Map<String, dynamic> obj,
  bool withDetails = true,
}) async {
  try {
    craft_row.PatternRow row = craft_row.PatternRow(
      partId: obj['part_id'],
      startRow: obj['start_row'],
      numberOfRows: obj['number_of_rows'],
      stitchesPerRow: obj['stitches_count_per_row'],
      inSameStitch: obj['in_same_stitch'],
      note: obj['note'],
      preview: obj['preview'],
    );
    row.rowId = await PatternRowRepository().insertRow(patternRow: row, db: db);
    if (withDetails == true && obj['details'] != null) {
      obj['details'].forEach((detailObj) async {
        detailObj['row_id'] = row.rowId;
        row.details.add(await detailFromJson(obj: detailObj, db: db));
        // print(detailObj);
      });
    }
    return row;
  } catch (e) {
    throw "Could not create row ($e)";
  }
}

Future<craft_details.PatternRowDetail> detailFromJson({
  Database? db,
  required Map<String, dynamic> obj,
  bool withDetails = true,
}) async {
  try {
    craft_details.PatternRowDetail detail = craft_details.PatternRowDetail(
      rowId: obj['row_id'],
      stitchId: obj['stitch_id'],
      repeatXTime: obj['repeat_x_time'],
      patternId: obj['pattern_id'],
      note: obj['note'],
    );
    detail.rowDetailId = await PatternDetailRepository().insertDetail(
      detail,
      db,
    );
    return detail;
  } catch (e) {
    throw "Could not create detail ($e)";
  }
}
