import 'package:craft_stash/class/yarns/material.dart';
import 'package:craft_stash/data/repository/yarn/material_repository.dart';
import 'package:craft_stash/ui/yarn_form_dialog/yarn_form_dialog_model_abstart.dart';
import 'package:flutter/material.dart';

class MaterialDropdownMenu extends StatelessWidget {
  MaterialDropdownMenu({super.key, required this.model});
  YarnFormDialogModelAbstart model;
  @override
  Widget build(BuildContext context) {
    if (model.materialMenuEntries.isEmpty) return Text("");
    if (model.fromCategory) {
      return TextFormField(
        initialValue: model.base.material,
        readOnly: true,
        style: TextStyle(color: Colors.grey),
      );
    }

    return DropdownMenu(
      label: Text("Material"),
      inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
      expandedInsets: EdgeInsets.all(0),
      dropdownMenuEntries: model.materialMenuEntries,
      initialSelection: model.base.material,
      onSelected: (value) {
        if (value == "New") {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text("New material name"),
              content: TextField(
                onChanged: (value) {
                  value = value.trim();
                  model.base.material = value;
                },
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (!model.materialList.contains(model.base.material)) {
                      await MaterialRepository().insertMaterial(
                        YarnMaterial(name: model.base.material),
                      );
                    }

                    await model.reload();
                    Navigator.pop(context);
                  },
                  child: Text("Add"),
                ),
              ],
            ),
          );
        } else {
          model.base.material = value!;
        }
      },
    );
  }
}
