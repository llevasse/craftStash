import 'package:craft_stash/class/yarn.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class YarnForm extends StatefulWidget {
  final Future<void> Function() updateYarn;
  final Future<void> Function(Yarn) ifValideFunction;
  String confirm;
  String cancel;
  String title;
  Yarn base;

  YarnForm({
    super.key,
    required this.base,
    required this.updateYarn,
    required this.ifValideFunction,
    required this.confirm,
    required this.cancel,
    required this.title,
  });

  @override
  State<StatefulWidget> createState() => _YarnForm();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _YarnForm extends State<YarnForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> brandList = List.empty(growable: true);
  List<String> materialList = List.empty(growable: true);
  List<MenuEntry> brandMenuEntries = List.empty(growable: true);
  List<MenuEntry> materialMenuEntries = List.empty(growable: true);

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
    List<MenuEntry> brandMenuEntriesTmp = List.empty(growable: true);
    List<MenuEntry> materialMenuEntriesTmp = List.empty(growable: true);
    for (String brand in brandList) {
      brandMenuEntriesTmp.add(DropdownMenuEntry(value: brand, label: brand));
    }
    brandMenuEntriesTmp.add(
      DropdownMenuEntry(value: "Unknown", label: "Unknown"),
    );
    brandMenuEntriesTmp.add(DropdownMenuEntry(value: "New", label: "New"));

    for (String material in materialList) {
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

  void changeColor(Color color) {
    setState(() => widget.base.color = color.toARGB32());
  }

  Future<dynamic> _createColorPickerPopup(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Pick a color"),
        content: ColorPicker(
          pickerColor: Color(widget.base.color),
          onColorChanged: changeColor,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: Text("Select"),
          ),
        ],
      ),
    );
  }

  Widget getBrandDropdownMenu() {
    return DropdownMenu(
      inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
      expandedInsets: EdgeInsets.all(0),
      dropdownMenuEntries: brandMenuEntries,
      initialSelection: widget.base.brand,
      onSelected: (value) {
        widget.base.brand = value!;
      },
    );
  }

  Widget getMaterialDropdownMenu() {
    return DropdownMenu(
      inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
      expandedInsets: EdgeInsets.all(0),
      dropdownMenuEntries: materialMenuEntries,
      initialSelection: widget.base.material,
      onSelected: (value) {
        widget.base.material = value!;
      },
    );
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
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 20,
                      color: Color(widget.base.color),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      _createColorPickerPopup(context);
                    },
                    child: const Text(
                      "Pick a color",
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 20,
                      color: Color(widget.base.color),
                    ),
                  ),
                ],
              ),

              getBrandDropdownMenu(),

              getMaterialDropdownMenu(),

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
                  widget.base.colorName = newValue;
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
                  widget.base.thickness = double.parse(newValue);
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
                  widget.base.minHook = double.parse(newValue);
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
                  widget.base.maxHook = double.parse(newValue);
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
                  widget.base.nbOfSkeins = int.parse(newValue);
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
