import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/widgets/patternButtons/stitch_count_button.dart';
import 'package:craft_stash/widgets/stitches/stitch_list.dart';
import 'package:flutter/material.dart';

/// if rowId or partId are null, new subrow will be created but not added to any pattern or row
class NewSubRowPage extends StatefulWidget {
  final int? stitchId;
  final PatternRow? subrow;
  final int? rowId;
  final int? partId;
  const NewSubRowPage({
    super.key,
    this.subrow,
    this.rowId,
    this.partId,
    this.stitchId,
  });

  @override
  State<StatefulWidget> createState() => _NewSubRowPageState();
}

class _NewSubRowPageState extends State<NewSubRowPage> {
  List<Stitch> stitches = [];
  List<int> blacklist = [];
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
    if (widget.stitchId != null) {
      blacklist.add(widget.stitchId as int);
    }
    getAllStitches();
    row.startRow = 0;
    row.numberOfRows = 0;
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

  Future<Stitch?> _addStitch(Stitch stitch) async {
    if (row.details.isNotEmpty &&
        row.details.last.stitch == stitch.abreviation) {
      row.details.last.repeatXTime += 1;
      details.removeLast();
    } else {
      row.details.add(PatternRowDetail(rowId: -1, stitchId: stitch.id));
    }
    details.add(_createStitchCountButton(stitch.abreviation));
    needScroll = true;
    setState(() {});
  }

  Widget _saveButton() {
    return IconButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          PatternRowDetail detail = PatternRowDetail(rowId: 0, stitchId: 0);

          if (widget.stitchId == null) {
            detail.stitchId = await insertStitchInDb(
              Stitch(
                abreviation: detail.toString(),
                isSequence: 1,
                sequenceId: row.rowId,
              ),
            );
          } else {
            await updateStitchInDb(
              Stitch(
                id: widget.stitchId as int,
                abreviation: detail.toString(),
                isSequence: 1,
                sequenceId: row.rowId,
              ),
            );
          }

          if (widget.partId != null && widget.rowId != null) {
            row.partId = widget.partId!;
            detail.rowId = widget.rowId!;
          }
          if (widget.subrow == null) {
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

              Expanded(
                child: StitchList(
                  onStitchPressed: _addStitch,
                  stitchBlacklistById: blacklist,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
