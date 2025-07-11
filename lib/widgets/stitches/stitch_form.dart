import 'package:craft_stash/class/stitch.dart';
import 'package:flutter/material.dart';

class StitchForm extends StatefulWidget {
  final void Function() onValidate;
  const StitchForm({super.key, required this.onValidate});

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
              await insertStitchInDb(
                Stitch(
                  abreviation: abreviation,
                  name: fullName,
                  description: description,
                ),
              );
              widget.onValidate.call();
            }
            Navigator.pop(context);
          },
          child: Text("Add stitch"),
        ),
      ],
    );
  }
}
