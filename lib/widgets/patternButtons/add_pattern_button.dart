import 'package:craft_stash/pages/newPatternPage.dart';
import 'package:flutter/material.dart';

class AddPatternButton extends StatefulWidget {
  final Future<void> Function() updateYarn;

  const AddPatternButton({super.key, required this.updateYarn});

  @override
  State<StatefulWidget> createState() => _AddPatternButton();
}

class _AddPatternButton extends State<AddPatternButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      onPressed: () async {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const NewPatternPage(),
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
        "Add pattern",
        style: TextStyle(color: theme.colorScheme.secondary),
        textScaler: TextScaler.linear(1.25),
      ),
    );
  }
}
