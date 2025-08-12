import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/ui/wip_part/wip_part_model.dart';
import 'package:flutter/material.dart';

ListView wipPartRowsListView({required WipPartModel wpm}) {
  List<Widget> children = List.empty(growable: true);
  for (PatternRow row in wpm.wipPart!.part!.rows) {
    String rowNumber = "Row ${row.startRow}";
    if (row.numberOfRows > 1) {
      rowNumber +=
          "-${row.startRow + row.numberOfRows - 1} (${row.numberOfRows}rows)";
    }
    String? preview = row.preview;
    if (preview != null) {
      for (MapEntry<int, String> entry in wpm.yarnNameMap!.entries) {
        preview = preview!.replaceAll("\${${entry.key}}", entry.value);
      }
    }
    children.add(
      ListTile(
        title: Text("$rowNumber : $preview"),
        contentPadding: EdgeInsets.all(0),
      ),
    );
  }
  return ListView(children: children);
}
