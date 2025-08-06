import 'package:craft_stash/ui/row/row_model.dart';
import 'package:flutter/material.dart';

TextFormField rowPreviewField({required PatternRowModel patternRowModel}) {
  return TextFormField(
    scrollController: patternRowModel.previewScrollController,
    controller: patternRowModel.previewControler,
    readOnly: true,
    maxLines: 2,
    minLines: 1,
    decoration: InputDecoration(label: Text("Preview")),
  );
}
