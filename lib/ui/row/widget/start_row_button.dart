import 'package:craft_stash/ui/core/widgets/buttons/count_button.dart';
import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/ui/wip_part/wip_part_model.dart';
import 'package:flutter/material.dart';

Widget rowStartRowButton({required PatternRowModel patternRowModel}) {
  return CountButton(
    prefixText: "Row ",
    count: patternRowModel.row!.startRow,
    onChange: (value) {
      patternRowModel.setStartRow(value);
    },
    min: 1,
  );
}
