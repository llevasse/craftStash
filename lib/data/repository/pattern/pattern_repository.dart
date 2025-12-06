import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/data/repository/pattern/pattern_part_repository.dart';
import 'package:craft_stash/data/repository/yarn/yarn_repository.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class PatternRepository {
  static const String _tableName = 'pattern';
  const PatternRepository();

  craft.Pattern _fromMap(Map<String, Object?> map) {
    return craft.Pattern(
      patternId: map['pattern_id'] as int,
      name: map['name'] as String,
      note: map['note'] as String?,
      hookSize: map['hook_size'] as double?,
      totalStitchNb: map['total_stitch_nb'] as int,
    );
  }

  Future<craft.Pattern> getPatternById({
    required int id,
    bool withParts = false,
    bool withRows = false,
    bool withDetails = false,
    bool withYarnNames = false,
  }) async {
    final db = (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> patternMaps = await db.query(
        _tableName,
        where: "pattern_id = ?",
        whereArgs: [id],
        limit: 1,
      );
      craft.Pattern p = _fromMap(patternMaps[0]);
      if (withParts) {
        p.parts = await PatternPartRepository().getAllParts(
          patternId: id,
          withRow: withRows,
          withDetails: withDetails,
        );
      }
      if (withYarnNames) {
        p.yarnIdToNameMap = await getYarnIdToNameMapByPatternId(id);
      }
      return (p);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<Map<int, String>> getYarnIdToNameMapByPatternId(int patternId) async {
    Map<int, String> map = {};
    List<Yarn> yarns = await YarnRepository().getAllYarnByPatternId(patternId);
    for (Yarn yarn in yarns) {
      if (yarn.inPreviewId != null) {
        map[yarn.inPreviewId!] = yarn.colorName;
      }
    }
    return map;
  }

  Future<List<craft.Pattern>> getAllPattern({
    bool withParts = false,
    Database? db,
  }) async {
    db ??= (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> patternMaps = await db.query(_tableName);
      List<craft.Pattern> p = [for (final map in patternMaps) _fromMap(map)];
      if (withParts == true) {
        for (craft.Pattern pattern in p) {
          pattern.parts = await PatternPartRepository().getAllParts(
            patternId: pattern.patternId,
          );
        }
      }
      return (p);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<int> insertPattern({
    required craft.Pattern pattern,
    Database? db,
  }) async {
    db ??= (await DbService().database);
    if (db != null) {
      return db.insert(
        _tableName,
        pattern.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> updatePattern(craft.Pattern pattern) async {
    final db = (await DbService().database);
    if (db != null) {
      await db.update(
        _tableName,
        pattern.toMap(),
        where: "pattern_id = ?",
        whereArgs: [pattern.patternId],
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> deletePattern({required int id, Database? db}) async {
    db ??= (await DbService().database);
    if (db != null) {
      await db.delete(_tableName, where: "pattern_id = ?", whereArgs: [id]);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> removeAllPattern() async {
    final db = (await DbService().database);
    if (db != null) {
      db.rawDelete('DELETE FROM $_tableName');
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<int> insertYarnInPattern({
    required int yarnId,
    required int patternId,
    required int inPreviewId,
    Database? db,
  }) async {
    db ??= (await DbService().database);
    if (db != null) {
      if ((await db.query(
        "yarn_in_pattern",
        where: "pattern_id = ? AND yarn_id = ?",
        whereArgs: [patternId, yarnId],
      )).isNotEmpty) {
        throw EntryAlreadyExist("yarn_in_pattern");
      }
      return db.insert("yarn_in_pattern", {
        'pattern_id': patternId,
        'yarn_id': yarnId,
        'in_preview_id': inPreviewId,
      });
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<int> updateYarnInPattern({
    required int yarnId,
    required int patternId,
    required int inPreviewId,
    Database? db,
  }) async {
    db ??= (await DbService().database);
    if (db != null) {
      List<Map<String, Object?>> l = await db.query(
        "yarn_in_pattern",
        where: "pattern_id = ? AND in_preview_id = ?",
        limit: 1,
        whereArgs: [patternId, inPreviewId],
      );
      if (l.isEmpty) {
        throw DatabaseNoElementsMeetConditionException(
          "pattern_id = $patternId AND in_preview_id = $inPreviewId",
          "yarn_in_pattern",
        );
      }
      return db.update(
        "yarn_in_pattern",
        {
          'pattern_id': patternId,
          'yarn_id': yarnId,
          'in_preview_id': inPreviewId,
        },
        where: "id = ?",
        whereArgs: [l[0]['id'] as int],
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<int> deleteYarnInPattern({
    required int yarnId,
    required int inPatternYarnId,
    required int patternId,
    Database? db,
  }) async {
    db ??= (await DbService().database);
    if (db != null) {
      if ((await db.query(
        "pattern_row_detail",
        limit: 1,
        where: "pattern_id = ? AND yarn_id = ?",
        whereArgs: [patternId, inPatternYarnId],
      )).isNotEmpty) {
        throw ElementIsUsedSomewhereElse('pattern_row_detail');
      }
      return await db.delete(
        "yarn_in_pattern",
        where: "pattern_id = ? AND yarn_id = ?",
        whereArgs: [patternId, yarnId],
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }
}
