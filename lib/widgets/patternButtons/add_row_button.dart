import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/pages/row_page.dart';

import 'package:flutter/material.dart';

class AddRowButton extends StatefulWidget {
  final Future<void> Function() updatePattern;
  PatternPart part;
  int startRow;
  int numberOfRows;
  Map<int, String> yarnIdToNameMap;
  AddRowButton({
    super.key,
    required this.part,
    required this.updatePattern,
    this.startRow = 1,
    this.numberOfRows = 1,
    this.yarnIdToNameMap = const {}
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
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            settings: RouteSettings(name: "row"),
            builder: (BuildContext context) => RowPage(
              part: widget.part,
              updatePattern: widget.updatePattern,
              startRow: widget.startRow,
              numberOfRows: widget.numberOfRows,
              yarnIdToNameMap: widget.yarnIdToNameMap,
            ),
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
