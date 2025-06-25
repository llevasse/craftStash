import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

final String _tableName = "pattern_row_detail";

class PatternRowDetail {
  int rowId;
  int rowDetailId;
  String stitch;
  int repeatXTime;
  int color;
  int hasSubrow;
  PatternRow? subRow;
  PatternRowDetail({
    required this.rowId,
    this.rowDetailId = 0,
    this.repeatXTime = 1,
    this.stitch = "empty",
    this.color = 0xFFFFC107,
    this.hasSubrow = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'row_detail_id': rowDetailId,
      'row_id': rowId,
      'stitch': stitch,
      'color': color,
      'has_subrow': hasSubrow,
    };
  }

  @override
  String toString() {
    if (hasSubrow == 0) {
      return "${repeatXTime == 1 ? "" : repeatXTime.toString()}$stitch";
    }
    return "${subRow.toString()} ${repeatXTime == 1 ? "" : "x${repeatXTime.toString()}"}";
  }

  @override
  int get hashCode => Object.hash(rowDetailId, rowId, stitch, color, hasSubrow);
}

Future<void> insertPatternRowDetailInDb(
  PatternRowDetail patternRowDetail,
) async {
  final db = (await DbService().database);
  if (db != null) {
    db.insert(
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
      whereArgs: [patternRowDetail.rowId],
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

Future<List<PatternRowDetail>> getAllPatternRowDetail() async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternRowDetailMaps = await db.query(
      _tableName,
    );
    return [
      for (final {
            'row_detail_id': rowDetailId as int,
            'row_id': rowId as int,
            'stitch': stitch as String,
            'color': color as int,
            'has_subrow': hasSubrow as int,
          }
          in patternRowDetailMaps)
        PatternRowDetail(
          rowDetailId: rowDetailId,
          rowId: rowId,
          stitch: stitch,
          color: color,
          hasSubrow: hasSubrow,
        ),
    ];
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<PatternRowDetail>> getAllPatternRowDetailByRowId(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternRowDetailMaps = await db.query(
      _tableName,
      where: "row_id = ?",
      whereArgs: [id],
    );
    return [
      for (final {
            'row_detail_id': rowDetailId as int,
            'row_id': rowId as int,
            'stitch': stitch as String,
            'color': color as int,
            'has_subrow': hasSubrow as int,
          }
          in patternRowDetailMaps)
        PatternRowDetail(
          rowDetailId: rowDetailId,
          rowId: rowId,
          stitch: stitch,
          color: color,
          hasSubrow: hasSubrow,
        ),
    ];
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
