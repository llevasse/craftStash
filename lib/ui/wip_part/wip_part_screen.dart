import 'package:craft_stash/ui/core/loading_screen.dart';
import 'package:craft_stash/ui/wip_part/widget/wip_part_rows.dart';
import 'package:craft_stash/ui/wip_part/wip_part_model.dart';
import 'package:flutter/material.dart';

class WipPartScreen extends StatelessWidget {
  final WipPartModel wipPartModel;

  const WipPartScreen({super.key, required this.wipPartModel});

  @override
  Widget build(BuildContext context) {
    wipPartModel.load();
    ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: wipPartModel,
      builder: (BuildContext context, _) {
        if (!wipPartModel.loaded) {
          return LoadingScreen();
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(wipPartModel.wipPart!.part!.name),
              backgroundColor: theme.colorScheme.primary,
            ),

            body: Container(
              padding: EdgeInsets.all(wipPartModel.spacing),
              child: Column(
                spacing: wipPartModel.spacing,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: wipPartRowsListView(wpm: wipPartModel)),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
