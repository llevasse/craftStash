import 'package:craft_stash/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class Yarn {
  Yarn({
    this.id = 0,
    this.collectionId,
    required this.color,
    this.brand = "Unknown",
    this.material = "Unknown",
    this.colorName = "Unknown",
    this.minHook = 0,
    this.maxHook = 0,
    this.thickness = 0,
    this.nbOfSkeins = 1,
    this.inPreviewId,
  });
  int id;
  int? collectionId;
  String brand; // ex : "my brand"
  String material; // ex : "coton"
  String colorName; // ex : "ocean"
  double thickness; // ex : "3mm"
  double minHook; // ex : "2.5mm"
  double maxHook; // ex : "3.5mm"
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
}
