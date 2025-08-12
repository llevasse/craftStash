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
  void Function(int value) onChange;
  void Function()? onLongPress;
  bool allowIncrease;
  bool allowDecrease;

  CountButton({
    super.key,
    required this.count,
    this.suffixText,
    this.prefixText,
    this.min,
    this.max,
    this.showCount = true,

    required this.onChange,
    this.onLongPress,
    this.signed = true,
    this.textBackgroundColor,
    this.allowIncrease = true,
    this.allowDecrease = true,
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
      onLongPress: widget.onLongPress,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ?widget.allowIncrease ? _increase() : null,

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
          ?widget.allowDecrease ? _decrease() : null,
        ],
      ),
    );
  }

  Widget _increase() {
    ThemeData theme = Theme.of(context);
    return IconButton(
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
          widget.count -= 1;
          widget.onChange(widget.count);
          setState(() {});
        }
      },
      icon: Icon(Icons.remove, color: theme.colorScheme.secondary),
    );
  }

  Widget _decrease() {
    ThemeData theme = Theme.of(context);
    return IconButton(
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
          widget.count += 1;
          widget.onChange(widget.count);
          setState(() {});
        }
      },
      icon: Icon(Icons.add, color: theme.colorScheme.secondary),
    );
  }
}
