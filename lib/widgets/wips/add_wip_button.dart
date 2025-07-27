import 'package:craft_stash/class/wip/wip.dart';
import 'package:craft_stash/pages/wip_page.dart';
import 'package:craft_stash/widgets/wips/add_wip_from_pattern_dialog.dart';
import 'package:flutter/material.dart';

class AddWipButton extends StatefulWidget {
  final Future<void> Function() updateWipListView;

  const AddWipButton({super.key, required this.updateWipListView});

  @override
  State<StatefulWidget> createState() => _AddWipButton();
}

class _AddWipButton extends State<AddWipButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      onPressed: () async {
        Wip? newWip =
            await showDialog(
                  context: context,
                  builder: (context) => AddWipFromPatternDialog(),
                )
                as Wip?;
        if (newWip != null) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => WipPage(
                updateWipListView: widget.updateWipListView,
                wip: newWip,
              ),
            ),
          );
        }
      },

      style: ButtonStyle(
        side: WidgetStatePropertyAll(
          BorderSide(color: theme.colorScheme.primary, width: 5),
        ),
        shape: WidgetStatePropertyAll(
          RoundedSuperellipseBorder(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(18)),
          ),
        ),

        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
      child: Text(
        "Add wip",
        style: TextStyle(color: theme.colorScheme.secondary),
        textScaler: TextScaler.linear(1.25),
      ),
    );
  }
}
