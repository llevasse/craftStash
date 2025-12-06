import 'package:craft_stash/ui/pattern_part/pattern_part_model.dart';
import 'package:craft_stash/ui/pattern_part/widget/row_list_tile.dart';
import 'package:flutter/material.dart';

class RowListView extends StatelessWidget {
  final PatternPartModel patternPartModel;
  double spacing = 10;

  RowListView({super.key, required this.patternPartModel});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: patternPartModel.part!.rows.length,
      itemBuilder: (_, index) => RowListTile(
        row: patternPartModel.part!.rows[index],
        patternPartModel: patternPartModel,
        prevRowStitchNumber: index > 0
            ? patternPartModel.part!.rows[index - 1].stitchesPerRow
            : 0,
      ),
    );
  }
}
