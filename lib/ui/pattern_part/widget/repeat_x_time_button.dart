import 'package:craft_stash/ui/pattern_part/pattern_part_model.dart';
import 'package:craft_stash/widgets/patternButtons/count_button.dart';
import 'package:flutter/material.dart';

Widget partRepeatXTimeButton({required PatternPartModel patternPartModel}) {
  return CountButton(
    prefixText: "Make ",
    count: patternPartModel.part!.numbersToMake,
    onChange: (value) {
      patternPartModel.setNumberToMake(value);
    },
    min: 1,
  );
}
