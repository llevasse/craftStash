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
    this.rowId,
  });
  int id;
  String abreviation;
  String? name;
  String? description;
  int isSequence;
  int? rowId;
  PatternRow? row;

  Map<String, dynamic> toMap() {
    return {
      "abreviation": abreviation,
      "name": name,
      "description": description,
      "is_sequence": isSequence,
      "row_id": rowId,
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
    PatternRowDetail(
      rowId: row.rowId,
      stitch: stitches[2].abreviation,
      stitchId: stitches[2].id,
    ),
    PatternRowDetail(
      rowId: row.rowId,
      stitch: stitches[6].abreviation,
      stitchId: stitches[6].id,
    ),
  ];
  for (PatternRowDetail e in row.details) {
    print(e.stitchId);
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
      rowId: row.rowId,
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
          "row_id": rowId as int?,
        }
        in stitchMaps) {
      l.add(
        Stitch(
          id: id,
          abreviation: abreviation,
          name: name,
          description: description,
          isSequence: isSequence,
          rowId: rowId,
        ),
      );
      if (isSequence != 0 && rowId != null) {
        l.last.row = await getPatternRowByRowId(rowId, db);
      }
    }
    return l;
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
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
