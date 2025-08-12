import 'package:craft_stash/main.dart';
import 'package:craft_stash/ui/core/loading_screen.dart';
import 'package:craft_stash/ui/stitch/stitch_model.dart';
import 'package:craft_stash/ui/settings/widget/print_db_button.dart';
import 'package:craft_stash/ui/settings/widget/recreate_db_button.dart';
import 'package:craft_stash/ui/stitch/widget/stitch_list.dart';
import 'package:flutter/material.dart';

class StitchScreen extends StatelessWidget {
  final StitchModel stitchModel;

  const StitchScreen({super.key, required this.stitchModel});
  final double spacing = 10;

  @override
  Widget build(BuildContext context) {
    stitchModel.load();
    ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: stitchModel,
      builder: (BuildContext context, _) {
        if (!stitchModel.loaded) {
          return LoadingScreen();
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: theme.colorScheme.primary,
              title: Text("Stitch"),
            ),

            body: Container(
              padding: EdgeInsets.all(spacing),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: StitchScreenStitchList(stitchModel: stitchModel),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
