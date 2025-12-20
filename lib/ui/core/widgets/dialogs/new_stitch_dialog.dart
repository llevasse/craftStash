import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/data/repository/pattern/pattern_row_repository.dart';
import 'package:craft_stash/data/repository/stitch_repository.dart';
import 'package:craft_stash/ui/core/widgets/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';

class NewStitchDialog extends StatefulWidget {
  final void Function() onValidate;
  final Stitch? base;
  const NewStitchDialog({super.key, required this.onValidate, this.base});

  @override
  State<StatefulWidget> createState() => _NewStitchDialogState();
}

class _NewStitchDialogState extends State<NewStitchDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String abreviation = "";
  String? fullName;
  String? description;
  late int fillXStitches;
  late int createXStitches;

  @override
  void initState() {
    fillXStitches = widget.base?.nbStsTaken ?? 0;
    createXStitches = widget.base?.stitchNb ?? 1;
  }

  Widget _createAbreviationInput() {
    return TextFormField(
      decoration: InputDecoration(label: Text("Abreviation")),
      initialValue: widget.base?.abreviation,
      maxLength: 15,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return ("Abreviation can't be empty");
        }
        return null;
      },
      onSaved: (newValue) {
        abreviation = newValue!.trim();
      },
    );
  }

  Widget _createFullNameInput() {
    return TextFormField(
      decoration: InputDecoration(label: Text("Full name")),
      initialValue: widget.base?.name,
      maxLength: 50,
      validator: (value) {
        return null;
      },
      onSaved: (newValue) {
        fullName = newValue?.trim();
      },
    );
  }

  Widget _createDescriptionInput() {
    return TextFormField(
      decoration: InputDecoration(label: Text("Description")),
      maxLines: 5,
      minLines: 2,
      maxLength: 500,
      initialValue: widget.base?.description,
      validator: (value) {
        return null;
      },
      onSaved: (newValue) {
        description = newValue?.trim();
      },
    );
  }

  Widget _createStitchFillNumberInput() {
    return TextFormField(
      decoration: InputDecoration(
        label: Text("Number of stitch used in previous row"),
      ),
      initialValue: fillXStitches.toString(),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || int.tryParse(value) == null) {
          return "Value must be a valid number";
        }
        return null;
      },
      onSaved: (newValue) {
        fillXStitches = int.tryParse((newValue!.trim())) ?? 0;
      },
    );
  }

  Widget _createStitchCreateNumberInput() {
    return TextFormField(
      decoration: InputDecoration(
        label: Text("Number of stitch in this stitch"),
      ),
      initialValue: createXStitches.toString(),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || int.tryParse(value) == null) {
          return "Value must be a valid number";
        }
        return null;
      },
      onSaved: (newValue) {
        createXStitches = int.tryParse((newValue!.trim())) ?? 0;
      },
    );
  }

  List<Widget> actions() {
    List<Widget> l = List.empty(growable: true);
    if (widget.base != null) {
      l.add(
        TextButton(
          onPressed: () async {
            try {
              await StitchRepository().deleteStitch(widget.base!);
              Navigator.pop(context);
            } on StitchIsUsed catch (e) {
              showDialog(
                context: context,
                builder: (BuildContext context) => ErrorDialog(error: e.cause),
              );
            }
          },
          child: Text("Delete stitch"),
        ),
      );
    }
    l.add(
      TextButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            Stitch s = Stitch(
              abreviation: abreviation,
              name: fullName,
              description: description,
              nbStsTaken: fillXStitches,
              stitchNb: createXStitches,
            );
            if (widget.base == null) {
              await StitchRepository().insertStitch(s);
            } else {
              s.id = widget.base!.id;
              await StitchRepository().updateStitch(s);
            }
            widget.onValidate.call();
            Navigator.pop(context, s);
          }
        },
        child: Text(widget.base == null ? "Add stitch" : "Edit stitch"),
      ),
    );
    return (l);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.base == null ? "Create stitch" : "Edit stitch"),
      content: Form(
        key: _formKey,
        child: ListView(
          children: [
            _createAbreviationInput(),
            _createFullNameInput(),
            _createDescriptionInput(),
            _createStitchFillNumberInput(),
            _createStitchCreateNumberInput(),
          ],
        ),
        // child: Column(
        //   mainAxisSize: MainAxisSize.min,
        // ),
      ),
      actions: actions(),
    );
  }
}
