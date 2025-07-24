import 'package:craft_stash/class/wip/wip.dart';
import 'package:craft_stash/pages/wip_page.dart';
import 'package:craft_stash/widgets/page_select_dropdown_button.dart';
import 'package:flutter/material.dart';

typedef MyBuilder =
    void Function(BuildContext context, Future<void> Function() updateWips);

class WipStashPage extends StatefulWidget {
  final MyBuilder builder;
  const WipStashPage({super.key, required this.builder});

  @override
  State<WipStashPage> createState() => _WipStashPageState();
}

class _WipStashPageState extends State<WipStashPage> {
  List<Widget> listViewContent = List.empty(growable: true);
  List<Wip> wips = List.empty(growable: true);

  Future<void> updateListView() async {
    wips = await getAllWip(withPattern: true);
    List<Widget> tmp = List.empty(growable: true);
    for (Wip wip in wips) {
      if (wip.pattern == null) continue;
      tmp.add(
        ListTile(
          title: Text(wip.pattern!.name),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                settings: RouteSettings(name: "/wip"),
                builder: (BuildContext context) =>
                    WipPage(updateWipListView: updateListView, wip: wip),
              ),
            );
            await updateListView();
          },
          onLongPress: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text("Do you want to delete this wip"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await deleteWipInDb(wip.id);
                      await updateListView();
                      Navigator.pop(context);
                    },
                    child: Text("Delete"),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    setState(() {
      listViewContent = tmp;
    });
  }

  @override
  void initState() {
    try {
      updateListView();
    } catch (e) {
      print(e);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.builder.call(context, updateListView);
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        actions: [
          PageSelectDropdownButton(
            onQuit: () async {
              await updateListView();
            },
          ),
        ],

        title: Text("Wips"),
      ),
      body: ListView(children: listViewContent),
    );
  }
}
