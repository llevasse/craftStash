import 'package:craft_stash/class/wip/wip_part.dart';
import 'package:craft_stash/data/repository/wip_part_repository.dart';
import 'package:craft_stash/ui/wip/wip_model.dart';
import 'package:craft_stash/ui/wip_part/wip_part_model.dart';
import 'package:craft_stash/ui/wip_part/wip_part_screen.dart';
import 'package:flutter/material.dart';

class WipPartsListTile extends StatelessWidget {
  const WipPartsListTile({
    super.key,
    required this.wipPart,
    required this.wipModel,
  });
  final WipPart wipPart;

  final WipModel wipModel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(wipPart.part!.name),
      trailing: Text(
        wipPart.finished == 1
            ? "Finished"
            : "${wipPart.madeXTime}/${wipPart.part!.numbersToMake}",
      ),
      contentPadding: EdgeInsets.all(0),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            settings: RouteSettings(name: "wip_part"),
            builder: (BuildContext context) => WipPartScreen(
              wipPartModel: WipPartModel(
                wipPartRepository: WipPartRepository(),
                id: wipPart.id,
                wipId: wipModel.wip!.id,
              ),
            ),
          ),
        );
      },
    );
  }
}
