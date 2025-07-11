import 'package:craft_stash/services/database_service.dart';
import 'package:craft_stash/widgets/stitch_list.dart';
import 'package:flutter/material.dart';

class StitchesPage extends StatefulWidget {
  const StitchesPage({super.key});

  @override
  State<StatefulWidget> createState() => _StitchesPageState();
}

class _StitchesPageState extends State<StitchesPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Stitches"),

        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(
        child: Container(
        padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Expanded(child: StitchList(onPressed: (String) {}))],
          ),
        ),
      ),
    );
  }
}
