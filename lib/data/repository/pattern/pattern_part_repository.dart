import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/data/repository/pattern/pattern_repository.dart';
import 'package:craft_stash/data/repository/pattern/pattern_row_repository.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class PatternPartRepository {
  static const String _tablename = "pattern_part";
  const PatternPartRepository();

  Future<Map<int, String>> getYarnIdToNameMap({required int patternId}) async {
    Map<int, String> yarnIdToNameMap = await PatternRepository()
        .getYarnIdToNameMapByPatternId(patternId);
    return yarnIdToNameMap;
  }

  PatternPart _fromMap(Map<String, Object?> map) {
    return PatternPart(
      partId: map['part_id'] as int,
      patternId: map['pattern_id'] as int,
      name: map["name"] as String,
      numbersToMake: map['numbers_to_make'] as int,
      note: map['note'] as String?,
      totalStitchNb: map['total_stitch_nb'] as int,
    );
  }

  Future<int> insertPart(PatternPart patternPart, [Database? db]) async {
    db ??= (await DbService().database);
    if (db != null) {
      return db.insert(
        _tablename,
        patternPart.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> updatePart(PatternPart patternPart) async {
    final db = (await DbService().database);
    if (db != null) {
      await db.update(
        _tablename,
        patternPart.toMap(),
        where: "part_id = ?",
        whereArgs: [patternPart.partId],
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> deletePart(int id) async {
    final db = (await DbService().database);
    if (db != null) {
      await PatternRowRepository().deleteRowByPartId(id);
      await db.delete(_tablename, where: "part_id = ?", whereArgs: [id]);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<List<PatternPart>> getAllParts({
    int? patternId,
    bool withRow = false,
    bool withDetails = false,
    Database? db,
  }) async {
    db ??= (await DbService().database);
    if (db != null) {
      String? where;
      List<Object?>? whereArgs;
      if (patternId != null) {
        where = "pattern_id = ?";
        whereArgs = [patternId];
      }
      final List<Map<String, Object?>> patternPartMaps = await db.query(
        _tablename,
        where: where,
        whereArgs: whereArgs,
      );
      List<PatternPart> l = [for (final map in patternPartMaps) _fromMap(map)];
      if (withRow == true) {
        for (PatternPart part in l) {
          print(part);
          part.rows = await PatternRowRepository().getAllRows(
            part.partId,
            withDetails,
            db,
          );
        }
      }
      return (l);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<PatternPart> getPartById({
    required int id,
    bool withRows = true,
    bool withDetails = false,
    Database? db,
  }) async {
    db ??= (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> patternPartMaps = await db.query(
        _tablename,
        where: "part_id = ?",
        whereArgs: [id],
        limit: 1,
      );
      PatternPart p = _fromMap(patternPartMaps[0]);
      if (withRows) {
        p.rows = await PatternRowRepository().getAllRows(id, withDetails, db);
      }
      return (p);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> deleteAllParts() async {
    final db = (await DbService().database);
    if (db != null) {
      db.rawDelete('DELETE FROM $_tablename');
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }
}
