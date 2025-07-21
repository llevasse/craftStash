import 'package:craft_stash/add_part_button.dart';
import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/pages/pattern_part_page.dart';
import 'package:craft_stash/widgets/yarn/pattern_yarn_list.dart';
import 'package:craft_stash/widgets/yarn/yarn_list_dialog.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PatternPage extends StatefulWidget {
  final Future<void> Function() updatePatternListView;
  craft.Pattern? pattern;
  PatternPage({super.key, required this.updatePatternListView, this.pattern});

  @override
  State<StatefulWidget> createState() => _PatternPageState();
}

class _PatternPageState extends State<PatternPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String title = "New pattern";
  craft.Pattern pattern = craft.Pattern();
  List<Widget> patternListView = List.empty(growable: true);
  double spacing = 10;

  void _insertPattern() async {
    pattern.patternId = await craft.insertPatternInDb(pattern);
  }

  @override
  void initState() {
    if (widget.pattern == null) {
      _insertPattern();
    } else {
      pattern = widget.pattern!;
      title = pattern.name;
    }
    updateListView();
    super.initState();
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
                  await craft.deletePatternInDb(pattern.patternId);
                  await widget.updatePatternListView();
                  while (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
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

  Widget _titleInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        initialValue: widget.pattern != null ? widget.pattern!.name : title,
        decoration: InputDecoration(label: Text("Pattern title")),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return ("Pattern title can't be empty");
          }
          return null;
        },
        onChanged: (value) {
          title = value.trim();
          setState(() {});
        },
        onSaved: (newValue) {
          title = newValue!.trim();
          pattern.name = title;
        },
      ),
    );
  }

  Widget _assemblyInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        maxLines: 5,
        initialValue: widget.pattern?.note,
        decoration: InputDecoration(label: Text("Assembly")),
        validator: (value) {
          return null;
        },
        onSaved: (newValue) {
          pattern.note = newValue?.trim();
        },
      ),
    );
  }

  Future<void> updatePattern() async {
    pattern = await craft.getPatternById(pattern.patternId);
    await updateListView();
  }

  Future<void> updateListView() async {
    List<Widget> tmp = List.empty(growable: true);

    pattern.parts = await getAllPatternPartsByPatternIdWithoutRows(
      pattern.patternId,
    );
    tmp.add(
      Container(
        padding: EdgeInsets.all(10),
        child: Column(
          spacing: spacing / 2,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Yarns used :"),
            PatternYarnList(
              onAddYarnPress: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) => YarnListDialog(
                    onPressed: (yarn) async {
                      try {
                        await craft.insertYarnInPattern(
                          yarn.id,
                          pattern.patternId,
                        );
                        await updateListView(); //TODO optimize to just update PatternYarnList
                      } catch (e) {}
                    },
                  ),
                );
              },
              patternId: pattern.patternId,
            ),
          ],
        ),
      ),
    );

    for (PatternPart part in pattern.parts) {
      tmp.add(
        ListTile(
          title: Text(part.name),
          subtitle: Text("Make ${part.numbersToMake}"),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(
                settings: RouteSettings(name: "part"),
                builder: (BuildContext context) => PatternPartPage(
                  updatePatternListView: updatePattern,
                  pattern: pattern,
                  part: part,
                ),
              ),
            );
            await updateListView();
          },
          onLongPress: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text("Do you want to delete this part"),
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
                      await updateListView();
                      Navigator.pop(context);
                    },
                    child: Text("Delete"),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    patternListView.clear();
    patternListView.add(_titleInput());
    patternListView.add(Expanded(child: ListView(children: tmp)));
    patternListView.add(_assemblyInput());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: theme.colorScheme.primary,
        leading: IconButton(
          onPressed: () async {
            if (widget.pattern == null) {
              await craft.deletePatternInDb(pattern.patternId);
            }
            await widget.updatePatternListView();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          widget.pattern == null ? Container() : _deleteButton(),
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
        child: Column(
          spacing: spacing,
          mainAxisSize: MainAxisSize.min,
          children: patternListView,
        ),
      ),
      floatingActionButton: AddPartButton(
        updatePatternListView: updatePattern,
        pattern: pattern,
      ),
    );
  }
}
