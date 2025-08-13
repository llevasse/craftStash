import 'package:craft_stash/ui/core/loading_screen.dart';
import 'package:craft_stash/ui/core/widgets/buttons/count_button.dart';
import 'package:craft_stash/ui/yarn_form_dialog/widget/brand_drop_down_menu.dart';
import 'package:craft_stash/ui/yarn_form_dialog/widget/color_name_input.dart';
import 'package:craft_stash/ui/yarn_form_dialog/widget/color_selector.dart';
import 'package:craft_stash/ui/yarn_form_dialog/widget/material_drop_down_menu.dart';
import 'package:craft_stash/ui/yarn_form_dialog/widget/max_hook_input.dart';
import 'package:craft_stash/ui/yarn_form_dialog/widget/min_hook_input.dart';
import 'package:craft_stash/ui/yarn_form_dialog/widget/thickness_input.dart';
import 'package:craft_stash/ui/yarn_form_dialog/yarn_form_dialog_model_abstart.dart';
import 'package:flutter/material.dart';

class YarnForm extends StatelessWidget {
  YarnForm({super.key, required this.model});
  YarnFormDialogModelAbstart model;

  @override
  Widget build(BuildContext context) {
    model.load();
    return ListenableBuilder(
      listenable: model,
      builder: (BuildContext context, _) {
        return AlertDialog(
          title: Text(model.title),
          content: model.loaded == false
              ? LoadingScreen()
              : Form(
                  key: model.formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: model.spacing,
                      children: [
                        ?!model.isCollection
                            ? YarnColorSelector(model: model)
                            : null,
                        ?!model.isCollection ? colorNameInput(model) : null,
                        BrandDropdownMenu(model: model),
                        MaterialDropdownMenu(model: model),
                        thicknessInput(model),
                        Row(
                          spacing: model.spacing,
                          children: [
                            Expanded(child: minHookInput(model)),
                            Expanded(child: maxHookInput(model)),
                          ],
                        ),
                        ?model.showSkeins && !model.isCollection
                            ? CountButton(
                                count: model.base.nbOfSkeins,
                                onChange: model.setNbSkeins,
                                suffixText: " Skein",
                                signed: false,
                              )
                            : null,
                      ],
                    ),
                  ),
                ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (model.onCancel != null) {
                  await model.onCancel!(model.base);
                }
                Navigator.pop(context);
              },
              child: Text(model.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (model.ifValidFunction != null) {
                  if (model.formKey.currentState!.validate()) {
                    model.formKey.currentState!.save();
                    await model.ifValidFunction!(model.base);
                  }
                }
                if (model.updateYarn != null) {
                  await model.updateYarn!();
                }

                Navigator.pop(context);
              },
              child: Text(model.confirm),
            ),
          ],
        );
      },
    );
  }
}
