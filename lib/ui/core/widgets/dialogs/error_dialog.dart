import 'package:flutter/material.dart';

class ErrorDialog extends StatefulWidget {
  final String error;
  const ErrorDialog({super.key, required this.error});

  @override
  State<StatefulWidget> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Error"),
      content: Text(widget.error),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Ok"),
        ),
      ],
    );
  }
}
