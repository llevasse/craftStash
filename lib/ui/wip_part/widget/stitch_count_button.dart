import 'package:craft_stash/ui/core/widgets/buttons/count_button.dart';
import 'package:craft_stash/ui/wip_part/wip_part_model.dart';
import 'package:craft_stash/ui/wip_part/wip_part_model.dart';
import 'package:flutter/material.dart';

Widget wipPartStitchCount({required WipPartModel wpm}) {
  return Column(
    children: [
      Text("Current stitch", textScaler: TextScaler.linear(1.5)),
      CountButton(
        textBackgroundColor: Colors.white,
        count: wpm.wipPart!.currentStitchNumber,
        onChange: wpm.setCurrentStitch,
        max: wpm
            .wipPart!
            .part!
            .rows[wpm.wipPart!.currentRowIndex]
            .stitchesPerRow,
        signed: false,
      ),
    ],
  );
}
