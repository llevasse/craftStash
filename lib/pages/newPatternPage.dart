import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/widgets/patternButtons/add_row_button.dart';
import 'package:flutter/material.dart';

class NewPatternPage extends StatefulWidget {
  final Future<void> Function() updatePatternListView;
  craft.Pattern? pattern;
  NewPatternPage({
    super.key,
    required this.updatePatternListView,
    this.pattern,
  });

  @override
  State<StatefulWidget> createState() => _NewPatternPageState();
}

class _NewPatternPageState extends State<NewPatternPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String title = "New pattern";
  craft.Pattern pattern = craft.Pattern();
  PatternPart part = PatternPart(name: "Main", patternId: 0);
  List<Widget> patternListView = List.empty(growable: true);

  void _insertPattern() async {
    int patternId = await craft.insertPatternInDb(pattern);
    //    print(patternId);
    pattern.patternId = patternId;
    part.patternId = pattern.patternId;
    int partId = await insertPatternPartInDb(part);
    part.partId = partId;
  }

  @override
  void initState() {
    if (widget.pattern == null) {
      _insertPattern();
    } else {
      pattern = widget.pattern!;
      part = widget.pattern!.parts[0];
    }
    patternListView.add(_titleInput());
    for (PatternPart part in pattern.parts) {
      patternListView.add(
        Row(
          children: [
            Expanded(child: Divider(color: Colors.amber)),
            Expanded(
              child: Text(
                part.name,
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.5),
              ),
            ),
            Expanded(child: Divider(color: Colors.amber)),
          ],
        ),
      );
      for (PatternRow row in part.rows) {
        patternListView.add(_patternRowTile(row));
      }
    }
    super.initState();
  }

  Widget _titleInput() {
    return TextFormField(
      initialValue: widget.pattern?.name,
      decoration: InputDecoration(label: Text("Pattern title")),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return ("Pattern title can't be empty");
        }
        return null;
      },
      onSaved: (newValue) {
        title = newValue!.trim();
        pattern.name = title;
      },
    );
  }

  Widget _patternRowTile(PatternRow row) {
    return ListTile(
      title: Text("row ${row.startRow}"),
      subtitle: Text(row.detailsAsString()),
    );
  }

  Future<void> updateListView() async {
    List<Widget> tmp = List.empty(growable: true);
    pattern = await craft.getPatternById(pattern.patternId);
    tmp.add(_titleInput());
    for (PatternPart part in pattern.parts) {
      tmp.add(
        Row(
          children: [
            Expanded(child: Divider(color: Colors.amber)),
            Expanded(
              child: Text(
                part.name,
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.5),
              ),
            ),
            Expanded(child: Divider(color: Colors.amber)),
          ],
        ),
      );
      for (PatternRow row in part.rows) {
        tmp.add(_patternRowTile(row));
      }
    }
    setState(() {
      patternListView = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("New pattern"),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await craft.updatePatternInDb(pattern);
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
      ),
    );
  }
}
