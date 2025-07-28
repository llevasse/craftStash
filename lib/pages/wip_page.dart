import 'package:craft_stash/class/wip/wip.dart';
import 'package:craft_stash/class/wip/wip_part.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/pages/wip_part_page.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:craft_stash/widgets/yarn/pattern_yarn_list.dart';
import 'package:craft_stash/widgets/yarnButtons/yarn_form.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class WipPage extends StatefulWidget {
  final Future<void> Function() updateWipListView;
  Wip wip;
  WipPage({super.key, required this.updateWipListView, required this.wip});

  @override
  State<StatefulWidget> createState() => WipPageState();
}

class WipPageState extends State<WipPage> {
  Wip wip = Wip();
  List<Widget> patternListView = List.empty(growable: true);
  double spacing = 10;
  late void Function() yarnListInitFunction;

  void getWipData() async {
    await DbService().printDbTables(wip: true, yarnInWip: true, yarn: true);
    wip.pattern = await craft.getPatternById(
      id: wip.patternId,
      withParts: true,
    );
    wip.parts = await getAllWipPart(wipId: wip.id);
    updateListView();
  }

  @override
  void initState() {
    wip = widget.wip;
    wip.pattern = craft.Pattern();
    super.initState();
    getWipData();
  }

  Widget _yarnList() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        spacing: spacing / 2,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text("Yarns used :"),
          PatternYarnList(
            onPress: (yarn) async {
              await showDialog(
                context: context,
                builder: (BuildContext context) => YarnForm(
                  fill: true,
                  readOnly: true,
                  base: yarn,
                  confirm: "close",
                  cancel: "",
                  title: yarn.colorName,
                  onCancel: (yarn) async {},
                  showSkeins: false,
                ),
              );
            },
            builder: (BuildContext context, void Function() methodFromChild) {
              yarnListInitFunction = methodFromChild;
            },
            wipId: wip.id,
          ),
        ],
      ),
    );
  }

  Widget _deleteButton() {
    return IconButton(
      onPressed: () async {
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
                  await deleteWipInDb(wip.id);
                  await widget.updateWipListView();
                  while (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Text("Delete"),
              ),
            ],
          ),
        );
      },
      icon: Icon(LucideIcons.trash),
    );
  }

  Widget _assembly() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        maxLines: 5,
        readOnly: true,
        initialValue: wip.pattern?.note,
        decoration: InputDecoration(label: Text("Assembly")),
      ),
    );
  }

  Future<void> updateListView() async {
    List<Widget> tmp = List.empty(growable: true);

    for (WipPart wipPart in wip.parts) {
      if (wipPart.part == null) continue;
      tmp.add(
        ListTile(
          title: Text(
            "${wipPart.part!.name} (${((wipPart.stitchDoneNb / (wipPart.part!.totalStitchNb)) * 100).toStringAsFixed(2)}%)",
          ),
          trailing: Text(
            wipPart.finished == 1
                ? "Finished"
                : "${wipPart.madeXTime}/${wipPart.part!.numbersToMake}",
          ),
          onTap: () async {
            int currentStitchNb = wipPart.stitchDoneNb;
            wipPart =
                await Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        settings: RouteSettings(name: "/wip_part"),
                        builder: (BuildContext context) =>
                            WipPartPage(wipPart: wipPart),
                      ),
                    )
                    as WipPart;
            if (currentStitchNb != wipPart.stitchDoneNb) {
              wip.stitchDoneNb -= currentStitchNb;
              wip.stitchDoneNb += wipPart.stitchDoneNb;
              await updateWipInDb(wip);
              updateListView();
            }
          },
        ),
      );
    }
    patternListView.clear();
    patternListView.add(_yarnList());
    patternListView.add(Expanded(child: ListView(children: tmp)));
    if (wip.pattern?.note != null) patternListView.add(_assembly());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(wip.pattern!.name),
        backgroundColor: theme.colorScheme.primary,
        leading: IconButton(
          onPressed: () async {
            await widget.updateWipListView();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),

        actions: [_deleteButton()],
      ),
      body: Column(
        spacing: spacing,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: patternListView,
      ),
    );
  }
}
