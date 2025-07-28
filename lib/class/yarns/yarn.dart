import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class Yarn {
  Yarn({
    this.id = 0,
    this.collectionId,
    required this.color,
    this.brand = "Unknown",
    this.material = "Unknown",
    this.colorName = "Unknown",
    this.minHook = 0,
    this.maxHook = 0,
    this.thickness = 0,
    this.nbOfSkeins = 1,
    this.inPatternId,
  });
  int id;
  int? collectionId;
  String brand; // ex : "my brand"
  String material; // ex : "coton"
  String colorName; // ex : "ocean"
  double thickness; // ex : "3mm"
  double minHook; // ex : "2.5mm"
  double maxHook; // ex : "3.5mm"
  int color; // ex : 0xFFFFC107
  int nbOfSkeins; // ex : 1
  int? inPatternId;

  @override
  String toString() {
    return ("color: $color\ncollection_id: $collectionId\nbrand: $brand\nmaterial: $material\ncolor_name: $colorName\nmin_hook: $minHook\nmax_hook: $maxHook\nthickness: $thickness\nnumber_of_skeins: $nbOfSkeins\nhash: $hashCode\n");
  }

  Map<String, dynamic> toMap() {
    return {
      "color": color,
      "collection_id": collectionId,
      "brand": brand,
      "material": material,
      "color_name": colorName,
      "min_hook": minHook,
      "max_hook": maxHook,
      "thickness": thickness,
      "number_of_skeins": nbOfSkeins,
      "hash": hashCode,
      "in_pattern_id": inPatternId,
    };
  }

  @override
  int get hashCode => Object.hash(
    color,
    brand.toLowerCase(),
    collectionId,
    colorName.toLowerCase(),
    material.toLowerCase(),
    maxHook,
    minHook,
    thickness,
  );
}

Yarn _fromMap(Map<String, Object?> map) {
  return Yarn(
    id: map["id"] as int,
    collectionId: map["collection_id"] as int,
    color: map["color"] as int,
    brand: map["brand"] as String,
    material: map["material"] as String,
    colorName: map["color_name"] as String,
    minHook: map["min_hook"] as double,
    maxHook: map["max_hook"] as double,
    thickness: map["thickness"] as double,
    nbOfSkeins: map["number_of_skeins"] as int,
    inPatternId: map["in_pattern_id"] as int?,
  );
}

Future<void> insertYarnInDb(Yarn yarn, [Database? db]) async {
  db ??= (await DbService().database);
  if (db != null) {
    final list = await db.query(
      'yarn',
      where: "hash = ?",
      whereArgs: [yarn.hashCode],
    );
    if (list.isEmpty) {
      db.insert(
        'yarn',
        yarn.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      yarn.id = list[0]['id'] as int;
      yarn.nbOfSkeins = (list[0]['number_of_skeins'] as int) + 1;
      updateYarnInDb(yarn);
    }
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> updateYarnInDb(Yarn yarn) async {
  final db = (await DbService().database);
  if (db != null) {
    await db.update(
      'yarn',
      yarn.toMap(),
      where: "id = ?",
      whereArgs: [yarn.id],
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> deleteYarnInDb(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    await db.delete('yarn', where: "id = ?", whereArgs: [id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> deleteYarnsByCollectionId(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    try {
      await db.delete('yarn', where: "collection_id = ?", whereArgs: [id]);
    } catch (e) {
      throw "Can't delete yarn from this collection, it may be used somewhere else";
    }
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<Yarn>> getAllYarn([Database? db]) async {
  db ??= (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> yarnMaps = await db.query('yarn');
    return [for (Map<String, Object?> map in yarnMaps) _fromMap(map)];
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<Yarn> getYarnById(int id, [Database? db]) async {
  db ??= (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> yarnMaps = await db.query(
      'yarn',
      where: "id = ?",
      whereArgs: [id],
    );
    return _fromMap(yarnMaps.first);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<Yarn>> getAllYarnByPatternId(int patternId, [Database? db]) async {
  db ??= (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> connectionsMaps = await db.query(
      'yarn_in_pattern',
      where: "pattern_id = ?",
      whereArgs: [patternId],
    );
    List<Yarn> l = List.empty(growable: true);
    for (final {'yarn_id': yarnId as int, 'in_pattern_id': inPatternId as int?}
        in connectionsMaps) {
      l.add(await getYarnById(yarnId));
      l.last.inPatternId = inPatternId;
    }
    return l;
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<Yarn>> getAllYarnByCollectionId(
  int collectionId, [
  Database? db,
]) async {
  db ??= (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> yarnMaps = await db.query(
      'yarn',
      where: "collection_id = ?",
      whereArgs: [collectionId],
      columns: ['id', 'color', 'color_name', 'number_of_skeins'],
    );
    return [
      for (final {
            'id': yarnId as int,
            'color': color as int,
            'color_name': colorName as String,
            'number_of_skeins': nbSkeins as int,
          }
          in yarnMaps)
        Yarn(
          id: yarnId,
          color: color,
          colorName: colorName,
          nbOfSkeins: nbSkeins,
          collectionId: collectionId,
        ),
    ];
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> removeAllYarn() async {
  final db = (await DbService().database);
  if (db != null) {
    db.rawDelete('DELETE FROM yarn');
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}
