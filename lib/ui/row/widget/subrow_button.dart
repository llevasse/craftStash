import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/widgets/patternButtons/add_custom_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/new_subrow_button.dart';

AddCustomDetailButton rowSubrowButton({
  required PatternRowModel patternRowModel,
}) {
  return NewSubrowButton(
    rowId: patternRowModel.row!.rowId,
    onPressed: patternRowModel.addSubrow,
  );
}
