import 'package:craft_stash/services/database_service.dart';
import 'package:craft_stash/ui/yarn_stash/widget/yarn_collection_form.dart';
import 'package:flutter/material.dart';

class RecreateDbButton extends StatelessWidget {
  final Future<void> Function() onQuitPage;

  const RecreateDbButton({super.key, required this.onQuitPage});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      onPressed: () async {
        await DbService().recreateDb();
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
        "Recreate db",
        style: TextStyle(color: theme.colorScheme.secondary),
        textScaler: TextScaler.linear(1.25),
      ),
    );
  }
}
