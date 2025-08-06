import 'package:craft_stash/ui/row/row_model.dart';
import 'package:flutter/material.dart';

IconButton rowSaveButton({
  required PatternRowModel patternRowModel,
  required BuildContext context,
}) {
  return IconButton(
    onPressed: () async {
      if ((await patternRowModel.saveRow()) == true) {
        Navigator.pop(context);
      }
    },
    icon: Icon(Icons.save),
  );
}
