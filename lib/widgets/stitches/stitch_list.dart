import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/ui/core/count_button.dart';
import 'package:craft_stash/ui/core/pattern_detail_buttons/add_custom_detail_button.dart';
import 'package:craft_stash/ui/core/pattern_detail_buttons/add_generic_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/new_stitch_button.dart';
import 'package:craft_stash/ui/row/widget/subrow_button.dart';
import 'package:flutter/material.dart';

typedef MyBuilder =
    void Function(BuildContext context, void Function() methodFromChild);

class StitchList extends StatefulWidget {
  Future<Stitch?> Function(Stitch stitch)? onStitchPressed;
  Future<Stitch?> Function(Stitch stitch)? onSequencePressed;
  void Function(Stitch stitch)? onLongPress;
  final MyBuilder? builder;
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
    this.builder,
  });

  List<AddCustomDetailButton>? customActions = [];
  List<CountButton>? stitchCountButtonList = [];
  List<int>? stitchBlacklistById = [];
  PatternRow? row;
  double spacing;
  bool newSubrow;
  bool newStitch;
  int? rowId;
  int? partId;
  @override
  State<StatefulWidget> createState() => StitchListState();
}

class StitchListState extends State<StitchList> {
  List<Stitch> stitches = [];
  String stitchSearch = "";
  List<Widget> list = List.empty(growable: true);

  void init() async {
    await getAllStitches();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  Future<void> getAllStitches() async {
    stitches = await getAllVisibleStitchesInDb();
    // stitches = await getAllStitchesInDb();
    list.clear();
    if (widget.customActions != null) {
      for (AddCustomDetailButton action in widget.customActions!) {
        list.add(action);
      }
    }
    // if (widget.newSubrow) {
    //   list.add(
    //     RowSubrowButton(
    //       onPressed: (detail) async {
    //         if (detail != null) {
    //           stitches.add(Stitch(abreviation: detail.toString()));
    //         }
    //         init();
    //       },
    //     ),
    //   );
    // }
    if (widget.newStitch) {
      list.add(
        NewStitchButton(
          onPressed: (stitch) async {
            if (stitch != null) {
              stitches.add(stitch);
              init();
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
                  init();
                }
              },
              onPressed: () async {
                if (widget.onStitchPressed != null) {
                  Stitch? s = await widget.onStitchPressed?.call(e);
                  if (s != null) await getAllStitches();
                  init();
                }
              },
            ),
          );
        } else {
          list.add(
            AddCustomDetailButton(
              text: e.abreviation,
              onPressed: (detail) async {
                if (widget.onSequencePressed != null) {
                  Stitch? s = await widget.onSequencePressed?.call(e);
                  if (s != null) await getAllStitches();
                  init();
                }
              },
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      widget.builder!(context, init);
    }
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
