import 'package:craft_stash/ui/yarn_form_dialog/yarn_form_dialog_model_abstart.dart';
import 'package:flutter/material.dart';

typedef MenuEntry = DropdownMenuEntry<String>;

class YarnFormDialogModel extends YarnFormDialogModelAbstart {
  YarnFormDialogModel({
    required super.base,
    required super.confirm,
    required super.cancel,
    required super.title,
    super.fill,
    super.fromCategory,
    super.ifValidFunction,
    super.onCancel,
    super.readOnly,
    super.showSkeins,
    super.updateYarn,
  });
}
