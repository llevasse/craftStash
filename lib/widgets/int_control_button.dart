import 'package:flutter/material.dart';

class IntControlButton extends StatefulWidget {
  int count;
  String text;
  void Function() increase;
  void Function() decrease;
  IntControlButton({
    super.key,
    required this.count,
    required this.text,
    required this.increase,
    required this.decrease,
  });

  @override
  State<StatefulWidget> createState() => _IntControlButtonState();
}

class _IntControlButtonState extends State<IntControlButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.text, softWrap: true, overflow: TextOverflow.ellipsis),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
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
                  widget.decrease();
                  setState(() {
                    widget.count -= 1;
                  });
                },
                child: Text(
                  "-",
                  textScaler: TextScaler.linear(1.25),
                  style: TextStyle(color: Colors.white),
                ),
              ),

              SizedBox.fromSize(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    widget.count.toString(),
                    textAlign: TextAlign.center,
                  ),
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
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
