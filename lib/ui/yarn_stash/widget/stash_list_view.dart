import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/ui/yarn_stash/widget/collection_list_tile.dart';
import 'package:craft_stash/ui/yarn_stash/yarn_model.dart';
import 'package:flutter/material.dart';

ListView yarnStashListView({required YarnStashModel yarnStashModel}) {
  return ListView(
    children: [
      for (YarnCollection collection in yarnStashModel.yarns!)
        CollectionListTile(
          collection: collection,
          yarnStashModel: yarnStashModel,
        ),
    ],
  );
}
