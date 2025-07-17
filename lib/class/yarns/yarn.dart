import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class Yarn {
  Yarn({
    this.id = 0,
    this.collectionId = -1,
    required this.color,
    this.brand = "Unknown",
    this.material = "Unknown",
    this.colorName = "Unknown",
    this.minHook = 0,
    this.maxHook = 0,
    this.thickness = 0,
    this.nbOfSkeins = 1,
  });
  int id;
  int collectionId;
  String brand; // ex : "my brand"
  String material; // ex : "coton"
  String colorName; // ex : "ocean"
  double thickness; // ex : "3mm"
  double minHook; // ex : "2.5mm"
  double maxHook; // ex : "3.5mm"
  int color; // ex : 0xFFFFC107
  int nbOfSkeins; // ex : 1

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
      updateYarnInDb(
        Yarn(
          id: list[0]['id'] as int,
          color: list[0]['color'] as int,
          collectionId: list[0]['collection_id'] as int,
          brand: list[0]['brand'] as String,
          material: list[0]['material'] as String,
          colorName: list[0]['color_name'] as String,
          minHook: list[0]['min_hook'] as double,
          maxHook: list[0]['max_hook'] as double,
          thickness: list[0]['thickness'] as double,
          nbOfSkeins: (list[0]['number_of_skeins'] as int) + 1,
        ),
      );
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
    await db.delete('yarn', where: "collection_id = ?", whereArgs: [id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<Yarn>> getAllYarn() async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> yarnMaps = await db.query('yarn');
    return [
      for (final {
            'id': id as int,
            "collection_id": collentionId as int,
            "color": color as int,
            "brand": brand as String,
            "material": material as String,
            "color_name": colorName as String,
            "min_hook": minHook as double,
            "max_hook": maxHook as double,
            "thickness": thickness as double,
            "number_of_skeins": nbOfSkeins as int,
          }
          in yarnMaps)
        Yarn(
          id: id,
          collectionId: collentionId,
          color: color,
          brand: brand,
          material: material,
          colorName: colorName,
          minHook: minHook,
          maxHook: maxHook,
          thickness: thickness,
          nbOfSkeins: nbOfSkeins,
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
