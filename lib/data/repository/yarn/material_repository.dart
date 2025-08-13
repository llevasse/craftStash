import 'package:craft_stash/class/yarns/material.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class MaterialRepository {
  static const _tablename = "material";
  const MaterialRepository();
  Future<void> insertMaterial(YarnMaterial yarnMaterial, [Database? db]) async {
    db ??= (await DbService().database);
    if (db != null) {
      final list = await db.query(
        _tablename,
        where: "hash = ?",
        whereArgs: [yarnMaterial.hashCode],
      );
      if (list.isEmpty) {
        await db.insert(
          _tablename,
          yarnMaterial.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> updateMaterial(YarnMaterial yarnMaterial) async {
    final db = (await DbService().database);
    if (db != null) {
      await db.update(
        _tablename,
        yarnMaterial.toMap(),
        where: "id = ?",
        whereArgs: [yarnMaterial.id],
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> deleteMaterial(int id) async {
    final db = (await DbService().database);
    if (db != null) {
      await db.delete(_tablename, where: "id = ?", whereArgs: [id]);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<List<YarnMaterial>> getAllMaterials() async {
    final db = (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> yarnMaterialMaps = await db.query(
        _tablename,
      );
      return [
        for (final {'id': id as int, "name": name as String}
            in yarnMaterialMaps)
          YarnMaterial(id: id, name: name),
      ];
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> removeAllMaterials() async {
    final db = (await DbService().database);
    if (db != null) {
      await db.rawDelete('DELETE FROM $_tablename');
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }
}
