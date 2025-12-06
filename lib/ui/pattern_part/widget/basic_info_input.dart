import 'package:craft_stash/ui/pattern_part/pattern_part_model.dart';
import 'package:craft_stash/ui/pattern_part/widget/repeat_x_time_button.dart';
import 'package:craft_stash/ui/pattern_part/widget/title_input.dart';
import 'package:flutter/material.dart';

class BasicInfoInput extends StatelessWidget {
  final PatternPartModel patternPartModel;
  double spacing = 10;

  BasicInfoInput({
    super.key,
    required this.patternPartModel,
    this.spacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: spacing,
      children: [
        Expanded(child: partTitleInput(patternPartModel: patternPartModel)),
        Expanded(
          child: partRepeatXTimeButton(patternPartModel: patternPartModel),
        ),
      ],
    );
  }
}
