import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/widgets/patternButtons/add_row_button.dart';
import 'package:flutter/material.dart';

class NewPatternPage extends StatefulWidget {
  const NewPatternPage();

  @override
  State<StatefulWidget> createState() => _NewPatternPageState();
}

class _NewPatternPageState extends State<NewPatternPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String title = "New pattern";
  craft.Pattern pattern = craft.Pattern();
  PatternPart part = PatternPart(name: "Main", patternId: 0);

  void _insertPattern() async {
    int patternId = await craft.insertPatternInDb(pattern);
    pattern.patternId = patternId;
    part.patternId = pattern.patternId;
    int partId = await insertPatternPartInDb(part);
    part.partId = partId;
  }

  @override
  void initState() {
    _insertPattern();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("New pattern"),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
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
            ),
          ],
        ),
      ),
      floatingActionButton: AddRowButton(
        part: part,
        updatePattern: () async {},
      ),
    );
  }
}
