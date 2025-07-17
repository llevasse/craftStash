import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/pages/sequence_page.dart';
import 'package:craft_stash/widgets/patternButtons/add_custom_detail_button.dart';
import 'package:flutter/material.dart';

class NewSubrowButton extends AddCustomDetailButton {
  int? rowId;

  NewSubrowButton({super.key, this.rowId, required super.onPressed})
    : super(text: "New sequence");
  @override
  State<StatefulWidget> createState() => _NewSubrowButtonState();
}

class _NewSubrowButtonState extends State<NewSubrowButton> {
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
                    builder: (BuildContext context) =>
                        SequencePage(rowId: widget.rowId),
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
