import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:flutter/material.dart';

class Yarn extends YarnCollection {
  Yarn({
    super.id,
    super.name,
    super.brand,
    super.material,
    super.minHook,
    super.maxHook,
    super.thickness,
    this.collectionId,
    this.color = 0xFFFFC107,
    this.colorName = "Unknown",
    this.nbOfSkeins = 1,
    this.inPreviewId,
  });
  int? collectionId;
  String colorName; // ex : "ocean"
  int color; // ex : 0xFFFFC107
  int nbOfSkeins; // ex : 1
  int? inPreviewId;

  @override
  String toString() {
    return ("color: $color\ncollection_id: $collectionId\nbrand: $brand\nmaterial: $material\ncolor_name: $colorName\nmin_hook: $minHook\nmax_hook: $maxHook\nthickness: $thickness\nnumber_of_skeins: $nbOfSkeins\nhash: $hashCode\n");
  }

  Map<String, dynamic> toMap() {
    return {
      "color": color,
      "collection_id": collectionId,
      "brand": brand,
      "material": material,
      "color_name": colorName,
      "min_hook": minHook,
      "max_hook": maxHook,
      "thickness": thickness,
      "number_of_skeins": nbOfSkeins,
      "hash": hashCode,
      "in_preview_id": inPreviewId,
    };
  }

  @override
  int get hashCode => Object.hash(
    color,
    brand.toLowerCase(),
    collectionId,
    colorName.toLowerCase(),
    material.toLowerCase(),
    maxHook,
    minHook,
    thickness,
  );

  YarnCollection toCollection() {
    return YarnCollection(
      id: id,
      name: name,
      brand: brand,
      material: material,
      thickness: thickness,
      minHook: minHook,
      maxHook: maxHook,
    );
  }
}
