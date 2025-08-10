import 'package:craft_stash/data/repository/pattern/pattern_part_repository.dart';
import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:craft_stash/ui/pattern_part/pattern_part_model.dart';
import 'package:craft_stash/ui/pattern_part/pattern_part_screen.dart';
import 'package:flutter/material.dart';

class AddPartButton extends StatelessWidget {
  final PatternModel patternModel;
  const AddPartButton({super.key, required this.patternModel});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return TextButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            settings: RouteSettings(name: "part"),
            builder: (BuildContext context) => PatternPartScreen(
              patternPartModel: PatternPartModel(
                patternPartRepository: PatternPartRepository(),
                patternId: patternModel.pattern!.patternId,
              ),
            ),
          ),
        );
        patternModel.reload();
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
