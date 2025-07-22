import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class YarnCollection {
  YarnCollection({
    this.id = 0,
    this.name = "Unknown",
    this.brand = "Unknown",
    this.material = "Unknown",
    this.minHook = 0,
    this.maxHook = 0,
    this.thickness = 0,
  });
  int id;
  String name;
  String brand; // ex : "my brand"
  String material; // ex : "coton"
  double thickness; // ex : "3mm"
  double minHook; // ex : "2.5mm"
  double maxHook; // ex : "3.5mm"
  List<Yarn>? yarns;

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "brand": brand,
      "material": material,
      "min_hook": minHook,
      "max_hook": maxHook,
      "thickness": thickness,
      "hash": hashCode,
    };
  }

  @override
  int get hashCode => Object.hash(
    name.toLowerCase(),
    brand.toLowerCase(),
    material.toLowerCase(),
    thickness,
    minHook,
    maxHook,
  );

  @override
  String toString() {
    return toMap().toString();
  }
}

Future<int?> insertYarnCollection(YarnCollection yarn, [Database? db]) async {
  db ??= (await DbService().database);

  if (db != null) {
    final list = await db.query(
      'yarn_collection',
      where: "hash = ?",
      whereArgs: [yarn.hashCode],
    );
    if (list.isEmpty) {
      return db.insert(
        'yarn_collection',
        yarn.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return null;
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> updateYarnCollection(YarnCollection yarn) async {
  final db = (await DbService().database);
  if (db != null) {
    await db.update(
      'yarn_collection',
      yarn.toMap(),
      where: "id = ?",
      whereArgs: [yarn.id],
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> deleteYarnCollection(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    await db.delete('yarn_collection', where: "id = ?", whereArgs: [id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<YarnCollection>> getAllYarnCollection({
  bool getYarn = false,
  Database? db,
}) async {
  db ??= (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> yarnMaps = await db.query(
      'yarn_collection',
    );
    List<YarnCollection> l = List.empty(growable: true);
    for (final {
          'id': id as int,
          "name": name as String,
          "brand": brand as String,
          "material": material as String,
          "min_hook": minHook as double,
          "max_hook": maxHook as double,
          "thickness": thickness as double,
        }
        in yarnMaps) {
      YarnCollection yarnCollection = YarnCollection(
        id: id,
        name: name,
        brand: brand,
        material: material,
        minHook: minHook,
        maxHook: maxHook,
        thickness: thickness,
      );
      if (getYarn) {
        yarnCollection.yarns = await getAllYarnByCollectionId(id);
      }
      l.add(yarnCollection);
    }
    return l;
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> removeAllYarnCollection() async {
  final db = (await DbService().database);
  if (db != null) {
    db.rawDelete('DELETE FROM yarn_collection');
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}
