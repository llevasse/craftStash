import 'package:craft_stash/ui/wip/wip_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

IconButton wipDeleteButton({
  required WipModel wipModel,
  required BuildContext context,
}) {
  return IconButton(
    onPressed: () async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("Do you want to delete this wip"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await wipModel.deleteWip();
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
