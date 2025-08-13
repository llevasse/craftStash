import 'package:craft_stash/class/yarns/brand.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class BrandRepository {
  static const _tablename = "brand";
  const BrandRepository();

  Future<void> insertBrand(Brand brand, [Database? db]) async {
    db ??= (await DbService().database);
    if (db != null) {
      final list = await db.query(
        'brand',
        where: "hash = ?",
        whereArgs: [brand.hashCode],
      );
      if (list.isEmpty) {
        await db.insert(
          'brand',
          brand.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> updateBrand(Brand brand) async {
    final db = (await DbService().database);
    if (db != null) {
      await db.update(
        _tablename,
        brand.toMap(),
        where: "id = ?",
        whereArgs: [brand.id],
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> deleteBrand(int id) async {
    final db = (await DbService().database);
    if (db != null) {
      await db.delete(_tablename, where: "id = ?", whereArgs: [id]);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<List<Brand>> getAllBrand() async {
    final db = (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> brandMaps = await db.query(_tablename);
      return [
        for (final {'id': id as int, "name": name as String} in brandMaps)
          Brand(id: id, name: name),
      ];
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> removeAllBrand() async {
    final db = (await DbService().database);
    if (db != null) {
      await db.rawDelete('DELETE FROM $_tablename');
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }
}
