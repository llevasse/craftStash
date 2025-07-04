import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/widgets/patternButtons/stitch_count_button.dart';
import 'package:flutter/material.dart';

class RowForm extends StatefulWidget {
  final Future<void> Function() updatePattern;
  PatternPart part;
  PatternRow? row;
  int startRow;
  int endRow;
  RowForm({
    super.key,
    required this.part,
    required this.updatePattern,
    this.startRow = 0,
    this.endRow = 1,
    this.row,
  });

  @override
  State<StatefulWidget> createState() => _RowFormState();
}

class _RowFormState extends State<RowForm> {
  List<String> stitches = [];
  List<StitchCountButton> details = List.empty(growable: true);
  String detailsString = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PatternRow row = PatternRow(startRow: 0, endRow: 0, stitchesPerRow: 0);
  TextEditingController previewControler = TextEditingController();
  @override
  void initState() {
    getAllStitches();
    row.startRow = widget.startRow;
    row.endRow = widget.endRow;
    if (widget.row != null) {
      row = widget.row!;
      detailsString = "";
      row.details.forEach((detail) {
        if (detail.repeatXTime != 0) {
          if (detail.repeatXTime > 1) {
            detailsString += detail.repeatXTime.toString();
          }
          detailsString += "${detail.stitch}, ";
        }
        details.add(
          StitchCountButton(
            signed: false,
            text: detail.stitch,
            count: detail.repeatXTime,
            increase: () {
              detail.repeatXTime += 1;
              row.stitchesPerRow += 1;
              setState(() {});
            },
            decrease: () {
              detail.repeatXTime -= 1;
              row.stitchesPerRow -= 1;
              setState(() {});
            },
          ),
        );
      });
      previewControler.text = detailsString;
    }
    super.initState();
  }

  Future<void> getAllStitches() async {
    List<Stitch> l = await getAllStitchesInDb();
    for (Stitch stitch in l) {
      // print(stitch.abreviation);
      stitches.add(stitch.abreviation);
    }
    setState(() {});
  }

  @override
  void setState(VoidCallback fn) {
    detailsString = "";
    row.details.forEach((detail) {
      if (detail.repeatXTime != 0) {
        if (detail.repeatXTime > 1) {
          detailsString += detail.repeatXTime.toString();
        }
        detailsString += "${detail.stitch}, ";
      }
    });
    previewControler.text = detailsString;
    super.setState(fn);
  }

  Widget _createStichButton(String stitch) {
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      onPressed: () async {
        if (row.details.isNotEmpty && row.details.last.stitch == stitch) {
          row.details.last.repeatXTime += 1;
          details.removeLast();
        } else {
          row.details.add(PatternRowDetail(rowId: -1, stitch: stitch));
        }
        int length = row.details.length;
        details.add(
          StitchCountButton(
            signed: false,
            text: stitch,
            count: row.details[length - 1].repeatXTime,
            increase: () {
              row.details[length - 1].repeatXTime += 1;
              row.stitchesPerRow += 1;
              setState(() {});
            },
            decrease: () {
              row.details[length - 1].repeatXTime -= 1;
              row.stitchesPerRow -= 1;
              setState(() {});
            },
          ),
        );
        setState(() {});
      },

      style: ButtonStyle(
        side: WidgetStatePropertyAll(
          BorderSide(color: theme.colorScheme.primary, width: 5),
        ),
        shape: WidgetStatePropertyAll(
          RoundedSuperellipseBorder(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(18)),
          ),
        ),

        backgroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
      ),
      child: Text(
        stitch,
        style: TextStyle(color: theme.colorScheme.secondary),
        textScaler: TextScaler.linear(1.25),
      ),
    );
  }

  Widget _rowNumberInput() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.numberWithOptions(),
            decoration: InputDecoration(label: Text("Start row")),
            initialValue: row.startRow.toString(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return ("Can't be empty");
              }
              try {
                int val = int.parse(value.trim());
                if (val < 0) {
                  return ("Row number can't be negative");
                }
              } catch (e) {
                return ("Only digits allowed");
              }
              return null;
            },
            onChanged: (newValue) {
              if (newValue.trim().isEmpty) {
                return;
              }

              try {
                row.startRow = int.parse(newValue.trim());
              } catch (e) {}
            },
            onSaved: (newValue) {
              if (newValue == null || newValue.trim().isEmpty) {
                return;
              }
              row.startRow = int.parse(newValue.trim());
            },
          ),
        ),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.numberWithOptions(),
            decoration: InputDecoration(label: Text("Number of rows")),
            initialValue: row.endRow.toString(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return ("Can't be empty");
              }
              try {
                int val = int.parse(value.trim());
                if (val < 1) {
                  return ("Row number can't be inferior to one");
                }
              } catch (e) {
                return ("Only digits allowed");
              }
              return null;
            },
            onSaved: (newValue) {
              if (newValue == null) return;
              row.endRow = int.parse(newValue.trim());
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Row ${row.startRow}"),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            _rowNumberInput(),

            TextFormField(
              controller: previewControler,
              readOnly: true,
              decoration: InputDecoration(label: Text("Preview")),
            ),
            Container(
              constraints: BoxConstraints(maxHeight: 150),
              padding: EdgeInsets.only(top: 10),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 10,
                  children: [for (Widget e in details) e],
                ),
              ),
            ),
            Wrap(
              spacing: 10,
              children: [for (String e in stitches) _createStichButton(e)],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              row.partId = widget.part.partId;
              if (widget.row == null) {
                int rowId = await insertPatternRowInDb(row);
                for (PatternRowDetail e in row.details) {
                  if (e.repeatXTime != 0) {
                    e.rowId = rowId;
                    await insertPatternRowDetailInDb(e);
                  }
                }
              } else {
                await updatePatternRowInDb(row);
                int rowId = row.rowId;
                for (PatternRowDetail e in row.details) {
                  if (e.repeatXTime != 0) {
                    e.rowId = rowId;
                    if (e.rowDetailId == 0) {
                      await insertPatternRowDetailInDb(e);
                    } else {
                      await updatePatternRowDetailInDb(e);
                    }
                  } else {
                    if (e.rowDetailId != 0) {
                      await deletePatternRowDetailInDb(e.rowDetailId);
                    }
                  }
                }
              }
              await widget.updatePattern();
              Navigator.pop(context);
            }
          },
          child: Text(widget.row == null ? "Add" : "Edit"),
        ),
      ],
    );
  }
}
