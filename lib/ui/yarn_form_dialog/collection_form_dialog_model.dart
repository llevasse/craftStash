import 'package:craft_stash/ui/yarn_form_dialog/yarn_form_dialog_model_abstart.dart';
import 'package:flutter/material.dart';

typedef MenuEntry = DropdownMenuEntry<String>;

class CollectionFormDialogModel extends YarnFormDialogModelAbstart {
  CollectionFormDialogModel({
    required super.base,
    required super.confirm,
    required super.cancel,
    required super.title,
    super.fill,
    super.allowDelete,
    super.ifValidFunction,
    super.updateYarn,
  }) : super(isCollection: true);
}
