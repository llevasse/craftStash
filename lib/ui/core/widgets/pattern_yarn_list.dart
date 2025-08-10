import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/data/repository/yarn/yarn_repository.dart';
import 'package:flutter/material.dart';

typedef MyBuilder =
    void Function(BuildContext context, void Function() methodFromChild);

class PatternYarnList extends StatefulWidget {
  void Function(Yarn yarn)? onPress;
  void Function(Yarn yarn)? onLongPress;
  final MyBuilder? builder;
  void Function()? onAddYarnPress;
  final int? patternId;
  final int? wipId;
  PatternYarnList({
    super.key,
    this.onPress,
    this.onLongPress,
    this.spacing = 10,
    this.builder,
    this.onAddYarnPress,
    this.patternId,
    this.wipId,
  });

  double spacing;
  @override
  State<StatefulWidget> createState() => PatternYarnListState();
}

class PatternYarnListState extends State<PatternYarnList> {
  late ThemeData theme;
  List<Yarn> yarns = [];
  List<Widget> list = List.empty(growable: true);
  double buttonSize = 48;

  void init() async {
    await getAllYarns();
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

  Future<void> getAllYarns() async {
    if (widget.patternId == null && widget.wipId == null) {
      yarns = await YarnRepository().getAllYarn();
    } else {
      if (widget.patternId != null) {
        yarns = await YarnRepository().getAllYarnByPatternId(widget.patternId!);
      } else if (widget.wipId != null) {
        yarns = await YarnRepository().getAllYarnByWipId(widget.wipId!);
      }
    }
    list.clear();

    for (Yarn yarn in yarns) {
      list.add(
        TextButton(
          onPressed: () {
            if (widget.onPress != null) widget.onPress!(yarn);
          },
          onLongPress: () {
            if (widget.onLongPress != null) widget.onLongPress!(yarn);
          },
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(buttonSize, buttonSize)),
            fixedSize: WidgetStatePropertyAll(Size(buttonSize, buttonSize)),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: WidgetStateColor.fromMap({
              WidgetState.any: Color(yarn.color),
            }),
          ),
          child: Text(""),
        ),
      );
    }
    if (widget.onAddYarnPress != null) {
      list.add(
        TextButton(
          onPressed: () {
            widget.onAddYarnPress!();
          },
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(buttonSize, buttonSize)),
            fixedSize: WidgetStatePropertyAll(Size.fromHeight(buttonSize)),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: WidgetStatePropertyAll(
              BorderSide(color: theme.colorScheme.primary, width: 1),
            ),
            backgroundColor: WidgetStateColor.fromMap({
              WidgetState.any: theme.colorScheme.tertiary,
            }),
          ),
          child: Text(
            "Add yarn",
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

    if (widget.builder != null) {
      widget.builder!(context, init);
    }
    return Wrap(spacing: widget.spacing, children: list);
  }
}
