import 'package:craft_stash/services/database_service.dart';
import 'package:flutter/material.dart';

class PrintDbButton extends StatelessWidget {
  final Future<void> Function() onQuitPage;

  const PrintDbButton({super.key, required this.onQuitPage});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      onPressed: () async {
        await DbService().printDbTables(
          brand: true,
          material: true,
          pattern: true,
          patternPart: true,
          patternRow: true,
          patternRowDetail: true,
          stitch: true,
          wip: true,
          wipPart: true,
          yarn: true,
          yarnCollection: true,
          yarnInPattern: true,
          yarnInWip: true,
        );
        Navigator.popUntil(context, ModalRoute.withName("/"));
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
        "Print db",
        style: TextStyle(color: theme.colorScheme.secondary),
        textScaler: TextScaler.linear(1.25),
      ),
    );
  }
}
