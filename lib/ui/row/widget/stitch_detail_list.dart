import 'package:craft_stash/ui/row/row_model.dart';
import 'package:flutter/material.dart';

Widget rowStitchDetailsList({required PatternRowModel patternRowModel}) {
  return Container(
    constraints: BoxConstraints(maxHeight: patternRowModel.buttonHeight * 2.5),
    child: SingleChildScrollView(
      controller: patternRowModel.stitchDetailsScrollController,
      child: Wrap(
        spacing: 10,
        children: [for (Widget e in patternRowModel.detailsCountButtonList) e],
      ),
    ),
  );
}
