import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/data/repository/yarn/yarn_repository.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class CollectionRepository {
  static const _tablename = "yarn_collection";
  const CollectionRepository();

  Future<int?> insertYarnCollection(YarnCollection yarn, [Database? db]) async {
    db ??= (await DbService().database);

    if (db != null) {
      final list = await db.query(
        _tablename,
        where: "hash = ?",
        whereArgs: [yarn.hashCode],
      );
      if (list.isEmpty) {
        return db.insert(
          _tablename,
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
        _tablename,
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
      await db.delete(_tablename, where: "id = ?", whereArgs: [id]);
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
      final List<Map<String, Object?>> yarnMaps = await db.query(_tablename);
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
          yarnCollection.yarns = await YarnRepository()
              .getAllYarnByCollectionId(id);
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
      db.rawDelete('DELETE FROM $_tablename');
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }
}
