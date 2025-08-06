import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/widgets/patternButtons/count_button.dart';
import 'package:flutter/material.dart';

Widget rowNbOfRowButton({required PatternRowModel patternRowModel}) {
  return CountButton(
    prefixText: "Do ",
    count: patternRowModel.row!.numberOfRows,
    onChange: (value) {
      patternRowModel.setNumberOfRows(value);
    },
    min: 1,
  );
}
