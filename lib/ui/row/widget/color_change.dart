import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/ui/core/pattern_detail_buttons/add_custom_detail_button.dart';
import 'package:craft_stash/ui/core/pattern_detail_buttons/color_change_button.dart';

AddCustomDetailButton rowColorChangeButton({
  required PatternRowModel patternRowModel,
}) {
  return ColorChangeButton(
    onPressed: patternRowModel.addColorChange,
    rowId: patternRowModel.row!.rowId,
    patternId: patternRowModel.patternId!,
  );
}
