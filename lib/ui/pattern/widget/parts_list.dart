import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:craft_stash/ui/pattern/widget/parts_list_tile.dart';
import 'package:flutter/material.dart';

ListView patternPartListView(PatternModel patternModel) {
  return ListView.builder(
    itemCount: patternModel.pattern!.parts.length,
    itemBuilder: (_, index) => PatternPartsListTile(
      part: patternModel.pattern!.parts[index],
      patternModel: patternModel,
    ),
  );
}
