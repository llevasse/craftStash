import 'package:craft_stash/ui/core/loading_screen.dart';
import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/ui/row/widget/delete_button.dart';
import 'package:craft_stash/ui/row/widget/nb_row_button%20copy.dart';
import 'package:craft_stash/ui/row/widget/preview_field.dart';
import 'package:craft_stash/ui/row/widget/save_button.dart';
import 'package:craft_stash/ui/row/widget/start_row_button.dart';
import 'package:craft_stash/ui/row/widget/stitch_detail_list.dart';
import 'package:craft_stash/ui/row/widget/stitch_list.dart';

import 'package:flutter/material.dart';

class RowScreen extends StatelessWidget {
  final PatternRowModel patternRowModel;

  const RowScreen({super.key, required this.patternRowModel});
  final double spacing = 10;

  @override
  Widget build(BuildContext context) {
    patternRowModel.load();
    ThemeData theme = Theme.of(context);
    return ListenableBuilder(
      listenable: patternRowModel,
      builder: (BuildContext context, _) {
        if (!patternRowModel.loaded) {
          return LoadingScreen();
        } else {
          if (patternRowModel.needScroll) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => patternRowModel.scrollDown(
                ctrl: patternRowModel.previewScrollController,
                duration: 300,
              ),
            );
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => patternRowModel.scrollDown(
                ctrl: patternRowModel.stitchDetailsScrollController,
                duration: 300,
              ),
            );
            patternRowModel.needScroll = false;
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Row ${patternRowModel.row!.startRow}${patternRowModel.row!.numberOfRows > 1 ? "-${patternRowModel.row!.startRow + patternRowModel.row!.numberOfRows - 1}" : ""}",
              ),
              backgroundColor: theme.colorScheme.primary,
              actions: [
                rowDeleteButton(
                  patternRowModel: patternRowModel,
                  context: context,
                ),
                rowSaveButton(
                  patternRowModel: patternRowModel,
                  context: context,
                ),
              ],
            ),

            body: Form(
              key: patternRowModel.formKey,
              child: Container(
                padding: EdgeInsets.all(spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: spacing,
                  children: [
                    Row(
                      spacing: spacing,
                      children: [
                        Expanded(
                          child: rowStartRowButton(
                            patternRowModel: patternRowModel,
                          ),
                        ),
                        Expanded(
                          child: rowNbOfRowButton(
                            patternRowModel: patternRowModel,
                          ),
                        ),
                      ],
                    ),
                    rowPreviewField(patternRowModel: patternRowModel),
                    rowStitchDetailsList(patternRowModel: patternRowModel),
                    Expanded(
                      child: RowStitchList(patternRowModel: patternRowModel),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}