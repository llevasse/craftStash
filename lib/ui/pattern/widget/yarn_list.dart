import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/ui/yarn_form_dialog/yarn_form_dialog_model.dart';
import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:craft_stash/ui/core/widgets/pattern_yarn_list.dart';
import 'package:craft_stash/ui/core/widgets/dialogs/yarn_list_dialog.dart';
import 'package:craft_stash/ui/yarn_form_dialog/yarn_form_dialog_screen.dart';
import 'package:flutter/material.dart';

class PatternYarnListWidget extends StatelessWidget {
  PatternYarnListWidget({
    super.key,
    required this.context,
    required this.patternModel,
    this.spacing = 5,
  });

  late void Function() yarnListInitFunction;
  final PatternModel patternModel;
  final double spacing;
  BuildContext context;

  void _yarnListOnAddYarnPress() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => YarnListDialog(
        onPressed: (yarn, numberOfYarns) async {
          try {
            await patternModel.insertYarn(
              yarnId: yarn.id,
              inPreviewId: numberOfYarns + 1,
            );
            patternModel.pattern?.yarnIdToNameMap[numberOfYarns + 1] =
                yarn.colorName;
            yarnListInitFunction.call();
          } catch (e) {}
        },
      ),
    );
  }

  void _yarnListOnPress({required Yarn yarn}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => YarnForm(
        model: YarnFormDialogModel(
          fill: true,
          readOnly: true,
          base: yarn,
          confirm: "close",
          cancel: "",
          title: yarn.colorName,
          showSkeins: false,
        ),
      ),
    );
  }

  void _yarnListOnLongPress({required Yarn yarn}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () async {
                int inPreviewId = yarn.inPreviewId!;
                await showDialog(
                  context: context,
                  builder: (BuildContext context) => YarnListDialog(
                    onPressed: (newYarn, numberOfYarns) async {
                      try {
                        await patternModel.updateYarn(
                          yarnId: newYarn.id,
                          inPreviewId: inPreviewId,
                        );
                        patternModel.pattern?.yarnIdToNameMap[inPreviewId] =
                            newYarn.colorName;
                        yarnListInitFunction.call();
                        Navigator.pop(context);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                );
              },
              child: Text("Replace"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await patternModel.deleteYarn(
                    yarnId: yarn.id,
                    inPatternYarnId: yarn.inPreviewId!,
                  );
                  yarnListInitFunction.call();
                } catch (e) {}
              },
              child: Text("Remove"),
            ),
          ],
        ),
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
          onPress: (yarn) {
            _yarnListOnPress(yarn: yarn);
          },
          onLongPress: (yarn) {
            _yarnListOnLongPress(yarn: yarn);
          },
          onAddYarnPress: () {
            _yarnListOnAddYarnPress();
          },
          builder: (BuildContext context, void Function() methodFromChild) {
            yarnListInitFunction = methodFromChild;
          },
          patternId: patternModel.pattern?.patternId,
        ),
      ],
    );
  }
}
