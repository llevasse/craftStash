import 'package:craft_stash/class/wip/wip.dart';
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/data/repository/pattern/pattern_repository.dart';
import 'package:craft_stash/data/repository/wip/wip_part_repository.dart';
import 'package:craft_stash/data/repository/yarn/yarn_repository.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class WipRepository {
  static const String _tableName = "wip";
  const WipRepository();

  Wip _fromMap(Map<String, Object?> map) {
    return Wip(
      id: map['id'] as int,
      patternId: map['pattern_id'] as int,
      finished: map['finished'] as int,
      stitchDoneNb: map['stitch_done_nb'] as int,
      name: map['name'] as String,
      hookSize: map['hook_size'] as double?,
    );
  }

  Future<int> insertWip(Wip wip, [Database? db]) async {
    db ??= (await DbService().database);
    if (db != null) {
      return db.insert(
        _tableName,
        wip.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> updateWip(Wip wip) async {
    final db = (await DbService().database);
    if (db != null) {
      await db.update(
        _tableName,
        wip.toMap(),
        where: "id = ?",
        whereArgs: [wip.id],
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> deleteWip(int id) async {
    final db = (await DbService().database);
    if (db != null) {
      await db.delete(_tableName, where: "id = ?", whereArgs: [id]);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<List<Wip>> getAllWip({
    bool withPattern = true,
    bool withParts = false,
    bool withYarnNames = false,
  }) async {
    final db = (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> patternMaps = await db.query(_tableName);
      List<Wip> w = [for (final map in patternMaps) _fromMap(map)];
      if (withParts || withPattern) {
        for (Wip wip in w) {
          if (withParts) {
            wip.parts = await WipPartRepository().getAllWipPart(wipId: wip.id);
          }
          if (withPattern) {
            wip.pattern = await PatternRepository().getPatternById(
              id: wip.patternId,
            );
          }
          if (withYarnNames) {
            wip.yarnIdToNameMap = await getYarnIdToName(wip.id);
          }
        }
      }
      return (w);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<Wip> getWipById({
    required int id,
    bool withParts = false,
    bool withPattern = false,
  }) async {
    final db = (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> patternMaps = await db.query(
        _tableName,
        where: "id = ?",
        whereArgs: [id],
        limit: 1,
      );
      Wip p = _fromMap(patternMaps[0]);
      if (withPattern) {
        p.pattern = await PatternRepository().getPatternById(id: p.patternId);
      }
      if (withParts) {
        p.parts = await WipPartRepository().getAllWipPart(wipId: id);
      }
      return (p);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> removeAllWip() async {
    final db = (await DbService().database);
    if (db != null) {
      db.rawDelete('DELETE FROM $_tableName');
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<int> insertYarnInWip({
    required int yarnId,
    required int wipId,
    required int inPreviewId,
    Database? db,
  }) async {
    db ??= (await DbService().database);
    if (db != null) {
      if ((await db.query(
        "yarn_in_wip",
        where: "wip_id = ? AND yarn_id = ?",
        whereArgs: [wipId, yarnId],
      )).isNotEmpty) {
        throw EntryAlreadyExist("yarn_in_wip");
      }
      return db.insert("yarn_in_wip", {
        'wip_id': wipId,
        'yarn_id': yarnId,
        'in_preview_id': inPreviewId,
      });
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<int> deleteYarnInPattern(
    int yarnId,
    int patternId, [
    Database? db,
  ]) async {
    db ??= (await DbService().database);
    if (db != null) {
      return await db.delete(
        "yarn_in_pattern",
        where: "pattern_id = ? AND yarn_id = ?",
        whereArgs: [patternId, yarnId],
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<int> updateYarnInWip({
    required int yarnId,
    required int wipId,
    required int inPreviewId,
    Database? db,
  }) async {
    db ??= (await DbService().database);
    if (db != null) {
      List<Map<String, Object?>> l = await db.query(
        "yarn_in_wip",
        where: "wip_id = ? AND in_preview_id = ?",
        limit: 1,
        whereArgs: [wipId, inPreviewId],
      );
      if (l.isEmpty) {
        throw DatabaseNoElementsMeetConditionException(
          "wip_id = $wipId AND in_preview_id = $inPreviewId",
          "yarn_in_wip",
        );
      }
      return db.update(
        "yarn_in_wip",
        {'wip_id': wipId, 'yarn_id': yarnId, 'in_preview_id': inPreviewId},
        where: "id = ?",
        whereArgs: [l[0]['id'] as int],
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<Map<int, String>> getYarnIdToName(int wipId) async {
    Map<int, String> map = {};
    List<Yarn> yarns = await YarnRepository().getAllYarnByWipId(wipId);
    for (Yarn yarn in yarns) {
      if (yarn.inPreviewId != null) {
        map[yarn.inPreviewId!] = yarn.colorName;
      }
    }
    return map;
  }
}
