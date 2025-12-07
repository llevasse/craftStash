import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/data/repository/pattern/pattern_detail_repository.dart';
import 'package:craft_stash/data/repository/pattern/pattern_row_repository.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class StitchRepository {
  static const String _tableName = "stitch";
  const StitchRepository();

  Stitch _fromMap(Map<String, Object?> map) {
    return Stitch(
      id: map["id"] as int,
      abreviation: map["abreviation"] as String,
      name: map["name"] as String?,
      description: map["description"] as String?,
      isSequence: map["is_sequence"] as int,
      sequenceId: map["sequence_id"] as int?,
      hidden: map["hidden"] as int,
      stitchNb: map['stitch_nb'] as int,
      nbStsTaken: map['nb_of_stitches_taken'] != null
          ? (map['nb_of_stitches_taken'] as int)
          : 1,
    );
  }

  Future<void> setStitchToIdMap([Database? db]) async {
    List<Stitch> l = await getAllStitches(db);
    stitchToIdMap.clear();
    for (Stitch s in l) {
      stitchToIdMap.addAll({s.abreviation: s.id});
    }
  }

  Future<void> insertDefaultStitches([Database? db]) async {
    List<Stitch> stitches = [
      Stitch(
        abreviation: "ch",
        name: "chain",
        description: null,
        nbStsTaken: 0,
      ),
      Stitch(abreviation: "sl st", name: "slip stitch", description: null),
      Stitch(abreviation: "sc", name: "single crochet", description: null),
      Stitch(
        abreviation: "hdc",
        name: "half double crochet",
        description: null,
      ),
      Stitch(abreviation: "dc", name: "double crochet", description: null),
      Stitch(abreviation: "tr", name: "treble crochet", description: null),
      Stitch(
        abreviation: "inc",
        name: "increase",
        description: null,
        stitchNb: 2,
      ),
      Stitch(
        abreviation: "dec",
        name: "decrease",
        description: null,
        nbStsTaken: 2,
      ),
      Stitch(abreviation: "sk", name: "skip", description: null, stitchNb: 0),
      Stitch(
        abreviation: "color change",
        name: null,
        description: null,
        hidden: 1,
        stitchNb: 0,
      ),
      Stitch(
        abreviation: "start color",
        name: null,
        description: null,
        hidden: 1,
        stitchNb: 0,
      ),
    ];
    for (Stitch s in stitches) {
      s.id = await insertStitch(s, db);
      stitchToIdMap[s.abreviation] = s.id;
    }
    await _insertScInc(stitches: stitches, db: db);
    await _insertScDec(stitches: stitches, db: db);
    print("INSERTED DEFAULT STITCHES");
  }

  Future<void> _insertScInc({
    required List<Stitch> stitches,
    Database? db,
  }) async {
    PatternRow row = PatternRow(
      startRow: 0,
      numberOfRows: 0,
      stitchesPerRow: 3,
    );
    row.rowId = await PatternRowRepository().insertRow(patternRow: row, db: db);
    row.details = [
      PatternRowDetail(rowId: row.rowId, stitchId: stitches[2].id),
      PatternRowDetail(rowId: row.rowId, stitchId: stitches[6].id),
    ];
    for (PatternRowDetail e in row.details) {
      if (e.repeatXTime != 0) {
        e.rowId = row.rowId;
        await PatternDetailRepository().insertDetail(e, db);
      }
    }
    await insertStitch(
      Stitch(
        abreviation: "(sc, inc)",
        name: null,
        description: null,
        isSequence: 1,
        sequenceId: row.rowId,
        stitchNb: 3,
        nbStsTaken: 2,
      ),
      db,
    );
  }

  Future<void> _insertScDec({
    required List<Stitch> stitches,
    Database? db,
  }) async {
    PatternRow row = PatternRow(
      startRow: 0,
      numberOfRows: 0,
      stitchesPerRow: 2,
    );
    row.rowId = await PatternRowRepository().insertRow(patternRow: row, db: db);
    row.details = [
      PatternRowDetail(rowId: row.rowId, stitchId: stitches[2].id),
      PatternRowDetail(rowId: row.rowId, stitchId: stitches[7].id),
    ];
    for (PatternRowDetail e in row.details) {
      if (e.repeatXTime != 0) {
        e.rowId = row.rowId;
        await PatternDetailRepository().insertDetail(e, db);
      }
    }
    await insertStitch(
      Stitch(
        abreviation: "(sc, dec)",
        name: null,
        description: null,
        isSequence: 1,
        sequenceId: row.rowId,
        stitchNb: 2,
        nbStsTaken: 3,
      ),
      db,
    );
  }

  Future<int> insertStitch(Stitch stitch, [Database? db]) async {
    db ??= (await DbService().database);
    if (db != null) {
      final list = await db.query(
        _tableName,
        where: "hash = ?",
        whereArgs: [stitch.hashCode],
      );
      if (list.isNotEmpty) {
        throw StitchAlreadyExist(
          "Stitch with hash ${stitch.hashCode} already exist",
        );
      }
      return await db.insert(
        _tableName,
        stitch.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> insertStitchWithDefinedId(Stitch stitch, [Database? db]) async {
    db ??= (await DbService().database);
    if (db != null) {
      Map<String, Object?> m = stitch.toMap();
      m.addAll({'id': stitch.id});
      await db.insert(
        _tableName,
        m,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> updateStitch(Stitch stitch) async {
    final db = (await DbService().database);
    if (db != null) {
      await db.update(
        _tableName,
        stitch.toMap(),
        where: "id = ?",
        whereArgs: [stitch.id],
      );
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<void> deleteStitch(Stitch stitch) async {
    final db = (await DbService().database);
    if (db != null) {
      if ((await PatternDetailRepository().getAllDetailsByStitch(
        stitch,
      )).isNotEmpty) {
        throw StitchIsUsed(
          "Can't delete a stitch that is currently used in a pattern.",
        );
      }
      await db.delete(_tableName, where: "id = ?", whereArgs: [stitch.id]);
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<List<Stitch>> getAllStitches([Database? db]) async {
    db ??= (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> stitchMaps = await db.query(_tableName);
      List<Stitch> l = List.empty(growable: true);
      for (Map<String, Object?> map in stitchMaps) {
        l.add(_fromMap(map));
        if (l.last.sequenceId != null) {
          l.last.row = await PatternRowRepository().getRowById(
            id: l.last.sequenceId!,
            db: db,
          );
        }
      }
      return l;
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<List<Stitch>> getAllVisibleStitches([Database? db]) async {
    db ??= (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> stitchMaps = await db.query(
        _tableName,
        where: "hidden = ?",
        whereArgs: [0],
      );
      List<Stitch> l = List.empty(growable: true);
      for (Map<String, Object?> map in stitchMaps) {
        l.add(_fromMap(map));
        if (l.last.sequenceId != null) {
          l.last.row = await PatternRowRepository().getRowById(
            id: l.last.sequenceId!,
            db: db,
          );
        }
      }
      return l;
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<Stitch> getStitchById(int id, [Database? db]) async {
    db ??= (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> stitchMaps = await db.query(
        _tableName,
        where: "id = ?",
        whereArgs: [id],
        limit: 1,
      );
      if (stitchMaps.isEmpty) {
        throw DatabaseNoElementsMeetConditionException("id = $id", _tableName);
      }
      Stitch s = _fromMap(stitchMaps.first);
      if (s.isSequence != 0 && s.sequenceId != null) {
        s.row = await PatternRowRepository().getRowById(
          id: s.sequenceId!,
          db: db,
        );
      }
      return s;
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }

  Future<Map<int, Stitch>> getAllStitchMappedById([Database? db]) async {
    List<Stitch> l = await getAllStitches(db);
    Map<int, Stitch> stitchesMap = {};
    for (Stitch s in l) {
      stitchesMap.addAll({s.id: s});
    }
    return stitchesMap;
  }

  Future<void> removeAllStitch() async {
    final db = (await DbService().database);
    if (db != null) {
      db.rawDelete('DELETE FROM stitch');
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
  }
}

class StitchAlreadyExist implements Exception {
  StitchAlreadyExist(this.cause);
  String cause;
}

class StitchIsUsed implements Exception {
  StitchIsUsed(this.cause);
  String cause;
}
