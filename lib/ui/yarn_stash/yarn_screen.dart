import 'package:craft_stash/ui/core/loading_screen.dart';
import 'package:craft_stash/ui/yarn_stash/widget/stash_list_view.dart';
import 'package:craft_stash/ui/yarn_stash/yarn_model.dart';
import 'package:craft_stash/widgets/page_select_dropdown_button.dart';
import 'package:flutter/material.dart';

class YarnStashScreen extends StatelessWidget {
  final YarnStashModel yarnStashModel;

  const YarnStashScreen({super.key, required this.yarnStashModel});
  final double spacing = 10;

  @override
  Widget build(BuildContext context) {
    yarnStashModel.load();
    ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: yarnStashModel,
      builder: (BuildContext context, _) {
        if (!yarnStashModel.loaded) {
          return LoadingScreen();
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: theme.colorScheme.primary,
              actions: [
                PageSelectDropdownButton(onQuit: yarnStashModel.reload),
              ],

              title: Text("Yarns"),
            ),

            body: yarnStashListView(yarnStashModel: yarnStashModel),
          );
        }
      },
    );
  }
}
