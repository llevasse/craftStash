import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/data/repository/pattern/pattern_row_repository.dart';
import 'package:craft_stash/data/repository/stitch_repository.dart';
import 'package:craft_stash/ui/core/widgets/dialogs/new_stitch_dialog.dart';
import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/ui/row/row_screen.dart';
import 'package:flutter/material.dart';

class StitchModel extends ChangeNotifier {
  StitchModel({required StitchRepository stitchRepository})
    : _stitchRepository = stitchRepository;
  final StitchRepository _stitchRepository;

  bool loaded = false;

  Future<void> load() async {
    loaded = true;
    notifyListeners();
  }

  Future<void> reload() async {
    loaded = false;
    notifyListeners();
    load();
  }

  Future<Stitch?> onStitchPressed({
    required BuildContext context,
    required Stitch stitch,
  }) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) =>
              NewStitchDialog(base: stitch, onValidate: () {}),
        )
        as Stitch?;
  }

  Future<Stitch?> onSequencePressed({
    required BuildContext context,
    required Stitch stitch,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        settings: RouteSettings(name: "subrow"),
        builder: (context) => RowScreen(
          patternRowModel: PatternRowModel(
            patternRowRepository: PatternRowRepository(),
            id: stitch.row!.rowId,
            stitchId: stitch.id,
            isSubRow: true,
          ),
        ),
      ),
    );
    return stitch;
  }
}
