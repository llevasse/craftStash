import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/data/repository/pattern/pattern_detail_repository.dart';
import 'package:craft_stash/main.dart';
import 'package:craft_stash/ui/core/widgets/buttons/count_button.dart';
import 'package:craft_stash/ui/row/row_model.dart';
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
    this.prevRowStitchNb,
  });
  final int index;
  final PatternRowModel patternRowModel;
  final PatternRowDetail detail;
  final bool showCount;
  final bool allowIncrease;
  final bool allowDecrease;
  final String? text;
  final int? prevRowStitchNb;

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
          patternRowModel.row!.stitchesUsedFromPreviousRow += 1;
        } else {
          patternRowModel.setStitchNb(
            patternRowModel.row!.stitchesPerRow -= detail.stitch!.stitchNb,
          );
          patternRowModel.row!.stitchesUsedFromPreviousRow -= 1;
        }
        detail.repeatXTime = value;
        if (debug) {
          print("Row stitch nb : ${patternRowModel.row!.stitchesPerRow}");
        }
        patternRowModel.setPreview(patternRowModel.row!.detailsAsString());
      },
      onLongPress: () async {
        await stitchCountLongPress(context);
      },
    );
  }

  Future<void> stitchCountLongPress(BuildContext context) async {
    PatternRow tmpRow = patternRowModel.row!;
    tmpRow.details.remove(detail);
    tmpRow.stitchesPerRow -= detail.repeatXTime * detail.stitch!.stitchNb;
    tmpRow.stitchesUsedFromPreviousRow -= detail.repeatXTime;

    PatternRowDetail? newDetail = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        tmpRow.printDetails();
        return StitchDetailDialog(
          detail: detail,
          prevRowStitchNb: prevRowStitchNb,
          previousRowStitchNbUsed: tmpRow.stitchesUsedFromPreviousRow,
        );
      },
    );
    if (newDetail == null) {
      tmpRow.stitchesPerRow += detail.repeatXTime * detail.stitch!.stitchNb;
      tmpRow.details.insert(index, detail);

      return;
    }

    if (newDetail.rowId == -1) {
      // if detail is set to be deleted
      await PatternDetailRepository().deleteDetail(detail.rowDetailId);
      patternRowModel.detailsCountButtonList.removeAt(index);
    } else {
      print("Add button");
      tmpRow.stitchesPerRow +=
          newDetail.repeatXTime * newDetail.stitch!.stitchNb;
      tmpRow.stitchesUsedFromPreviousRow += newDetail.repeatXTime;
      tmpRow.details.insert(index, newDetail);
      patternRowModel.detailsCountButtonList.removeAt(index);
      patternRowModel.detailsCountButtonList.insert(
        index,
        RowStitchCountButton(
          patternRowModel: patternRowModel,
          prevRowStitchNb: prevRowStitchNb,
          detail: newDetail,
          index: index,
        ),
      );
    }
    patternRowModel.setRow(tmpRow);
    patternRowModel.setPreview(tmpRow.detailsAsString());
  }
}
