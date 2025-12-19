import 'package:craft_stash/ui/row/row_model.dart';
import 'package:flutter/material.dart';

IconButton rowReturnButton({
  required PatternRowModel patternRowModel,
  required BuildContext context,
}) {
  return IconButton(
    onPressed: () async {
      await patternRowModel.saveRow(deleteIfEmpty: true);
    },
    icon: Icon(Icons.arrow_back),
  );
}
