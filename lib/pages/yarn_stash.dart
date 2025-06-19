import 'package:craft_stash/class/yarn.dart';
import 'package:craft_stash/class/yarn_collection.dart';
import 'package:craft_stash/widgets/yarnButtons/edit_yarn_button.dart';
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
    setState(() {});
  }

  Future<void> getAllYarns() async {
    await _getAllCollections();
    yarns = await getAllYarn();
    for (Yarn yarn in yarns) {
      yarnsByCollection[collectionById[yarn.collectionId]]?.add(yarn);
    }
    updateListView();
    setState(() {});
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
          tmp.add(EditYarnButton(updateYarn: getAllYarns, currentYarn: yarn));
        }
      }
    });
    setState(() {
      listViewContent.clear();
      listViewContent = tmp;
    });
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

  @override
  Widget build(BuildContext context) {
    widget.builder.call(context, getAllYarns);
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text("Yarn stash"),
      ),
      body: ListView(children: listViewContent),
    );
  }
}
