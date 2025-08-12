import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:flutter/material.dart';

IconButton patternSaveButton({
  required PatternModel patternModel,
  required BuildContext context,
}) {
  return IconButton(
    onPressed: () async {
      if ((await patternModel.savePattern()) == true) {
        Navigator.pop(context);
      }
    },
    icon: Icon(Icons.save),
  );
}
