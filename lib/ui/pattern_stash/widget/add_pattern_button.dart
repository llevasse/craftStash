import 'package:craft_stash/data/repository/pattern_repository.dart';
import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:craft_stash/ui/pattern/pattern_screen.dart';
import 'package:flutter/material.dart';

class AddPatternButton extends StatelessWidget {
  final Future<void> Function() onQuitPage;

  const AddPatternButton({super.key, required this.onQuitPage});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => PatternScreen(
              patternModel: PatternModel(
                patternRepository: PatternRepository(),
              ),
            ),
          ),
        );
        onQuitPage();
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

        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
      child: Text(
        "Add pattern",
        style: TextStyle(color: theme.colorScheme.secondary),
        textScaler: TextScaler.linear(1.25),
      ),
    );
  }
}
