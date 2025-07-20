import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class PatternPart {
  int partId;
  int patternId;
  int numbersToMake;
  String name;
  List<PatternRow> rows = List.empty(growable: true);
  PatternPart({
    this.partId = 0,
    required this.name,
    required this.patternId,
    this.numbersToMake = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'pattern_id': patternId,
      'numbers_to_make': numbersToMake,
      'name': name,
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

Future<List<PatternPart>> getAllPatternPart() async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternPartMaps = await db.query(
      'pattern_part',
    );
    return [
      for (final {
            'part_id': patternPartId as int,
            'pattern_id': patternId as int,
            "name": name as String,
            'numbers_to_make': numbersToMake as int,
          }
          in patternPartMaps)
        PatternPart(
          name: name,
          patternId: patternId,
          partId: patternPartId,
          numbersToMake: numbersToMake,
        ),
    ];
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<PatternPart>> getAllPatternPartsByPatternId(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternPartMaps = await db.query(
      'pattern_part',
      where: "pattern_id = ?",
      whereArgs: [id],
      columns: ["part_id", "name", "numbers_to_make"],
    );
    List<PatternPart> l = [
      for (final {
            'part_id': patternPartId as int,
            "name": name as String,
            'numbers_to_make': numbersToMake as int,
          }
          in patternPartMaps)
        PatternPart(
          name: name,
          patternId: id,
          partId: patternPartId,
          numbersToMake: numbersToMake,
        ),
    ];
    for (PatternPart part in l) {
      part.rows = await getAllPatternRowByPartId(part.partId);
    }
    return (l);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<PatternPart>> getAllPatternPartsByPatternIdWithoutRows(
  int id,
) async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternPartMaps = await db.query(
      'pattern_part',
      where: "pattern_id = ?",
      whereArgs: [id],
      columns: ["part_id", "name", "numbers_to_make"],
    );
    List<PatternPart> l = [
      for (final {
            'part_id': patternPartId as int,
            "name": name as String,
            'numbers_to_make': numbersToMake as int,
          }
          in patternPartMaps)
        PatternPart(
          name: name,
          patternId: id,
          partId: patternPartId,
          numbersToMake: numbersToMake,
        ),
    ];
    return (l);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<PatternPart> getPatternPartByPartId(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternPartMaps = await db.query(
      'pattern_part',
      where: "part_id = ?",
      whereArgs: [id],
      limit: 1,
    );
    PatternPart p = PatternPart(
      partId: patternPartMaps[0]['part_id'] as int,
      patternId: patternPartMaps[0]['pattern_id'] as int,
      name: patternPartMaps[0]['name'] as String,
      numbersToMake: patternPartMaps[0]['numbers_to_make'] as int,
    );
    p.rows = await getAllPatternRowByPartIdWithoutDetails(id);
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
