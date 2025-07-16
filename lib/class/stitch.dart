import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

final String _tableName = "stitch";

class Stitch {
  Stitch({
    this.id = 0,
    required this.abreviation,
    this.name,
    this.description,
    this.isSequence = 0,
    this.sequenceId,
  });
  int id;
  String abreviation;
  String? name;
  String? description;
  int isSequence;
  int? sequenceId;
  PatternRow? row;

  Map<String, dynamic> toMap() {
    return {
      "abreviation": abreviation,
      "name": name,
      "description": description,
      "is_sequence": isSequence,
      "sequence_id": sequenceId,
      "hash": hashCode,
    };
  }

  @override
  String toString() {
    return abreviation;
  }

  @override
  int get hashCode => Object.hash(abreviation, name, description);
}

Stitch _fromMap(Map<String, Object?> map) {
  return Stitch(
    abreviation: map["abreviation"] as String,
    name: map["name"] as String?,
    description: map["description"] as String?,
    isSequence: map["is_sequence"] as int,
    sequenceId: map["sequence_id"] as int?,
  );
}

Future<void> insertDefaultStitchesInDb([Database? db]) async {
  List<Stitch> stitches = [
    Stitch(abreviation: "ch", name: "chain", description: null),
    Stitch(abreviation: "sl st", name: "slip stitch", description: null),
    Stitch(abreviation: "sc", name: "single crochet", description: null),
    Stitch(abreviation: "hdc", name: "half double crochet", description: null),
    Stitch(abreviation: "dc", name: "double crochet", description: null),
    Stitch(abreviation: "tr", name: "treble crochet", description: null),
    Stitch(abreviation: "inc", name: "increase", description: null),
    Stitch(abreviation: "dec", name: "decrease", description: null),
    Stitch(abreviation: "sk", name: "skip", description: null),
  ];
  for (Stitch s in stitches) {
    s.id = await insertStitchInDb(s, db);
  }

  PatternRow row = PatternRow(startRow: 0, numberOfRows: 0, stitchesPerRow: 3);
  row.rowId = await insertPatternRowInDb(row, db);
  row.details = [
    PatternRowDetail(rowId: row.rowId, stitchId: stitches[2].id),
    PatternRowDetail(rowId: row.rowId, stitchId: stitches[6].id),
  ];
  for (PatternRowDetail e in row.details) {
    if (e.repeatXTime != 0) {
      e.rowId = row.rowId;
      await insertPatternRowDetailInDb(e, db);
    }
  }
  await insertStitchInDb(
    Stitch(
      abreviation: "(sc, inc)",
      name: null,
      description: null,
      isSequence: 1,
      sequenceId: row.rowId,
    ),
    db,
  );

  print("INSERTED DEFAULT STITCHES");
}

Future<int> insertStitchInDb(Stitch stitch, [Database? db]) async {
  db ??= (await DbService().database);
  if (db != null) {
    final list = await db.query(
      _tableName,
      where: "hash = ?",
      whereArgs: [stitch.hashCode],
    );
    if (list.isNotEmpty) {
      throw StitchAlreadyExist(
        "Stitch with hash ${stitch.hashCode} already exist",
      );
    }
    return await db.insert(
      _tableName,
      stitch.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> updateStitchInDb(Stitch stitch) async {
  final db = (await DbService().database);
  if (db != null) {
    await db.update(
      _tableName,
      stitch.toMap(),
      where: "id = ?",
      whereArgs: [stitch.id],
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> deleteStitchInDb(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    await db.delete(_tableName, where: "id = ?", whereArgs: [id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<Stitch>> getAllStitchesInDb([Database? db]) async {
  db ??= (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> stitchMaps = await db.query(_tableName);
    List<Stitch> l = List.empty(growable: true);
    for (final {
          'id': id as int,
          'abreviation': abreviation as String,
          'name': name as String?,
          'description': description as String?,
          "is_sequence": isSequence as int,
          "sequence_id": sequenceId as int?,
        }
        in stitchMaps) {
      l.add(
        Stitch(
          id: id,
          abreviation: abreviation,
          name: name,
          description: description,
          isSequence: isSequence,
          sequenceId: sequenceId,
        ),
      );
      if (isSequence != 0 && sequenceId != null) {
        l.last.row = await getPatternRowByRowId(sequenceId, db);
      }
    }
    return l;
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<Stitch> getStitchInDbById(int id, [Database? db]) async {
  if (db != null) {
    final List<Map<String, Object?>> stitchMaps = await db.query(
      _tableName,
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (stitchMaps.isEmpty) {
      throw DatabaseNoElementsMeetConditionException("id = $id", _tableName);
    }
    Stitch s = _fromMap(stitchMaps.first);
    if (s.isSequence != 0 && s.sequenceId != null) {
      s.row = await getPatternRowByRowId(s.sequenceId!, db);
    }
    return s;
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<Map<int, Stitch>> getAllStitchMappedById([Database? db]) async {
  List<Stitch> l = await getAllStitchesInDb(db);
  Map<int, Stitch> _stitchesMap = {};
  for (Stitch s in l) {
    _stitchesMap.addAll({s.id: s});
  }
  return _stitchesMap;
}

Future<void> removeAllStitch() async {
  final db = (await DbService().database);
  if (db != null) {
    db.rawDelete('DELETE FROM stitch');
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

class StitchAlreadyExist implements Exception {
  StitchAlreadyExist(this.cause);
  String cause;
}
