import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/main.dart';
import 'package:craft_stash/widgets/patternButtons/add_custom_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/color_change_button.dart';
import 'package:craft_stash/widgets/patternButtons/new_subrow_button.dart';
import 'package:craft_stash/widgets/patternButtons/start_color_button.dart';
import 'package:craft_stash/widgets/patternButtons/count_button.dart';
import 'package:craft_stash/widgets/patternButtons/stitch_detail_dialog.dart';
import 'package:craft_stash/widgets/stitches/stitch_list.dart';
import 'package:flutter/material.dart';

class RowPage extends StatefulWidget {
  final Future<void> Function() updatePattern;
  Map<int, String> yarnIdToNameMap;
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
    this.yarnIdToNameMap = const {},
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
  ScrollController previewScrollController = ScrollController();
  List<CountButton> details = List.empty(growable: true);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PatternRow row = PatternRow(startRow: 0, numberOfRows: 0, stitchesPerRow: 0);
  TextEditingController previewControler = TextEditingController();
  StitchList stitchList = StitchList();
  double spacing = 20;
  late void Function() stitchListInitFunction;

  @override
  void initState() {
    getAllStitches();
    row.startRow = widget.startRow;
    row.numberOfRows = widget.numberOfRows;
    if (widget.row != null) {
      row = widget.row!;
      for (PatternRowDetail detail in row.details) {
        String text = detail.stitch!.abreviation;
        bool isColorChange = false;
        if (detail.stitchId == stitchToIdMap['color change']) {
          text = "change to ${widget.yarnIdToNameMap[detail.inPatternYarnId]}";
          isColorChange = true;
        } else if (detail.stitchId == stitchToIdMap['start color']) {
          text = "start with ${widget.yarnIdToNameMap[detail.inPatternYarnId]}";
          isColorChange = true;
        }
        details.add(
          _createStitchCountButton(
            stitch: detail,
            showCount: !isColorChange,
            allowDecrease: !isColorChange,
            allowIncrease: !isColorChange,
            text: text,
          ),
        );
      }
    } else {
      _insertRowInDb();
    }

    stitchList = _createStitchList();

    super.initState();
  }

  AddCustomDetailButton _subrowButton() {
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
        row.stitchesPerRow += detail.stitch!.stitchNb;
        if (debug) print("Row stitch nb : ${row.stitchesPerRow}");

        details.add(_createStitchCountButton(stitch: detail));
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
            details.add(
              _createStitchCountButton(
                stitch: detail,
                showCount: false,
                allowIncrease: false,
                allowDecrease: false,
              ),
            );
          } else if (row.details.last.stitchId == 'start color') {
            row.details.last.inPatternYarnId = detail.inPatternYarnId;
            await updatePatternRowDetailInDb(row.details.last);
          } else {
            row.details.add(detail);
            details.add(
              _createStitchCountButton(
                stitch: detail,
                showCount: false,
                allowIncrease: false,
                allowDecrease: false,
              ),
            );
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
            row.details.first.inPatternYarnId = detail.inPatternYarnId;
            await updatePatternRowDetailInDb(row.details.first);
          } else {
            row.details.insert(0, detail);
            details.insert(
              0,
              _createStitchCountButton(
                stitch: detail,
                showCount: false,
                allowDecrease: false,
                allowIncrease: false,
              ),
            );
          }
        } else {
          row.details.add(detail);
          details.add(
            _createStitchCountButton(
              stitch: detail,
              showCount: false,
              allowDecrease: false,
              allowIncrease: false,
            ),
          );
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
        _subrowButton(),
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
    String preview = row.detailsAsString();
    for (MapEntry<int, String> entry in widget.yarnIdToNameMap.entries) {
      preview = preview!.replaceAll("\${${entry.key}}", entry.value);
    }
    previewControler.text = preview;
    previewScrollController.jumpTo(
      previewScrollController.position.maxScrollExtent,
    );
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
          child: CountButton(
            prefixText: "Row ",
            count: row.startRow,
            onChange: (value) {
              row.startRow = value;
              setState(() {});
            },
            min: 1,
          ),
        ),
        Expanded(
          child: CountButton(
            prefixText: "Do ",
            count: row.numberOfRows,
            onChange: (value) {
              row.numberOfRows = value;
              setState(() {});
            },
            min: 1,
          ),
        ),
      ],
    );
  }

  CountButton _createStitchCountButton({
    required PatternRowDetail stitch,
    bool showCount = true,
    bool allowIncrease = true,
    bool allowDecrease = true,
    String? text,
  }) {
    if (text == null) {
      String text = stitch.toString();
      if (stitch.inPatternYarnId != null) {
        if (debug) {
          print(text);
          print(widget.yarnIdToNameMap);
        }
        text = text.replaceAll(
          "\${${stitch.inPatternYarnId}}",
          widget.yarnIdToNameMap[stitch.inPatternYarnId]!,
        );
      }
    }
    return CountButton(
      signed: false,
      suffixText: stitch.stitch?.abreviation,
      showCount: showCount,
      count: stitch.repeatXTime,
      allowIncrease: allowIncrease,
      allowDecrease: allowDecrease,
      onChange: (value) {
        if (value > stitch.repeatXTime) {
          row.stitchesPerRow += stitch.stitch!.stitchNb;
        } else {
          row.stitchesPerRow -= stitch.stitch!.stitchNb;
        }
        stitch.repeatXTime = value;
        if (debug) print("Row stitch nb : ${row.stitchesPerRow}");

        setState(() {});
      },
      onLongPress: () async {
        await stitchCountLongPress(detail: stitch, index: details.length - 1);
      },
    );
  }

  Future<void> stitchCountLongPress({
    required PatternRowDetail detail,
    required int index,
  }) async {
    PatternRowDetail? newDetail = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StitchDetailDialog(detail: detail);
      },
    );
    row.stitchesPerRow -= detail.repeatXTime * detail.stitch!.stitchNb;
    if (newDetail == null) {
      if (detail.rowDetailId != 0) {
        await deletePatternRowDetailInDb(detail.rowDetailId);
      }
      details.removeAt(index);
      row.details.remove(detail);
    } else {
      row.stitchesPerRow += detail.repeatXTime * detail.stitch!.stitchNb;
      if (detail.rowDetailId != 0) {
        row.details.remove(detail);
        row.details.insert(index, newDetail);
        details[index];
        details[index].count = newDetail.repeatXTime;
      }
    }
    previewControler.text = row.detailsAsString();
    setState(() {});
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
          if (debug) print("Row stitch nb : ${row.stitchesPerRow}");
          if (row.stitchesPerRow < 1) {
            await deletePatternRowInDb(row.rowId);
          } else {
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
                    await deletePatternRowDetailInDb(
                      row.details[i].rowDetailId,
                    );
                  }
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
    row.stitchesPerRow += stitch.stitchNb;

    if (debug) print("Row stitch nb : ${row.stitchesPerRow}");

    details.add(_createStitchCountButton(stitch: row.details.last));
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
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => previewScrollController.animateTo(
          previewScrollController.position.maxScrollExtent,
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
        leading: IconButton(
          onPressed: () async {
            if (row.stitchesPerRow < 1) {
              await deletePatternRowInDb(row.rowId);
            }
            await widget.updatePattern();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [_saveButton()],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 10,
            children: [
              _rowNumberInput(),
              TextFormField(
                scrollController: previewScrollController,
                controller: previewControler,
                readOnly: true,
                maxLines: 2,
                minLines: 1,
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
