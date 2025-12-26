import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/ui/core/pattern_detail_buttons/add_custom_detail_button.dart';
import 'package:craft_stash/ui/core/pattern_detail_buttons/start_color_button.dart';

AddCustomDetailButton rowStartColorButton({
  required PatternRowModel patternRowModel,
}) {
  return StartColorButton(
    onReturn: patternRowModel.addStartColor,
    rowId: patternRowModel.row!.rowId,
    patternId: patternRowModel.part!.patternId,
  );
}
