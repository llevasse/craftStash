import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/ui/wip_part/wip_part_model.dart';
import 'package:flutter/material.dart';

IconButton wipPartReturnButton({
  required WipPartModel wipPartModel,
  required BuildContext context,
}) {
  return IconButton(
    onPressed: () async {
      Navigator.pop(context, wipPartModel.wipPart);
    },
    icon: Icon(Icons.arrow_back),
  );
}
