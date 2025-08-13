import 'package:craft_stash/ui/yarn_form_dialog/yarn_form_dialog_model.dart';
import 'package:craft_stash/ui/yarn_form_dialog/yarn_form_dialog_model_abstart.dart';
import 'package:flutter/material.dart';

Widget minHookInput(YarnFormDialogModelAbstart model) {
  return TextFormField(
    keyboardType: TextInputType.numberWithOptions(),
    decoration: InputDecoration(label: Text("Min hook")),
    initialValue: model.fill ? model.base.minHook.toStringAsFixed(2) : null,

    style: TextStyle(color: model.readOnly ? Colors.grey : Colors.black),
    validator: (value) {
      return null;
    },
    onSaved: (newValue) {
      newValue = newValue?.trim();
      if (newValue == null || newValue.isEmpty) {
        newValue = "0.0";
      }
      model.base.minHook = double.parse(newValue);
    },
    readOnly: model.readOnly,
  );
}
