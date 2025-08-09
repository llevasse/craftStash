import 'package:craft_stash/ui/core/count_button.dart';
import 'package:craft_stash/ui/wip_part/wip_part_model.dart';
import 'package:flutter/material.dart';

Widget wipPartRowCount({required WipPartModel wpm}) {
  return Column(
    children: [
      Text("Current row", textScaler: TextScaler.linear(1.5)),
      CountButton(
        textBackgroundColor: Colors.white,
        count: wpm.wipPart!.currentRowNumber,
        onChange: wpm.setCurrentRow,
        max: wpm.totalNumberOfRows + 1,
        min: 1,
        signed: false,
      ),
    ],
  );
}
