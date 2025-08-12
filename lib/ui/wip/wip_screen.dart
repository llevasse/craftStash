import 'package:craft_stash/ui/core/loading_screen.dart';
import 'package:craft_stash/ui/wip/widget/assembly_input.dart';
import 'package:craft_stash/ui/wip/widget/delete_button.dart';
import 'package:craft_stash/ui/wip/widget/hook_size_input.dart';
import 'package:craft_stash/ui/wip/widget/parts_list_tile.dart';
import 'package:craft_stash/ui/wip/widget/save_button.dart';
import 'package:craft_stash/ui/wip/widget/title_input.dart';
import 'package:craft_stash/ui/wip/widget/yarn_list.dart';
import 'package:craft_stash/ui/wip/wip_model.dart';
import 'package:flutter/material.dart';

class WipScreen extends StatelessWidget {
  final WipModel wipModel;

  const WipScreen({super.key, required this.wipModel});

  @override
  Widget build(BuildContext context) {
    wipModel.load();
    ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: wipModel,
      builder: (BuildContext context, _) {
        if (!wipModel.loaded) {
          return LoadingScreen();
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(wipModel.wip!.name),
              backgroundColor: theme.colorScheme.primary,
              actions: [
                wipDeleteButton(wipModel: wipModel, context: context),
                wipSaveButton(wipModel: wipModel, context: context),
              ],
            ),

            body: Container(
              padding: EdgeInsets.all(wipModel.spacing),
              child: Column(
                spacing: wipModel.spacing,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: wipModel.spacing,
                    children: [
                      Expanded(child: wipTitleInput(wipModel: wipModel)),
                      Expanded(child: wipHookSizeInput(wipModel: wipModel)),
                    ],
                  ),
                  WipYarnList(context: context, wipModel: wipModel),
                  Expanded(
                    child: ListView.builder(
                      itemCount: wipModel.wip!.parts.length,
                      itemBuilder: (_, index) => WipPartsListTile(
                        wipModel: wipModel,
                        wipPart: wipModel.wip!.parts[index],
                      ),
                    ),
                  ),
                  ?wipModel.wip!.pattern!.note != null
                      ? wipAssemblyText(wipModel: wipModel)
                      : null,
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
