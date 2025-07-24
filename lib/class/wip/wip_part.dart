import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

String _tableName = "wip_part";

class WipPart {
  int id;
  int wipId;
  int partId;
  int madeXTime;
  int finished;
  int currentRowNumber;
  int currentStitchNumber;
  PatternPart? part;
  WipPart({
    this.id = 0,
    required this.wipId,
    required this.partId,
    this.madeXTime = 1,
    this.currentRowNumber = 1,
    this.currentStitchNumber = 0,
    this.finished = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'wip_id': wipId,
      'part_id': partId,
      'made_x_time': madeXTime,
      'finished': finished,
      'current_row_number': currentRowNumber,
      'current_stitch_number': currentStitchNumber,
    };
  }

  @override
  String toString() {
    if (part == null) return "";
    String tmp = "${part?.name} $madeXTime/${part?.numbersToMake}:\n";
    for (PatternRow row in part!.rows) {
      tmp += "\t\t${row.toString()}";
    }

    return tmp;
  }
}

WipPart _fromMap(Map<String, Object?> map) {
  return WipPart(
    id: map['id'] as int,
    wipId: map['wip_id'] as int,
    partId: map['part_id'] as int,
    madeXTime: map['made_x_time'] as int,
    finished: map['finished'] as int,
    currentRowNumber: map['current_row_number'] as int,
    currentStitchNumber: map['current_stitch_number'] as int,
  );
}

Future<int> insertWipPartInDb(WipPart patternPart, [Database? db]) async {
  db ??= (await DbService().database);
  if (db != null) {
    return db.insert(
      _tableName,
      patternPart.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> updateWipPartInDb(WipPart wipPart) async {
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

Future<void> deleteWipPartInDb(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    await deletePatternRowInDbByPartId(id);
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
      wipPart.part = await getPatternPartByPartId(
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

Future<WipPart> getWipPartByWipPartId({
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
    p.part = await getPatternPartByPartId(
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
