import 'package:craft_stash/class/stitch.dart';
import 'package:flutter/material.dart';

class AddGenericDetailButton extends StatefulWidget {
  final Function() onPressed;
  final Function()? onLongPress;
  final String? text;
  final ButtonStyle? style;
  final Stitch? stitch;
  const AddGenericDetailButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.text,
    this.stitch,
    this.style,
  });

  @override
  State<StatefulWidget> createState() => _AddGenericDetailButton();
}

class _AddGenericDetailButton extends State<AddGenericDetailButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text == null && widget.stitch == null) {
      throw GenericDetailButtonMissingElements(
        "AddGenericDetailButton() need either a String or Stitch ar argument",
      );
    }
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      onPressed: widget.onPressed,
      onLongPress: widget.onLongPress,
      style:
          widget.style ??
          ButtonStyle(
            side: WidgetStatePropertyAll(
              BorderSide(color: theme.colorScheme.primary, width: 0),
            ),
            shape: WidgetStatePropertyAll(
              RoundedSuperellipseBorder(
                borderRadius: BorderRadiusGeometry.all(Radius.circular(18)),
              ),
            ),

            backgroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
          ),
      child: Text(
        widget.text ?? widget.stitch!.abreviation,
        style: TextStyle(color: theme.colorScheme.secondary),
        textScaler: TextScaler.linear(1.25),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class GenericDetailButtonMissingElements implements Exception {
  GenericDetailButtonMissingElements(this.cause);
  String cause;
}
