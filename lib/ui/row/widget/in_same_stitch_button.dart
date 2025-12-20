import 'package:craft_stash/ui/row/row_model.dart';
import 'package:flutter/material.dart';

class InSameStitchButton extends StatefulWidget {
  PatternRowModel patternRowModel;
  Set selection = {0};

  InSameStitchButton({super.key, required this.patternRowModel});

  @override
  State<StatefulWidget> createState() => _InSameStitchButtonState();
}

class _InSameStitchButtonState extends State<InSameStitchButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("In same stitch ?"),
        SegmentedButton(
          segments: [
            ButtonSegment(value: 1, label: Text("Yes")),
            ButtonSegment(value: 0, label: Text("No")),
          ],
          selected: widget.selection,
          onSelectionChanged: (p0) {
            widget.patternRowModel.setInSameStitch(p0.first);
            widget.selection = p0;
            setState(() {});
          },
        ),
      ],
    );
  }
}
