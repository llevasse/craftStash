import 'package:flutter/material.dart';

class AddDetailButton extends StatefulWidget {
  final Function() onPressed;
  final String text;
  final ButtonStyle? style;
  const AddDetailButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.style,
  });

  @override
  State<StatefulWidget> createState() => _AddDetailButton();
}

class _AddDetailButton extends State<AddDetailButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      onPressed: widget.onPressed,
      style:
          widget.style ??
          ButtonStyle(
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
        widget.text,
        style: TextStyle(color: theme.colorScheme.secondary),
        textScaler: TextScaler.linear(1.25),
      ),
    );
  }
}
