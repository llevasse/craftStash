import 'package:craft_stash/class/wip/wip_part.dart';
import 'package:craft_stash/data/repository/wip/wip_part_repository.dart';
import 'package:craft_stash/ui/wip_part/wip_part_model.dart';
import 'package:flutter/material.dart';

OutlinedButton wipPartFinishedButton({
  required BuildContext context,
  required WipPartModel wpm,
}) {
  ThemeData theme = Theme.of(context);
  return OutlinedButton(
    onPressed: () async {
      wpm.wipPart!.finished = wpm.wipPart!.finished == 0 ? 1 : 0;
      await WipPartRepository().updateWipPart(wpm.wipPart!);
      Navigator.pop(context, wpm.wipPart);
    },
    style: ButtonStyle(
      side: WidgetStatePropertyAll(
        BorderSide(color: theme.colorScheme.primary, width: 0),
      ),
      shape: WidgetStatePropertyAll(
        RoundedSuperellipseBorder(
          borderRadius: BorderRadiusGeometry.all(Radius.circular(18)),
        ),
      ),

      backgroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
    ),
    child: Text(
      wpm.wipPart!.finished == 0 ? "Mark as finished" : "Mark as unfinished",
      style: TextStyle(color: theme.colorScheme.secondary),
      textScaler: TextScaler.linear(1.25),
      overflow: TextOverflow.ellipsis,
    ),
  );
}
