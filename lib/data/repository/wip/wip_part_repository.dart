import 'package:craft_stash/class/wip/wip.dart';
import 'package:craft_stash/class/wip/wip_part.dart';
import 'package:craft_stash/data/repository/wip/wip_repository.dart';

import 'package:craft_stash/data/repository/pattern/pattern_part_repository.dart';
import 'package:craft_stash/data/repository/pattern/pattern_row_repository.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

String _tableName = "wip_part";

class WipPartRepository {
  const WipPartRepository();

  Future<Map<int, String>> getYarnIdToNameMap({required int wipId}) async {
    Map<int, String> yarnIdToNameMap = await WipRepository().getYarnIdToName(
      wipId,
    );
    return yarnIdToNameMap;
  }

  WipPart _fromMap(Map<String, Object?> map) {
    return WipPart(
      id: map['id'] as int,
      wipId: map['wip_id'] as int,
      partId: map['part_id'] as int,
      madeXTime: map['made_x_time'] as int,
      finished: map['finished'] as int,
      currentRowNumber: map['current_row_number'] as int,
      currentRowIndex: map['current_row_index'] as int,
      currentStitchNumber: map['current_stitch_number'] as int,
      stitchDoneNb: map['stitch_done_nb'] as int,
    );
  }

  Future<int> insertWipPart(WipPart wipPart, [Database? db]) async {
    db ??= (await DbService().database);
    if (db != null) {
      return db.insert(
        _tableName,
        wipPart.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> updateWipPart(WipPart wipPart) async {
    final db = (await DbService().database);
    if (db != null) {
      await db.update(
        _tableName,
        wipPart.toMap(),
        where: "id = ?",
        whereArgs: [wipPart.id],
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> deleteWipPart(int id) async {
    final db = (await DbService().database);
    if (db != null) {
      await PatternRowRepository().deleteRowByPartId(id);
      await db.delete(_tableName, where: "id = ?", whereArgs: [id]);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<List<WipPart>> getAllWipPart({
    required int wipId,
    bool withRows = false,
    bool withDetails = false,
    Database? db,
  }) async {
    db ??= (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> patternPartMaps = await db.query(
        _tableName,
        where: "wip_id = ?",
        whereArgs: [wipId],
      );
      List<WipPart> l = [for (final map in patternPartMaps) _fromMap(map)];

      for (WipPart wipPart in l) {
        wipPart.part = await PatternPartRepository().getPartById(
          id: wipPart.partId,
          withRows: withRows,
          withDetails: withDetails,
          db: db,
        );
      }
      return (l);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<WipPart> getWipPartById({
    required int id,
    bool withRows = false,
    bool withDetails = false,
    Database? db,
  }) async {
    db ??= (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> patternPartMaps = await db.query(
        _tableName,
        where: "id = ?",
        whereArgs: [id],
        limit: 1,
      );
      WipPart p = _fromMap(patternPartMaps[0]);
      p.part = await PatternPartRepository().getPartById(
        id: p.partId,
        withRows: withRows,
        withDetails: withDetails,
        db: db,
      );
      return (p);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> removeAllWipPart() async {
    final db = (await DbService().database);
    if (db != null) {
      db.rawDelete('DELETE FROM $_tableName');
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }
}
