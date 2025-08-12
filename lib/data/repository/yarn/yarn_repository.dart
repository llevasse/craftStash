import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class YarnRepository {
  static const _tablename = "yarn";
  const YarnRepository();

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
      inPreviewId: map["in_preview_id"] as int?,
    );
  }

  Future<void> insertYarn(Yarn yarn, [Database? db]) async {
    db ??= (await DbService().database);
    if (db != null) {
      final list = await db.query(
        _tablename,
        where: "hash = ?",
        whereArgs: [yarn.hashCode],
      );
      if (list.isEmpty) {
        db.insert(
          _tablename,
          yarn.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        yarn.id = list[0]['id'] as int;
        yarn.nbOfSkeins = (list[0]['number_of_skeins'] as int) + 1;
        updateYarn(yarn);
      }
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> updateYarn(Yarn yarn) async {
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

  Future<void> deleteYarn(int id) async {
    final db = (await DbService().database);
    if (db != null) {
      await db.delete(_tablename, where: "id = ?", whereArgs: [id]);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> deleteYarnsByCollectionId(int id) async {
    final db = (await DbService().database);
    if (db != null) {
      try {
        await db.delete(
          _tablename,
          where: "collection_id = ?",
          whereArgs: [id],
        );
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
      final List<Map<String, Object?>> yarnMaps = await db.query(_tablename);
      return [for (Map<String, Object?> map in yarnMaps) _fromMap(map)];
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<Yarn> getYarnById(int id, [Database? db]) async {
    db ??= (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> yarnMaps = await db.query(
        _tablename,
        where: "id = ?",
        whereArgs: [id],
      );
      return _fromMap(yarnMaps.first);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<List<Yarn>> getAllYarnByPatternId(
    int patternId, [
    Database? db,
  ]) async {
    db ??= (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> connectionsMaps = await db.query(
        'yarn_in_pattern',
        where: "pattern_id = ?",
        whereArgs: [patternId],
      );
      List<Yarn> l = List.empty(growable: true);
      for (final {
            'yarn_id': yarnId as int,
            'in_preview_id': inPreviewId as int?,
          }
          in connectionsMaps) {
        l.add(await getYarnById(yarnId));
        l.last.inPreviewId = inPreviewId;
      }
      return l;
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<List<Yarn>> getAllYarnByWipId(int wipId, [Database? db]) async {
    db ??= (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> connectionsMaps = await db.query(
        'yarn_in_wip',
        where: "wip_id = ?",
        whereArgs: [wipId],
      );
      List<Yarn> l = List.empty(growable: true);
      for (final {
            'yarn_id': yarnId as int,
            'in_preview_id': inPreviewId as int?,
          }
          in connectionsMaps) {
        l.add(await getYarnById(yarnId));
        l.last.inPreviewId = inPreviewId;
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
        _tablename,
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
      db.rawDelete('DELETE FROM $_tablename');
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }
}
