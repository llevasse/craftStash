import 'package:craft_stash/class/yarn.dart';
import 'package:flutter/material.dart';

class PatternsPage extends StatefulWidget {
  const PatternsPage({super.key});

  @override
  State<PatternsPage> createState() => _PatternsPageState();
}

class _PatternsPageState extends State<PatternsPage> {
  List<Yarn> yarns = List.empty(growable: true);
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text("Patterns"),
      ),
      body: Scaffold(),
    );
  }
}
