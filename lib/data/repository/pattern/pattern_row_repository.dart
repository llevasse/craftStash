import 'package:craft_stash/class/patterns/pattern_row.dart' as pattern_row;
import 'package:craft_stash/data/repository/pattern/pattern_detail_repository.dart';
import 'package:craft_stash/main.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class PatternRowRepository {
  static const String _tableName = "pattern_row";

  const PatternRowRepository();

  pattern_row.PatternRow _fromMap(Map<String, Object?> map) {
    return pattern_row.PatternRow(
      rowId: map['row_id'] as int,
      partId: map['part_id'] as int?,
      startRow: map['start_row'] as int,
      numberOfRows: map['number_of_rows'] as int,
      inSameStitch: map['in_same_stitch'] as int,
      stitchesPerRow: map['stitches_count_per_row'] as int,
      preview: map['preview'] as String?,
      note: map['note'] as String?,
    );
  }

  Future<int> insertRow({
    required pattern_row.PatternRow patternRow,
    Database? db,
  }) async {
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

  Future<void> updateRow(pattern_row.PatternRow patternRow) async {
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

  Future<void> deleteRow(int id) async {
    final db = (await DbService().database);
    if (db != null) {
      // await deletePatternRowDetailByRowId(id);
      await db.delete(_tableName, where: "row_id = ?", whereArgs: [id]);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> deleteRowByPartId(int id) async {
    final db = (await DbService().database);
    if (db != null) {
      await db.delete(_tableName, where: "part_id = ?", whereArgs: [id]);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<List<pattern_row.PatternRow>> getAllRows([
    int? partId,
    bool withDetails = false,
    Database? db,
  ]) async {
    db ??= (await DbService().database);
    if (db != null) {
      String? where;
      List<Object?>? whereArgs;
      if (partId != null) {
        where = "part_id = ?";
        whereArgs = [partId];
      }
      final List<Map<String, Object?>> patternRowMaps = await db.query(
        _tableName,
        where: where,
        whereArgs: whereArgs,
        orderBy: "start_row ASC",
      );
      List<pattern_row.PatternRow> l = [
        for (final map in patternRowMaps) _fromMap(map),
      ];
      if (withDetails == true) {
        for (pattern_row.PatternRow row in l) {
          row.details = await PatternDetailRepository().getAllDetailsByRowId(
            row.rowId,
          );
          row.stitchesUsedFromPreviousRow = row.details.fold(0, (
            total,
            currentDetail,
          ) {
            return currentDetail.repeatXTime *
                (currentDetail.stitch?.nbStsTaken ?? 1);
          });
        }
      }
      return (l);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<pattern_row.PatternRow> getRowByDetailId(
    int id, [
    Database? db,
  ]) async {
    db ??= (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> patternRowMaps = await db.query(
        _tableName,
        where: "part_detail_id = ?",
        whereArgs: [id],
        orderBy: "start_row ASC",
        limit: 1,
      );
      List<pattern_row.PatternRow> l = List.empty(growable: true);
      for (Map<String, Object?> map in patternRowMaps) {
        pattern_row.PatternRow tmp = _fromMap(map);
        tmp.details = await PatternDetailRepository().getAllDetailsByRowId(
          tmp.rowId,
          db,
        );
        tmp.stitchesUsedFromPreviousRow = tmp.details.fold(0, (
          total,
          currentDetail,
        ) {
          return currentDetail.repeatXTime;
        });
        l.add(tmp);
      }
      return (l[0]);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<pattern_row.PatternRow> getRowById({
    required int id,
    Database? db,
  }) async {
    db ??= (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> patternRowMaps = await db.query(
        _tableName,
        where: "row_id = ?",
        whereArgs: [id],
        limit: 1,
      );
      if (patternRowMaps.isEmpty) {
        throw Exception("Row not found");
      }
      pattern_row.PatternRow row = _fromMap(patternRowMaps[0]);
      row.details = await PatternDetailRepository().getAllDetailsByRowId(
        row.rowId,
        db,
      );
      row.stitchesUsedFromPreviousRow = row.details.fold(0, (
        total,
        currentDetail,
      ) {
        return currentDetail.repeatXTime *
            (currentDetail.stitch?.nbStsTaken ?? 1);
      });
      // if (debug) {
      //   print("getRowById with id = $id returned :");
      //   row.printDetails(1);
      // }
      return (row);
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
}
