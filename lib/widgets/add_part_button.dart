import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/pages/pattern_part_page.dart';
import 'package:flutter/material.dart';

class AddPartButton extends StatefulWidget {
  final Future<void> Function() updatePatternListView;
  PatternPart? part;
  craft.Pattern pattern;
  AddPartButton({
    super.key,
    required this.updatePatternListView,
    required this.pattern,
  });

  @override
  State<StatefulWidget> createState() => _AddPartButton();
}

class _AddPartButton extends State<AddPartButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return TextButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            settings: RouteSettings(name: "part"),
            builder: (BuildContext context) => PatternPartPage(
              updatePatternListView: widget.updatePatternListView,
              pattern: widget.pattern,
              part: widget.part,
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
