import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/pages/new_sub_row_page.dart';
import 'package:craft_stash/widgets/patternButtons/add_custom_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/add_generic_detail_button.dart';
import 'package:craft_stash/widgets/patternButtons/new_stitch_button.dart';
import 'package:craft_stash/widgets/stitches/stitch_form.dart';
import 'package:craft_stash/widgets/stitches/stitch_list.dart';
import 'package:flutter/material.dart';

class StitchesPage extends StatefulWidget {
  const StitchesPage({super.key});

  @override
  State<StatefulWidget> createState() => _StitchesPageState();
}

class _StitchesPageState extends State<StitchesPage> {
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
                  onStitchPressed: (stitch) async {
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
                  onSequencePressed: (stitch) async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        settings: RouteSettings(name: "subrow"),
                        builder: (BuildContext context) =>
                            NewSubRowPage(subrow: stitch.row),
                      ),
                    );
                    return stitch;
                  },
                  newSubrow: true,
                  newStitch: true,
                  customActions: [
                    // _createNewStitchButton(),
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
