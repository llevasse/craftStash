import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/data/repository/pattern/pattern_row_repository.dart';
import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/ui/row/row_screen.dart';
import 'package:craft_stash/ui/core/pattern_detail_buttons/add_custom_detail_button.dart';
import 'package:flutter/material.dart';

class RowSubrowButton extends AddCustomDetailButton {
  PatternRowModel patternRowModel;

  RowSubrowButton({super.key, required this.patternRowModel})
    : super(text: "New sequence", onPressed: patternRowModel.addSubrow);
  @override
  Widget build(BuildContext context) {
    return AddCustomDetailButton(
      text: "New sequence",
      onPressed: (detail) async {
        PatternRowDetail? t =
            await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    settings: RouteSettings(name: "subrow"),
                    builder: (BuildContext context) => RowScreen(
                      patternRowModel: PatternRowModel(
                        patternRowRepository: PatternRowRepository(),
                        yarnNameMap: patternRowModel.yarnNameMap,
                        part: patternRowModel.part,
                        isSubRow: true,
                      ),
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
