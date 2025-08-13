import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/data/repository/yarn/collection_repository.dart';
import 'package:craft_stash/data/repository/yarn/yarn_repository.dart';
import 'package:craft_stash/ui/core/widgets/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';

class CollectionForm extends StatefulWidget {
  final Future<void> Function() updateYarn;
  final Future<void> Function(YarnCollection) ifValideFunction;
  String confirm;
  String cancel;
  String title;
  bool fill;
  bool allowDelete;
  YarnCollection base;

  CollectionForm({
    super.key,
    required this.base,
    required this.updateYarn,
    required this.ifValideFunction,
    required this.confirm,
    required this.cancel,
    required this.title,
    this.fill = false,
    this.allowDelete = false,
  });

  @override
  State<StatefulWidget> createState() => _CollectionForm();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _CollectionForm extends State<CollectionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Form _createForm() {
    return Form(
      key: _formKey,
      child: IntrinsicHeight(
        child: SizedBox(
          height: 410,
          width: 300,
          child: ListView(
            //spacing: spacing,
            children: [
              TextFormField(
                initialValue: widget.fill == true ? widget.base.name : null,
                decoration: InputDecoration(label: Text("Collection name")),
                validator: (value) {
                  return null;
                },
                onSaved: (newValue) {
                  newValue = newValue?.trim();
                  if (newValue == null || newValue.isEmpty) {
                    newValue = "Unknown";
                  }
                  widget.base.name = newValue;
                },
              ),

              TextFormField(
                initialValue: widget.fill == true
                    ? widget.base.thickness.toStringAsFixed(2)
                    : null,
                keyboardType: TextInputType.numberWithOptions(),
                decoration: InputDecoration(label: Text("Thickness")),
                validator: (value) {
                  return null;
                },
                onSaved: (newValue) {
                  newValue = newValue?.trim();
                  if (newValue == null || newValue.isEmpty) {
                    newValue = "0.0";
                  }
                  widget.base.thickness = double.parse(newValue);
                },
              ),

              TextFormField(
                initialValue: widget.fill == true
                    ? widget.base.minHook.toStringAsFixed(2)
                    : null,
                keyboardType: TextInputType.numberWithOptions(),
                decoration: InputDecoration(label: Text("Min hook size")),
                validator: (value) {
                  return null;
                },
                onSaved: (newValue) {
                  newValue = newValue?.trim();
                  if (newValue == null || newValue.isEmpty) {
                    newValue = "0.0";
                  }
                  widget.base.minHook = double.parse(newValue);
                },
              ),

              TextFormField(
                initialValue: widget.fill == true
                    ? widget.base.maxHook.toStringAsFixed(2)
                    : null,
                keyboardType: TextInputType.numberWithOptions(),
                decoration: InputDecoration(label: Text("Max hook size")),
                validator: (value) {
                  return null;
                },
                onSaved: (newValue) {
                  newValue = newValue?.trim();
                  if (newValue == null || newValue.isEmpty) {
                    newValue = "0.0";
                  }
                  widget.base.maxHook = double.parse(newValue);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // updateDropdownMenuList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: _createForm(),
      actions: <Widget>[
        if (widget.allowDelete)
          TextButton(
            onPressed: () async {
              if (await showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(
                        "Do you want to delete this coletion and all it's yarns",
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
                            try {
                              await YarnRepository().deleteYarnsByCollectionId(
                                widget.base.id,
                              );
                              await CollectionRepository().deleteYarnCollection(
                                widget.base.id,
                              );
                              await widget.updateYarn();
                            } catch (e) {
                              await showDialog(
                                context: context,
                                builder: (context) =>
                                    ErrorDialog(error: e.toString()),
                              );
                            }
                            Navigator.pop(context, "delete");
                          },
                          child: Text("Delete"),
                        ),
                      ],
                    ),
                  ) ==
                  "delete") {
                Navigator.pop(context);
              }
            },
            child: Text("Delete"),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.cancel),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              await widget.ifValideFunction(widget.base);
            }
            await widget.updateYarn();
            Navigator.pop(context);
            setState(() {});
          },
          child: Text(widget.confirm),
        ),
      ],
    );
  }
}
