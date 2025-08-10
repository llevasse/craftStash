import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:flutter/material.dart';

class StitchDetailDialog extends StatefulWidget {
  PatternRowDetail detail;

  StitchDetailDialog({super.key, required this.detail});
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
        widget.detail.repeatXTime = int.parse(newValue!.trim());
      },
    );
  }

  TextButton deleteButton() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
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
        child: Column(children: [_repeatXTimeInput(), deleteButton()]),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),

        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              if (widget.detail.repeatXTime <= 0) {
                Navigator.pop(context);
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
