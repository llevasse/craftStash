import 'package:craft_stash/ui/yarn_form_dialog/yarn_form_dialog_model.dart';
import 'package:craft_stash/ui/yarn_form_dialog/yarn_form_dialog_model_abstart.dart';
import 'package:flutter/material.dart';

Widget colorNameInput(YarnFormDialogModelAbstart model) {
  return TextFormField(
    decoration: InputDecoration(label: Text("Color name")),
    initialValue: model.fill ? model.base.colorName : null,

    style: TextStyle(color: model.readOnly ? Colors.grey : Colors.black),
    validator: (value) {
      return null;
    },
    onSaved: (newValue) {
      newValue = newValue?.trim();
      if (newValue == null || newValue.isEmpty) {
        newValue = "Unknown";
      }
      model.base.colorName = newValue;
    },
    readOnly: model.readOnly,
  );
}
