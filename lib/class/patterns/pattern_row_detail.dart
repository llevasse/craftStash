import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

final String _tableName = "pattern_row_detail";

class PatternRowDetail {
  int rowId;
  int rowDetailId;
  int stitchId;
  Stitch? stitch;
  int repeatXTime;
  int color;
  PatternRowDetail({
    required this.rowId,
    required this.stitchId,
    this.rowDetailId = 0,
    this.repeatXTime = 1,
    this.color = 0xFFFFC107,
  });

  Map<String, dynamic> toMap() {
    return {
      'row_id': rowId,
      'stitch_id': stitchId,
      'repeat_x_time': repeatXTime,
      'color': color,
    };
  }

  @override
  String toString() {
    if (stitch != null && repeatXTime < 1) {
      if (repeatXTime == 1) return (stitch.toString());
      if (stitch!.isSequence == 1) {
        return ("${stitch.toString()}x${repeatXTime.toString()}");
      }
      return ("${repeatXTime.toString()}${stitch.toString()}");
    }

    return "";
  }

  // String toString() {
  //   if (hasSubrow == 0) {
  //     return stitch;
  //   }
  //   return subRow.toString();
  // }

  @override
  int get hashCode => Object.hash(rowId, stitch.hashCode, color);
}

PatternRowDetail _fromMap(Map<String, dynamic> map) {
  return PatternRowDetail(
    rowId: map['row_id'] as int,
    stitchId: map['stitch_id'] as int,
    repeatXTime: map['repeat_x_time'] as int,
    color: map['color'] as int,
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
    return [
      for (Map<String, Object?> map in patternRowDetailMaps) _fromMap(map),
    ];
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
