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
      'part_id': partId,
      'pattern_id': patternId,
      'numbers_to_make': numbersToMake,
      'name': name,
      'hash': hashCode,
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

Future<void> insertPatternPartInDb(PatternPart patternPart) async {
  final db = (await DbService().database);
  if (db != null) {
    final list = await db.query(
      'pattern_part',
      where: "hash = ?",
      whereArgs: [patternPart.hashCode],
    );
    if (list.isEmpty) {
      db.insert(
        'pattern_part',
        patternPart.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
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

Future<void> removeAllPatternPart() async {
  final db = (await DbService().database);
  if (db != null) {
    db.rawDelete('DELETE FROM pattern_part');
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}
