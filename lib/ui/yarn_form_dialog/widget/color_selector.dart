import 'package:craft_stash/ui/yarn_form_dialog/yarn_form_dialog_model_abstart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class YarnColorSelector extends StatelessWidget {
  YarnColorSelector({super.key, required this.model});

  YarnFormDialogModelAbstart model;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 20, color: Color(model.base.color))),

        TextButton(
          onPressed: model.readOnly
              ? null
              : () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("Pick a color"),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: Color(model.base.color),
                          onColorChanged: model.setColor,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            model.load();
                          },
                          child: Text("Select"),
                        ),
                      ],
                    ),
                  );
                },
          child: Text(
            model.readOnly ? model.base.colorName : "Pick a color",
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        ),
        Expanded(child: Container(height: 20, color: Color(model.base.color))),
      ],
    );
  }
}
