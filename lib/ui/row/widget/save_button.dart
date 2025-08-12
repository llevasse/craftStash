import 'package:craft_stash/ui/row/row_model.dart';
import 'package:flutter/material.dart';

IconButton rowSaveButton({
  required PatternRowModel patternRowModel,
  required BuildContext context,
}) {
  return IconButton(
    onPressed: () async {
      await patternRowModel.saveSequence(context);
    },
    icon: Icon(Icons.save),
  );
}
