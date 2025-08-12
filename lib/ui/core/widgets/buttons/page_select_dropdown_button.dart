import 'package:craft_stash/data/repository/settings_repository.dart';
import 'package:craft_stash/data/repository/stitch_repository.dart';
import 'package:craft_stash/ui/settings/settings_model.dart';
import 'package:craft_stash/ui/settings/settings_screen.dart';
import 'package:craft_stash/ui/stitch/stitch_model.dart';
import 'package:craft_stash/ui/stitch/stitch_screen.dart';
import 'package:flutter/material.dart';

class PageSelectDropdownButton extends StatelessWidget {
  final Future<void> Function() onQuit;

  const PageSelectDropdownButton({super.key, required this.onQuit});
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Text("Stitches"),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(
                settings: RouteSettings(name: "Stitches"),
                builder: (BuildContext context) => StitchScreen(
                  stitchModel: StitchModel(
                    stitchRepository: StitchRepository(),
                  ),
                ),
              ),
            );
          },
        ),
        PopupMenuItem(
          child: Text("Settings"),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(
                settings: RouteSettings(name: "Settings"),
                builder: (BuildContext context) => SettingsScreen(
                  settingsModel: SettingsModel(
                    onQuit: onQuit,
                    settingsRepository: SettingsRepository(),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
