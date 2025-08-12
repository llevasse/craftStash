import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/data/repository/stitch_repository.dart';
import 'package:craft_stash/ui/core/pattern_detail_buttons/add_custom_detail_button.dart';
import 'package:craft_stash/ui/core/widgets/pattern_yarn_list.dart';
import 'package:flutter/material.dart';

class ColorChangeButton extends AddCustomDetailButton {
  final int rowId;
  final int patternId;

  ColorChangeButton({
    super.key,
    required this.rowId,
    required this.patternId,
    required super.onPressed,
  }) : super(text: "Color change");
  @override
  Widget build(BuildContext context) {
    return AddCustomDetailButton(
      text: "Color change",
      onPressed: (detail) async {
        PatternRowDetail? t =
            await showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text("Yarn selection"),
                    content: PatternYarnList(
                      patternId: patternId,
                      onPress: (yarn) async {
                        PatternRowDetail p = PatternRowDetail(
                          rowId: rowId,
                          stitchId: stitchToIdMap["color change"]!,
                          stitch: await StitchRepository().getStitchById(
                            stitchToIdMap["color change"]!,
                          ),
                          inPatternYarnId: yarn.inPreviewId,
                        );
                        // await insertPatternRowDetail(p);
                        Navigator.pop(context, p);
                      },
                    ),
                  ),
                )
                as PatternRowDetail?;
        if (t == null) return;
        await onPressed.call(t);
      },
    );
  }
}
