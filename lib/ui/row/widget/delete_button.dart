import 'package:craft_stash/ui/row/row_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

IconButton rowDeleteButton({
  required PatternRowModel patternRowModel,
  required BuildContext context,
}) {
  return IconButton(
    onPressed: () async {
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
                await patternRowModel.deleteRow();
                Navigator.pop(context);
              },
              child: Text("Delete"),
            ),
          ],
        ),
      );
    },
    icon: Icon(LucideIcons.trash),
  );
}
