import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/data/repository/pattern_part_repository.dart';
import 'package:craft_stash/main.dart';
import 'package:craft_stash/ui/pattern_part/pattern_part_model.dart';
import 'package:craft_stash/ui/pattern_part/pattern_part_screen.dart';
import 'package:flutter/material.dart';

class AddPartButton extends StatelessWidget {
  final Future<void> Function() updatePatternListView;
  craft.Pattern pattern;
  AddPartButton({
    super.key,
    required this.updatePatternListView,
    required this.pattern,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return TextButton(
      onPressed: () async {
        if (debug) print("on addPartButton ${pattern.yarnIdToNameMap}");
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            settings: RouteSettings(name: "part"),
            builder: (BuildContext context) => PatternPartScreen(
              patternPartModel: PatternPartModel(
                patternPartRepository: PatternPartRepository(),
                patternId: pattern.patternId,
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
        "Add part",
        style: TextStyle(color: theme.colorScheme.secondary),
        textScaler: TextScaler.linear(1.25),
      ),
    );
  }
}
