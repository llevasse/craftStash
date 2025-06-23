import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/pages/newPatternPage.dart';
import 'package:craft_stash/widgets/int_control_button.dart';
import 'package:craft_stash/widgets/patternButtons/stitch_count_button.dart';
import 'package:flutter/material.dart';

class AddRowButton extends StatefulWidget {
  final Future<void> Function() updatePattern;
  int startRow;
  int endRow;
  AddRowButton({
    super.key,
    required this.updatePattern,
    this.startRow = 0,
    this.endRow = 0,
  });

  @override
  State<StatefulWidget> createState() => _AddRowButton();
}

class _AddRowButton extends State<AddRowButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return TextButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) => RowForm(
            updatePattern: widget.updatePattern,
            startRow: widget.startRow,
            endRow: widget.endRow,
          ),
        );
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
        "Add row",
        style: TextStyle(color: theme.colorScheme.secondary),
        textScaler: TextScaler.linear(1.25),
      ),
    );
  }
}

class RowForm extends StatefulWidget {
  final Future<void> Function() updatePattern;
  int startRow;
  int endRow;
  RowForm({
    super.key,
    required this.updatePattern,
    this.startRow = 0,
    this.endRow = 0,
  });

  @override
  State<StatefulWidget> createState() => _RowFormState();
}

class _RowFormState extends State<RowForm> {
  List<String> stitches = ["ch", "sl", "sc", "hdc", "dc", "tr"];
  List<StitchCountButton> details = List.empty(growable: true);
  String detailsString = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PatternRow row = PatternRow(startRow: 0, endRow: 0, stitchesPerRow: 0);
  @override
  void initState() {
    row.startRow = widget.startRow;
    row.endRow = widget.endRow;
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    detailsString = "";
    row.details.forEach((detail) {
      if (detail.repeatXTime > 1) {
        detailsString += detail.repeatXTime.toString();
      }
      detailsString += "${detail.stitch}, ";
    });
    super.setState(fn);
  }

  Widget _createStichButton(String stitch) {
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      onPressed: () async {
        if (row.details.isNotEmpty && row.details.last.stitch == stitch) {
          row.details.last.repeatXTime += 1;
          int length = row.details.length;
          details[length - 1] = StitchCountButton(
            text: stitch,
            count: row.details[length - 1].repeatXTime,
            increase: () {
              row.details[length - 1].repeatXTime += 1;
              setState(() {});
            },
            decrease: () {
              row.details[length - 1].repeatXTime -= 1;
              setState(() {});
            },
          );
          setState(() {});
          return;
        }
        row.details.add(PatternRowDetail(rowId: 0, stitch: stitch));
        int length = row.details.length;
        details.add(
          StitchCountButton(
            text: stitch,
            count: row.details[length - 1].repeatXTime,
            increase: () {
              row.details[length - 1].repeatXTime += 1;
              setState(() {});
            },
            decrease: () {
              row.details[length - 1].repeatXTime -= 1;
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Row ${row.startRow}"),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(label: Text("Start row")),
              initialValue: row.startRow.toString(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return ("Can't be empty");
                }
                int val = int.parse(value.trim());
                if (val < 0) {
                  return ("Row number can't be negative");
                }
                if (val < row.endRow) {
                  return ("Start row number can't be inferior to end row number");
                }
                return null;
              },
              onSaved: (newValue) {
                if (newValue == null) return;
                row.startRow = int.parse(newValue.trim());
                row.endRow = row.startRow;
              },
            ),
            // TextFormField(
            //   keyboardType: TextInputType.numberWithOptions(),
            //   decoration: InputDecoration(label: Text("End row")),
            //   initialValue: row.endRow.toString(),
            //   validator: (value) {
            //     if (value == null || value.trim().isEmpty) {
            //       return ("Can't be empty");
            //     }
            //     int val = int.parse(value.trim());
            //     if (val < 0) {
            //       return ("Row number can't be negative");
            //     }
            //     if (val > row.startRow) {
            //       return ("Start row number can't be inferior to end row number");
            //     }
            //     return null;
            //   },
            //   onSaved: (newValue) {
            //     if (newValue == null) return;
            //     row.endRow = int.parse(newValue.trim());
            //   },
            // ),
            Text(detailsString),
            SizedBox(
              height: 200,
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
      actions: [TextButton(onPressed: () {}, child: Text("Add"))],
    );
  }
}
