import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/pages/new_sub_row_page.dart';
import 'package:craft_stash/widgets/patternButtons/add_custom_detail_button.dart';
import 'package:flutter/material.dart';

class NewSubrowButton extends StatefulWidget {
  int? rowId;
  int? partId;
  Future<void> Function(PatternRowDetail?) onPressed;

  NewSubrowButton({
    super.key,
    this.partId,
    this.rowId,
    required this.onPressed,
  });
  @override
  State<StatefulWidget> createState() => _NewSubrowButtonState();
}

class _NewSubrowButtonState extends State<NewSubrowButton> {
  @override
  Widget build(BuildContext context) {
    return AddCustomDetailButton(
      text: "New sequence",
      onPressed: () async {
        PatternRowDetail? t =
            await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    settings: RouteSettings(name: "subrow"),
                    builder: (BuildContext context) => NewSubRowPage(
                      rowId: widget.rowId,
                      partId: widget.partId,
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
