import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/ui/yarn_stash/widget/collection_list_tile.dart';
import 'package:craft_stash/ui/yarn_stash/yarn_model.dart';
import 'package:flutter/material.dart';

ListView yarnStashListView({required YarnStashModel yarnStashModel}) {
  List<Widget> list = List.empty(growable: true);
  for (YarnCollection collection in yarnStashModel.yarns!) {
    if (collection.yarns!.isEmpty) continue;
    list.add(
      CollectionListTile(
        collection: collection,
        yarnStashModel: yarnStashModel,
      ),
    );
  }
  return ListView(children: list);
}
