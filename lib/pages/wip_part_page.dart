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
  List<Widget> content = List.empty(growable: true);
  int totalNumberOfRow = 0;
  double spacing = 10;
  String title = "";
  late PatternPart part;

  void getWipPartData() async {
    part = await getPatternPartByPartId(
      id: widget.wipPart.partId,
      withRows: true,
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
      tmp.add(ListTile(title: Text("$rowNumber : ${row.preview!}")));
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
    return (Center(
      child: Row(
        spacing: spacing,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CountButton(
            text: "Current row",
            count: widget.wipPart.currentRowNumber,
            increase: () {
              widget.wipPart.currentRowNumber++;
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
              if (widget.wipPart.currentRowNumber <
                  part.rows[widget.wipPart.currentRowIndex].startRow) {
                widget.wipPart.currentRowIndex--;
              }
              widget.wipPart.currentStitchNumber = 0;
              updateListView();
            },
            min: 1,
            max: totalNumberOfRow,
            signed: false,
          ),
          CountButton(
            text: "Current Stitch",
            count: widget.wipPart.currentStitchNumber,
            increase: () {
              widget.wipPart.currentStitchNumber++;
            },
            decrease: () {
              widget.wipPart.currentStitchNumber--;
            },
            max: part.rows[widget.wipPart.currentRowIndex].stitchesPerRow,
            signed: false,
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Column(
        spacing: spacing,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      ),
    );
  }
}
