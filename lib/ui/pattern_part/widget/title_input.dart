import 'package:craft_stash/ui/pattern_part/pattern_part_model.dart';
import 'package:flutter/material.dart';

Widget partTitleInput({required PatternPartModel patternPartModel}) {
  String title = "New pattern";
  return TextFormField(
    initialValue: patternPartModel.part != null
        ? patternPartModel.part!.name
        : title,
    decoration: InputDecoration(label: Text("Part title")),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return ("Part title can't be empty");
      }
      return null;
    },
    onChanged: (value) {
      patternPartModel.setTitle(value.trim());
    },
    onSaved: (newValue) {
      patternPartModel.setTitle(newValue!.trim());
    },
  );
}
