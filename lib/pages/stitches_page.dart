import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/widgets/patternButtons/add_custom_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/add_generic_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/new_subrow_button.dart';
import 'package:craft_stash/widgets/stitches/stitch_form.dart';
import 'package:craft_stash/widgets/stitches/stitch_list.dart';
import 'package:flutter/material.dart';

class StitchesPage extends StatefulWidget {
  const StitchesPage({super.key});

  @override
  State<StatefulWidget> createState() => _StitchesPageState();
}

class _StitchesPageState extends State<StitchesPage> {
  Widget _createNewStitchButton() {
    return AddCustomDetailButton(
      text: "New stitch",
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) => StitchForm(
            onValidate: () {
              setState(() {});
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Stitches"),

        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: StitchList(
                  onPressed: (stitch) async {
                    return await showDialog(
                          context: context,
                          builder: (BuildContext context) => StitchForm(
                            base: stitch,
                            onValidate: () {
                              setState(() {});
                            },
                          ),
                        )
                        as Stitch?;
                  },
                  customActions: [
                    _createNewStitchButton(),
                    NewSubrowButton(
                      onPressed: (detail) async {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
