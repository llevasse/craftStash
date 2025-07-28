import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/wip/wip.dart';
import 'package:craft_stash/class/wip/wip_part.dart';
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:flutter/material.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;

class AddWipFromPatternDialog extends StatefulWidget {
  const AddWipFromPatternDialog({super.key});

  @override
  State<StatefulWidget> createState() => _AddWipFromPatternDialogState();
}

class _AddWipFromPatternDialogState extends State<AddWipFromPatternDialog> {
  List<craft.Pattern> patterns = List.empty(growable: true);

  void init() async {
    patterns = await craft.getAllPattern(withParts: true);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Widget patternListView() {
    return ListView.builder(
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(patterns[index].name),
          onTap: () async {
            Wip newWip = Wip(patternId: patterns[index].patternId);
            newWip.id = await insertWipInDb(newWip);
            List<Yarn> yarns = await getAllYarnByPatternId(
              patterns[index].patternId,
            );
            for (Yarn yarn in yarns) {
              if (yarn.inPreviewId == null) continue;
              await insertYarnInWip(
                yarnId: yarn.id,
                wipId: newWip.id,
                inPreviewId: yarn.inPreviewId!,
              );
            }
            for (PatternPart part in patterns[index].parts) {
              await insertWipPartInDb(
                WipPart(wipId: newWip.id, partId: part.partId),
              );
            }
            Navigator.pop(context, newWip);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Start WIP from pattern"),
      content: patternListView(),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
      ],
    );
  }
}
