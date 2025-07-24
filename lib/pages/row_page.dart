import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/widgets/patternButtons/add_custom_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/color_change_button.dart';
import 'package:craft_stash/widgets/patternButtons/new_subrow_button.dart';
import 'package:craft_stash/widgets/patternButtons/start_color_button.dart';
import 'package:craft_stash/widgets/patternButtons/stitch_count_button.dart';
import 'package:craft_stash/widgets/stitches/stitch_list.dart';
import 'package:flutter/material.dart';

class RowPage extends StatefulWidget {
  final Future<void> Function() updatePattern;
  PatternPart part;
  PatternRow? row;
  int startRow;
  int numberOfRows;
  RowPage({
    super.key,
    required this.part,
    required this.updatePattern,
    this.startRow = 0,
    this.numberOfRows = 1,
    this.row,
  });

  @override
  State<StatefulWidget> createState() => _RowPageState();
}

class _RowPageState extends State<RowPage> {
  List<Stitch> stitches = [];
  String stitchSearch = "";
  double buttonHeight = 50;
  bool needScroll = false;
  ScrollController stitchDetailsScrollController = ScrollController();
  List<StitchCountButton> details = List.empty(growable: true);
  String detailsString = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PatternRow row = PatternRow(startRow: 0, numberOfRows: 0, stitchesPerRow: 0);
  TextEditingController previewControler = TextEditingController();
  StitchList stitchList = StitchList();
  late void Function() stitchListInitFunction;

  @override
  void initState() {
    getAllStitches();
    row.startRow = widget.startRow;
    row.numberOfRows = widget.numberOfRows;
    if (widget.row != null) {
      row = widget.row!;
      detailsString = "";
      for (PatternRowDetail detail in row.details) {
        String text = detail.stitch!.abreviation;
        if (detail.stitchId == stitchToIdMap['color change']) {
          text = "change to ${detail.yarnColorName}";
        } else if (detail.stitchId == stitchToIdMap['start color']) {
          text = "start with ${detail.yarnColorName}";
        }
        details.add(
          StitchCountButton(
            signed: false,
            text: text,
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
      }
    } else {
      _insertRowInDb();
    }

    stitchList = _createStitchList();

    super.initState();
  }

  AddCustomDetailButton _SubrowButton() {
    return NewSubrowButton(
      rowId: row.rowId,
      onPressed: (PatternRowDetail? detail) async {
        if (detail == null) return;
        if (row.details.isNotEmpty &&
            row.details.last.hashCode == detail.hashCode) {
          await deletePatternRowDetailInDb(detail.rowDetailId);
          row.details.last.repeatXTime += 1;
          details.removeLast();
        } else {
          row.details.add(detail);
        }
        details.add(_createStitchCountButton(detail));
        await getAllStitches();
        stitchListInitFunction();
      },
    );
  }

  AddCustomDetailButton _colorChangeButton() {
    return ColorChangeButton(
      onPressed: (PatternRowDetail? detail) async {
        if (detail == null) return;
        if (row.details.isNotEmpty) {
          if (row.details.last.hashCode == detail.hashCode) {
            await deletePatternRowDetailInDb(detail.rowDetailId);
          } else if (row.details.last.stitchId ==
              stitchToIdMap['color change']) {
            await deletePatternRowDetailInDb(row.details.last.rowDetailId);
            row.details.removeLast();
            details.removeLast();
            row.details.add(detail);
            details.add(_createStitchCountButton(detail));
          } else if (row.details.last.stitchId == 'start color') {
            row.details.last.yarnId = detail.yarnId;
            row.details.last.yarnColorName = detail.yarnColorName;
            await updatePatternRowDetailInDb(row.details.last);
          } else {
            row.details.add(detail);
            details.add(_createStitchCountButton(detail));
          }
        }
        await getAllStitches();
        stitchListInitFunction();
      },
      rowId: row.rowId,
      patternId: widget.part.patternId,
    );
  }

  AddCustomDetailButton _startColorButton() {
    return StartColorButton(
      onPressed: (PatternRowDetail? detail) async {
        if (detail == null) return;
        if (row.details.isNotEmpty) {
          if (row.details.first.stitchId == stitchToIdMap["start color"]) {
            row.details.first.yarnId = detail.yarnId;
            row.details.first.yarnColorName = detail.yarnColorName;
            await updatePatternRowDetailInDb(row.details.first);
          } else {
            row.details.insert(0, detail);
            details.insert(0, _createStitchCountButton(detail));
          }
        } else {
          row.details.add(detail);
          details.add(_createStitchCountButton(detail));
        }
        await getAllStitches();
        stitchListInitFunction();
      },
      rowId: row.rowId,
      patternId: widget.part.patternId,
    );
  }

  StitchList _createStitchList() {
    StitchList s = StitchList(
      onStitchPressed: _addStitch,
      onSequencePressed: _addStitch,
      customActions: [
        _SubrowButton(),
        _colorChangeButton(),
        ?row.startRow == 1 ? _startColorButton() : null,
      ],
      builder: (BuildContext context, void Function() methodFromChild) {
        stitchListInitFunction = methodFromChild;
      },
    );
    return s;
  }

  Future<void> _insertRowInDb() async {
    row.partId = widget.part.partId;
    if (widget.row == null) {
      row.rowId = await insertPatternRowInDb(row);
    }
  }

  Future<void> getAllStitches() async {
    stitches = await getAllStitchesInDb();
    setState(() {});
  }

  @override
  void setState(VoidCallback fn) {
    detailsString = "";
    for (PatternRowDetail detail in row.details) {
      // detail.printDetail();
      // print("\r\n");
      if (detail.repeatXTime != 0) {
        detailsString += "${detail.toString()}, ";
      }
    }
    previewControler.text = detailsString;
    stitchDetailsScrollController.jumpTo(
      stitchDetailsScrollController.position.maxScrollExtent,
    );
    // print("\r\n");
    super.setState(fn);
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
                if (int.parse(value.trim()) < 0) {
                  return ("Row number can't be negative");
                }
              } catch (e) {
                return ("Only digits allowed");
              }
              return null;
            },
            onChanged: (newValue) {
              if (newValue.trim().isEmpty) return;

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
            initialValue: row.numberOfRows.toString(),
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
              row.numberOfRows = int.parse(newValue.trim());
            },
          ),
        ),
      ],
    );
  }

  StitchCountButton _createStitchCountButton(PatternRowDetail stitch) {
    return StitchCountButton(
      signed: false,
      text: stitch.toString(),
      count: stitch.repeatXTime,
      increase: () {
        stitch.repeatXTime += 1;
        row.stitchesPerRow += 1;
        setState(() {});
      },
      decrease: () {
        stitch.repeatXTime -= 1;
        row.stitchesPerRow -= 1;
        setState(() {});
      },
    );
  }

  Widget _stitchDetailsList() {
    return Container(
      constraints: BoxConstraints(maxHeight: buttonHeight * 2.5),
      padding: EdgeInsets.only(top: 10),
      child: SingleChildScrollView(
        controller: stitchDetailsScrollController,
        child: Wrap(spacing: 10, children: [for (Widget e in details) e]),
      ),
    );
  }

  Widget _saveButton() {
    return IconButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          row.preview = row.detailsAsString();
          await updatePatternRowInDb(row);
          if (widget.row == null) {
            for (int i = 0; i < row.details.length; i++) {
              if (row.details[i].repeatXTime != 0) {
                row.details[i].rowId = row.rowId;
                row.details[i].order = i;
                await insertPatternRowDetailInDb(row.details[i]);
              }
            }
          } else {
            for (int i = 0; i < row.details.length; i++) {
              if (row.details[i].repeatXTime != 0) {
                row.details[i].rowId = row.rowId;
                row.details[i].order = i;
                if (row.details[i].rowDetailId == 0) {
                  await insertPatternRowDetailInDb(row.details[i]);
                } else {
                  await updatePatternRowDetailInDb(row.details[i]);
                }
              } else {
                if (row.details[i].rowDetailId != 0) {
                  await deletePatternRowDetailInDb(row.details[i].rowDetailId);
                }
              }
            }
          }
          await widget.updatePattern();
          Navigator.pop(context);
        }
      },
      icon: Icon(Icons.save),
    );
  }

  Future<Stitch?> _addStitch(Stitch stitch) async {
    if (row.details.isNotEmpty &&
        row.details.last.stitch?.abreviation == stitch.abreviation) {
      row.details.last.repeatXTime += 1;
      details.removeLast();
    } else {
      row.details.add(
        PatternRowDetail(rowId: -1, stitchId: stitch.id, stitch: stitch),
      );
    }
    details.add(_createStitchCountButton(row.details.last));
    needScroll = true;
    setState(() {});
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    if (needScroll) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => stitchDetailsScrollController.animateTo(
          stitchDetailsScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.linear,
        ),
      );
      needScroll = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.part.name}/Row ${row.startRow}${row.numberOfRows > 1 ? "-${row.startRow + row.numberOfRows - 1}" : ""}",
        ),
        backgroundColor: theme.colorScheme.primary,
        actions: [_saveButton()],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 10,
            children: [
              _rowNumberInput(),
              TextFormField(
                controller: previewControler,
                readOnly: true,
                decoration: InputDecoration(label: Text("Preview")),
              ),
              _stitchDetailsList(),

              Expanded(child: stitchList),
            ],
          ),
        ),
      ),
    );
  }
}
