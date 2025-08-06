import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/ui/row/widget/color_change.dart';
import 'package:craft_stash/ui/row/widget/start_color_button.dart';
import 'package:craft_stash/ui/row/widget/subrow_button.dart';
import 'package:craft_stash/widgets/stitches/stitch_list.dart';
import 'package:flutter/material.dart';

class RowStitchList extends StatelessWidget {
  const RowStitchList({required this.patternRowModel});
  final PatternRowModel patternRowModel;

  @override
  Widget build(BuildContext context) {
    return StitchList(
      onStitchPressed: patternRowModel.addStitch,
      onSequencePressed: patternRowModel.addStitch,
      customActions: [
        rowSubrowButton(patternRowModel: patternRowModel),
        rowColorChangeButton(patternRowModel: patternRowModel),
        ?patternRowModel.row!.startRow == 1
            ? rowStartColorButton(patternRowModel: patternRowModel)
            : null,
      ],
    );
  }
}
