import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/data/repository/pattern_row_repository.dart';
import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/ui/row/row_screen.dart';
import 'package:craft_stash/widgets/patternButtons/add_custom_detail_button.dart';
import 'package:flutter/material.dart';

class RowSubrowButton extends AddCustomDetailButton {
  PatternRowModel patternRowModel;

  RowSubrowButton({super.key, required this.patternRowModel})
    : super(text: "New sequence", onPressed: patternRowModel.addSubrow);
  @override
  State<StatefulWidget> createState() => _NewSubrowButtonState();
}

class _NewSubrowButtonState extends State<RowSubrowButton> {
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
                        yarnNameMap: widget.patternRowModel.yarnNameMap,
                        partId: widget.patternRowModel.partId,
                        patternId: widget.patternRowModel.patternId,
                        isSubRow: true,
                      ),
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
