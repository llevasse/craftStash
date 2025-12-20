import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:flutter/material.dart';

class StitchDetailDialog extends StatefulWidget {
  PatternRowDetail detail;
  int? prevRowStitchNb;
  int currentRowStitchNb;
  int previousRowStitchNbUsed;
  int originalPreviousRowStitchNbUsed = 0;

  StitchDetailDialog({
    super.key,
    required this.detail,
    required this.currentRowStitchNb,
    this.prevRowStitchNb,
    this.previousRowStitchNbUsed = 0,
  });
  @override
  State<StatefulWidget> createState() => _StitchDetailDialogState();
}

class _StitchDetailDialogState extends State<StitchDetailDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool displaySelector = false;
  Set selection = {false};

  @override
  void initState() {
    super.initState();
    widget.originalPreviousRowStitchNbUsed = widget.previousRowStitchNbUsed;
    widget.previousRowStitchNbUsed +=
        widget.detail.repeatXTime * (widget.detail.stitch?.stitchNb ?? 1);
    displaySelectorChecker();
    // print("Init StitchDetailDialog with var : ");
    // print("\tDetail : ${widget.detail.toString()}");
    // print("\tPrevious row stitch nb : ${widget.prevRowStitchNb}");
    // print("\tPrevious row stitch nb used : ${widget.previousRowStitchNbUsed}");
    // print(
    //   "\tPrevious row stitch nb used (without this detail) : ${widget.originalPreviousRowStitchNbUsed}",
    // );
    // print("\tCurrent row stitch nb : ${widget.currentRowStitchNb}");
  }

  displaySelectorChecker() {
    displaySelector = false;
    if (widget.prevRowStitchNb != null &&
        widget.prevRowStitchNb! > widget.previousRowStitchNbUsed) {
      displaySelector = true;
    }
  }

  TextFormField _inStitchInput() {
    return TextFormField(
      initialValue: widget.detail.note,
      decoration: InputDecoration(label: Text("In ...")),
      keyboardType: TextInputType.text,
      onChanged: (value) {
        value = value.trim();
        widget.detail.note = value.isEmpty ? null : value;
        setState(() {});
      },
      validator: (value) {
        return null;
      },
      onSaved: (newValue) {
        widget.detail.note = newValue?.trim();
      },
    );
  }

  TextFormField _repeatXTimeInput() {
    return TextFormField(
      initialValue: widget.detail.repeatXTime.toString(),
      decoration: InputDecoration(label: Text("Repeat x times")),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        widget.previousRowStitchNbUsed =
            widget.originalPreviousRowStitchNbUsed +
            (int.tryParse(value.trim()) ?? 0) *
                (widget.detail.stitch?.stitchNb ?? 1);
        if (widget.prevRowStitchNb != null) {
          setState(() {});
        }
      },
      validator: (value) {
        if (value == null ||
            value.isEmpty ||
            int.tryParse(value.trim()) == null) {
          return "Invalid input";
        }
        return null;
      },
      onSaved: (newValue) {
        if (selection.first == false) {
          widget.detail.repeatXTime = int.parse(newValue!.trim());
        }
      },
    );
  }

  Widget _toggleButton() {
    return SegmentedButton(
      segments: [
        ButtonSegment(value: true, label: Text("Around")),
        ButtonSegment(value: false, label: Text("Custom")),
      ],
      selected: selection,
      onSelectionChanged: (p0) {
        if (p0.first == true) {
          widget.detail.repeatXTime = widget.prevRowStitchNb!;
        }
        selection = p0;
        setState(() {});
      },
    );
  }

  TextButton deleteButton() {
    return TextButton(
      onPressed: () {
        widget.detail.rowId = -1;
        Navigator.pop(context, widget.detail);
      },
      child: Text("Delete"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit row detail"),

      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?displaySelector ? _toggleButton() : null,
            ?selection.first == false ? _repeatXTimeInput() : null,
            _inStitchInput(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, widget.detail);
          },
          child: Text("Cancel"),
        ),
        deleteButton(),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              if (widget.detail.repeatXTime <= 0) {
                widget.detail.rowId = -1;
                Navigator.pop(context, widget.detail);
              }

              if (widget.prevRowStitchNb != null && selection.first == true) {
                // if set as around, set to prevRowStitchNumber - preRowStitchUsed
                widget.detail.repeatXTime =
                    ((widget.prevRowStitchNb! -
                                widget.originalPreviousRowStitchNbUsed) /
                            (widget.detail.stitch?.nbStsTaken ?? 1))
                        .floor();
              }
              Navigator.pop(context, widget.detail);
            }
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
