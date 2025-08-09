import 'package:craft_stash/ui/wip/wip_model.dart';
import 'package:flutter/material.dart';

Widget wipAssemblyText({required WipModel wipModel}) {
  return TextFormField(
    initialValue: wipModel.wip!.pattern!.note,
    decoration: InputDecoration(label: Text("Assembly")),
    readOnly: true,
  );
}
