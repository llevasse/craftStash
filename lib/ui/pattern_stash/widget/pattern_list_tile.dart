import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/data/repository/pattern/pattern_repository.dart';
import 'package:craft_stash/ui/pattern/pattern_model.dart';
import 'package:craft_stash/ui/pattern/pattern_screen.dart';
import 'package:craft_stash/ui/pattern_stash/stash_model.dart';
import 'package:flutter/material.dart';

class PatternListTile extends StatelessWidget {
  const PatternListTile({
    super.key,
    required this.pattern,
    required this.patternStashModel,
  });
  final craft.Pattern pattern;

  final PatternStashModel patternStashModel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(pattern.name),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            settings: RouteSettings(name: "pattern"),
            builder: (BuildContext context) => PatternScreen(
              patternModel: PatternModel(
                patternRepository: PatternRepository(),
                id: pattern.patternId,
              ),
            ),
          ),
        );
        patternStashModel.reload();
      },
      onLongPress: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text("Do you want to delete this pattern"),
            content: Text(
              "Every wips, parts and rows connected to it will be deleted as well",
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
                  await PatternRepository().deletePattern(
                    id: pattern.patternId,
                  );
                  Navigator.pop(context);
                },
                child: Text("Delete"),
              ),
            ],
          ),
        );
        patternStashModel.reload();
      },
    );
  }
}
