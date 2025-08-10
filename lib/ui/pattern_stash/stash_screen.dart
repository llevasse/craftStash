import 'package:craft_stash/ui/core/loading_screen.dart';
import 'package:craft_stash/ui/pattern_stash/stash_model.dart';
import 'package:craft_stash/ui/pattern_stash/widget/pattern_list_tile.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/ui/core/widgets/buttons/page_select_dropdown_button.dart';
import 'package:flutter/material.dart';

class PatternStashScreen extends StatelessWidget {
  final PatternStashModel patternStashModel;

  const PatternStashScreen({super.key, required this.patternStashModel});
  final double spacing = 10;

  @override
  Widget build(BuildContext context) {
    patternStashModel.load();
    ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: patternStashModel,
      builder: (BuildContext context, _) {
        if (!patternStashModel.loaded) {
          return LoadingScreen();
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: theme.colorScheme.primary,
              actions: [
                PageSelectDropdownButton(onQuit: patternStashModel.reload),
              ],

              title: Text("Patterns"),
            ),

            body: ListView(
              children: [
                for (craft.Pattern pattern in patternStashModel.patterns!)
                  PatternListTile(
                    pattern: pattern,
                    patternStashModel: patternStashModel,
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}
