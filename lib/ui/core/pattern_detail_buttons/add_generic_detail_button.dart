import 'package:craft_stash/class/stitch.dart';
import 'package:flutter/material.dart';

class AddGenericDetailButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (text == null && stitch == null) {
      throw GenericDetailButtonMissingElements(
        "AddGenericDetailButton() need either a String or Stitch ar argument",
      );
    }
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style:
          style ??
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
        text ?? stitch!.abreviation,
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
