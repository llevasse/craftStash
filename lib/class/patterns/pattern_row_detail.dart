import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

final String _tableName = "pattern_row_detail";

class PatternRowDetail {
  int rowId;
  int rowDetailId;
  int stitchId;
  Stitch? stitch;
  int repeatXTime;
  int? yarnId;
  String? yarnColorName;
  PatternRowDetail({
    required this.rowId,
    required this.stitchId,
    this.stitch,
    this.rowDetailId = 0,
    this.repeatXTime = 1,
    this.yarnId,
  });

  Map<String, dynamic> toMap() {
    return {
      'row_id': rowId,
      'stitch_id': stitchId,
      'repeat_x_time': repeatXTime,
      'yarn_id': yarnId,
    };
  }

  @override
  String toString() {
    if (stitchId == 0 && yarnId != null) {
      return ("change to $yarnColorName");
    }
    if (stitch != null && repeatXTime >= 1) {
      if (repeatXTime == 1) return (stitch.toString());
      if (stitch!.isSequence == 1) {
        return ("${stitch.toString()}x${repeatXTime.toString()}");
      }
      return ("${repeatXTime.toString()}${stitch.toString()}");
    }
    return "";
  }

  void printDetail([int tab = 0]) {
    String s = "";
    for (int i = 0; i < tab; i++) {
      s += "\t";
    }
    print("${s}rowId : ${rowId.toString()}");
    print("${s}rowDetailId : ${rowDetailId.toString()}");
    print("${s}stitchId : ${stitchId.toString()}");
    stitch?.printDetails(tab + 1);
    print("${s}repeat : ${repeatXTime.toString()}");
    print("${s}yarn_id : ${yarnId.toString()}");
    print("\r\n");
  }

  @override
  int get hashCode => Object.hash(rowId, stitch.hashCode, yarnId);
}

PatternRowDetail _fromMap(Map<String, dynamic> map) {
  return PatternRowDetail(
    rowDetailId: map['row_detail_id'] as int,
    rowId: map['row_id'] as int,
    stitchId: map['stitch_id'] as int,
    repeatXTime: map['repeat_x_time'] as int,
    yarnId: map['yarn_id'] as int?,
  );
}

Future<int> insertPatternRowDetailInDb(
  PatternRowDetail patternRowDetail, [
  Database? db,
]) async {
  db ??= (await DbService().database);
  if (db != null) {
    return await db.insert(
      _tableName,
      patternRowDetail.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> updatePatternRowDetailInDb(
  PatternRowDetail patternRowDetail,
) async {
  final db = (await DbService().database);
  if (db != null) {
    await db.update(
      _tableName,
      patternRowDetail.toMap(),
      where: "row_detail_id = ?",
      whereArgs: [patternRowDetail.rowDetailId],
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> deletePatternRowDetailInDb(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    await db.delete(_tableName, where: "row_detail_id = ?", whereArgs: [id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> deletePatternRowDetailInDbByRowId(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    await db.delete(_tableName, where: "row_id = ?", whereArgs: [id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<PatternRowDetail>> getAllPatternRowDetail() async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternRowDetailMaps = await db.query(
      _tableName,
    );
    List<PatternRowDetail> l = List.empty(growable: true);
    for (Map<String, Object?> map in patternRowDetailMaps) {
      PatternRowDetail t = _fromMap(map);
      if (t.yarnId != null) {
        t.yarnColorName = (await getYarnById(t.yarnId!)).colorName;
      }
    }
    return l;
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<PatternRowDetail>> getAllPatternRowDetailByRowId(
  int id, [
  Database? db,
]) async {
  db ??= (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternRowDetailMaps = await db.query(
      _tableName,
      where: "row_id = ?",
      whereArgs: [id],
    );
    List<PatternRowDetail> l = [
      for (Map<String, Object?> map in patternRowDetailMaps) _fromMap(map),
    ];
    for (PatternRowDetail detail in l) {
      detail.stitch = await getStitchInDbById(detail.stitchId, db);
      if (detail.yarnId != null) {
        detail.yarnColorName = (await getYarnById(detail.yarnId!)).colorName;
      }
    }
    return l;
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<PatternRowDetail>> getAllPatternRowDetailByStitch(
  Stitch stitch, [
  Database? db,
]) async {
  db ??= (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternRowDetailMaps = await db.query(
      _tableName,
      where: "stitch_id = ?",
      whereArgs: [stitch.id],
    );
    List<PatternRowDetail> l = [
      for (Map<String, Object?> map in patternRowDetailMaps) _fromMap(map),
    ];
    for (PatternRowDetail detail in l) {
      detail.stitch = stitch;
    }
    return l;
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> removeAllPatternRowDetail() async {
  final db = (await DbService().database);
  if (db != null) {
    db.rawDelete('DELETE FROM $_tableName');
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}
