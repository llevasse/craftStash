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

// class RowPage extends StatefulWidget {
//   final Future<void> Function() updatePattern;
//   Map<int, String> yarnIdToNameMap;
//   PatternPart part;
//   PatternRow? row;
//   int startRow;
//   int numberOfRows;
//   RowPage({
//     super.key,
//     required this.part,
//     required this.updatePattern,
//     this.startRow = 0,
//     this.numberOfRows = 1,
//     this.row,
//     this.yarnIdToNameMap = const {},
//   });

//   @override
//   State<StatefulWidget> createState() => _RowPageState();
// }

// class _RowPageState extends State<RowPage> {
//   List<Stitch> stitches = [];
//   String stitchSearch = "";
//   double buttonHeight = 50;
//   bool needScroll = false;
//   ScrollController stitchDetailsScrollController = ScrollController();
//   List<CountButton> details = List.empty(growable: true);
//   PatternRow row = PatternRow(startRow: 0, numberOfRows: 0, stitchesPerRow: 0);
//   StitchList stitchList = StitchList();
//   double spacing = 20;


//   Future<void> _insertRowInDb() async {
//     row.partId = widget.part.partId;
//     if (widget.row == null) {
//       row.rowId = await insertPatternRowInDb(row);
//     }
//   }

//   @override
//   void setState(VoidCallback fn) {
//     String preview = row.detailsAsString();
//     for (MapEntry<int, String> entry in widget.yarnIdToNameMap.entries) {
//       preview = preview!.replaceAll("\${${entry.key}}", entry.value);
//     // }
//     // previewControler.text = preview;
//     // previewScrollController.jumpTo(
//     //   previewScrollController.position.maxScrollExtent,
//     // );
//     stitchDetailsScrollController.jumpTo(
//       stitchDetailsScrollController.position.maxScrollExtent,
//     );
//     // print("\r\n");
//     super.setState(fn);
//   }


//   Widget _stitchDetailsList() {
//     return Container(
//       constraints: BoxConstraints(maxHeight: buttonHeight * 2.5),
//       padding: EdgeInsets.only(top: 10),
//       child: SingleChildScrollView(
//         controller: stitchDetailsScrollController,
//         child: Wrap(spacing: 10, children: [for (Widget e in details) e]),
//       ),
//     );
//   }



//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     // if (needScroll) {
//     //   WidgetsBinding.instance.addPostFrameCallback(
//     //     (_) => stitchDetailsScrollController.animateTo(
//     //       stitchDetailsScrollController.position.maxScrollExtent,
//     //       duration: Duration(milliseconds: 500),
//     //       curve: Curves.linear,
//     //     ),
//     //   );
//     //   WidgetsBinding.instance.addPostFrameCallback(
//     //     (_) => previewScrollController.animateTo(
//     //       previewScrollController.position.maxScrollExtent,
//     //       duration: Duration(milliseconds: 500),
//     //       curve: Curves.linear,
//     //     ),
//     //   );
//     //   needScroll = false;
//     // }
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "${widget.part.name}/Row ${row.startRow}${row.numberOfRows > 1 ? "-${row.startRow + row.numberOfRows - 1}" : ""}",
//         ),
//         backgroundColor: theme.colorScheme.primary,
//         leading: IconButton(
//           onPressed: () async {
//             if (row.stitchesPerRow < 1) {
//               await deletePatternRowInDb(row.rowId);
//             }
//             await widget.updatePattern();
//             Navigator.pop(context);
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//       ),
//       body: Container(
//         padding: EdgeInsets.all(10),
//         child: Form(
//           // key: _formKey,
//           child: Column(spacing: 10, children: [Expanded(child: stitchList)]),
//         ),
//       ),
//     );
//   }
// }
