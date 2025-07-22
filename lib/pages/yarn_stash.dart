import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/widgets/page_select_dropdown_button.dart';
import 'package:craft_stash/widgets/yarnButtons/edit_yarn_button.dart';
import 'package:craft_stash/widgets/yarnButtons/yarn_form.dart';
import 'package:flutter/material.dart';

typedef MyBuilder =
    void Function(BuildContext context, Future<void> Function() updateYarn);

class YarnStashPage extends StatefulWidget {
  final MyBuilder builder;
  const YarnStashPage({super.key, required this.builder});

  @override
  State<YarnStashPage> createState() => _YarnStashPageState();
}

class _YarnStashPageState extends State<YarnStashPage> {
  List<Widget> listViewContent = List.empty(growable: true);
  List<YarnCollection> yarnCollection = List.empty(growable: true);

  Future<void> _getAllCollections() async {
    yarnCollection = await getAllYarnCollection(getYarn: true);

    List<Widget> tmp = List.empty(growable: true);
    for (YarnCollection collection in yarnCollection) {
      if (collection.yarns != null && collection.yarns!.isNotEmpty) {
        tmp.add(
          Row(
            children: [
              Expanded(child: Divider(color: Colors.amber)),
              Expanded(
                child: Text(
                  collection.name,
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.5),
                ),
              ),
              Expanded(child: Divider(color: Colors.amber)),
            ],
          ),
        );
        for (Yarn yarn in collection.yarns!) {
          yarn.brand = collection.brand;
          yarn.material = collection.material;
          yarn.maxHook = collection.maxHook;
          yarn.minHook = collection.minHook;
          yarn.thickness = collection.thickness;
          tmp.add(
            EditYarnButton(
              updateYarn: _getAllCollections,
              currentYarn: yarn,
              onClick: () => showDialog(
                context: context,
                builder: (BuildContext context) => YarnForm(
                  base: yarn,
                  updateYarn: _getAllCollections,
                  ifValidFunction: updateYarnInDb,
                  title: "Edit yarn",
                  cancel: "Cancel",
                  confirm: "Edit",
                  fill: true,
                ),
              ),
            ),
          );
        }
      }
    }
    setState(() {
      listViewContent = tmp;
    });
    setState(() {});
  }

  @override
  void initState() {
    try {
      _getAllCollections();
    } catch (e) {
      print(e);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.builder.call(context, _getAllCollections);
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text("Yarn stash"),
        actions: [
          PageSelectDropdownButton(
            onQuit: () async {
              await _getAllCollections();
            },
          ),
        ],
      ),
      body: ListView(children: listViewContent),
    );
  }
}
