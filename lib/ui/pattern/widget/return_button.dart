import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

IconButton patternReturnButton({
  required PatternModel patternModel,
  required BuildContext context,
}) {
  return IconButton(
    onPressed: () async {
      try {
        await patternModel.savePattern();
      } catch (exception) {
        print("Error while saving pattern : $exception");
      }
      Navigator.pop(context);
    },
    icon: Icon(LucideIcons.arrowLeft),
  );
}
