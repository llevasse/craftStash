import 'package:craft_stash/class/yarns/brand.dart';
import 'package:craft_stash/class/yarns/material.dart';
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/data/repository/yarn/brand_repository.dart';
import 'package:craft_stash/data/repository/yarn/collection_repository.dart';
import 'package:craft_stash/data/repository/yarn/material_repository.dart';
import 'package:craft_stash/data/repository/yarn/yarn_repository.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

Future<void> insertPhildarYarn([Database? db]) async {
  BrandRepository().insertBrand(Brand(name: "Phildar"), db);
  MaterialRepository().insertMaterial(YarnMaterial(name: "Coton"), db);
  YarnCollection collection = YarnCollection(
    name: "Phil coton 3",
    brand: "Phildar",
    material: "Coton",
    minHook: 2.5,
    maxHook: 3.5,
    thickness: 3,
  );
  int? yarnCollectionId = await CollectionRepository().insertYarnCollection(
    collection,
    db,
  );
  await YarnRepository().insertYarn(
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
  await YarnRepository().insertYarn(
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
  await YarnRepository().insertYarn(
    Yarn(
      collectionId: yarnCollectionId,
      color: Colors.brown.shade900.toARGB32(),
      colorName: "Brown",
      minHook: collection.minHook,
      maxHook: collection.maxHook,
      thickness: collection.thickness,
      brand: collection.brand,
      material: collection.material,
    ),
    db,
  );
  await YarnRepository().insertYarn(
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
