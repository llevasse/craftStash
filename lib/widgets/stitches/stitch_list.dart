import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/widgets/patternButtons/add_generic_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/stitch_count_button.dart';
import 'package:flutter/material.dart';

class StitchList extends StatefulWidget {
  void Function(String stitch)? onPressed;
  StitchList({
    super.key,
    required this.onPressed,
    this.customActions,
    this.stitchCountButtonList,
    this.row,
    this.spacing = 10,
  });
  List<Widget>? customActions = [];
  List<StitchCountButton>? stitchCountButtonList = [];
  PatternRow? row;
  double spacing;
  @override
  State<StatefulWidget> createState() => _StitchListState();
}

class _StitchListState extends State<StitchList> {
  List<Stitch> stitches = [];
  String stitchSearch = "";
  List<Widget> list = List.empty(growable: true);
  @override
  void initState() {
    getAllStitches();
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    list.clear();
    if (widget.customActions != null) {
      for (Widget action in widget.customActions!) {
        list.add(action);
      }
    }
    for (Stitch e in stitches) {
      if (e.abreviation.contains(stitchSearch) ||
          (e.name != null && e.name!.contains(stitchSearch))) {
        list.add(
          AddGenericDetailButton(
            text: e.abreviation,
            onPressed: () {
              if (widget.onPressed != null) {
                widget.onPressed?.call(e.abreviation);
              }
            },
          ),
        );
      }
    }
    super.setState(fn);
  }

  Future<void> getAllStitches() async {
    stitches = await getAllStitchesInDb();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: widget.spacing,
      children: [
        TextFormField(
          decoration: InputDecoration(label: Text("Search a stitch")),
          onChanged: (value) {
            stitchSearch = value.trim();
            setState(() {});
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(spacing: 10, children: list),
          ),
        ),
      ],
    );
  }
}
