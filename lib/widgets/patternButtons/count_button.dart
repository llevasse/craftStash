import 'package:flutter/material.dart';

class CountButton extends StatefulWidget {
  int count;
  int? min;
  int? max;
  bool signed;
  String? suffixText;
  String? prefixText;
  Color? textBackgroundColor;
  bool showCount;
  void Function() increase;
  void Function() decrease;
  CountButton({
    super.key,
    required this.count,
    this.suffixText,
    this.prefixText,
    this.min,
    this.max,
    this.showCount = true,
    required this.increase,
    required this.decrease,
    this.signed = true,
    this.textBackgroundColor,
  });

  @override
  State<StatefulWidget> createState() => _CountButtonState();
}

class _CountButtonState extends State<CountButton> {
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
          IconButton(
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
              if (widget.min == null || widget.count > (widget.min as int)) {
                widget.decrease();
                setState(() {
                  widget.count -= 1;
                });
              }
            },
            icon: Icon(Icons.remove, color: theme.colorScheme.secondary),
          ),

          Container(
            color: widget.textBackgroundColor,
            constraints: BoxConstraints(maxWidth: 200),
            padding: EdgeInsets.all(10),

            child: Text(
              "${widget.prefixText ?? ""}${widget.showCount ? widget.count : ""}${widget.suffixText ?? ""}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.secondary,
                overflow: TextOverflow.clip,
              ),
              overflow: TextOverflow.clip,
            ),
          ),
          IconButton(
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
              if (widget.max == null || widget.count < (widget.max as int)) {
                widget.increase();
                setState(() {
                  widget.count += 1;
                });
              }
            },
            icon: Icon(Icons.add, color: theme.colorScheme.secondary),
          ),
        ],
      ),
    );
  }
}
