import 'package:craft_stash/class/yarns/brand.dart';
import 'package:craft_stash/class/yarns/material.dart';
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/data/repository/yarn/brand_repository.dart';
import 'package:craft_stash/data/repository/yarn/collection_repository.dart';
import 'package:craft_stash/data/repository/yarn/material_repository.dart';
import 'package:craft_stash/data/repository/yarn/yarn_repository.dart';
import 'package:craft_stash/ui/core/widgets/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';

class CollectionForm extends StatefulWidget {
  final Future<void> Function() updateYarn;
  final Future<void> Function(YarnCollection) ifValideFunction;
  String confirm;
  String cancel;
  String title;
  bool fill;
  bool allowDelete;
  YarnCollection base;

  CollectionForm({
    super.key,
    required this.base,
    required this.updateYarn,
    required this.ifValideFunction,
    required this.confirm,
    required this.cancel,
    required this.title,
    this.fill = false,
    this.allowDelete = false,
  });

  @override
  State<StatefulWidget> createState() => _CollectionForm();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _CollectionForm extends State<CollectionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> brandList = List.empty(growable: true);
  List<String> materialList = List.empty(growable: true);
  List<MenuEntry> brandMenuEntries = List.empty(growable: true);
  List<MenuEntry> materialMenuEntries = List.empty(growable: true);

  Future<List<String>> getAllBrandsAsList() async {
    List<Brand> list = await BrandRepository().getAllBrand();
    brandList.clear();
    for (Brand element in list) {
      brandList.add(element.name);
    }
    return brandList;
  }

  Future<List<String>> getAllMaterialsAsList() async {
    List<YarnMaterial> list = await MaterialRepository().getAllMaterials();
    materialList.clear();
    for (YarnMaterial element in list) {
      materialList.add(element.name);
    }
    return materialList;
  }

  Future<void> updateDropdownMenuList() async {
    await getAllBrandsAsList();
    await getAllMaterialsAsList();
    List<MenuEntry> brandMenuEntriesTmp = List.empty(growable: true);
    List<MenuEntry> materialMenuEntriesTmp = List.empty(growable: true);
    for (String brand in brandList) {
      if (brand == "Unknown") continue;
      brandMenuEntriesTmp.add(DropdownMenuEntry(value: brand, label: brand));
    }
    brandMenuEntriesTmp.add(
      DropdownMenuEntry(value: "Unknown", label: "Unknown"),
    );
    brandMenuEntriesTmp.add(DropdownMenuEntry(value: "New", label: "New"));

    for (String material in materialList) {
      if (material == "Unknown") continue;
      materialMenuEntriesTmp.add(
        DropdownMenuEntry(value: material, label: material),
      );
    }
    materialMenuEntriesTmp.add(
      DropdownMenuEntry(value: "Unknown", label: "Unknown"),
    );
    materialMenuEntriesTmp.add(DropdownMenuEntry(value: "New", label: "New"));
    setState(() {
      brandMenuEntries = brandMenuEntriesTmp;
      materialMenuEntries = materialMenuEntriesTmp;
    });
  }

  Widget getBrandDropdownMenu() {
    if (brandMenuEntries.isEmpty) return Text("");
    return DropdownMenu(
      inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
      expandedInsets: EdgeInsets.all(0),
      dropdownMenuEntries: brandMenuEntries,
      initialSelection: widget.base.brand,

      onSelected: (value) {
        if (value == "New") {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text("New brand name"),
              content: TextField(
                onChanged: (value) {
                  value = value.trim();
                  widget.base.brand = value;
                },
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (!brandList.contains(widget.base.brand)) {
                      await BrandRepository().insertBrand(
                        Brand(name: widget.base.brand),
                      );
                    }

                    Navigator.pop(context);
                    await updateDropdownMenuList();
                    setState(() {});
                  },
                  child: Text("Add"),
                ),
              ],
            ),
          );
        } else {
          widget.base.brand = value!;
        }
      },
    );
  }

  Widget getMaterialDropdownMenu() {
    if (materialMenuEntries.isEmpty) return Text("");

    return DropdownMenu(
      inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
      expandedInsets: EdgeInsets.all(0),
      dropdownMenuEntries: materialMenuEntries,
      initialSelection: widget.base.material,
      onSelected: (value) {
        if (value == "New") {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text("New material name"),
              content: TextField(
                onChanged: (value) {
                  value = value.trim();
                  widget.base.material = value;
                },
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await getAllMaterialsAsList();
                    if (!materialList.contains(widget.base.material)) {
                      await MaterialRepository().insertMaterial(
                        YarnMaterial(name: widget.base.material),
                      );
                    }

                    Navigator.pop(context);
                    await updateDropdownMenuList();
                    setState(() {});
                  },
                  child: Text("Add"),
                ),
              ],
            ),
          );
        } else {
          widget.base.material = value!;
        }
      },
    );
  }

  Form _createForm() {
    return Form(
      key: _formKey,
      child: IntrinsicHeight(
        child: SizedBox(
          height: 410,
          width: 300,
          child: ListView(
            //spacing: spacing,
            children: [
              TextFormField(
                initialValue: widget.fill == true ? widget.base.name : null,
                decoration: InputDecoration(label: Text("Collection name")),
                validator: (value) {
                  return null;
                },
                onSaved: (newValue) {
                  newValue = newValue?.trim();
                  if (newValue == null || newValue.isEmpty) {
                    newValue = "Unknown";
                  }
                  widget.base.name = newValue;
                },
              ),

              getBrandDropdownMenu(),

              getMaterialDropdownMenu(),

              TextFormField(
                initialValue: widget.fill == true
                    ? widget.base.thickness.toStringAsFixed(2)
                    : null,
                keyboardType: TextInputType.numberWithOptions(),
                decoration: InputDecoration(label: Text("Thickness")),
                validator: (value) {
                  return null;
                },
                onSaved: (newValue) {
                  newValue = newValue?.trim();
                  if (newValue == null || newValue.isEmpty) {
                    newValue = "0.0";
                  }
                  widget.base.thickness = double.parse(newValue);
                },
              ),

              TextFormField(
                initialValue: widget.fill == true
                    ? widget.base.minHook.toStringAsFixed(2)
                    : null,
                keyboardType: TextInputType.numberWithOptions(),
                decoration: InputDecoration(label: Text("Min hook size")),
                validator: (value) {
                  return null;
                },
                onSaved: (newValue) {
                  newValue = newValue?.trim();
                  if (newValue == null || newValue.isEmpty) {
                    newValue = "0.0";
                  }
                  widget.base.minHook = double.parse(newValue);
                },
              ),

              TextFormField(
                initialValue: widget.fill == true
                    ? widget.base.maxHook.toStringAsFixed(2)
                    : null,
                keyboardType: TextInputType.numberWithOptions(),
                decoration: InputDecoration(label: Text("Max hook size")),
                validator: (value) {
                  return null;
                },
                onSaved: (newValue) {
                  newValue = newValue?.trim();
                  if (newValue == null || newValue.isEmpty) {
                    newValue = "0.0";
                  }
                  widget.base.maxHook = double.parse(newValue);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    updateDropdownMenuList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: _createForm(),
      actions: <Widget>[
        if (widget.allowDelete)
          TextButton(
            onPressed: () async {
              if (await showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(
                        "Do you want to delete this coletion and all it's yarns",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              await YarnRepository().deleteYarnsByCollectionId(
                                widget.base.id,
                              );
                              await CollectionRepository().deleteYarnCollection(
                                widget.base.id,
                              );
                              await widget.updateYarn();
                            } catch (e) {
                              await showDialog(
                                context: context,
                                builder: (context) =>
                                    ErrorDialog(error: e.toString()),
                              );
                            }
                            Navigator.pop(context, "delete");
                          },
                          child: Text("Delete"),
                        ),
                      ],
                    ),
                  ) ==
                  "delete") {
                Navigator.pop(context);
              }
            },
            child: Text("Delete"),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.cancel),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              await widget.ifValideFunction(widget.base);
            }
            await widget.updateYarn();
            Navigator.pop(context);
            setState(() {});
          },
          child: Text(widget.confirm),
        ),
      ],
    );
  }
}
