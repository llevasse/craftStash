import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/widgets/yarnButtons/yarn_form.dart';
import 'package:flutter/material.dart';

class EditYarnButton extends StatefulWidget {
  final Future<void> Function() updateYarn;
  final bool showBrand;
  final bool showMaterial;
  final bool showThickness;
  final bool showMinHook;
  final bool showMaxHook;
  final bool showSkeins;
  Yarn currentYarn;

  EditYarnButton({
    super.key,
    required this.updateYarn,
    required this.currentYarn,
    this.showBrand = true,
    this.showMaterial = true,
    this.showThickness = true,
    this.showMinHook = true,
    this.showMaxHook = true,
    this.showSkeins = true,
  });

  @override
  State<StatefulWidget> createState() => _EditYarnButton();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _EditYarnButton extends State<EditYarnButton> {
  String brand = "";
  String material = "";
  String thickness = "";
  String minHook = "";
  String maxHook = "";
  Widget? subtitle;
  Widget? trailing;
  @override
  void initState() {
    if (widget.showBrand) brand = ", ${widget.currentYarn.brand}";
    if (widget.showMaterial) material = ", ${widget.currentYarn.material}";
    if (widget.showThickness) {
      thickness = ", ${widget.currentYarn.thickness.toStringAsFixed(2)}mm";
    }
    if (widget.showMinHook || widget.showMaxHook) {
      if (widget.showMinHook) {
        minHook = "${widget.currentYarn.minHook.toStringAsFixed(2)}mm";
      }
      if (widget.showMaxHook) {
        maxHook = "${widget.currentYarn.maxHook.toStringAsFixed(2)}mm";
      }
      subtitle = Text("Hook : $minHook${maxHook.isEmpty ? "" : "-$maxHook"}");
    }
    if (widget.showSkeins) {
      trailing = Text("${widget.currentYarn.nbOfSkeins} skeins");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        color: Color(widget.currentYarn.color),
      ),
      title: Text("${widget.currentYarn.colorName}$brand$material$thickness"),
      subtitle: subtitle,
      trailing: trailing,
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
