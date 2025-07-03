import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/widgets/patternButtons/add_row_button.dart';
import 'package:craft_stash/widgets/patternButtons/row_form.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PatternPartPage extends StatefulWidget {
  final Future<void> Function() updatePatternListView;
  PatternPart? part;
  craft.Pattern pattern;
  PatternPartPage({
    super.key,
    required this.updatePatternListView,
    this.part,
    required this.pattern,
  });

  @override
  State<StatefulWidget> createState() => _PatternPartPageState();
}

class _PatternPartPageState extends State<PatternPartPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String title = "New part";
  PatternPart part = PatternPart(name: "New part", patternId: 0);
  List<Widget> patternListView = List.empty(growable: true);

  void _insertPart() async {
    part.patternId = widget.pattern.patternId;
    int partId = await insertPatternPartInDb(part);
    part.partId = partId;
  }

  @override
  void initState() {
    if (widget.part == null) {
      _insertPart();
    } else {
      part = widget.part!;
      title = part.name;
    }
    patternListView.add(_titleInput());
    patternListView.add(_numbersToMakeInput());
    for (PatternRow row in part.rows) {
      if (row.startRow != 0) {
        patternListView.add(_patternRowTile(row));
      }
    }
    super.initState();
  }

  Widget _titleInput() {
    return TextFormField(
      initialValue: part.name,
      decoration: InputDecoration(label: Text("Pattern title")),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return ("Part title can't be empty");
        }
        return null;
      },
      onSaved: (newValue) {
        title = newValue!.trim();
        part.name = title;
      },
    );
  }

  Widget _numbersToMakeInput() {
    return TextFormField(
      keyboardType: TextInputType.numberWithOptions(),
      initialValue: part.numbersToMake.toString(),
      decoration: InputDecoration(label: Text("Numbers to make")),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return ("Can't be empty");
        }
        if (int.parse(value.trim()) < 1) {
          return ("Can't be lower than one");
        }
        return null;
      },
      onSaved: (newValue) {
        part.numbersToMake = int.parse(newValue!.trim());
      },
    );
  }

  Widget _patternRowTile(PatternRow row) {
    String title = "row ${row.startRow}";
    if (row.endRow > 1) {
      title += "-${row.startRow + row.endRow - 1} (${row.endRow} rows)";
    }
    return ListTile(
      title: Text(title),
      subtitle: Text(row.detailsAsString()),
      onTap: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) =>
              RowForm(part: part, updatePattern: updateListView, row: row),
        );
      },
      onLongPress: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text("Do you want to delete this row"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await deletePatternRowInDb(row.rowId);
                  await updateListView();
                  Navigator.pop(context);
                },
                child: Text("Delete"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> updateListView() async {
    List<Widget> tmp = List.empty(growable: true);
    part = await getPatternPartByPartId(part.partId);
    tmp.add(_titleInput());
    tmp.add(_numbersToMakeInput());
    for (PatternRow row in part.rows) {
      if (row.startRow != 0) {
        tmp.add(_patternRowTile(row));
      }
    }
    setState(() {
      patternListView = tmp;
    });
  }

  Widget _deleteButton() {
    return IconButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text("Do you want to delete this pattern"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await deletePatternPartInDb(part.partId);
                  await widget.updatePatternListView();
                  Navigator.popUntil(context, ModalRoute.withName("/pattern"));
                },
                child: Text("Delete"),
              ),
            ],
          ),
        );
      },
      icon: Icon(LucideIcons.trash),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.pattern.name}/$title"),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          _deleteButton(),
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await updatePatternPartInDb(part);
                await widget.updatePatternListView();
                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(children: patternListView),
      ),
      floatingActionButton: AddRowButton(
        part: part,
        updatePattern: updateListView,
        startRow: part.rows.isEmpty
            ? 1
            : part.rows.last.startRow + part.rows.last.endRow,
        endRow: 1,
      ),
    );
  }
}
