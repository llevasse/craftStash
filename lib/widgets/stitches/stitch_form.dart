import 'package:craft_stash/class/stitch.dart';
import 'package:flutter/material.dart';

class StitchForm extends StatefulWidget {
  final void Function() onValidate;
  final Stitch? base;
  const StitchForm({super.key, required this.onValidate, this.base});

  @override
  State<StatefulWidget> createState() => _StitchFormState();
}

class _StitchFormState extends State<StitchForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String abreviation = "";
  String? fullName;
  String? description;

  Widget _createAbreviationInput() {
    return TextFormField(
      decoration: InputDecoration(label: Text("Abreviation")),
      initialValue: widget.base?.abreviation,
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
      initialValue: widget.base?.description,
      validator: (value) {
        return null;
      },
      onSaved: (newValue) {
        description = newValue?.trim();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create stitch"),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            _createAbreviationInput(),
            _createFullNameInput(),
            _createDescriptionInput(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Stitch s = Stitch(
                abreviation: abreviation,
                name: fullName,
                description: description,
              );
              if (widget.base == null) {
                await insertStitchInDb(s);
              } else {
                s.id = widget.base!.id;
                await updateStitchInDb(s);
              }
              widget.onValidate.call();
              Navigator.pop(context, s);
            }
          },
          child: Text("Add stitch"),
        ),
      ],
    );
  }
}
