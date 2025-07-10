import 'package:craft_stash/pages/settings_page.dart';
import 'package:flutter/material.dart';

class PageSelectDropdownButton extends StatefulWidget {
  final Future<void> Function() onQuit;

  const PageSelectDropdownButton({super.key, required this.onQuit});

  @override
  State<StatefulWidget> createState() => _PageSelectDropdownButtonState();
}

class _PageSelectDropdownButtonState extends State<PageSelectDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Text("Settings"),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(
                settings: RouteSettings(name: "settings"),
                builder: (BuildContext context) =>
                    SettingsPage(onQuit: widget.onQuit),
              ),
            );
          },
        ),
      ],
    );
  }
}
