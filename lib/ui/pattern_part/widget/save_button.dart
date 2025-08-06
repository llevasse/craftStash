import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/ui/pattern_part/pattern_part_model.dart';
import 'package:flutter/material.dart';

IconButton partSaveButton({
  required PatternPartModel patternPartModel,
  required BuildContext context,
}) {
  return IconButton(
    onPressed: () async {
      if ((await patternPartModel.savePart()) == true) {
        Navigator.pop(context);
      }
    },
    icon: Icon(Icons.save),
  );
}
