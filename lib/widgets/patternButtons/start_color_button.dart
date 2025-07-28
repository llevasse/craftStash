import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/widgets/patternButtons/add_custom_detail_button.dart';
import 'package:craft_stash/widgets/yarn/pattern_yarn_list.dart';
import 'package:flutter/material.dart';

class StartColorButton extends AddCustomDetailButton {
  final int rowId;
  final int patternId;

  StartColorButton({
    super.key,
    required this.rowId,
    required this.patternId,
    required super.onPressed,
  }) : super(text: "Start color");
  @override
  State<StatefulWidget> createState() => _StartWithColorButtonState();
}

class _StartWithColorButtonState extends State<StartColorButton> {
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
                      patternId: widget.patternId,
                      onPress: (yarn) async {
                        PatternRowDetail p = PatternRowDetail(
                          rowId: widget.rowId,
                          stitchId: stitchToIdMap["start color"]!,
                          inPatternYarnId: yarn.inPatternId,
                        );
                        // await insertPatternRowDetailInDb(p);
                        Navigator.pop(context, p);
                      },
                    ),
                  ),
                )
                as PatternRowDetail?;
        if (t == null) return;
        await widget.onPressed.call(t);
        setState(() {});
      },
    );
  }
}
