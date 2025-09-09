import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:flutter/material.dart';

class StitchDetailDialog extends StatefulWidget {
  PatternRowDetail detail;
  int? prevRowStitchNb;

  StitchDetailDialog({super.key, required this.detail, this.prevRowStitchNb});
  @override
  State<StatefulWidget> createState() => _StitchDetailDialogState();
}

class _StitchDetailDialogState extends State<StitchDetailDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  TextFormField _repeatXTimeInput() {
    return TextFormField(
      initialValue: widget.detail.repeatXTime.toString(),
      decoration: InputDecoration(label: Text("Repeat x times")),
      keyboardType: TextInputType.number,
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

  Set selection = {false};

  Widget _toggleButton() {
    return SegmentedButton(
      segments: [
        ButtonSegment(value: true, label: Text("True")),
        ButtonSegment(value: false, label: Text("False")),
      ],
      selected: selection,
      onSelectionChanged: (p0) {
        setState(() {
          widget.detail.repeatXTime = widget.prevRowStitchNb!;
          selection = p0;
        });
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
            _repeatXTimeInput(),
            ?widget.prevRowStitchNb != null ? _toggleButton() : null,
            deleteButton(),
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

        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              if (widget.detail.repeatXTime <= 0) {
                widget.detail.rowId = -1;
                Navigator.pop(context, widget.detail);
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
