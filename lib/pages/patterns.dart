import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:flutter/material.dart';

typedef MyBuilder =
    void Function(BuildContext context, Future<void> Function() updateYarn);

class PatternsPage extends StatefulWidget {
  final MyBuilder builder;
  const PatternsPage({super.key, required this.builder});

  @override
  State<PatternsPage> createState() => _PatternsPageState();
}

class _PatternsPageState extends State<PatternsPage> {
  List<Widget> listViewContent = List.empty(growable: true);
  List<craft.Pattern> patterns = List.empty(growable: true);
  Future<void> getAllPatterns() async {
    patterns = await craft.getAllPattern();
    updateListView();
    setState(() {});
  }

  void updateListView() {
    List<Widget> tmp = List.empty(growable: true);
    for (craft.Pattern pattern in patterns) {
      tmp.add(
        ListTile(
          title: Text(pattern.name),
          onTap: () {
            print(pattern);
          },
        ),
      );
    }
    ;
    setState(() {
      listViewContent.clear();
      listViewContent = tmp;
    });
  }

  @override
  void initState() {
    try {
      getAllPatterns();
    } catch (e) {
      print(e);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.builder.call(context, getAllPatterns);
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text("Patterns"),
      ),
      body: ListView(children: listViewContent),
    );
  }
}
