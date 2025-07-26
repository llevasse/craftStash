import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

final String _tableName = "stitch";

Map<String, int> stitchToIdMap = {};

class Stitch {
  Stitch({
    this.id = 0,
    required this.abreviation,
    this.name,
    this.description,
    this.isSequence = 0,
    this.sequenceId,
    this.hidden = 0,
  });
  int id;
  String abreviation;
  String? name;
  String? description;
  int isSequence;
  int? sequenceId;
  PatternRow? row;
  int hidden;

  Map<String, dynamic> toMap() {
    return {
      "abreviation": abreviation,
      "name": name,
      "description": description,
      "is_sequence": isSequence,
      "sequence_id": sequenceId,
      "hidden": hidden,
      "hash": hashCode,
    };
  }

  @override
  String toString() {
    return abreviation;
  }

  void printDetails([int tab = 0]) {
    String s = "";
    for (int i = 0; i < tab; i++) {
      s += "\t";
    }
    print("${s}id $id");
    print("${s}abreviation $abreviation");
    print("${s}name $name");
    print("${s}description $description");
    print("${s}is_sequence $isSequence");
    if (isSequence == 1) {
      print("${s}sequence_id $sequenceId");
      row?.printDetails(tab + 1);
    }
    print("${s}hidden $hidden");
    print("${s}hash $hashCode");
    print("\r\n");
  }

  @override
  int get hashCode => Object.hash(abreviation, name, description);
}

Stitch _fromMap(Map<String, Object?> map) {
  return Stitch(
    id: map["id"] as int,
    abreviation: map["abreviation"] as String,
    name: map["name"] as String?,
    description: map["description"] as String?,
    isSequence: map["is_sequence"] as int,
    sequenceId: map["sequence_id"] as int?,
    hidden: map["hidden"] as int,
  );
}

Future<void> setStitchToIdMap() async {
  List<Stitch> l = await getAllStitchesInDb();
  stitchToIdMap.clear();
  for (Stitch s in l) {
    stitchToIdMap.addAll({s.abreviation: s.id});
  }
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
    Stitch(
      abreviation: "color change",
      name: null,
      description: null,
      hidden: 1,
    ),
    Stitch(
      abreviation: "start color",
      name: null,
      description: null,
      hidden: 1,
    ),
  ];
  for (Stitch s in stitches) {
    s.id = await insertStitchInDb(s, db);
    stitchToIdMap[s.abreviation] = s.id;
  }
  await _insertScIncInDb(stitches: stitches, db: db);
  await _insertScDecInDb(stitches: stitches, db: db);
  print("INSERTED DEFAULT STITCHES");
}

Future<void> _insertScIncInDb({
  required List<Stitch> stitches,
  Database? db,
}) async {
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
}

Future<void> _insertScDecInDb({
  required List<Stitch> stitches,
  Database? db,
}) async {
  PatternRow row = PatternRow(startRow: 0, numberOfRows: 0, stitchesPerRow: 2);
  row.rowId = await insertPatternRowInDb(row, db);
  row.details = [
    PatternRowDetail(rowId: row.rowId, stitchId: stitches[2].id),
    PatternRowDetail(rowId: row.rowId, stitchId: stitches[7].id),
  ];
  for (PatternRowDetail e in row.details) {
    if (e.repeatXTime != 0) {
      e.rowId = row.rowId;
      await insertPatternRowDetailInDb(e, db);
    }
  }
  await insertStitchInDb(
    Stitch(
      abreviation: "(sc, dec)",
      name: null,
      description: null,
      isSequence: 1,
      sequenceId: row.rowId,
    ),
    db,
  );
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

Future<void> insertStitchInDbWithDefinedId(
  Stitch stitch, [
  Database? db,
]) async {
  db ??= (await DbService().database);
  if (db != null) {
    Map<String, Object?> m = stitch.toMap();
    m.addAll({'id': stitch.id});
    await db.insert(
      _tableName,
      m,
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

Future<void> deleteStitchInDb(Stitch stitch) async {
  final db = (await DbService().database);
  if (db != null) {
    if ((await getAllPatternRowDetailByStitch(stitch)).isNotEmpty) {
      throw StitchIsUsed(
        "Can't delete a stitch that is currently used in a pattern.",
      );
    }
    await db.delete(_tableName, where: "id = ?", whereArgs: [stitch.id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<Stitch>> getAllStitchesInDb([Database? db]) async {
  db ??= (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> stitchMaps = await db.query(_tableName);
    List<Stitch> l = List.empty(growable: true);
    for (Map<String, Object?> map in stitchMaps) {
      l.add(_fromMap(map));
      if (l.last.sequenceId != null) {
        l.last.row = await getPatternRowByRowId(l.last.sequenceId!, db);
      }
    }
    return l;
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<Stitch>> getAllVisibleStitchesInDb([Database? db]) async {
  db ??= (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> stitchMaps = await db.query(
      _tableName,
      where: "hidden = ?",
      whereArgs: [0],
    );
    List<Stitch> l = List.empty(growable: true);
    for (Map<String, Object?> map in stitchMaps) {
      l.add(_fromMap(map));
      if (l.last.sequenceId != null) {
        l.last.row = await getPatternRowByRowId(l.last.sequenceId!, db);
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
  Map<int, Stitch> stitchesMap = {};
  for (Stitch s in l) {
    stitchesMap.addAll({s.id: s});
  }
  return stitchesMap;
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

class StitchIsUsed implements Exception {
  StitchIsUsed(this.cause);
  String cause;
}
