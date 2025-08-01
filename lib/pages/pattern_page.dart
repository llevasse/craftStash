import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:craft_stash/widgets/add_part_button.dart';
import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/pages/pattern_part_page.dart';
import 'package:craft_stash/widgets/yarn/pattern_yarn_list.dart';
import 'package:craft_stash/widgets/yarn/yarn_list_dialog.dart';
import 'package:craft_stash/widgets/yarnButtons/yarn_form.dart';
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
  late void Function() yarnListInitFunction;

  void _setPattern() async {
    if (widget.pattern == null) {
      pattern.patternId = await craft.insertPatternInDb(pattern);
    } else {
      pattern = widget.pattern!;
      pattern.yarnIdToNameMap = await craft.getYarnIdToNameMapByPatternId(
        pattern.patternId,
      );
      title = pattern.name;
      setState(() {});
    }
    updateListView();
  }

  @override
  void initState() {
    _setPattern();
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

  Widget _hookSizeInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        keyboardType: TextInputType.numberWithOptions(),
        initialValue: widget.pattern?.hookSize?.toStringAsFixed(2),
        decoration: InputDecoration(label: Text("Hook size")),
        validator: (value) {
          return null;
        },
        onSaved: (newValue) {
          newValue = newValue?.trim();
          if (newValue != null && newValue.isNotEmpty) {
            pattern.hookSize = double.parse(newValue);
          }
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

  Widget _yarnList() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        spacing: spacing / 2,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text("Yarns used :"),
          PatternYarnList(
            onPress: _yarnListOnPress,
            onLongPress: _yarnListOnLongPress,
            onAddYarnPress: _yarnListOnAddYarnPress,
            builder: (BuildContext context, void Function() methodFromChild) {
              yarnListInitFunction = methodFromChild;
            },
            patternId: pattern.patternId,
          ),
        ],
      ),
    );
  }

  void _yarnListOnPress(Yarn yarn) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => YarnForm(
        fill: true,
        readOnly: true,
        base: yarn,
        confirm: "close",
        cancel: "",
        title: yarn.colorName,
        showSkeins: false,
      ),
    );
  }

  void _yarnListOnLongPress(Yarn yarn) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () async {
                int inPreviewId = yarn.inPreviewId!;
                await showDialog(
                  context: context,
                  builder: (BuildContext context) => YarnListDialog(
                    onPressed: (newYarn, numberOfYarns) async {
                      try {
                        await craft.updateYarnInPattern(
                          yarnId: newYarn.id,
                          patternId: pattern.patternId,
                          inPreviewId: inPreviewId,
                        );
                        pattern.yarnIdToNameMap[inPreviewId] =
                            newYarn.colorName;
                        yarnListInitFunction.call();
                        Navigator.pop(context);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                );
              },
              child: Text("Replace"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await craft.deleteYarnInPattern(
                    yarnId: yarn.id,
                    patternId: pattern.patternId,
                    inPatternYarnId: yarn.inPreviewId!,
                  );
                  yarnListInitFunction.call();
                } catch (e) {}
              },
              child: Text("Remove"),
            ),
          ],
        ),
      ),
    );
  }

  void _yarnListOnAddYarnPress() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => YarnListDialog(
        onPressed: (yarn, numberOfYarns) async {
          try {
            await craft.insertYarnInPattern(
              yarnId: yarn.id,
              patternId: pattern.patternId,
              inPreviewId: numberOfYarns + 1,
            );
            pattern.yarnIdToNameMap[numberOfYarns + 1] = yarn.colorName;

            yarnListInitFunction.call();
          } catch (e) {}
        },
      ),
    );
  }

  Future<void> updatePattern() async {
    pattern = await craft.getPatternById(
      id: pattern.patternId,
      withParts: true,
      withYarnNames: true,
    );
    await updateListView();
  }

  Future<void> updateListView() async {
    List<Widget> tmp = List.empty(growable: true);

    pattern.parts = await getAllPatternPart(patternId: pattern.patternId);
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
    patternListView.add(
      Row(
        children: [
          Expanded(child: _titleInput()),
          Expanded(child: _hookSizeInput()),
        ],
      ),
    );
    patternListView.add(_yarnList());
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
                pattern.totalStitchNb = 0;
                for (PatternPart part in pattern.parts) {
                  pattern.totalStitchNb +=
                      part.totalStitchNb * part.numbersToMake;
                }
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
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
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
