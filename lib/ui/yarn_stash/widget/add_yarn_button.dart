import 'package:craft_stash/ui/yarn_stash/widget/yarn_collection_form.dart';
import 'package:flutter/material.dart';

typedef MenuEntry = DropdownMenuEntry<String>;

class AddYarnButton extends StatelessWidget {
  final Future<void> Function() onQuitPage;

  const AddYarnButton({super.key, required this.onQuitPage});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) =>
              YarnCollectionForm(title: "Collections", updateYarn: onQuitPage),
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

        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
      child: Text(
        "Add yarn",
        style: TextStyle(color: theme.colorScheme.secondary),
        textScaler: TextScaler.linear(1.25),
      ),
    );
  }
}
