import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/data/repository/pattern_row_repository.dart';
import 'package:craft_stash/ui/row/row_model.dart';
import 'package:craft_stash/ui/row/row_screen.dart';
import 'package:craft_stash/ui/core/widgets/dialogs/new_stitch_dialog.dart';
import 'package:craft_stash/ui/core/widgets/stitch_list.dart';
import 'package:flutter/material.dart';

class StitchesPage extends StatefulWidget {
  const StitchesPage({super.key});

  @override
  State<StatefulWidget> createState() => _StitchesPageState();
}

class _StitchesPageState extends State<StitchesPage> {
  @override
  void initState() {
    // printAllStitch();
    super.initState();
  }

  void printAllStitch() async {
    List<Stitch> stitches = await getAllStitchesInDb();
    for (Stitch s in stitches) {
      s.printDetails();
    }
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
                  onStitchPressed: (stitch) async {
                    return await showDialog(
                          context: context,
                          builder: (BuildContext context) => NewStitchDialog(
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
