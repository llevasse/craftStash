import 'package:craft_stash/class/yarns/brand.dart';
import 'package:craft_stash/data/repository/yarn/brand_repository.dart';
import 'package:craft_stash/ui/yarn_form_dialog/yarn_form_dialog_model_abstart.dart';
import 'package:flutter/material.dart';

class BrandDropdownMenu extends StatelessWidget {
  BrandDropdownMenu({super.key, required this.model});
  YarnFormDialogModelAbstart model;
  @override
  Widget build(BuildContext context) {
    if (model.brandMenuEntries.isEmpty) return Text("");
    if (model.fromCategory) {
      return TextFormField(
        initialValue: model.base.brand,
        readOnly: true,
        style: TextStyle(color: Colors.grey),
      );
    }
    return DropdownMenu(
      label: Text("Brand"),
      inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
      expandedInsets: EdgeInsets.all(0),
      dropdownMenuEntries: model.brandMenuEntries,
      initialSelection: model.base.brand,

      onSelected: (value) {
        if (value == "New") {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text("New brand name"),
              content: TextField(
                onChanged: (value) {
                  model.base.brand = value.trim();
                },
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (!model.brandList.contains(model.base.brand)) {
                      await BrandRepository().insertBrand(
                        Brand(name: model.base.brand),
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
          model.base.brand = value!;
        }
      },
    );
  }
}
