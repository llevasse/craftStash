import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/data/repository/pattern_row_repository.dart';
import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/ui/row/row_screen.dart';

import 'package:flutter/material.dart';

class AddRowButton extends StatelessWidget {
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
    this.yarnIdToNameMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return TextButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            settings: RouteSettings(name: "row"),
            builder: (BuildContext context) => RowScreen(
              patternRowModel: PatternRowModel(
                patternRowRepository: PatternRowRepository(),
                partId: part.partId,
                patternId: part.patternId,
                yarnNameMap: yarnIdToNameMap,
              ),
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
