import 'dart:collection';
import 'dart:ffi';

import 'package:craft_stash/class/yarn.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:flutter/material.dart';

class AddYarnButton extends StatefulWidget {
  final Future<void> Function() updateYarn;

  const AddYarnButton({super.key, required this.updateYarn});

  @override
  State<StatefulWidget> createState() => _AddYarnButton();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _AddYarnButton extends State<AddYarnButton> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> brandList = List.empty(growable: true);
  List<String> materialList = List.empty(growable: true);
  List<MenuEntry> brandMenuEntries = List.empty(growable: true);
  List<MenuEntry> materialMenuEntries = List.empty(growable: true);

  String _brand = "Unknown", _colorName = "Unknown", _material = "Unknown";
  int _color = 0, _nbSkeins = 1;
  double _minHook = 0, _maxHook = 0, _thickness = 0;

  Future<List<String>> getAllBrandsAsList() async {
    final db = (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> yarnMaps = await db.rawQuery(
        "SELECT DISTINCT brand FROM yarn",
      );
      brandList = [for (final {"brand": brand as String} in yarnMaps) brand];
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
    return brandList;
  }

  Future<List<String>> getAllMaterialsAsList() async {
    final db = (await DbService().database);
    if (db != null) {
      final List<Map<String, Object?>> yarnMaps = await db.rawQuery(
        "SELECT DISTINCT material FROM yarn",
      );
      materialList = [
        for (final {"material": material as String} in yarnMaps) material,
      ];
    } else {
      throw DatabaseDoesNotExistException("Could not get database");
    }
    return materialList;
  }

  Future<void> updateDropdownMenuList() async {
    await getAllBrandsAsList();
    await getAllMaterialsAsList();
    brandMenuEntries.clear();
    materialMenuEntries.clear();
    for (String brand in brandList) {
      brandMenuEntries.add(DropdownMenuEntry(value: brand, label: brand));
    }
    brandMenuEntries.add(DropdownMenuEntry(value: "Unknown", label: "Unknown"));
    brandMenuEntries.add(DropdownMenuEntry(value: "New", label: "New"));

    for (String material in materialList) {
      materialMenuEntries.add(
        DropdownMenuEntry(value: material, label: material),
      );
    }
    materialMenuEntries.add(
      DropdownMenuEntry(value: "Unknown", label: "Unknown"),
    );
    materialMenuEntries.add(DropdownMenuEntry(value: "New", label: "New"));
    setState(() {});
  }

  Form _createForm() {
    return Form(
      key: _formKey,
      child: IntrinsicHeight(
        child: Container(
          height: 400,
          width: 300,
          child: ListView(
            //spacing: spacing,
            children: [
              TextFormField(
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
                  _minHook = double.parse(newValue);
                },
              ),
              TextFormField(
                decoration: InputDecoration(label: Text("Color name")),
                validator: (value) {
                  return null;
                },
                onSaved: (newValue) {
                  newValue = newValue?.trim();
                  if (newValue == null || newValue.isEmpty) {
                    newValue = "Unknown";
                  }
                  _colorName = newValue;
                },
              ),
              DropdownMenu(
                inputDecorationTheme: InputDecorationTheme(
                  border: InputBorder.none,
                ),
                expandedInsets: EdgeInsets.all(0),
                dropdownMenuEntries: brandMenuEntries,
                initialSelection: _brand,
                onSelected: (value) {
                  _brand = value!;
                },
              ),

              DropdownMenu(
                inputDecorationTheme: InputDecorationTheme(
                  border: InputBorder.none,
                ),
                expandedInsets: EdgeInsets.all(0),
                dropdownMenuEntries: materialMenuEntries,
                initialSelection: _material,
                onSelected: (value) {
                  _material = value!;
                },
              ),

              TextFormField(
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
                  _thickness = double.parse(newValue);
                },
              ),
              TextFormField(
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
                  _minHook = double.parse(newValue);
                },
              ),
              TextFormField(
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
                  _maxHook = double.parse(newValue);
                },
              ),

              TextFormField(
                keyboardType: TextInputType.numberWithOptions(),
                decoration: InputDecoration(label: Text("Number of skeins")),
                validator: (value) {
                  return null;
                },
                onSaved: (newValue) {
                  newValue = newValue?.trim();
                  if (newValue == null || newValue.isEmpty) {
                    newValue = "1";
                  }
                  _nbSkeins = int.parse(newValue);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> createFormPopup(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add Yarn'),
        content: _createForm(),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await insertYarnInDb(
                  Yarn(
                    color: _color,
                    brand: _brand,
                    material: _material,
                    colorName: _colorName,
                    minHook: _minHook,
                    maxHook: _maxHook,
                    thickness: _thickness,
                    nbOfSkeins: _nbSkeins,
                  ),
                );
              }
              await widget.updateYarn();
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    updateDropdownMenuList();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      onPressed: () => createFormPopup(context),

      style: ButtonStyle(
        side: WidgetStatePropertyAll(
          BorderSide(color: theme.colorScheme.primary, width: 5),
        ),
        shape: WidgetStatePropertyAll(
          RoundedSuperellipseBorder(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(18)),
          ),
        ),

        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
      child: Text(
        "Add yarn",
        style: TextStyle(color: theme.colorScheme.secondary),
        textScaler: TextScaler.linear(1.25),
      ),
    );
  }
}
