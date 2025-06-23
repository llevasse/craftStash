import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

final String _tableName = "pattern_row";

class PatternRow {
  int rowId;
  int partId;
  int partDetailId;
  int startRow, endRow;
  int stitchesPerRow;
  List<PatternRowDetail> details = List.empty(growable: true);
  PatternRow({
    this.rowId = 0,
    this.partDetailId =
        -1, // non negative if is a 'subrow' (i.e repetetive instruction with different stitches)
    this.partId = -1,
    required this.startRow,
    required this.endRow,
    required this.stitchesPerRow,
  });

  Map<String, dynamic> toMap() {
    return {
      'row_id': rowId,
      'part_detail_id': partDetailId,
      'part_id': partId,
      'start_row': startRow,
      'end_row': endRow,
      'stitches_count_per_row': stitchesPerRow,
      'hash': hashCode,
    };
  }

  @override
  String toString() {
    if (partDetailId == -1) {
      String tmp = "$startRow-$endRow :\n";
      for (PatternRowDetail detail in details) {
        tmp += "\t\t${detail.toString()}";
      }

      return tmp;
    } else {
      String tmp = "(";
      for (PatternRowDetail detail in details) {
        tmp += "${detail.toString()}, ";
      }
      tmp += ")";
      return tmp;
    }
  }

  @override
  int get hashCode => Object.hash(
    rowId,
    partDetailId,
    partId,
    startRow,
    endRow,
    stitchesPerRow,
  );
}

Future<void> insertPatternRowInDb(PatternRow patternRow) async {
  final db = (await DbService().database);
  if (db != null) {
    final list = await db.query(
      _tableName,
      where: "hash = ?",
      whereArgs: [patternRow.hashCode],
    );
    if (list.isEmpty) {
      db.insert(
        _tableName,
        patternRow.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
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
    await db.delete(_tableName, where: "row_id = ?", whereArgs: [id]);
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
    return [
      for (final {
            'row_id': rowId as int,
            'part_detail_id': partDetailId as int,
            'part_id': partId as int,
            'start_row': startRow as int,
            'end_row': endRow as int,
            'stitches_count_per_row': stitchesPerRow as int,
          }
          in patternRowMaps)
        PatternRow(
          rowId: rowId,
          partDetailId: partDetailId,
          partId: partId,
          startRow: startRow,
          endRow: endRow,
          stitchesPerRow: stitchesPerRow,
        ),
    ];
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
