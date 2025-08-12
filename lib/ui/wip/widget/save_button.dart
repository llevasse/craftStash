import 'package:craft_stash/ui/wip/wip_model.dart';
import 'package:flutter/material.dart';

IconButton wipSaveButton({
  required WipModel wipModel,
  required BuildContext context,
}) {
  return IconButton(
    onPressed: () async {
      if ((await wipModel.saveWip()) == true) {
        Navigator.pop(context);
      }
    },
    icon: Icon(Icons.save),
  );
}
