import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class Pattern {
  int patternId;
  String name;
  List<PatternPart> parts = List.empty(growable: true);
  Pattern({this.patternId = 0, this.name = "New pattern"});

  Map<String, dynamic> toMap() {
    // return {'pattern_id': patternId, 'name': name};
    return {'name': name};
  }

  @override
  String toString() {
    String tmp = "$name :\n";
    for (PatternPart part in parts) {
      tmp += "\t${part.toString()}";
    }

    return tmp;
  }

  @override
  int get hashCode => Object.hash(name, 0);
}

Future<int> insertPatternInDb(Pattern pattern) async {
  final db = (await DbService().database);
  if (db != null) {
    return db.insert(
      'pattern',
      pattern.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> updatePatternInDb(Pattern pattern) async {
  final db = (await DbService().database);
  if (db != null) {
    await db.update(
      'pattern',
      pattern.toMap(),
      where: "pattern_id = ?",
      whereArgs: [pattern.patternId],
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> deletePatternInDb(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    await db.delete('pattern', where: "pattern_id = ?", whereArgs: [id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<Pattern>> getAllPattern() async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternMaps = await db.query('pattern');
    List<Pattern> p = [
      for (final {'pattern_id': patternId as int, 'name': name as String}
          in patternMaps)
        Pattern(patternId: patternId, name: name),
    ];
    for (Pattern pattern in p) {
      pattern.parts = await getAllPatternPartsByPatternId(pattern.patternId);
    }
    return (p);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<Pattern> getPatternById(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> patternMaps = await db.query(
      'pattern',
      where: "pattern_id = ?",
      whereArgs: [id],
      limit: 1,
    );
    Pattern p = Pattern(
      patternId: patternMaps[0]['pattern_id'] as int,
      name: patternMaps[0]['name'] as String,
    );
    p.parts = await getAllPatternPartsByPatternId(id);
    return (p);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> removeAllPattern() async {
  final db = (await DbService().database);
  if (db != null) {
    db.rawDelete('DELETE FROM pattern');
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}
