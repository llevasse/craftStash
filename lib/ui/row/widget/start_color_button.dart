import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/widgets/patternButtons/add_custom_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/start_color_button.dart';

AddCustomDetailButton rowStartColorButton({
  required PatternRowModel patternRowModel,
}) {
  return StartColorButton(
    onPressed: patternRowModel.addStartColor,
    rowId: patternRowModel.row!.rowId,
    patternId: patternRowModel.patternId,
  );
}
