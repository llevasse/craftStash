import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:flutter/material.dart';

Widget patternAssemblyInput({required PatternModel patternModel}) {
  return TextFormField(
    maxLines: 5,
    initialValue: patternModel.pattern?.note,
    decoration: InputDecoration(label: Text("Assembly")),
    validator: (value) {
      return null;
    },
    onChanged: (value) {
      patternModel.setAssembly(value);
    },
    // onSaved: (newValue) {
    //   patternModel.pattern?.note = newValue?.trim();
    // },
  );
}
