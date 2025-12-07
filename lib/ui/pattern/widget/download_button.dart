import 'dart:convert';

import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/data/local_file.dart';
import 'package:craft_stash/data/repository/yarn/collection_repository.dart';
import 'package:craft_stash/data/repository/yarn/yarn_repository.dart';
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
        Map<String, dynamic> json = pattern.toJson();
        json['yarns'] = {};
        json['yarn_collections'] = {};
        List<Yarn> yarns = await YarnRepository().getAllYarnByPatternId(
          pattern.patternId,
        );
        for (final yarn in yarns) {
          json['yarns'][yarn.id.toString()] = yarn.toJson();
          if (yarn.collectionId != null &&
              json['yarn_collections'][yarn.collectionId.toString()] == null) {
            json['yarn_collections'][yarn.collectionId.toString()] =
                (await CollectionRepository().getYarnCollectionById(
                  id: yarn.collectionId!,
                )).toJson();
          }
        }
        await FileStorage.writeCounter(
          jsonEncode(json),
          "${pattern.name}.json",
        );
      }
    },
    icon: Icon(LucideIcons.save),
  );
}
