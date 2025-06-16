import 'package:craft_stash/class/yarn.dart';
import 'package:craft_stash/widgets/yarnButtons/yarn_form.dart';
import 'package:flutter/material.dart';

class EditYarnButton extends StatefulWidget {
  final Future<void> Function() updateYarn;
  Yarn currentYarn;

  EditYarnButton({
    super.key,
    required this.updateYarn,
    required this.currentYarn,
  });

  @override
  State<StatefulWidget> createState() => _EditYarnButton();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _EditYarnButton extends State<EditYarnButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        color: Color(widget.currentYarn.color),
      ),
      title: Text(
        "${widget.currentYarn.colorName}, ${widget.currentYarn.brand}, ${widget.currentYarn.material}, ${widget.currentYarn.thickness.toStringAsFixed(2)}mm",
      ),
      subtitle: Text(
        "Min hook : ${widget.currentYarn.minHook.toStringAsFixed(2)}mm, Max hook : ${widget.currentYarn.maxHook.toStringAsFixed(2)}mm",
      ),
      trailing: Text("${widget.currentYarn.nbOfSkeins} skeins"),
      onTap: () => showDialog(
        context: context,
        builder: (BuildContext context) => YarnForm(
          base: widget.currentYarn,
          updateYarn: widget.updateYarn,
          ifValideFunction: updateYarnInDb,
          title: "Edit yarn",
          cancel: "Cancel",
          confirm: "Edit",
          fill: true,
        ),
      ),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text("Do you want to delete this yarn"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await deleteYarnInDb(widget.currentYarn.id);
                  await widget.updateYarn();
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
