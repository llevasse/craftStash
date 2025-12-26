import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/data/repository/stitch_repository.dart';
import 'package:craft_stash/main.dart';
import 'package:craft_stash/ui/core/pattern_detail_buttons/add_custom_detail_button.dart';
import 'package:craft_stash/ui/core/widgets/pattern_yarn_list.dart';
import 'package:flutter/material.dart';

class StartColorButton extends AddCustomDetailButton {
  Future<void> Function(PatternRowDetail?) onReturn;
  final int rowId;
  final int patternId;

  StartColorButton({
    super.key,
    required this.rowId,
    required this.patternId,
    required this.onReturn,
  }) : super(
         text: "Start color",
         onPressed: (p0) {
           return Future(() => null);
         },
       );

  @override
  Widget build(BuildContext context) {
    return AddCustomDetailButton(
      text: "Start color",
      onPressed: (detail) async {
        PatternRowDetail? t =
            await showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text("Yarn selection"),
                    content: PatternYarnList(
                      patternId: patternId,
                      onPress: (yarn) async {
                        print(yarn.toMap(withId: true));
                        PatternRowDetail p = PatternRowDetail(
                          rowId: rowId,
                          stitchId: stitchToIdMap["start color"]!,
                          stitch: await StitchRepository().getStitchById(
                            stitchToIdMap["start color"]!,
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
        if (debug) {
          print("StartColorButton return : $t");
        }
        if (t == null) return;
        await onReturn.call(t);
      },
    );
  }
}
