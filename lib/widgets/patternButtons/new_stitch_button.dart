import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/widgets/patternButtons/add_custom_detail_button.dart';
import 'package:craft_stash/widgets/stitches/stitch_form.dart';
import 'package:flutter/material.dart';

class NewStitchButton extends StatefulWidget {
  Future<void> Function(Stitch?) onPressed;

  NewStitchButton({super.key, required this.onPressed});
  @override
  State<StatefulWidget> createState() => _NewStitchButtonState();
}

class _NewStitchButtonState extends State<NewStitchButton> {
  @override
  Widget build(BuildContext context) {
    return AddCustomDetailButton(
      text: "New stitch",
      onPressed: (detail) async {
        Stitch? s =
            await showDialog(
                  context: context,
                  builder: (BuildContext context) => StitchForm(
                    onValidate: () {
                      setState(() {});
                    },
                  ),
                )
                as Stitch?;
        await widget.onPressed(s);
      },
    );
  }
}
