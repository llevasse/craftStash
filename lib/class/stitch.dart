import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

final String _tableName = "stitch";

class Stitch {
  Stitch({this.id = 0, required this.abreviation, this.name, this.description});
  int id;
  String abreviation;
  String? name;
  String? description;

  Map<String, dynamic> toMap() {
    return {
      "abreviation": abreviation,
      "name": name,
      "description": description,
      "hash": hashCode,
    };
  }

  @override
  int get hashCode => Object.hash(abreviation, name, description);
}

Future<void> insertDefaultStitchesInDb() async {
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
  for (int i = 0; i < 50; i++) {
    stitches.add(
      Stitch(abreviation: "$i", name: "bogus $i", description: null),
    );
  }
  stitches.forEach((stitch) async {
    // print(stitch.abreviation);
    await insertStitchInDb(stitch);
  });
}

Future<void> insertStitchInDb(Stitch stitch) async {
  final db = (await DbService().database);
  if (db != null) {
    final list = await db.query(
      _tableName,
      where: "hash = ?",
      whereArgs: [stitch.hashCode],
    );
    if (list.isEmpty) {
      db.insert(
        _tableName,
        stitch.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
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

Future<List<Stitch>> getAllStitchesInDb() async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> stitchMaps = await db.query(_tableName);
    return [
      for (final {
            'id': id as int,
            'abreviation': abreviation as String,
            'name': name as String?,
            'description': description as String?,
          }
          in stitchMaps)
        Stitch(
          id: id,
          abreviation: abreviation,
          name: name,
          description: description,
        ),
    ];
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
