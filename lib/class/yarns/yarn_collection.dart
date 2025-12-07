import 'package:craft_stash/class/yarns/yarn.dart';

class YarnCollection {
  YarnCollection({
    this.id = 0,
    this.name = "Unknown",
    this.brand = "Unknown",
    this.material = "Unknown",
    this.minHook = 0,
    this.maxHook = 0,
    this.thickness = 0,
  });
  int id;
  String name;
  String brand; // ex : "my brand"
  String material; // ex : "coton"
  double thickness; // ex : "3mm"
  double minHook; // ex : "2.5mm"
  double maxHook; // ex : "3.5mm"
  List<Yarn>? yarns;

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "brand": brand,
      "material": material,
      "min_hook": minHook,
      "max_hook": maxHook,
      "thickness": thickness,
      "hash": hashCode,
    };
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> obj = toMap();
    obj.remove('hash');
    return obj; 
  }

  @override
  int get hashCode => Object.hash(
    name.toLowerCase(),
    brand.toLowerCase(),
    material.toLowerCase(),
    thickness,
    minHook,
    maxHook,
  );

  @override
  String toString() {
    return toMap().toString();
  }

  Yarn toYarn() {
    return Yarn(
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
