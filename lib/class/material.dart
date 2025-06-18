import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class YarnMaterial {
  YarnMaterial({this.id = 0, required this.name});
  int id;
  String name;

  Map<String, dynamic> toMap() {
    return {'name': name, "hash": hashCode};
  }

  @override
  int get hashCode => Object.hash(name.toLowerCase(), 0);
}

Future<void> insertYarnMaterialInDb(YarnMaterial yarnMaterial) async {
  final db = (await DbService().database);
  if (db != null) {
    final list = await db.query(
      'material',
      where: "hash = ?",
      whereArgs: [yarnMaterial.hashCode],
    );
    if (list.isEmpty) {
      db.insert(
        'material',
        yarnMaterial.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> updateYarnMaterialInDb(YarnMaterial yarnMaterial) async {
  final db = (await DbService().database);
  if (db != null) {
    db.update(
      'material',
      yarnMaterial.toMap(),
      where: "id = ?",
      whereArgs: [yarnMaterial.id],
    );
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> deleteYarnMaterialInDb(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    db.delete('material', where: "id = ?", whereArgs: [id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<YarnMaterial>> getAllYarnMaterial() async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> yarnMaterialMaps = await db.query(
      'material',
    );
    return [
      for (final {'id': id as int, "name": name as String} in yarnMaterialMaps)
        YarnMaterial(id: id, name: name),
    ];
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> removeAllYarnMaterial() async {
  final db = (await DbService().database);
  if (db != null) {
    db.rawDelete('DELETE FROM material');
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}
