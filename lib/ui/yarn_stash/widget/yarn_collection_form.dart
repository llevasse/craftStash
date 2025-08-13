import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/data/repository/yarn/collection_repository.dart';
import 'package:craft_stash/data/repository/yarn/yarn_repository.dart';
import 'package:craft_stash/ui/yarn_form_dialog/yarn_form_dialog_model.dart';
import 'package:craft_stash/ui/yarn_stash/widget/collection_form.dart';
import 'package:craft_stash/ui/yarn_form_dialog/yarn_form_dialog_screen.dart';
import 'package:flutter/material.dart';

class YarnCollectionForm extends StatefulWidget {
  String title;
  final Future<void> Function() updateYarn;

  YarnCollectionForm({
    super.key,
    required this.title,
    required this.updateYarn,
  });

  @override
  State<StatefulWidget> createState() => _YarnCollectionForm();
}

class _YarnCollectionForm extends State<YarnCollectionForm> {
  List<Widget> listViewChildren = List.empty(growable: true);

  List<YarnCollection> collectionList = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    updateListView();
  }

  Future<void> updateListView() async {
    collectionList = await CollectionRepository().getAllYarnCollection();

    List<Widget> tmp = List.empty(growable: true);
    tmp.add(
      ListTile(
        title: Text("Unique yarn"),
        onTap: () async {
          Navigator.pop(context);
          await showDialog(
            context: context,
            builder: (BuildContext context) => YarnForm(
              model: YarnFormDialogModel(
                base: Yarn(color: Colors.amber.toARGB32()),
                updateYarn: widget.updateYarn,
                ifValidFunction: YarnRepository().insertYarn,
                title: "Add yarn",
                cancel: "Cancel",
                confirm: "Add",
                fromCategory: false,
              ),
            ),
          );
        },
      ),
    );
    tmp.add(
      ListTile(
        title: Text("New collection"),
        onTap: () async {
          Navigator.pop(context);
          await showDialog(
            context: context,
            builder: (BuildContext context) => CollectionForm(
              base: YarnCollection(),
              updateYarn: widget.updateYarn,
              ifValideFunction: CollectionRepository().insertYarnCollection,
              title: "Add collection",
              cancel: "Cancel",
              confirm: "Add",
            ),
          );
        },
      ),
    );
    for (YarnCollection element in collectionList) {
      if (element.id == -1) continue;
      tmp.add(
        ListTile(
          title: Text(
            element.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(element.brand),
          trailing: Text("${element.thickness.toStringAsFixed(2)}mm"),
          onTap: () async {
            Navigator.pop(context);
            await showDialog(
              context: context,
              builder: (BuildContext context) => YarnForm(
                model: YarnFormDialogModel(
                  base: Yarn(
                    collectionId: element.id,
                    color: Colors.amber.toARGB32(),
                    brand: element.brand,
                    material: element.material,
                    minHook: element.minHook,
                    maxHook: element.maxHook,
                    thickness: element.thickness,
                  ),
                  updateYarn: widget.updateYarn,
                  ifValidFunction: YarnRepository().insertYarn,
                  title: "Add yarn",
                  cancel: "Cancel",
                  confirm: "Add",
                  fill: true,
                ),
              ),
            );
          },
          onLongPress: () async {
            Navigator.pop(context);
            if (await showDialog(
                  context: context,
                  builder: (BuildContext context) => CollectionForm(
                    base: element,
                    updateYarn: widget.updateYarn,
                    ifValideFunction:
                        CollectionRepository().updateYarnCollection,
                    title: "Edit collection",
                    cancel: "Cancel",
                    confirm: "Edit",
                    fill: true,
                    allowDelete: true,
                  ),
                ) ==
                "Delete") {}
          },
        ),
      );
    }
    listViewChildren = tmp;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 300,
        height: 400,
        child: ListView(children: listViewChildren),
      ),
    );
  }
}
