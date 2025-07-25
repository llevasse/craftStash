import 'package:craft_stash/widgets/yarnButtons/yarn_collection_form.dart';
import 'package:flutter/material.dart';

class AddYarnButton extends StatefulWidget {
  final Future<void> Function() updateYarn;

  const AddYarnButton({super.key, required this.updateYarn});

  @override
  State<StatefulWidget> createState() => _AddYarnButton();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _AddYarnButton extends State<AddYarnButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) => YarnCollectionForm(
            title: "Collections",
            updateYarn: widget.updateYarn,
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
