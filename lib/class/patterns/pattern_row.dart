import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

final String _tableName = "pattern_row";

class PatternRow {
  int rowId;
  int? partId;
  int inSameStitch;
  int startRow, numberOfRows;
  int stitchesPerRow;
  List<PatternRowDetail> details = List.empty(growable: true);
  PatternRow({
    this.rowId = 0,
    this.inSameStitch = 0, // non zero if is a subrow in done in the same stitch
    this.partId,
    required this.startRow,
    required this.numberOfRows,
    required this.stitchesPerRow,
  });

  Map<String, dynamic> toMap() {
    return {
      'part_id': partId,
      'start_row': startRow,
      'number_of_rows': numberOfRows,
      'in_same_stitch': inSameStitch,
      'stitches_count_per_row': stitchesPerRow,
      // 'hash': hashCode,
    };
  }

  String getSpecAsString() {
    return "rowId : $rowId | partId : $partId | startRow : $startRow | numberOfRows : $numberOfRows";
  }

  @override
  String toString() {
    String tmp = inSameStitch == 0 ? "(" : "[";
    for (PatternRowDetail detail in details) {
      if (detail.repeatXTime > 0) tmp += "${detail.toString()}, ";
    }
    if (details.isNotEmpty) {
      tmp = tmp.substring(0, tmp.length - 2);
    }
    tmp += inSameStitch == 0 ? ")" : "]";
    return tmp;
  }

  @override
  int get hashCode => Object.hash(
    partId,
    startRow,
    numberOfRows,
    inSameStitch,
    stitchesPerRow,
    toString(),
  );

  String detailsAsString() {
    String tmp = "";
    if (details.isNotEmpty) {
      int lastId = details.last.rowDetailId;
      for (PatternRowDetail detail in details) {
        // detail.printDetail();
        // print("\n\r");
        if (detail.rowDetailId != lastId) {
          tmp += "${detail.toString()}, ";
        } else {
          tmp += detail.toString();
        }
      }
    }
    return tmp;
  }
}

PatternRow _fromMap(Map<String, Object?> map) {
  return PatternRow(
    rowId: map['row_id'] as int,
    partId: map['part_id'] as int?,
    startRow: map['start_row'] as int,
    numberOfRows: map['number_of_rows'] as int,
    inSameStitch: map['in_same_stitch'] as int,
    stitchesPerRow: map['stitches_count_per_row'] as int,
  );
}

Future<int> insertPatternRowInDb(PatternRow patternRow, [Database? db]) async {
  db ??= (await DbService().database);
  if (db != null) {
    return db.insert(
      _tableName,
      patternRow.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> updatePatternRowInDb(PatternRow patternRow) async {
  final db = (await DbService().database);
  if (db != null) {
    await db.update(
      _tableName,
      patternRow.toMap(),
      where: "row_id = ?",
      whereArgs: [patternRow.rowId],
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> deletePatternRowInDb(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    // await deletePatternRowDetailInDbByRowId(id);
    await db.delete(_tableName, where: "row_id = ?", whereArgs: [id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> deletePatternRowInDbByPartId(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    await db.delete(_tableName, where: "part_id = ?", whereArgs: [id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<PatternRow>> getAllPatternRow() async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternRowMaps = await db.query(
      _tableName,
    );
    return [for (Map<String, Object?> map in patternRowMaps) _fromMap(map)];
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<PatternRow>> getAllPatternRowByPartId(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternRowMaps = await db.query(
      _tableName,
      where: "part_id = ?",
      whereArgs: [id],
      orderBy: "start_row ASC",
    );
    List<PatternRow> l = List.empty(growable: true);
    for (Map<String, Object?> map in patternRowMaps) {
      PatternRow tmp = _fromMap(map);
      tmp.details = await getAllPatternRowDetailByRowId(tmp.rowId, db);
      l.add(tmp);
    }
    return (l);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<PatternRow> getPatternRowByDetailId(int id, [Database? db]) async {
  db ??= (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternRowMaps = await db.query(
      _tableName,
      where: "part_detail_id = ?",
      whereArgs: [id],
      orderBy: "start_row ASC",
      limit: 1,
    );
    List<PatternRow> l = List.empty(growable: true);
    for (Map<String, Object?> map in patternRowMaps) {
      PatternRow tmp = _fromMap(map);
      tmp.details = await getAllPatternRowDetailByRowId(tmp.rowId, db);
      l.add(tmp);
    }
    return (l[0]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<PatternRow> getPatternRowByRowId(int id, [Database? db]) async {
  db ??= (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternRowMaps = await db.query(
      _tableName,
      where: "row_id = ?",
      whereArgs: [id],
      limit: 1,
    );
    List<PatternRow> l = List.empty(growable: true);
    for (Map<String, Object?> map in patternRowMaps) {
      PatternRow tmp = _fromMap(map);
      tmp.details = await getAllPatternRowDetailByRowId(tmp.rowId, db);
      l.add(tmp);
    }
    return (l[0]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> removeAllPatternRow() async {
  final db = (await DbService().database);
  if (db != null) {
    db.rawDelete('DELETE FROM $_tableName');
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}
