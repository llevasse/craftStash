import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/class/wip/wip_part.dart';
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

String _tableName = "wip";

class Wip {
  int id;
  int patternId;
  int finished;
  int stitchDoneNb;
  String name;
  double? hookSize;
  craft.Pattern? pattern;
  Map<int, String> yarnIdToNameMap = {};
  List<WipPart> parts = List.empty(growable: true);
  Wip({
    this.id = 0,
    this.patternId = 0,
    this.finished = 0,
    this.stitchDoneNb = 0,
    this.name = "New wip",
    this.hookSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'finished': finished,
      'pattern_id': patternId,
      'stitch_done_nb': stitchDoneNb,
      "name": name,
      "hook_size": hookSize,
    };
  }

  @override
  String toString() {
    String tmp = "${pattern?.name} :\n";
    for (WipPart part in parts) {
      tmp += "\t${part.toString()}";
    }
    return tmp;
  }
}

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

Future<int> insertWipInDb(Wip wip, [Database? db]) async {
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

Future<void> updateWipInDb(Wip wip) async {
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

Future<void> deleteWipInDb(int id) async {
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
        if (withParts) wip.parts = await getAllWipPart(wipId: wip.id);
        if (withPattern) {
          wip.pattern = await craft.getPatternById(id: wip.patternId);
        }
        if (withYarnNames) {
          wip.yarnIdToNameMap = await getYarnIdToNameMapByWipId(wip.id);
        }
      }
    }
    return (w);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<Wip> getWipById({required int id, bool withParts = false}) async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternMaps = await db.query(
      _tableName,
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    Wip p = _fromMap(patternMaps[0]);
    if (withParts) p.parts = await getAllWipPart(wipId: id);
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

Future<Map<int, String>> getYarnIdToNameMapByWipId(int wipId) async {
  Map<int, String> map = {};
  List<Yarn> yarns = await getAllYarnByWipId(wipId);
  for (Yarn yarn in yarns) {
    if (yarn.inPreviewId != null) {
      map[yarn.inPreviewId!] = yarn.colorName;
    }
  }
  return map;
}
