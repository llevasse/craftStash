import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:flutter/material.dart';

Widget patternTitleInput({required PatternModel patternModel}) {
  String title = "New pattern";
  return TextFormField(
    initialValue: patternModel.pattern != null
        ? patternModel.pattern!.name
        : title,
    decoration: InputDecoration(label: Text("Pattern title")),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return ("Pattern title can't be empty");
      }
      return null;
    },
    onChanged: (value) {
      patternModel.setTitle(value.trim());
      print("changed title");
    },
    onSaved: (newValue) {
      // patternModel.setTitle(newValue!.trim());
      // print("saved title");
    },
  );
}
