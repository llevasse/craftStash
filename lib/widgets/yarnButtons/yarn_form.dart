import 'package:craft_stash/class/brand.dart';
import 'package:craft_stash/class/material.dart';
import 'package:craft_stash/class/yarn.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:craft_stash/widgets/int_control_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class YarnForm extends StatefulWidget {
  final Future<void> Function() updateYarn;
  final Future<void> Function(Yarn) ifValideFunction;
  String confirm;
  String cancel;
  String title;
  Yarn base;
  bool fill;
  bool fromCategory;

  YarnForm({
    super.key,
    required this.base,
    required this.updateYarn,
    required this.ifValideFunction,
    required this.confirm,
    required this.cancel,
    required this.title,
    this.fill = false,
    this.fromCategory = true,
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
    List<Brand> list = await getAllBrand();
    brandList.clear();
    for (Brand element in list) {
      brandList.add(element.name);
    }
    return brandList;
  }

  Future<List<String>> getAllMaterialsAsList() async {
    List<YarnMaterial> list = await getAllYarnMaterial();
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
    if (brandMenuEntries.isEmpty) return Text("");
    if (widget.fromCategory == true) {
      return TextFormField(
        initialValue: widget.base.brand,
        readOnly: true,
        style: TextStyle(color: Colors.grey),
      );
    }
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
                      await insertBrandInDb(Brand(name: widget.base.brand));
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
    if (widget.fromCategory == true) {
      return TextFormField(
        initialValue: widget.base.material,
        readOnly: true,
        style: TextStyle(color: Colors.grey),
      );
    }

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
                      await insertYarnMaterialInDb(
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

  void increaseSkeins() {
    widget.base.nbOfSkeins += 1;
  }

  void decreaseSkeins() {
    widget.base.nbOfSkeins -= 1;
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
                initialValue: widget.fill == true
                    ? widget.base.colorName
                    : null,
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
                readOnly: widget.fromCategory,
                style: TextStyle(
                  color: widget.fromCategory == true
                      ? Colors.grey
                      : Colors.black,
                ),
                decoration: InputDecoration(label: Text("Thickness")),
                initialValue: widget.fill == true
                    ? widget.base.thickness.toStringAsFixed(2)
                    : null,
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
                readOnly: widget.fromCategory,
                style: TextStyle(
                  color: widget.fromCategory == true
                      ? Colors.grey
                      : Colors.black,
                ),
                initialValue: widget.fill == true
                    ? widget.base.minHook.toStringAsFixed(2)
                    : null,
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
                readOnly: widget.fromCategory,
                style: TextStyle(
                  color: widget.fromCategory == true
                      ? Colors.grey
                      : Colors.black,
                ),
                initialValue: widget.fill == true
                    ? widget.base.maxHook.toStringAsFixed(2)
                    : null,
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

              IntControlButton(
                count: widget.base.nbOfSkeins,
                text: "Skeins",
                increase: increaseSkeins,
                decrease: decreaseSkeins,
                signed: false,
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
