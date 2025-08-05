import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

IconButton patternDeleteButton({
  required PatternModel patternModel,
  required BuildContext context,
}) {
  return IconButton(
    onPressed: () async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("Do you want to delete this pattern"),
          content: Text(
            "Every wips, parts and rows connected to it will be deleted as well",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await patternModel.deletePattern();
                while (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
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
