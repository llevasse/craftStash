import 'package:craft_stash/class/brand.dart';
import 'package:craft_stash/class/material.dart';
import 'package:craft_stash/class/yarn_collection.dart';
import 'package:flutter/material.dart';

class CollectionForm extends StatefulWidget {
  final Future<void> Function() updateYarn;
  final Future<void> Function(YarnCollection) ifValideFunction;
  String confirm;
  String cancel;
  String title;
  YarnCollection base;

  CollectionForm({
    super.key,
    required this.base,
    required this.updateYarn,
    required this.ifValideFunction,
    required this.confirm,
    required this.cancel,
    required this.title,
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
                  widget.base.material = value;
                },
              ),
              actions: [
                TextButton(
                  onPressed: () async {
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
