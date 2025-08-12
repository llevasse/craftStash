import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/data/repository/pattern/pattern_detail_repository.dart';
import 'package:craft_stash/main.dart';
import 'package:craft_stash/ui/core/widgets/buttons/count_button.dart';
import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/ui/wip_part/wip_part_model.dart';
import 'package:craft_stash/ui/core/widgets/dialogs/stitch_detail_dialog.dart';
import 'package:flutter/material.dart';

class RowStitchCountButton extends StatelessWidget {
  const RowStitchCountButton({
    super.key,
    required this.patternRowModel,
    required this.detail,
    required this.index,
    this.showCount = true,
    this.allowIncrease = true,
    this.allowDecrease = true,
    this.text,
  });
  final int index;
  final PatternRowModel patternRowModel;
  final PatternRowDetail detail;
  final bool showCount;
  final bool allowIncrease;
  final bool allowDecrease;
  final String? text;

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      String text = detail.toString();
      if (detail.inPatternYarnId != null) {
        if (debug) {
          print(text);
          print(patternRowModel.yarnNameMap);
        }
        text = text.replaceAll(
          "\${${detail.inPatternYarnId}}",
          patternRowModel.yarnNameMap![detail.inPatternYarnId]!,
        );
      }
    }
    return CountButton(
      signed: false,
      suffixText: detail.stitch?.abreviation,
      showCount: showCount,
      count: detail.repeatXTime,
      allowIncrease: allowIncrease,
      allowDecrease: allowDecrease,
      onChange: (value) {
        if (value > detail.repeatXTime) {
          patternRowModel.setStitchNb(
            patternRowModel.row!.stitchesPerRow += detail.stitch!.stitchNb,
          );
        } else {
          patternRowModel.setStitchNb(
            patternRowModel.row!.stitchesPerRow -= detail.stitch!.stitchNb,
          );
        }
        detail.repeatXTime = value;
        if (debug)
          print("Row stitch nb : ${patternRowModel.row!.stitchesPerRow}");
      },
      onLongPress: () async {
        await stitchCountLongPress(context);
      },
    );
  }

  Future<void> stitchCountLongPress(BuildContext context) async {
    PatternRowDetail? newDetail = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StitchDetailDialog(detail: detail);
      },
    );
    patternRowModel.row!.stitchesPerRow -=
        detail.repeatXTime * detail.stitch!.stitchNb;
    if (newDetail == null) {
      if (detail.rowDetailId != 0) {
        await PatternDetailRepository().deleteDetail(detail.rowDetailId);
      }
      patternRowModel.detailsCountButtonList.removeAt(index);
      patternRowModel.row!.details.remove(detail);
    } else {
      patternRowModel.row!.stitchesPerRow +=
          detail.repeatXTime * detail.stitch!.stitchNb;
      if (detail.rowDetailId != 0) {
        patternRowModel.row!.details.remove(detail);
        patternRowModel.row!.details.insert(index, newDetail);
        patternRowModel.detailsCountButtonList.removeAt(index);
        patternRowModel.detailsCountButtonList.insert(
          index,
          RowStitchCountButton(
            patternRowModel: patternRowModel,
            detail: detail,
            index: index,
          ),
        );
      }
    }
    patternRowModel.setPreview(patternRowModel.row!.detailsAsString());
  }
}
