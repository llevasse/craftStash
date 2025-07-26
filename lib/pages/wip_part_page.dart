import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/wip/wip_part.dart';
import 'package:craft_stash/widgets/patternButtons/count_button.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class WipPartPage extends StatefulWidget {
  WipPart wipPart;
  WipPartPage({super.key, required this.wipPart});

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
    print(
      "Part totalStitch : ${part.totalStitchNb} | totalStitchDone : ${widget.wipPart.stitchDoneNb}",
    );
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
      tmp.add(
        ListTile(
          title: Text("$rowNumber : ${row.preview!}"),
          contentPadding: EdgeInsets.all(0),
        ),
      );
      totalNumberOfRow += row.numberOfRows;
    }
    // print("total number of rows : $totalNumberOfRow");
    // print("Current row index : ${widget.wipPart.currentRowIndex}");

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
            widget.wipPart.currentRowNumber++;
            widget.wipPart.stitchDoneNb -= widget.wipPart.currentStitchNumber;
            widget.wipPart.stitchDoneNb +=
                part.rows[widget.wipPart.currentRowIndex].stitchesPerRow;
            if (widget.wipPart.currentRowNumber >
                part.rows[widget.wipPart.currentRowIndex].startRow +
                    (part.rows[widget.wipPart.currentRowIndex].numberOfRows -
                        1)) {
              widget.wipPart.currentRowIndex++;
            }
            widget.wipPart.currentStitchNumber = 0;
            updateListView();
          },
          decrease: () {
            widget.wipPart.currentRowNumber--;

            widget.wipPart.stitchDoneNb -= widget.wipPart.currentStitchNumber;
            widget.wipPart.stitchDoneNb -=
                part.rows[widget.wipPart.currentRowIndex].stitchesPerRow;
            if (widget.wipPart.currentRowNumber <
                part.rows[widget.wipPart.currentRowIndex].startRow) {
              widget.wipPart.currentRowIndex--;
            }
            widget.wipPart.currentStitchNumber = 0;
            updateListView();
          },
          min: 1,
          max: totalNumberOfRow,
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
            widget.wipPart.currentStitchNumber++;
            widget.wipPart.stitchDoneNb++;
            if (widget.wipPart.currentStitchNumber ==
                part.rows[widget.wipPart.currentRowIndex].stitchesPerRow) {
              widget.wipPart.madeXTime++;
              if (widget.wipPart.madeXTime == part.numbersToMake) {
                widget.wipPart.finished = 1;
              }
              widget.wipPart.currentRowIndex = 0;
              widget.wipPart.currentRowNumber = 0;
              widget.wipPart.currentStitchNumber = 0;
              updateListView();
            }
          },
          decrease: () {
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
                    widget.wipPart.madeXTime++;
                    if (widget.wipPart.madeXTime == part.numbersToMake) {
                      widget.wipPart.finished = 1;
                    }
                    widget.wipPart.stitchDoneNb =
                        ((part.totalStitchNb / part.numbersToMake) *
                                widget.wipPart.madeXTime)
                            .toInt();

                    widget.wipPart.currentRowIndex = 0;
                    widget.wipPart.currentRowNumber = 0;
                    widget.wipPart.currentStitchNumber = 0;
                  },
                  decrease: () {
                    widget.wipPart.finished = 0;
                    widget.wipPart.madeXTime--;
                    widget.wipPart.stitchDoneNb =
                        ((part.totalStitchNb / part.numbersToMake) *
                                widget.wipPart.madeXTime).toInt();
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
          Navigator.pop(context);
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
