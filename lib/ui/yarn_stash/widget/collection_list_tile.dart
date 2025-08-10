import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/data/repository/yarn/collection_repository.dart';
import 'package:craft_stash/data/repository/yarn/yarn_repository.dart';
import 'package:craft_stash/ui/yarn_stash/yarn_model.dart';
import 'package:craft_stash/ui/yarn_stash/widget/collection_form.dart';
import 'package:craft_stash/ui/core/widgets/buttons/edit_yarn_button.dart';
import 'package:craft_stash/ui/core/widgets/dialogs/yarn_form_dialog.dart';
import 'package:flutter/material.dart';

class CollectionListTile extends StatelessWidget {
  const CollectionListTile({
    super.key,
    required this.collection,
    required this.yarnStashModel,
  });
  final YarnCollection collection;

  final YarnStashModel yarnStashModel;

  Widget _yarnButton({
    required BuildContext context,
    required Yarn yarn,
    YarnCollection? collection,
  }) {
    if (collection != null) {
      yarn.brand = collection.brand;
      yarn.material = collection.material;
      yarn.maxHook = collection.maxHook;
      yarn.minHook = collection.minHook;
      yarn.thickness = collection.thickness;
    }
    return (EditYarnButton(
      updateYarn: yarnStashModel.reload,
      currentYarn: yarn,
      onClick: () => showDialog(
        context: context,
        builder: (BuildContext context) => YarnForm(
          base: yarn,
          updateYarn: yarnStashModel.reload,
          ifValidFunction: YarnRepository().updateYarn,
          title: "Edit yarn",
          cancel: "Cancel",
          confirm: "Edit",
          fill: true,
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    ExpansibleController controller = ExpansibleController();

    return ExpansionTile(
      controller: controller,
      showTrailingIcon: false,
      initiallyExpanded: true,
      shape: const Border(),
      title: Row(
        children: [
          Expanded(child: Divider(color: Colors.amber)),
          TextButton(
            onPressed: () {
              controller.isExpanded
                  ? controller.collapse()
                  : controller.expand();
            },
            onLongPress: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) => CollectionForm(
                  allowDelete: true,
                  fill: true,
                  base: collection,
                  updateYarn: yarnStashModel.reload,
                  ifValideFunction: CollectionRepository().updateYarnCollection,
                  title: "Edit collection",
                  cancel: "Cancel",
                  confirm: "Edit",
                ),
              );
            },
            child: Text(
              collection.name,
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
              textScaler: TextScaler.linear(1.5),
            ),
          ),
          Expanded(child: Divider(color: Colors.amber)),
        ],
      ),
      children: [
        for (Yarn yarn in collection.yarns!)
          _yarnButton(context: context, yarn: yarn, collection: collection),
      ],
    );
  }
}
