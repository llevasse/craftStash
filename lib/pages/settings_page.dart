import 'package:craft_stash/services/database_service.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Future<void> Function() onQuit;
  const SettingsPage({super.key, required this.onQuit});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),

        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                await DbService().recreateDb();
                Navigator.popUntil(context, ModalRoute.withName("/"));
                widget.onQuit.call();
              },
              child: Text("Recreate db"),
            ),
          ],
        ),
      ),
    );
  }
}
