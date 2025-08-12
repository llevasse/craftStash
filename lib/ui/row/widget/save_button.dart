import 'package:craft_stash/ui/row/row_model.dart';
import 'package:flutter/material.dart';

IconButton rowSaveButton({
  required PatternRowModel patternRowModel,
  required BuildContext context,
}) {
  return IconButton(
    onPressed: () async {
      if (patternRowModel.isSubRow == false) {
        if ((await patternRowModel.saveRow()) == true) {
          Navigator.pop(context, patternRowModel.row);
        }
      } else {
        if ((await patternRowModel.saveSequence(context)) == true) {}
      }
    },
    icon: Icon(Icons.save),
  );
}
