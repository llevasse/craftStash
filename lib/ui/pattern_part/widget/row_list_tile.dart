import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/pages/row_page.dart';
import 'package:craft_stash/ui/pattern_part/pattern_part_model.dart';
import 'package:craft_stash/ui/pattern_part/pattern_part_screen.dart';
import 'package:flutter/material.dart';

class RowListTile extends StatelessWidget {
  const RowListTile({
    super.key,
    required this.row,
    required this.patternPartModel,
  });
  final PatternRow row;

  final PatternPartModel patternPartModel;

  @override
  Widget build(BuildContext context) {
    String title = "row ${row.startRow}";
    String? preview;
    if (row.numberOfRows > 1) {
      title +=
          "-${row.startRow + row.numberOfRows - 1} (${row.numberOfRows} rows)";
    }

    if (row.preview != null) {
      preview = row.preview;
      for (MapEntry<int, String> entry
          in patternPartModel.yarnNameMap!.entries) {
        preview = preview!.replaceAll("\${${entry.key}}", entry.value);
      }
    }
    return ListTile(
      title: Text(title),
      subtitle: preview == null ? null : Text(preview),
      contentPadding: EdgeInsets.all(0),
      onTap: () async {
        PatternRow r = await getPatternRowByRowId(row.rowId);
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            settings: RouteSettings(name: "row"),
            builder: (BuildContext context) => RowPage(
              part: patternPartModel.part!,
              updatePattern: () async {},
              row: r,
              yarnIdToNameMap: patternPartModel.yarnNameMap!,
            ),
          ),
        );
      },
      onLongPress: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text("Do you want to delete this row"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await deletePatternRowInDb(row.rowId);
                  Navigator.pop(context);
                },
                child: Text("Delete"),
              ),
            ],
          ),
        );
      },
    );
  }
}
