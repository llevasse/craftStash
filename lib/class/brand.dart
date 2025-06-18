import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class Brand {
  Brand({this.id = 0, required this.name});
  int id;
  String name;

  Map<String, dynamic> toMap() {
    return {'name': name, "hash": hashCode};
  }

  @override
  int get hashCode => Object.hash(name.toLowerCase(), 0);
}

Future<void> insertBrandInDb(Brand brand) async {
  final db = (await DbService().database);
  if (db != null) {
    final list = await db.query(
      'brand',
      where: "hash = ?",
      whereArgs: [brand.hashCode],
    );
    if (list.isEmpty) {
      db.insert(
        'brand',
        brand.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> updateBrandInDb(Brand brand) async {
  final db = (await DbService().database);
  if (db != null) {
    db.update('brand', brand.toMap(), where: "id = ?", whereArgs: [brand.id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<void> deleteBrandInDb(int id) async {
  final db = (await DbService().database);
  if (db != null) {
    db.delete('brand', where: "id = ?", whereArgs: [id]);
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}

Future<List<Brand>> getAllBrand() async {
  final db = (await DbService().database);
  if (db != null) {
    final List<Map<String, Object?>> brandMaps = await db.query('brand');
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
    db.rawDelete('DELETE FROM brand');
  } else {
    throw DatabaseDoesNotExistException("Could not get database");
  }
}
