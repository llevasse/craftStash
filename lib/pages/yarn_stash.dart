import 'package:craft_stash/class/yarn.dart';
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
  List<Yarn> yarns = List.empty(growable: true);

  Future<void> getAllYarns() async {
    yarns = await getAllYarn();
    setState(() {});
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
      body: ListView.separated(
        itemBuilder: (context, index) {
          return EditYarnButton(
            updateYarn: getAllYarns,
            currentYarn: yarns[index],
          );
        },
        separatorBuilder: (context, index) =>
            Divider(color: theme.colorScheme.primary),
        itemCount: yarns.length,
      ),
    );
  }
}
