import 'package:craft_stash/class/wip/wip.dart';
import 'package:craft_stash/ui/core/loading_screen.dart';
import 'package:craft_stash/ui/pattern_stash/stash_model.dart';
import 'package:craft_stash/ui/pattern_stash/widget/pattern_list_tile.dart';
import 'package:craft_stash/ui/wip_stash/stash_model.dart';
import 'package:craft_stash/ui/wip_stash/widget/wip_list_tile.dart';
import 'package:craft_stash/ui/core/widgets/buttons/page_select_dropdown_button.dart';
import 'package:flutter/material.dart';

class WipStashScreen extends StatelessWidget {
  final WipStashModel wipStashModel;

  const WipStashScreen({super.key, required this.wipStashModel});
  final double spacing = 10;

  @override
  Widget build(BuildContext context) {
    wipStashModel.load();
    ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: wipStashModel,
      builder: (BuildContext context, _) {
        if (!wipStashModel.loaded) {
          return LoadingScreen();
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: theme.colorScheme.primary,
              actions: [PageSelectDropdownButton(onQuit: wipStashModel.reload)],

              title: Text("Patterns"),
            ),

            body: ListView(
              children: [
                for (Wip wip in wipStashModel.wips!)
                  WipListTile(wip: wip, wipStashModel: wipStashModel),
              ],
            ),
          );
        }
      },
    );
  }
}
