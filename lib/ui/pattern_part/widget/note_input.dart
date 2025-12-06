import 'package:craft_stash/ui/pattern_part/pattern_part_model.dart';
import 'package:flutter/material.dart';

class PartNoteInput extends StatelessWidget {
  final PatternPartModel patternPartModel;

  const PartNoteInput({super.key, required this.patternPartModel});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return TextFormField(
      maxLines: 2,
      initialValue: patternPartModel.part?.note,
      decoration: InputDecoration(
        label: Text("Note"),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.secondary, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 3),
        ),
      ),
      validator: (value) {
        return null;
      },
      onChanged: (value) {
        patternPartModel.setNote(value);
      },
    );
  }
}
