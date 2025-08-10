import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/ui/core/widgets/buttons/edit_yarn_button.dart';
import 'package:flutter/material.dart';

class YarnListDialog extends StatefulWidget {
  final Future<void> Function(Yarn yarn, int numberOfYarns) onPressed;
  const YarnListDialog({super.key, required this.onPressed});

  @override
  State<StatefulWidget> createState() => _YarnListDialogState();
}

class _YarnListDialogState extends State<YarnListDialog> {
  List<Widget> listViewContent = List.empty(growable: true);
  List<Yarn> yarns = List.empty(growable: true);
  List<YarnCollection> yarnCollection = List.empty(growable: true);
  Map<int, String> collectionById = {};
  Map<String, List<Yarn>> yarnsByCollection = {};

  Future<void> _getAllCollections() async {
    yarnCollection = await getAllYarnCollection();
    yarnsByCollection.clear();
    collectionById.clear();
    collectionById[-1] = "Unique";
    yarnsByCollection["Unique"] = List.empty(growable: true);
    for (YarnCollection collection in yarnCollection) {
      collectionById[collection.id] = collection.name;
      yarnsByCollection[collection.name] = List.empty(growable: true);
    }
    if (mounted) setState(() {});
  }

  Future<void> getAllYarns() async {
    await _getAllCollections();
    yarns = await getAllYarn();
    for (Yarn yarn in yarns) {
      yarnsByCollection[collectionById[yarn.collectionId]]?.add(yarn);
    }
    updateListView();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    try {
      getAllYarns();
    } catch (e) {
      print(e);
    }
    super.initState();
  }

  void updateListView() {
    List<Widget> tmp = List.empty(growable: true);

    yarnsByCollection.forEach((key, yarns) {
      if (yarns.isNotEmpty) {
        tmp.add(
          Row(
            children: [
              Expanded(child: Divider(color: Colors.amber)),
              Expanded(
                child: Text(
                  key,
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.5),
                ),
              ),
              Expanded(child: Divider(color: Colors.amber)),
            ],
          ),
        );
        for (var yarn in yarns) {
          tmp.add(
            EditYarnButton(
              updateYarn: getAllYarns,
              currentYarn: yarn,
              showBrand: false,
              showMaterial: false,
              showMaxHook: false,
              showMinHook: false,
              showThickness: false,
              showSkeins: false,
              onClick: () async {
                await widget.onPressed(yarn, tmp.length);
                Navigator.pop(context);
              },
            ),
          );
        }
      }
    });
    if (mounted) {
      setState(() {
        listViewContent.clear();
        listViewContent = tmp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Yarns"),
      content: ListView(children: listViewContent),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
      ],
    );
  }
}
