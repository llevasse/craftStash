import 'package:craft_stash/ui/wip/wip_model.dart';
import 'package:flutter/material.dart';

Widget wipTitleInput({required WipModel wipModel}) {
  return TextFormField(
    initialValue: wipModel.wip!.name,
    decoration: InputDecoration(label: Text("Wip title")),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return ("Wip title can't be empty");
      }
      return null;
    },
    onChanged: (value) {
      wipModel.setTitle(value.trim());
    },
    onSaved: (newValue) {
      wipModel.setTitle(newValue!.trim());
    },
  );
}
