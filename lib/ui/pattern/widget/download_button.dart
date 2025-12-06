import 'dart:convert';

import 'package:craft_stash/data/local_file.dart';
import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;

IconButton patternDownloadButton({
  required PatternModel patternModel,
  required BuildContext context,
}) {
  return IconButton(
    onPressed: () async {
      craft.Pattern? pattern = await patternModel.fullPattern;
      if (pattern != null) {
        await FileStorage.writeCounter(
          pattern.toJson(),
          "${pattern.name}.json",
        );
      }
    },
    icon: Icon(LucideIcons.save),
  );
}
