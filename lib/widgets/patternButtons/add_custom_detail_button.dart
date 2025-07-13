import 'package:craft_stash/widgets/patternButtons/add_generic_detail_button.dart';
import 'package:flutter/material.dart';

class AddCustomDetailButton extends StatefulWidget {
  final Function() onPressed;
  final String text;
  final ButtonStyle? style;
  const AddCustomDetailButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.style,
  });

  @override
  State<StatefulWidget> createState() => _AddCustomDetailButton();
}

class _AddCustomDetailButton extends State<AddCustomDetailButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return AddGenericDetailButton(
      onPressed: widget.onPressed,
      style:
          widget.style ??
          ButtonStyle(
            side: WidgetStatePropertyAll(
              BorderSide(color: theme.colorScheme.primary, width: 1),
            ),
            shape: WidgetStatePropertyAll(
              RoundedSuperellipseBorder(
                borderRadius: BorderRadiusGeometry.all(Radius.circular(18)),
              ),
            ),

            backgroundColor: WidgetStateProperty.all(
              theme.colorScheme.tertiary,
            ),
          ),
      text: widget.text,
    );
  }
}
