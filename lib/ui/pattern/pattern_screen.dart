import 'package:craft_stash/ui/core/loading_screen.dart';
import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:craft_stash/ui/pattern/widget/assembly_input.dart';
import 'package:craft_stash/ui/pattern/widget/delete_button.dart';
import 'package:craft_stash/ui/pattern/widget/hook_size_input.dart';
import 'package:craft_stash/ui/pattern/widget/parts_list_tile.dart';
import 'package:craft_stash/ui/pattern/widget/save_button.dart';
import 'package:craft_stash/ui/pattern/widget/title_input.dart';
import 'package:craft_stash/ui/pattern/widget/yarn_list.dart';
import 'package:craft_stash/ui/pattern/widget/add_part_button.dart';
import 'package:flutter/material.dart';

class PatternScreen extends StatelessWidget {
  final PatternModel patternModel;

  const PatternScreen({super.key, required this.patternModel});
  final double spacing = 10;

  @override
  Widget build(BuildContext context) {
    patternModel.load();
    ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: patternModel,
      builder: (BuildContext context, _) {
        if (!patternModel.loaded) {
          return LoadingScreen();
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(patternModel.pattern!.name),
              backgroundColor: theme.colorScheme.primary,
              actions: [
                patternDeleteButton(
                  patternModel: patternModel,
                  context: context,
                ),
                patternSaveButton(patternModel: patternModel, context: context),
              ],
            ),

            body: Form(
              key: patternModel.formKey,
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
                          child: patternTitleInput(patternModel: patternModel),
                        ),
                        Expanded(
                          child: patternHookSizeInput(
                            patternModel: patternModel,
                          ),
                        ),
                      ],
                    ),
                    patternYarnList(
                      context: context,
                      patternModel: patternModel,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: patternModel.pattern!.parts.length,
                        itemBuilder: (_, index) => PatternPartsListTile(
                          part: patternModel.pattern!.parts[index],
                          patternModel: patternModel,
                        ),
                      ),
                    ),
                    patternAssemblyInput(patternModel: patternModel),
                  ],
                ),
              ),
            ),
            floatingActionButton: AddPartButton(
              updatePatternListView: patternModel.reload,
              pattern: patternModel.pattern!,
            ),
          );
        }
      },
    );
  }
}
