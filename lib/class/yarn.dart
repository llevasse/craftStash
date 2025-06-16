import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class Yarn {
  Yarn({
    this.id = 0,
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
      "brand": brand,
      "material": material,
      "color_name": colorName,
      "min_hook": minHook,
      "max_hook": maxHook,
      "thickness": thickness,
      "number_of_skeins": nbOfSkeins,
    };
  }
}

Future<void> insertYarnInDb(Yarn yarn) async {
  final db = (await DbService().database);
  if (db != null) {
    db.insert(
      'yarn',
      yarn.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> updateYarnInDb(Yarn yarn) async {
  final db = (await DbService().database);
  if (db != null) {
    db.update('yarn', yarn.toMap(), where: "id = ?", whereArgs: [yarn.id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> deleteYarnInDb(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    db.delete('yarn', where: "id = ?", whereArgs: [id]);
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
