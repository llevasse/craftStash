import 'package:craft_stash/ui/wip/wip_model.dart';
import 'package:flutter/material.dart';

Widget wipHookSizeInput({required WipModel wipModel}) {
  return TextFormField(
    keyboardType: TextInputType.numberWithOptions(),
    initialValue: wipModel.wip?.hookSize?.toStringAsFixed(2),
    decoration: InputDecoration(label: Text("Hook size")),
    validator: (value) {
      return null;
    },
    onSaved: (newValue) {
      wipModel.setHookSize(newValue?.trim());
    },
  );
}
