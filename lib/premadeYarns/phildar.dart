import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

Future<void> insertPhildarYarn([Database? db]) async {
  YarnCollection collection = YarnCollection(
    name: "Phil coton 3",
    brand: "Phildar",
    material: "Coton",
    minHook: 2.5,
    maxHook: 3.5,
    thickness: 3,
  );
  int? yarnCollectionId = await insertYarnCollection(collection, db);
  await insertYarnInDb(
    Yarn(
      collectionId: yarnCollectionId as int,
      color: Colors.amber.toARGB32(),
      colorName: "Amber",
      minHook: collection.minHook,
      maxHook: collection.maxHook,
      thickness: collection.thickness,
      brand: collection.brand,
      material: collection.material,
    ),
    db,
  );
  await insertYarnInDb(
    Yarn(
      collectionId: yarnCollectionId,
      color: Colors.red.toARGB32(),
      colorName: "Red",
      minHook: collection.minHook,
      maxHook: collection.maxHook,
      thickness: collection.thickness,
      brand: collection.brand,
      material: collection.material,
    ),
    db,
  );
  await insertYarnInDb(
    Yarn(
      collectionId: yarnCollectionId,
      color: Colors.deepPurple.toARGB32(),
      colorName: "Deep purple",
      minHook: collection.minHook,
      maxHook: collection.maxHook,
      thickness: collection.thickness,
      brand: collection.brand,
      material: collection.material,
    ),
    db,
  );
  print("Created default yarn");
}
