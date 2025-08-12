import 'package:craft_stash/ui/home/home_model.dart';
import 'package:flutter/material.dart';

class HomeFloatActionButton extends StatelessWidget {
  const HomeFloatActionButton({super.key, required this.model});

  final HomeFloatActionButtonModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, child) {
        return model.button;
      },
    );
  }
}
