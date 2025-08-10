import 'package:craft_stash/class/yarns/brand.dart';
import 'package:craft_stash/class/yarns/material.dart';
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/data/repository/yarn/brand_repository.dart';
import 'package:craft_stash/data/repository/yarn/material_repository.dart';
import 'package:craft_stash/ui/core/widgets/buttons/int_control_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class YarnForm extends StatefulWidget {
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

  YarnForm({
    super.key,
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

  void changeColor(Color color) {
    setState(() => widget.base.color = color.toARGB32());
  }

  Future<dynamic> _createColorPickerPopup(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Pick a color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: Color(widget.base.color),
            onColorChanged: changeColor,
          ),
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
    if (widget.fromCategory) {
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
    if (widget.fromCategory) {
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

  void increaseSkeins() {
    widget.base.nbOfSkeins += 1;
  }

  void decreaseSkeins() {
    widget.base.nbOfSkeins -= 1;
  }

  Widget _colorSelector() {
    return Row(
      children: [
        Expanded(child: Container(height: 20, color: Color(widget.base.color))),

        TextButton(
          onPressed: widget.readOnly
              ? null
              : () {
                  _createColorPickerPopup(context);
                },
          child: Text(
            widget.readOnly ? widget.base.colorName : "Pick a color",
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        ),
        Expanded(child: Container(height: 20, color: Color(widget.base.color))),
      ],
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
              _colorSelector(),

              getBrandDropdownMenu(),

              getMaterialDropdownMenu(),

              TextFormField(
                decoration: InputDecoration(label: Text("Color name")),
                initialValue: widget.fill ? widget.base.colorName : null,

                style: TextStyle(
                  color: widget.readOnly ? Colors.grey : Colors.black,
                ),
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
                readOnly: widget.readOnly,
              ),

              TextFormField(
                keyboardType: TextInputType.numberWithOptions(),
                readOnly: widget.fromCategory || widget.readOnly,
                style: TextStyle(
                  color: widget.fromCategory ? Colors.grey : Colors.black,
                ),
                decoration: InputDecoration(label: Text("Thickness")),
                initialValue: widget.fill
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
                readOnly: widget.fromCategory || widget.readOnly,
                style: TextStyle(
                  color: widget.fromCategory ? Colors.grey : Colors.black,
                ),
                initialValue: widget.fill
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
                readOnly: widget.fromCategory || widget.readOnly,
                style: TextStyle(
                  color: widget.fromCategory ? Colors.grey : Colors.black,
                ),
                initialValue: widget.fill
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

              ?widget.showSkeins
                  ? IntControlButton(
                      count: widget.base.nbOfSkeins,
                      text: "Skeins",
                      increase: widget.readOnly ? () {} : increaseSkeins,
                      decrease: widget.readOnly ? () {} : decreaseSkeins,
                      signed: false,
                    )
                  : null,
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
          onPressed: () async {
            if (widget.onCancel != null) {
              await widget.onCancel!(widget.base);
            }
            Navigator.pop(context);
          },
          child: Text(widget.cancel),
        ),
        TextButton(
          onPressed: () async {
            if (widget.ifValidFunction != null) {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await widget.ifValidFunction!(widget.base);
              }
            }
            if (widget.updateYarn != null) {
              await widget.updateYarn!();
            }
            Navigator.pop(context);
            setState(() {});
          },
          child: Text(widget.confirm),
        ),
      ],
    );
  }
}
