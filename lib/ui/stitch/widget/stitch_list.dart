import 'package:craft_stash/ui/core/widgets/stitch_list.dart';
import 'package:craft_stash/ui/stitch/stitch_model.dart';
import 'package:flutter/material.dart';

class StitchScreenStitchList extends StatelessWidget {
  const StitchScreenStitchList({required this.stitchModel});
  final StitchModel stitchModel;

  @override
  Widget build(BuildContext context) {
    return StitchList(
      onStitchPressed: (stitch) async {
        await stitchModel.onStitchPressed(context: context, stitch: stitch);
      },
      onSequencePressed: (stitch) async {
        await stitchModel.onSequencePressed(context: context, stitch: stitch);
      },
      newSubrow: true,
      newStitch: true,
      customActions: [],
    );
  }
}
