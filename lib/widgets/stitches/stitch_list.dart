import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/widgets/patternButtons/add_custom_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/add_generic_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/new_stitch_button.dart';
import 'package:craft_stash/widgets/patternButtons/new_subrow_button.dart';
import 'package:craft_stash/widgets/patternButtons/stitch_count_button.dart';
import 'package:flutter/material.dart';

class StitchList extends StatefulWidget {
  Future<Stitch?> Function(Stitch stitch)? onStitchPressed;
  Future<Stitch?> Function(Stitch stitch)? onSequencePressed;
  void Function(Stitch stitch)? onLongPress;
  StitchList({
    super.key,
    this.onStitchPressed,
    this.onSequencePressed,
    this.onLongPress,
    this.customActions,
    this.stitchCountButtonList,
    this.row,
    this.spacing = 10,
    this.newSubrow = false,
    this.newStitch = false,
    this.stitchBlacklistById,
  });
  List<Widget>? customActions = [];
  List<StitchCountButton>? stitchCountButtonList = [];
  List<int>? stitchBlacklistById = [];
  PatternRow? row;
  double spacing;
  bool newSubrow;
  bool newStitch;
  int? rowId;
  int? partId;
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
    if (!mounted) return;
    super.setState(fn);
  }

  Future<void> getAllStitches() async {
    stitches = await getAllStitchesInDb();
    list.clear();
    if (widget.customActions != null) {
      for (Widget action in widget.customActions!) {
        list.add(action);
      }
    }
    if (widget.newSubrow) {
      list.add(
        NewSubrowButton(
          onPressed: (detail) async {
            if (detail != null) {
              stitches.add(Stitch(abreviation: detail.toStringWithoutNumber()));
            }
            setState(() {});
          },
        ),
      );
    }
    if (widget.newSubrow) {
      list.add(
        NewStitchButton(
          onPressed: (stitch) async {
            if (stitch != null) {
              stitches.add(stitch);
              setState(() {});
            }
          },
        ),
      );
    }
    for (Stitch e in stitches) {
      if (e.abreviation.contains(stitchSearch) ||
          (e.name != null && e.name!.contains(stitchSearch))) {
        if (widget.stitchBlacklistById != null &&
            widget.stitchBlacklistById!.contains(e.id)) {
          continue;
        }
        if (e.isSequence == 0) {
          list.add(
            AddGenericDetailButton(
              text: e.abreviation,
              onLongPress: () {
                if (widget.onLongPress != null) {
                  widget.onLongPress?.call(e);
                }
              },
              onPressed: () async {
                if (widget.onStitchPressed != null) {
                  Stitch? s = await widget.onStitchPressed?.call(e);
                  if (s != null) await getAllStitches();
                }
              },
            ),
          );
        } else {
          list.add(
            AddCustomDetailButton(
              text: e.abreviation,
              onPressed: () async {
                if (widget.onSequencePressed != null) {
                  Stitch? s = await widget.onSequencePressed?.call(e);
                  if (s != null) await getAllStitches();
                }
              },
            ),
          );
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    getAllStitches();
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
