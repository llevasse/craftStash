import 'package:craft_stash/data/repository/pattern/pattern_row_repository.dart';
import 'package:craft_stash/ui/pattern_part/pattern_part_model.dart';
import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/ui/row/row_screen.dart';

import 'package:flutter/material.dart';

class AddRowButton extends StatelessWidget {
  PatternPartModel patternPartModel;
  int startRow;
  int numberOfRows;
  AddRowButton({
    super.key,
    required this.patternPartModel,
    this.startRow = 1,
    this.numberOfRows = 1,
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
                part: patternPartModel.part,
                yarnNameMap: patternPartModel.yarnNameMap,
                prevRowStitchNb:
                    patternPartModel.part?.rows.last.stitchesPerRow ?? 0,
              ),
            ),
          ),
        );
        patternPartModel.reload();
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
