import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class PatternPart {
  int partId;
  int patternId;
  int numbersToMake;
  String name;
  String? note;
  int totalStitchNb;
  List<PatternRow> rows = List.empty(growable: true);
  PatternPart({
    this.partId = 0,
    required this.name,
    required this.patternId,
    this.numbersToMake = 1,
    this.note,
    this.totalStitchNb = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'pattern_id': patternId,
      'numbers_to_make': numbersToMake,
      'name': name,
      'note': note,
      'total_stitch_nb': totalStitchNb,
    };
  }

  @override
  String toString() {
    String tmp = "$name x$numbersToMake:\n";
    for (PatternRow row in rows) {
      tmp += "\t\t${row.toString()}";
    }

    return tmp;
  }

  @override
  int get hashCode => Object.hash(name, patternId, numbersToMake);
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

Future<int> insertPatternPartInDb(
  PatternPart patternPart, [
  Database? db,
]) async {
  db ??= (await DbService().database);
  if (db != null) {
    return db.insert(
      'pattern_part',
      patternPart.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> updatePatternPartInDb(PatternPart patternPart) async {
  final db = (await DbService().database);
  if (db != null) {
    await db.update(
      'pattern_part',
      patternPart.toMap(),
      where: "part_id = ?",
      whereArgs: [patternPart.partId],
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> deletePatternPartInDb(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    await deletePatternRowInDbByPartId(id);
    await db.delete('pattern_part', where: "part_id = ?", whereArgs: [id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<PatternPart>> getAllPatternPart({
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
      'pattern_part',
      where: where,
      whereArgs: whereArgs,
    );
    List<PatternPart> l = [for (final map in patternPartMaps) _fromMap(map)];
    if (withRow == true) {
      for (PatternPart part in l) {
        part.rows = await getAllPatternRow(part.partId, withDetails, db);
      }
    }
    return (l);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<PatternPart> getPatternPartByPartId({
  required int id,
  bool withRows = true,
  bool withDetails = false,
  Database? db,
}) async {
  db ??= (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternPartMaps = await db.query(
      'pattern_part',
      where: "part_id = ?",
      whereArgs: [id],
      limit: 1,
    );
    PatternPart p = _fromMap(patternPartMaps[0]);
    if (withRows) p.rows = await getAllPatternRow(id, withDetails, db);
    return (p);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> removeAllPatternPart() async {
  final db = (await DbService().database);
  if (db != null) {
    db.rawDelete('DELETE FROM pattern_part');
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}
