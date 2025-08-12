import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/data/repository/wip/wip_repository.dart';
import 'package:craft_stash/ui/wip/wip_model.dart';
import 'package:craft_stash/ui/core/widgets/pattern_yarn_list.dart';
import 'package:craft_stash/ui/core/widgets/dialogs/yarn_list_dialog.dart';
import 'package:craft_stash/ui/core/widgets/dialogs/yarn_form_dialog.dart';
import 'package:flutter/material.dart';

class WipYarnList extends StatelessWidget {
  WipYarnList({
    super.key,
    required this.context,
    required this.wipModel,
    this.spacing = 5,
  });

  late void Function() yarnListInitFunction;
  final WipModel wipModel;
  final double spacing;
  BuildContext context;

  void _yarnListOnPress(Yarn yarn) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => YarnForm(
        fill: true,
        readOnly: true,
        base: yarn,
        confirm: "close",
        cancel: "",
        title: yarn.colorName,
        showSkeins: false,
      ),
    );
  }

  void _yarnListOnLongPress(Yarn yarn) async {
    int inPreviewId = yarn.inPreviewId!;
    await showDialog(
      context: context,
      builder: (BuildContext context) => YarnListDialog(
        onPressed: (newYarn, numberOfYarns) async {
          try {
            await WipRepository().updateYarnInWip(
              yarnId: newYarn.id,
              wipId: wipModel.wip!.id,
              inPreviewId: inPreviewId,
            );
            wipModel.yarnNameMap![inPreviewId] = newYarn.colorName;
            yarnListInitFunction.call();
          } catch (e) {
            print(e.toString());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: spacing,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text("Yarns used :"),
        PatternYarnList(
          onPress: _yarnListOnPress,
          onLongPress: _yarnListOnLongPress,
          builder: (BuildContext context, void Function() methodFromChild) {
            yarnListInitFunction = methodFromChild;
          },
          wipId: wipModel.wip!.id,
        ),
      ],
    );
  }
}
