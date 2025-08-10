import 'package:craft_stash/ui/core/loading_screen.dart';
import 'package:craft_stash/ui/pattern_part/pattern_part_model.dart';
import 'package:craft_stash/ui/pattern_part/widget/delete_button.dart';
import 'package:craft_stash/ui/pattern_part/widget/repeat_x_time_button.dart';
import 'package:craft_stash/ui/pattern_part/widget/row_list_tile.dart';
import 'package:craft_stash/ui/pattern_part/widget/save_button.dart';
import 'package:craft_stash/ui/pattern_part/widget/title_input.dart';
import 'package:craft_stash/ui/pattern_part/widget/add_row_button.dart';
import 'package:flutter/material.dart';

class PatternPartScreen extends StatelessWidget {
  final PatternPartModel patternPartModel;

  const PatternPartScreen({super.key, required this.patternPartModel});
  final double spacing = 10;

  @override
  Widget build(BuildContext context) {
    patternPartModel.load();
    ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: patternPartModel,
      builder: (BuildContext context, _) {
        if (!patternPartModel.loaded) {
          return LoadingScreen();
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(patternPartModel.part!.name),
              backgroundColor: theme.colorScheme.primary,
              actions: [
                partDeleteButton(
                  patternPartModel: patternPartModel,
                  context: context,
                ),
                partSaveButton(
                  patternPartModel: patternPartModel,
                  context: context,
                ),
              ],
            ),

            body: Form(
              key: patternPartModel.formKey,
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
                          child: partTitleInput(
                            patternPartModel: patternPartModel,
                          ),
                        ),
                        Expanded(
                          child: partRepeatXTimeButton(
                            patternPartModel: patternPartModel,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: patternPartModel.part!.rows.length,
                        itemBuilder: (_, index) => RowListTile(
                          row: patternPartModel.part!.rows[index],
                          patternPartModel: patternPartModel,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: AddRowButton(
              patternPartModel: patternPartModel,
            ),
          );
        }
      },
    );
  }
}
