import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class Pattern {
  int patternId;
  String name;
  Pattern({this.patternId = 0, required this.name});

  Map<String, dynamic> toMap() {
    return {'pattern_id': patternId, 'name': name, 'hash': hashCode};
  }

  @override
  int get hashCode => Object.hash(name, 0);
}

Future<void> insertPatternInDb(Pattern pattern) async {
  final db = (await DbService().database);
  if (db != null) {
    final list = await db.query(
      'pattern',
      where: "hash = ?",
      whereArgs: [pattern.hashCode],
    );
    if (list.isEmpty) {
      db.insert(
        'pattern',
        pattern.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
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
    return [
      for (final {'pattern_id': patternId as int, "name": name as String}
          in patternMaps)
        Pattern(patternId: patternId, name: name),
    ];
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
