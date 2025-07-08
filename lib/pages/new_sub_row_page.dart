import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/widgets/patternButtons/add_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/stitch_count_button.dart';
import 'package:flutter/material.dart';

class NewSubRowPage extends StatefulWidget {
  final PatternRow? subrow;
  final int rowId;
  final int partId;
  const NewSubRowPage({
    super.key,
    this.subrow,
    required this.rowId,
    required this.partId,
  });

  @override
  State<StatefulWidget> createState() => _NewSubRowPageState();
}

class _NewSubRowPageState extends State<NewSubRowPage> {
  List<Stitch> stitches = [];
  String stitchSearch = "";
  double buttonHeight = 50;
  bool needScroll = false;
  ScrollController stitchDetailsScrollController = ScrollController();
  List<StitchCountButton> details = List.empty(growable: true);
  String detailsString = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PatternRow row = PatternRow(startRow: 0, endRow: 0, stitchesPerRow: 0);
  TextEditingController previewControler = TextEditingController();
  @override
  void initState() {
    getAllStitches();
    row.startRow = 0;
    row.endRow = 0;
    if (widget.subrow != null) {
      row = widget.subrow!;
      detailsString = "";
      row.details.forEach((detail) {
        if (detail.repeatXTime != 0) {
          if (detail.repeatXTime > 1) {
            detailsString += detail.repeatXTime.toString();
          }
          detailsString += "${detail.stitch}, ";
        }
        details.add(
          StitchCountButton(
            signed: false,
            text: detail.stitch,
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
      });
      previewControler.text = detailsString;
    }
    super.initState();
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
        if (detail.repeatXTime > 1) {
          detailsString += detail.repeatXTime.toString();
        }
        detailsString += "${detail.stitch}, ";
      }
    });
    previewControler.text = detailsString;
    stitchDetailsScrollController.jumpTo(
      stitchDetailsScrollController.position.maxScrollExtent,
    );
    super.setState(fn);
  }

  Widget _createStichButton(String stitch) {
    return AddDetailButton(
      text: stitch,
      onPressed: () async {
        if (row.details.isNotEmpty && row.details.last.stitch == stitch) {
          row.details.last.repeatXTime += 1;
          details.removeLast();
        } else {
          row.details.add(PatternRowDetail(rowId: -1, stitch: stitch));
        }
        int length = row.details.length;
        details.add(
          StitchCountButton(
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
          ),
        );
        needScroll = true;
        setState(() {});
      },
    );
  }

  Widget _stichesList() {
    List<Widget> list = List.empty(growable: true);
    for (Stitch e in stitches) {
      if (e.abreviation.contains(stitchSearch) ||
          e.name!.contains(stitchSearch)) {
        list.add(_createStichButton(e.abreviation));
      }
    }
    return Expanded(
      child: SingleChildScrollView(child: Wrap(spacing: 10, children: list)),
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
          row.partId = widget.partId;
          PatternRowDetail detail = PatternRowDetail(
            rowId: widget.rowId,
            hasSubrow: 1,
          );
          row.partDetailId = await insertPatternRowDetailInDb(detail);
          detail.rowDetailId = row.partDetailId!;
          if (widget.subrow == null) {
            // print("Insert row ${row.toString()}");
            row.rowId = await insertPatternRowInDb(row);
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
          detail.subRow = row;
          Navigator.pop(context, detail);
        }
      },
      icon: Icon(Icons.save),
    );
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
        title: Text("Create sequence"),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 10,
                children: [
                  Text("In the same stitch"),

                  Switch(
                    value: row.inSameStitch == 0 ? false : true,
                    onChanged: (value) {
                      setState(() {
                        row.inSameStitch = value == false ? 0 : 1;
                      });
                    },
                  ),
                ],
              ),
              TextFormField(
                controller: previewControler,
                readOnly: true,
                decoration: InputDecoration(label: Text("Preview")),
              ),
              _stitchDetailsList(),
              TextFormField(
                decoration: InputDecoration(label: Text("Search a stitch")),
                onChanged: (value) {
                  stitchSearch = value.trim();
                  setState(() {});
                },
              ),
              _stichesList(),
            ],
          ),
        ),
      ),
    );
  }
}
