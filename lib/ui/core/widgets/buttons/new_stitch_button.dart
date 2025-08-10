import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/ui/core/pattern_detail_buttons/add_custom_detail_button.dart';
import 'package:craft_stash/ui/core/widgets/dialogs/new)stitch_dialog.dart';
import 'package:flutter/material.dart';

class NewStitchButton extends StatelessWidget {
  Future<void> Function(Stitch?) onPressed;

  NewStitchButton({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return AddCustomDetailButton(
      text: "New stitch",
      onPressed: (detail) async {
        Stitch? s =
            await showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      NewStitchDialog(onValidate: () {}),
                )
                as Stitch?;
        await onPressed(s);
      },
    );
  }
}
