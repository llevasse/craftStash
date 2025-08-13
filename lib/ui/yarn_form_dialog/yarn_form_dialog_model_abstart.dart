import 'package:craft_stash/class/yarns/brand.dart';
import 'package:craft_stash/class/yarns/material.dart';
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/data/repository/yarn/brand_repository.dart';
import 'package:craft_stash/data/repository/yarn/material_repository.dart';
import 'package:flutter/material.dart';

typedef MenuEntry = DropdownMenuEntry<String>;

abstract class YarnFormDialogModelAbstart extends ChangeNotifier {
  final Future<void> Function()? updateYarn;
  final Future<void> Function(Yarn)? ifValidFunction;
  final Future<void> Function(Yarn)? onCancel;
  String confirm;
  String cancel;
  String title;
  Yarn base;
  bool fill;
  bool readOnly;
  bool fromCategory;
  bool showSkeins;
  bool isCollection;
  bool allowDelete;

  YarnFormDialogModelAbstart({
    required this.base,
    this.updateYarn,
    this.ifValidFunction,
    this.onCancel,
    required this.confirm,
    required this.cancel,
    required this.title,
    this.fill = false,
    this.readOnly = false,
    this.fromCategory = true,
    this.showSkeins = true,
    this.allowDelete = false,
    this.isCollection = false,
  });

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<String> brandList = List.empty(growable: true);
  List<String> materialList = List.empty(growable: true);
  List<MenuEntry> brandMenuEntries = List.empty(growable: true);
  List<MenuEntry> materialMenuEntries = List.empty(growable: true);

  double spacing = 5;

  bool loaded = false;

  Future<void> load() async {
    await getAllBrandsAsList();
    await getAllMaterialsAsList();
    loaded = true;
    notifyListeners();
  }

  Future<void> reload() async {
    loaded = false;
    notifyListeners();
    await load();
  }

  Future<List<String>> getAllBrandsAsList() async {
    List<Brand> list = await BrandRepository().getAllBrand();
    brandList.clear();
    brandMenuEntries.clear();

    brandMenuEntries.add(DropdownMenuEntry(value: "Unknown", label: "Unknown"));
    brandMenuEntries.add(DropdownMenuEntry(value: "New", label: "New"));

    for (Brand element in list) {
      if (element.name == "Unknown") continue;
      brandMenuEntries.add(
        DropdownMenuEntry(value: element.name, label: element.name),
      );

      brandList.add(element.name);
    }

    return brandList;
  }

  Future<List<String>> getAllMaterialsAsList() async {
    List<YarnMaterial> list = await MaterialRepository().getAllMaterials();
    materialList.clear();
    materialMenuEntries.clear();

    materialMenuEntries.add(
      DropdownMenuEntry(value: "Unknown", label: "Unknown"),
    );
    materialMenuEntries.add(DropdownMenuEntry(value: "New", label: "New"));

    for (YarnMaterial element in list) {
      if (element.name == "Unknown") continue;
      materialMenuEntries.add(
        DropdownMenuEntry(value: element.name, label: element.name),
      );
      materialList.add(element.name);
    }
    return materialList;
  }

  void increaseSkeins() {
    base.nbOfSkeins += 1;
  }

  void decreaseSkeins() {
    base.nbOfSkeins -= 1;
  }

  void setColor(Color color) {
    base.color = color.toARGB32();
  }

  void setNbSkeins(int value) {
    base.nbOfSkeins = value;
  }
}
