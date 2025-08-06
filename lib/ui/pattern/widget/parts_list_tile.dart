import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/data/repository/pattern_part_repository.dart';
import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:craft_stash/ui/pattern_part/pattern_part_model.dart';
import 'package:craft_stash/ui/pattern_part/pattern_part_screen.dart';
import 'package:flutter/material.dart';

class PatternPartsListTile extends StatelessWidget {
  const PatternPartsListTile({
    super.key,
    required this.part,
    required this.patternModel,
  });
  final PatternPart part;

  final PatternModel patternModel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(part.name),
      subtitle: Text("Make ${part.numbersToMake}"),
      contentPadding: EdgeInsets.all(0),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            settings: RouteSettings(name: "part"),
            builder: (BuildContext context) => PatternPartScreen(
              patternPartModel: PatternPartModel(
                patternPartRepository: PatternPartRepository(),
                patternId: patternModel.pattern!.patternId,
                id: part.partId,
              ),
            ),
          ),
        );
      },
      onLongPress: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text("Do you want to delete this part"),
            content: Text(
              "Every wips and rows connected to it will be deleted as well",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await deletePatternPartInDb(part.partId);
                  patternModel.reload();
                  Navigator.pop(context);
                },
                child: Text("Delete"),
              ),
            ],
          ),
        );
      },
    );
  }
}
