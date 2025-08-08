import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/wip/wip_part.dart';
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
    );
  }
}
