import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/main.dart';
import 'package:craft_stash/widgets/patternButtons/add_row_button.dart';
import 'package:craft_stash/pages/row_page.dart';
import 'package:craft_stash/widgets/patternButtons/count_button.dart';
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
    part.partId = await insertPatternPartInDb(part);
  }

  @override
  void initState() {
    if (debug) print("on PartPage ${widget.pattern.yarnIdToNameMap}");

    if (widget.part == null) {
      _insertPart();
      patternListView.add(_titleInput());
      patternListView.add(_numbersToMakeInput());
    } else {
      part = widget.part!;
      title = part.name;
      updateListView();
    }

    super.initState();
  }

  Widget _titleInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
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
      ),
    );
  }

  Widget _numbersToMakeInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: CountButton(
        prefixText: "Make ",
        count: part.numbersToMake,
        increase: () {
          part.numbersToMake += 1;
        },
        decrease: () {
          part.numbersToMake -= 1;
        },
        min: 1,
      ),
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
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
      ),
    );
  }

  Widget _patternRowTile(PatternRow row) {
    String title = "row ${row.startRow}";
    String? preview;
    if (row.numberOfRows > 1) {
      title +=
          "-${row.startRow + row.numberOfRows - 1} (${row.numberOfRows} rows)";
    }

    if (row.preview != null) {
      preview = row.preview;
      for (MapEntry<int, String> entry
          in widget.pattern.yarnIdToNameMap.entries) {
        preview = preview!.replaceAll("\${${entry.key}}", entry.value);
      }
    }

    Widget? subtitle = preview != null ? Text(preview) : null;
    return ListTile(
      title: Text(title),
      subtitle: subtitle,
      onTap: () async {
        PatternRow r = await getPatternRowByRowId(row.rowId);
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            settings: RouteSettings(name: "row"),
            builder: (BuildContext context) => RowPage(
              part: part,
              updatePattern: updateListView,
              row: r,
              yarnIdToNameMap: widget.pattern.yarnIdToNameMap,
            ),
          ),
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
    part = await getPatternPartByPartId(id: part.partId);

    tmp.add(
      Row(
        children: [
          Expanded(child: _titleInput()),
          Expanded(child: _numbersToMakeInput()),
        ],
      ),
    );
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
            title: Text("Do you want to delete this part"),
            content: Text(
              "Every wips and rows connected to it will be deleted as well",
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
                  await deletePatternPartInDb(part.partId);
                  await widget.updatePatternListView();
                  Navigator.popUntil(context, ModalRoute.withName("pattern"));
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
                part.totalStitchNb = 0;
                for (PatternRow row in part.rows) {
                  part.totalStitchNb += row.stitchesPerRow * row.numberOfRows;
                }
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
            : part.rows.last.startRow + part.rows.last.numberOfRows,
        numberOfRows: 1,
        yarnIdToNameMap: widget.pattern.yarnIdToNameMap,
      ),
    );
  }
}
