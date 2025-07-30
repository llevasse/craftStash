import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/wip/wip_part.dart';
import 'package:craft_stash/main.dart';
import 'package:craft_stash/widgets/patternButtons/count_button.dart';
import 'package:flutter/material.dart';

class WipPartPage extends StatefulWidget {
  WipPart wipPart;
  Map<int, String> yarnIdToNameMap;
  WipPartPage({
    super.key,
    required this.wipPart,
    required this.yarnIdToNameMap,
  });

  @override
  State<StatefulWidget> createState() => WipPartPageState();
}

class WipPartPageState extends State<WipPartPage> {
  late ThemeData theme;
  List<Widget> content = List.empty(growable: true);
  int totalNumberOfRow = 0;
  double spacing = 10;
  String title = "";
  PatternPart part = PatternPart(name: "", patternId: 0);

  void getWipPartData() async {
    part = await getPatternPartByPartId(
      id: widget.wipPart.partId,
      withRows: true,
    );
    if (debug) {
      print(
        "Part totalStitch : ${part.totalStitchNb} | totalStitchDone : ${widget.wipPart.stitchDoneNb}",
      );
    }
    title = part.name;
    updateListView();
  }

  @override
  void initState() {
    super.initState();
    getWipPartData();
  }

  Future<void> updateListView() async {
    List<Widget> tmp = List.empty(growable: true);
    totalNumberOfRow = 0;
    for (PatternRow row in part.rows) {
      String rowNumber = "Row ${row.startRow}";
      if (row.numberOfRows > 1) {
        rowNumber +=
            "-${row.startRow + row.numberOfRows - 1} (${row.numberOfRows}rows)";
      }
      String? preview = row.preview;
      if (preview != null) {
        for (MapEntry<int, String> entry in widget.yarnIdToNameMap.entries) {
          preview = preview!.replaceAll("\${${entry.key}}", entry.value);
        }
      }
      tmp.add(
        ListTile(
          title: Text("$rowNumber : $preview"),
          contentPadding: EdgeInsets.all(0),
        ),
      );
      totalNumberOfRow += row.numberOfRows;
    }

    content.clear();
    content.add(_wipPartInput());
    content.add(Expanded(child: ListView(children: tmp)));
    setState(() {});
  }

  Widget _wipPartInput() {
    return Center(
      child: Row(
        spacing: spacing,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [_rowCounter(), _stitchCounter()],
      ),
    );
  }

  Widget _rowCounter() {
    return Column(
      spacing: spacing,
      children: [
        _conterText("Current row"),
        CountButton(
          textBackgroundColor: Colors.white,
          count: widget.wipPart.currentRowNumber,
          increase: () {
            if (widget.wipPart.finished == 1) return;
            PatternRow row = part.rows[widget.wipPart.currentRowIndex];

            widget.wipPart.currentRowNumber++;
            widget.wipPart.stitchDoneNb +=
                row.stitchesPerRow - widget.wipPart.currentStitchNumber;
            if (debug) {
              print(
                "Add ${row.stitchesPerRow - widget.wipPart.currentStitchNumber} stitches",
              );
            }
            if (widget.wipPart.currentRowNumber >
                part.rows.last.startRow + (part.rows.last.numberOfRows - 1)) {
              widget.wipPart.madeXTime += 1;
              if (widget.wipPart.madeXTime >= part.numbersToMake) {
                widget.wipPart.finished = 1;
              }
              widget.wipPart.currentRowIndex = 0;
              widget.wipPart.currentRowNumber = part.rows.first.startRow;
            } else if (widget.wipPart.currentRowNumber >
                row.startRow + (row.numberOfRows - 1)) {
              widget.wipPart.currentRowIndex++;
            }
            widget.wipPart.currentStitchNumber = 0;
            updateListView();
          },
          decrease: () {
            widget.wipPart.currentRowNumber--;
            widget.wipPart.finished = 0;
            if (widget.wipPart.currentRowNumber <
                part.rows[widget.wipPart.currentRowIndex].startRow) {
              widget.wipPart.currentRowIndex--;
            }
            widget.wipPart.stitchDoneNb -= widget.wipPart.currentStitchNumber;
            widget.wipPart.stitchDoneNb -=
                part.rows[widget.wipPart.currentRowIndex].stitchesPerRow;
            if (debug) {
              print(
                "Remove ${widget.wipPart.currentStitchNumber + part.rows[widget.wipPart.currentRowIndex].stitchesPerRow} stitches",
              );
            }
            widget.wipPart.currentStitchNumber = 0;
            updateListView();
          },
          min: 1,
          max: totalNumberOfRow + 1,
        ),
      ],
    );
  }

  Widget _stitchCounter() {
    return Column(
      spacing: spacing,
      children: [
        _conterText("Stitch count"),
        CountButton(
          textBackgroundColor: Colors.white,
          count: widget.wipPart.currentStitchNumber,
          increase: () {
            if (widget.wipPart.finished == 1) return;
            widget.wipPart.currentStitchNumber++;
            widget.wipPart.stitchDoneNb++;
            if (widget.wipPart.currentStitchNumber ==
                part.rows[widget.wipPart.currentRowIndex].stitchesPerRow) {
              if (part.rows.length - 1 == widget.wipPart.currentRowIndex) {
                widget.wipPart.madeXTime++;
              }

              if (widget.wipPart.madeXTime == part.numbersToMake) {
                widget.wipPart.finished = 1;
              }

              widget.wipPart.currentRowIndex = 0;
              widget.wipPart.currentRowNumber = part.rows.first.startRow;
              widget.wipPart.currentStitchNumber = 0;
              updateListView();
            }
          },
          decrease: () {
            widget.wipPart.finished = 0;

            widget.wipPart.currentStitchNumber--;
            widget.wipPart.stitchDoneNb--;
          },
          max: part.rows[widget.wipPart.currentRowIndex].stitchesPerRow,
          signed: false,
        ),
      ],
    );
  }

  Widget _conterText(String text) {
    return Text(text, textScaler: TextScaler.linear(1.5));
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: theme.colorScheme.primary,
        leading: IconButton(
          onPressed: () async {
            await updateWipPartInDb(widget.wipPart);
            Navigator.pop(context, widget.wipPart);
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          ?part.numbersToMake > 1
              ? CountButton(
                  count: widget.wipPart.madeXTime,
                  increase: () {
                    if (widget.wipPart.finished == 1) return;

                    widget.wipPart.madeXTime++;
                    if (widget.wipPart.madeXTime == part.numbersToMake) {
                      widget.wipPart.finished = 1;
                    }
                    widget.wipPart.stitchDoneNb =
                        ((part.totalStitchNb / part.numbersToMake) *
                                widget.wipPart.madeXTime)
                            .toInt();
                    if (debug) {
                      print("Set to ${widget.wipPart.stitchDoneNb} stitches");
                    }
                    widget.wipPart.currentRowIndex = 0;
                    widget.wipPart.currentRowNumber = 0;
                    widget.wipPart.currentStitchNumber = 0;
                  },
                  decrease: () {
                    widget.wipPart.finished = 0;
                    widget.wipPart.madeXTime--;
                    widget.wipPart.stitchDoneNb =
                        ((part.totalStitchNb / part.numbersToMake) *
                                widget.wipPart.madeXTime)
                            .toInt();
                    if (debug) {
                      print("Set to ${widget.wipPart.stitchDoneNb} stitches");
                    }

                    widget.wipPart.currentRowIndex = 0;
                    widget.wipPart.currentRowNumber = 0;
                    widget.wipPart.currentStitchNumber = 0;
                  },
                  max: part.numbersToMake,
                  signed: false,
                )
              : null,
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(spacing),
        child: Column(
          spacing: spacing,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: content,
        ),
      ),
      floatingActionButton: OutlinedButton(
        onPressed: () async {
          widget.wipPart.finished = widget.wipPart.finished == 0 ? 1 : 0;
          await updateWipPartInDb(widget.wipPart);
          Navigator.pop(context, widget.wipPart);
        },
        style: ButtonStyle(
          side: WidgetStatePropertyAll(
            BorderSide(color: theme.colorScheme.primary, width: 0),
          ),
          shape: WidgetStatePropertyAll(
            RoundedSuperellipseBorder(
              borderRadius: BorderRadiusGeometry.all(Radius.circular(18)),
            ),
          ),

          backgroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
        ),
        child: Text(
          widget.wipPart.finished == 0
              ? "Mark as finished"
              : "Mark as unfinished",
          style: TextStyle(color: theme.colorScheme.secondary),
          textScaler: TextScaler.linear(1.25),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
