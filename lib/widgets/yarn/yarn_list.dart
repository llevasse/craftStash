import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:flutter/material.dart';

typedef MyBuilder =
    void Function(BuildContext context, void Function() methodFromChild);

class YarnList extends StatefulWidget {
  void Function(Yarn yarn)? onPress;
  final MyBuilder? builder;
  void Function(Yarn yarn)? onAddYarnPress;
  YarnList({
    super.key,
    this.onPress,
    this.spacing = 10,
    this.builder,
    this.onAddYarnPress,
  });

  double spacing;
  @override
  State<StatefulWidget> createState() => YarnListState();
}

class YarnListState extends State<YarnList> {
  late ThemeData theme;
  List<Yarn> yarns = [];
  List<Widget> list = List.empty(growable: true);
  double buttonSize = 24 * 2;

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
    yarns = await getAllYarn();
    list.clear();

    for (Yarn yarn in yarns) {
      list.add(
        TextButton(
          onPressed: () {
            print(yarn.id);
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
          onPressed: () async {},
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
