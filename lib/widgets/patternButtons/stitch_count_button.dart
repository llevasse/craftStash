import 'package:flutter/material.dart';

class StitchCountButton extends StatefulWidget {
  int count;
  bool signed;
  String? text;
  void Function() increase;
  void Function() decrease;
  StitchCountButton({
    super.key,
    required this.count,
    this.text,
    required this.increase,
    required this.decrease,
    this.signed = true,
  });

  @override
  State<StatefulWidget> createState() => _StitchCountButtonState();
}

class _StitchCountButtonState extends State<StitchCountButton> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsetsGeometry.zero),
        side: WidgetStatePropertyAll(
          BorderSide(color: theme.colorScheme.primary, width: 5),
        ),
        shape: WidgetStatePropertyAll(
          RoundedSuperellipseBorder(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(18)),
          ),
        ),

        backgroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
      ),
      clipBehavior: Clip.hardEdge,
      onPressed: () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder()),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: WidgetStatePropertyAll(Size.zero),
              padding: WidgetStatePropertyAll(EdgeInsetsGeometry.all(10)),
              backgroundColor: WidgetStateColor.fromMap({
                WidgetState.any: Colors.amber,
              }),
            ),
            onPressed: () {
              if (widget.signed == false && widget.count == 0) return;
              widget.decrease();
              setState(() {
                widget.count -= 1;
              });
            },
            child: Text(
              "-",
              textScaler: TextScaler.linear(1.25),
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),

          Container(
          constraints: BoxConstraints(maxWidth: 200),
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "${widget.count.toString()}${widget.text ?? ""}",
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),
          TextButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder()),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: WidgetStatePropertyAll(Size.zero),
              padding: WidgetStatePropertyAll(EdgeInsetsGeometry.all(10)),
              backgroundColor: WidgetStateColor.fromMap({
                WidgetState.any: Colors.amber,
              }),
            ),
            onPressed: () {
              widget.increase();
              setState(() {
                widget.count += 1;
              });
            },
            child: Text(
              "+",
              textScaler: TextScaler.linear(1.25),
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
