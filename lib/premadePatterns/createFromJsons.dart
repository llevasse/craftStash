import 'dart:async' show Future;
import 'dart:convert';
import 'dart:io';
import 'package:craft_stash/data/repository/pattern/pattern_detail_repository.dart';
import 'package:craft_stash/data/repository/pattern/pattern_part_repository.dart';
import 'package:craft_stash/data/repository/pattern/pattern_repository.dart';
import 'package:craft_stash/data/repository/pattern/pattern_row_repository.dart';
import 'package:craft_stash/data/repository/stitch_repository.dart';
import 'package:craft_stash/data/repository/yarn/collection_repository.dart';
import 'package:craft_stash/data/repository/yarn/yarn_repository.dart';
import 'package:craft_stash/main.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

import 'package:craft_stash/class/patterns/patterns.dart' as craft_pattern;
import 'package:craft_stash/class/patterns/pattern_part.dart' as craft_part;
import 'package:craft_stash/class/patterns/pattern_row.dart' as craft_row;
import 'package:craft_stash/class/patterns/pattern_row_detail.dart'
    as craft_details;

import 'package:craft_stash/class/yarns/yarn.dart' as craft_yarn;
import 'package:craft_stash/class/yarns/yarn_collection.dart'
    as craft_collection;

import 'package:craft_stash/class/stitch.dart' as craft_stitch;

Future<String> loadAsset(String fileName) async {
  return await rootBundle.loadString('assets/$fileName');
}

Map<int, int> _collectionIdToNewId = {};
Map<int, int> _yarnIdToNewId = {};
Map<int, int> _stitchIdToNewId = {};
// Map<int, int> _stitchIdToNewId = {};

Future<void> createPatternFromJsons({
  Database? db,
  required String path,
}) async {
  File file = File(path);
  dynamic obj = jsonDecode(file.readAsStringSync());

  Map<String, dynamic> collectionsObj = obj['yarn_collections'];
  Map<String, dynamic> yarnsObj = obj['yarns'];
  Map<String, dynamic> stitchesObj = obj['stitches'];
  Map<String, dynamic> stitchesSequenceObj = obj['stitches_sequence'];
  List<craft_yarn.Yarn> yarns = [];

  await Future.forEach(collectionsObj.entries, (entry) async {
    if (debug) {
      print("Create collection from ${entry.value}");
    }
    _collectionIdToNewId[int.parse(entry.key)] = (await yarnCollectionFromJson(
      db: db,
      obj: entry.value,
    )).id;
  });

  await Future.forEach(yarnsObj.entries, (entry) async {
    if (_collectionIdToNewId.containsKey(entry.value['collection_id'])) {
      entry.value['collection_id'] =
          _collectionIdToNewId[entry.value['collection_id']];
    }
    if (debug) {
      print("Create yarn from ${entry.value}");
    }
    // try {
    yarns.add(await yarnFromJson(obj: entry.value, db: db));
    _yarnIdToNewId[int.parse(entry.key)] = yarns.last.id;
    // } catch (e) {
    // print(e);
    // print(entry.value);
    // }
  });

  await Future.forEach(stitchesObj.entries, (entry) async {
    if (debug) {
      print("Create stitch from ${entry.value}");
    }
    _stitchIdToNewId[int.parse(entry.key)] = (await stitchFromJson(
      db: db,
      obj: entry.value,
    )).id;
  });

  await Future.forEach(stitchesSequenceObj.entries, (entry) async {
    if (debug) {
      print("Create stitch sequence from ${entry.value}");
    }
    _stitchIdToNewId[int.parse(entry.key)] = (await stitchSequenceFromJson(
      db: db,
      obj: entry.value,
    )).id;
  });

  print(_stitchIdToNewId);

  // print(obj.runtimeType);
  craft_pattern.Pattern pattern = await patternFromJson(obj: obj, db: db);

  Future.forEach(yarns, (yarn) async {
    await PatternRepository().insertYarnInPattern(
      yarnId: yarn.id,
      patternId: pattern.patternId,
      inPreviewId: yarn.inPreviewId!,
      db: db,
    );
  });

  _collectionIdToNewId.clear();
  _yarnIdToNewId.clear();
  _stitchIdToNewId.clear();
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
      await Future.forEach(obj['parts'], (Map<String, dynamic> partObj) async {
        try {
          partObj['pattern_id'] = pattern.patternId;
          pattern.parts.add(await partFromJson(obj: partObj, db: db));
        } catch (e) {
          rethrow;
        }
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
    print(obj);
    craft_part.PatternPart part = craft_part.PatternPart(
      name: obj['name'],
      patternId: obj['pattern_id'],
      numbersToMake: obj['numbers_to_make'],
      note: obj['note'],
      totalStitchNb: obj['total_stitch_nb'],
    );
    part.partId = await PatternPartRepository().insertPart(part, db);
    if (withRows == true && obj['rows'] != null) {
      await Future.forEach(obj['rows'], (Map<String, dynamic> rowObj) async {
        try {
          rowObj['pattern_id'] = part.patternId;
          rowObj['part_id'] = part.partId;
          part.rows.add(await rowFromJson(obj: rowObj, db: db));
        } catch (e) {
          throw "Error creating row : $e";
        }
      });
    }
    return part;
  } catch (e, stack) {
    print(stack);
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
    if (debug) {
      print("Insert row(${row.rowId}) : $obj");
    }
    if (withDetails == true && obj['details'] != null) {
      await Future.forEach(obj['details'], (
        Map<String, dynamic> detailObj,
      ) async {
        try {
          detailObj['pattern_id'] = obj['pattern_id'];
          detailObj['row_id'] = row.rowId;
          row.details.add(await detailFromJson(obj: detailObj, db: db));
        } catch (e) {
          rethrow;
        }
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
    if (_stitchIdToNewId[obj['stitch_id']] == null) {
      throw "Could not get stitch with id ${obj['stitch_id']}";
    }
    craft_details.PatternRowDetail detail = craft_details.PatternRowDetail(
      rowId: obj['row_id'],
      stitchId: _stitchIdToNewId[obj['stitch_id']]!,
      repeatXTime: obj['repeat_x_time'],
      patternId: obj['pattern_id'],
      note: obj['note'],
      inPatternYarnId: _yarnIdToNewId[obj['yarn_id']],
    );
    if (debug) {
      print("Insert detail : $obj");
    }
    detail.rowDetailId = await PatternDetailRepository().insertDetail(
      detail,
      db,
    );
    return detail;
  } catch (e, stack) {
    throw "Could not create detail ($e, $stack)";
  }
}

Future<craft_collection.YarnCollection> yarnCollectionFromJson({
  Database? db,
  required Map<String, dynamic> obj,
}) async {
  try {
    craft_collection.YarnCollection collection =
        craft_collection.YarnCollection(
          name: obj["name"],
          brand: obj["brand"],
          material: obj["material"],
          minHook: obj["min_hook"],
          maxHook: obj["max_hook"],
          thickness: obj["thickness"],
        );
    collection.id = await CollectionRepository().insertYarnCollection(
      collection,
      db,
    );
    return collection;
  } catch (e) {
    throw "Could not create yarn collection ($e)";
  }
}

Future<craft_yarn.Yarn> yarnFromJson({
  Database? db,
  required Map<String, dynamic> obj,
}) async {
  try {
  craft_yarn.Yarn yarn = craft_yarn.Yarn(
    color: obj['color'],
    brand: obj["brand"],
    material: obj["material"],
    colorName: obj["color_name"],
    minHook: obj["min_hook"],
    maxHook: obj["max_hook"],
    thickness: obj["thickness"],
    inPreviewId: obj["in_preview_id"],
    collectionId: _collectionIdToNewId[obj["collection_id"]],
  );
  yarn.id = await YarnRepository().insertYarn(yarn, db, false);
  return yarn;
  } catch (e) {
    throw "Could not create yarn ($e)";
  }
}

Future<craft_stitch.Stitch> stitchFromJson({
  Database? db,
  required Map<String, dynamic> obj,
}) async {
  try {
    craft_stitch.Stitch stitch = craft_stitch.Stitch(
      abreviation: obj["abreviation"],
      name: obj["name"],
      description: obj["description"],
      isSequence: obj["is_sequence"],
      sequenceId: obj["sequence_id"],
      hidden: obj["hidden"],
      stitchNb: obj["stitch_nb"],
      nbStsTaken: obj["nb_of_stitches_taken"],
    );
    stitch.id = await StitchRepository().insertStitch(stitch, db);
    return stitch;
  } catch (e) {
    throw "Could not create stitch ($e)";
  }
}

Future<craft_stitch.Stitch> stitchSequenceFromJson({
  Database? db,
  required Map<String, dynamic> obj,
}) async {
  try {
    Map<String, dynamic> sequenceObj = obj['sequence'];
    craft_row.PatternRow sequence = craft_row.PatternRow(
      startRow: 0,
      numberOfRows: 0,
      stitchesPerRow: sequenceObj['stitches_count_per_row'],
      inSameStitch: sequenceObj['in_same_stitch'],
      note: sequenceObj['note'],
    );

    sequence.rowId = await PatternRowRepository().insertRow(
      patternRow: sequence,
      db: db,
    );

    for (Map<String, dynamic> detailObj in sequenceObj['details']) {
      try {
        final stitchId = detailObj['stitch_id'];
        if (stitchId == null || _stitchIdToNewId[stitchId] == null) {
          throw ("Could not look up stitch : $detailObj");
        }
        craft_details.PatternRowDetail detail = craft_details.PatternRowDetail(
          rowId: sequence.rowId,
          stitchId: _stitchIdToNewId[stitchId]!,
          repeatXTime: detailObj['repeat_x_time'],
          note: detailObj['note'],
        );
        detail.rowDetailId = await PatternDetailRepository().insertDetail(
          detail,
          db,
        );
      } catch (e) {
        print(e);
      }
    }

    craft_stitch.Stitch stitch = craft_stitch.Stitch(
      abreviation: obj["abreviation"],
      name: obj["name"],
      description: obj["description"],
      isSequence: 1,
      sequenceId: sequence.rowId,
      hidden: obj["hidden"],
      stitchNb: obj["stitch_nb"],
      nbStsTaken: obj["nb_of_stitches_taken"],
    );
    stitch.id = await StitchRepository().insertStitch(stitch, db);
    return stitch;
  } catch (e) {
    throw "Could not create yarn ($e)";
  }
}
