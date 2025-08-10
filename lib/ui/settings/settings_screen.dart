import 'package:craft_stash/main.dart';
import 'package:craft_stash/ui/core/loading_screen.dart';
import 'package:craft_stash/ui/settings/settings_model.dart';
import 'package:craft_stash/ui/settings/widget/print_db_button.dart';
import 'package:craft_stash/ui/settings/widget/recreate_db_button.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsModel settingsModel;

  const SettingsScreen({super.key, required this.settingsModel});
  final double spacing = 10;

  @override
  Widget build(BuildContext context) {
    settingsModel.load();
    ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: settingsModel,
      builder: (BuildContext context, _) {
        if (!settingsModel.loaded) {
          return LoadingScreen();
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: theme.colorScheme.primary,
              title: Text("Settings"),
            ),

            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RecreateDbButton(onQuitPage: settingsModel.onQuit),
                ?debug ? PrintDbButton(onQuitPage: settingsModel.onQuit) : null,
              ],
            ),
          );
        }
      },
    );
  }
}
