import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/widgets/patternButtons/add_custom_detail_button.dart';
import 'package:craft_stash/widgets/yarn/pattern_yarn_list.dart';
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
  State<StatefulWidget> createState() => _ColorChangeButtonState();
}

class _ColorChangeButtonState extends State<ColorChangeButton> {
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
                      patternId: widget.patternId,
                      onPress: (yarn) async {
                        PatternRowDetail p = PatternRowDetail(
                          rowId: widget.rowId,
                          stitchId: stitchToIdMap["color change"]!,
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
