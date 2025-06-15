import 'package:craft_stash/class/yarn.dart';
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
    print("Update yarn");
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
          return ListTile(
            leading: Container(
              width: 30,
              height: 30,
              color: Color(yarns[index].color),
            ),
            title: Text(
              "${yarns[index].colorName}, ${yarns[index].brand}, ${yarns[index].material}, ${yarns[index].thickness.toStringAsFixed(2)}mm",
            ),
            subtitle: Text(
              "Min hook : ${yarns[index].minHook.toStringAsFixed(2)}mm, Max hook : ${yarns[index].maxHook.toStringAsFixed(2)}mm",
            ),
            trailing: Text("${yarns[index].nbOfSkeins} skeins"),
          );
        },
        separatorBuilder: (context, index) =>
            Divider(color: theme.colorScheme.primary),
        itemCount: yarns.length,
      ),
    );
  }
}
