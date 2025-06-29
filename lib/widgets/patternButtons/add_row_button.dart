import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/widgets/patternButtons/row_form.dart';

import 'package:flutter/material.dart';

class AddRowButton extends StatefulWidget {
  final Future<void> Function() updatePattern;
  PatternPart part;
  int startRow;
  int endRow;
  AddRowButton({
    super.key,
    required this.part,
    required this.updatePattern,
    this.startRow = 1,
    this.endRow = 1,
  });

  @override
  State<StatefulWidget> createState() => _AddRowButton();
}

class _AddRowButton extends State<AddRowButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return TextButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) => RowForm(
            part: widget.part,
            updatePattern: widget.updatePattern,
            startRow: widget.startRow,
            endRow: widget.endRow,
          ),
        );
      },
      style: ButtonStyle(
        side: WidgetStatePropertyAll(
          BorderSide(color: theme.colorScheme.primary, width: 5),
        ),
        shape: WidgetStatePropertyAll(
          RoundedSuperellipseBorder(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(18)),
          ),
        ),

        backgroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
      ),
      child: Text(
        "Add row",
        style: TextStyle(color: theme.colorScheme.secondary),
        textScaler: TextScaler.linear(1.25),
      ),
    );
  }
}
