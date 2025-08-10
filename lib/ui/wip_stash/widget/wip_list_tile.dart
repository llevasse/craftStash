import 'package:craft_stash/class/wip/wip.dart' as craft;
import 'package:craft_stash/data/repository/wip/wip_repository.dart';
import 'package:craft_stash/ui/pattern_stash/stash_model.dart';
import 'package:craft_stash/ui/wip/wip_model.dart';
import 'package:craft_stash/ui/wip/wip_screen.dart';
import 'package:craft_stash/ui/wip_stash/stash_model.dart';
import 'package:flutter/material.dart';

class WipListTile extends StatelessWidget {
  const WipListTile({
    super.key,
    required this.wip,
    required this.wipStashModel,
  });
  final craft.Wip wip;

  final WipStashModel wipStashModel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(wip.name),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            settings: RouteSettings(name: "wip"),
            builder: (BuildContext context) => WipScreen(
              wipModel: WipModel(wipRepository: WipRepository(), id: wip.id),
            ),
          ),
        );
      },
      onLongPress: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text("Do you want to delete this wip"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await craft.deleteWipInDb(wip.id);
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
