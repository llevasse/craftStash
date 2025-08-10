import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/data/repository/stitch_repository.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

final String _tableName = "pattern_row_detail";

class PatternDetailRepository {
  const PatternDetailRepository();

  PatternRowDetail _fromMap(Map<String, dynamic> map) {
    return PatternRowDetail(
      rowDetailId: map['row_detail_id'] as int,
      rowId: map['row_id'] as int,
      stitchId: map['stitch_id'] as int,
      repeatXTime: map['repeat_x_time'] as int,
      inPatternYarnId: map['yarn_id'] as int?,
      patternId: map['pattern_id'] as int?,
    );
  }

  Future<int> insertDetail(
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

  Future<void> updateDetail(PatternRowDetail patternRowDetail) async {
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

  Future<void> deleteDetail(int id) async {
    final db = (await DbService().database);
    if (db != null) {
      await db.delete(_tableName, where: "row_detail_id = ?", whereArgs: [id]);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> deleteDetailsByRowId(int id) async {
    final db = (await DbService().database);
    if (db != null) {
      await db.delete(_tableName, where: "row_id = ?", whereArgs: [id]);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<List<PatternRowDetail>> getAllDetails() async {
    final db = (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> patternRowDetailMaps = await db.query(
        _tableName,
      );
      List<PatternRowDetail> l = List.empty(growable: true);
      for (Map<String, Object?> map in patternRowDetailMaps) {
        l.add(_fromMap(map));
      }
      return l;
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<List<PatternRowDetail>> getAllDetailsByRowId(
    int id, [
    Database? db,
  ]) async {
    db ??= (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> patternRowDetailMaps = await db.query(
        _tableName,
        where: "row_id = ?",
        whereArgs: [id],
        orderBy: "in_row_order ASC",
      );
      List<PatternRowDetail> l = [
        for (Map<String, Object?> map in patternRowDetailMaps) _fromMap(map),
      ];
      for (PatternRowDetail detail in l) {
        detail.stitch = await StitchRepository().getStitchById(
          detail.stitchId,
          db,
        );
      }
      return l;
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<List<PatternRowDetail>> getAllDetailsByStitch(
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

  Future<void> removeAllDetails() async {
    final db = (await DbService().database);
    if (db != null) {
      db.rawDelete('DELETE FROM $_tableName');
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }
}
