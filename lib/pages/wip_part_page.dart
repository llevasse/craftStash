import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/wip/wip_part.dart';
import 'package:flutter/material.dart';

class WipPartPage extends StatefulWidget {
  WipPart wipPart;
  WipPartPage({super.key, required this.wipPart});

  @override
  State<StatefulWidget> createState() => WipPartPageState();
}

class WipPartPageState extends State<WipPartPage> {
  List<Widget> partListView = List.empty(growable: true);
  double spacing = 10;

  void getWipPartData() async {
    widget.wipPart.part = await getPatternPartByPartId(
      id: widget.wipPart.partId,
      withRows: true,
    );
    updateListView();
  }

  @override
  void initState() {
    super.initState();
    getWipPartData();
  }

  Future<void> updateListView() async {
    List<Widget> tmp = List.empty(growable: true);

    for (PatternRow row in widget.wipPart.part!.rows) {
      String rowNumber = "Row ${row.startRow}";
      if (row.numberOfRows > 1) {
        rowNumber +=
            "-${row.startRow + row.numberOfRows - 1} (${row.numberOfRows}rows)";
      }
      tmp.add(ListTile(title: Text("$rowNumber : ${row.preview!}")));
    }
    partListView.clear();

    partListView.add(Expanded(child: ListView(children: tmp)));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wipPart.part!.name),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Column(
        spacing: spacing,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: partListView,
      ),
    );
  }
}
