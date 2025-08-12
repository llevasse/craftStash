import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:flutter/material.dart';

Widget patternHookSizeInput({required PatternModel patternModel}) {
  return TextFormField(
    keyboardType: TextInputType.numberWithOptions(),
    initialValue: patternModel.pattern?.hookSize?.toStringAsFixed(2),
    decoration: InputDecoration(label: Text("Hook size")),
    validator: (value) {
      return null;
    },
    onSaved: (newValue) {
      patternModel.setHookSize(newValue?.trim());
    },
  );
}
