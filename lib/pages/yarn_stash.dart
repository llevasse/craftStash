import 'package:craft_stash/class/Yarn.dart';
import 'package:flutter/material.dart';

class YarnStashPage extends StatefulWidget {
  const YarnStashPage({super.key});

  @override
  State<YarnStashPage> createState() => _YarnStashPageState();
}

class _YarnStashPageState extends State<YarnStashPage> {
  List<Yarn> yarns = List.empty(growable: true);
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text("Yarn stash"),
      ),
      body: Scaffold(),
    );
  }
}
