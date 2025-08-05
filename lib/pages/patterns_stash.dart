import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/data/repository/pattern_repository.dart';
import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:craft_stash/ui/pattern/pattern_screen.dart';
import 'package:craft_stash/widgets/page_select_dropdown_button.dart';
import 'package:flutter/material.dart';

typedef MyBuilder =
    void Function(BuildContext context, Future<void> Function() updateYarn);

class PatternsStashPage extends StatefulWidget {
  final MyBuilder builder;
  const PatternsStashPage({super.key, required this.builder});

  @override
  State<PatternsStashPage> createState() => _PatternsStashPageState();
}

class _PatternsStashPageState extends State<PatternsStashPage> {
  List<Widget> listViewContent = List.empty(growable: true);
  List<craft.Pattern> patterns = List.empty(growable: true);

  Future<void> updateListView() async {
    patterns = await craft.getAllPattern();
    List<Widget> tmp = List.empty(growable: true);
    for (craft.Pattern pattern in patterns) {
      tmp.add(
        ListTile(
          title: Text(pattern.name),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                settings: RouteSettings(name: "pattern"),

                builder: (BuildContext context) => PatternScreen(
                  patternModel: PatternModel(
                    patternRepository: PatternRepository(),
                    id: pattern.patternId,
                  ),
                ),
                // builder: (BuildContext context) => PatternPage(
                //   updatePatternListView: updateListView,
                //   pattern: pattern,
                // ),
              ),
            );
            await updateListView();
          },
          onLongPress: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text("Do you want to delete this pattern"),
                content: Text(
                  "Every wips, parts and rows connected to it will be deleted as well",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await craft.deletePatternInDb(pattern.patternId);
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

        title: Text("Patterns"),
      ),
      body: ListView(children: listViewContent),
    );
  }
}
