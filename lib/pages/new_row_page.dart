import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/pages/new_sub_row_page.dart';
import 'package:craft_stash/widgets/patternButtons/add_custom_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/add_generic_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/stitch_count_button.dart';
import 'package:craft_stash/widgets/stitches/stitch_list.dart';
import 'package:flutter/material.dart';

class NewRowPage extends StatefulWidget {
  final Future<void> Function() updatePattern;
  PatternPart part;
  PatternRow? row;
  int startRow;
  int numberOfRows;
  NewRowPage({
    super.key,
    required this.part,
    required this.updatePattern,
    this.startRow = 0,
    this.numberOfRows = 1,
    this.row,
  });

  @override
  State<StatefulWidget> createState() => _NewRowPageState();
}

class _NewRowPageState extends State<NewRowPage> {
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
  @override
  void initState() {
    getAllStitches();
    row.startRow = widget.startRow;
    row.numberOfRows = widget.numberOfRows;
    if (widget.row != null) {
      row = widget.row!;
      detailsString = "";
      for (PatternRowDetail detail in row.details) {
        details.add(
          StitchCountButton(
            signed: false,
            text: detail.toStringWithoutNumber(),
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
    super.initState();
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
    row.details.forEach((detail) {
      if (detail.repeatXTime != 0) {
        detailsString += "${detail.toString()}, ";
      }
    });
    previewControler.text = detailsString;
    stitchDetailsScrollController.jumpTo(
      stitchDetailsScrollController.position.maxScrollExtent,
    );
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

  StitchCountButton _createStitchCountButton(String stitch) {
    int length = row.details.length;
    return StitchCountButton(
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
    );
  }

  Widget _createSubRowButton() {
    return AddCustomDetailButton(
      text: "New sequence",
      onPressed: () async {
        PatternRowDetail? t =
            await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    settings: RouteSettings(name: "subrow"),
                    builder: (BuildContext context) =>
                        NewSubRowPage(rowId: row.rowId, partId: row.partId),
                  ),
                )
                as PatternRowDetail?;
        if (t == null) return;
        if (row.details.isNotEmpty && row.details.last.hashCode == t.hashCode) {
          await deletePatternRowDetailInDb(t.rowDetailId);
          row.details.last.repeatXTime += 1;
          details.removeLast();
        } else {
          row.details.add(t);
        }
        details.add(_createStitchCountButton(t.subRow.toString()));
        await getAllStitches();
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
          if (widget.row == null) {
            for (PatternRowDetail e in row.details) {
              if (e.repeatXTime != 0) {
                e.rowId = row.rowId;
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
      icon: Icon(Icons.save),
    );
  }

  Future<Stitch?> _addStitch(Stitch stitch) async {
    if (row.details.isNotEmpty &&
        row.details.last.stitch == stitch.abreviation) {
      row.details.last.repeatXTime += 1;
      details.removeLast();
    } else {
      row.details.add(PatternRowDetail(rowId: -1, stitch: stitch.abreviation));
    }
    details.add(_createStitchCountButton(stitch.abreviation));
    needScroll = true;
    setState(() {});
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

              Expanded(
                child: StitchList(
                  customActions: [_createSubRowButton()],
                  onPressed: _addStitch,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
