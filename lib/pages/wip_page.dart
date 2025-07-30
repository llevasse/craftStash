import 'package:craft_stash/class/wip/wip.dart';
import 'package:craft_stash/class/wip/wip_part.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/class/yarns/yarn.dart';
import 'package:craft_stash/pages/wip_part_page.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:craft_stash/widgets/yarn/pattern_yarn_list.dart';
import 'package:craft_stash/widgets/yarn/yarn_list_dialog.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Wip wip = Wip();
  List<Widget> patternListView = List.empty(growable: true);
  double spacing = 10;
  late void Function() yarnListInitFunction;

  void getWipData() async {
    wip.pattern = await craft.getPatternById(
      id: wip.patternId,
      withParts: true,
    );
    wip.yarnIdToNameMap = await getYarnIdToNameMapByWipId(wip.id);
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
            onPress: _yarnListOnPress,
            onLongPress: _yarnListOnLongPress,
            builder: (BuildContext context, void Function() methodFromChild) {
              yarnListInitFunction = methodFromChild;
            },
            wipId: wip.id,
          ),
        ],
      ),
    );
  }

  void _yarnListOnPress(Yarn yarn) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => YarnForm(
        fill: true,
        readOnly: true,
        base: yarn,
        confirm: "close",
        cancel: "",
        title: yarn.colorName,
        showSkeins: false,
      ),
    );
  }

  void _yarnListOnLongPress(Yarn yarn) async {
    int inPreviewId = yarn.inPreviewId!;
    await showDialog(
      context: context,
      builder: (BuildContext context) => YarnListDialog(
        onPressed: (newYarn, numberOfYarns) async {
          try {
            await updateYarnInWip(
              yarnId: newYarn.id,
              wipId: wip.id,
              inPreviewId: inPreviewId,
            );
            wip.yarnIdToNameMap[inPreviewId] = newYarn.colorName;
            yarnListInitFunction.call();
          } catch (e) {
            print(e.toString());
          }
        },
      ),
    );
  }

  Widget _infoRow() {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          Expanded(child: _titleInput()),
          Expanded(child: _hookSizeInput()),
        ],
      ),
    );
  }

  Widget _titleInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        initialValue: widget.wip.name,
        decoration: InputDecoration(label: Text("Wip title")),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return ("Wip title can't be empty");
          }
          return null;
        },
        onChanged: (value) {
          wip.name = value.trim();
          setState(() {});
        },
        onSaved: (newValue) {
          wip.name = newValue!.trim();
        },
      ),
    );
  }

  Widget _hookSizeInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        keyboardType: TextInputType.numberWithOptions(),
        initialValue: wip.hookSize?.toStringAsFixed(2),
        decoration: InputDecoration(label: Text("Hook size")),
        validator: (value) {
          return null;
        },
        onSaved: (newValue) {
          newValue = newValue?.trim();
          if (newValue != null && newValue.isNotEmpty) {
            wip.hookSize = double.parse(newValue);
          }
        },
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

  Widget _saveButton() {
    return (IconButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          await updateWipInDb(wip);
          Navigator.pop(context);
        }
      },
      icon: Icon(Icons.save),
    ));
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
                        builder: (BuildContext context) => WipPartPage(
                          wipPart: wipPart,
                          yarnIdToNameMap: wip.yarnIdToNameMap,
                        ),
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
    patternListView.add(_infoRow());
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
        title: Text(wip.name),
        backgroundColor: theme.colorScheme.primary,
        leading: IconButton(
          onPressed: () async {
            await widget.updateWipListView();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),

        actions: [_deleteButton(), _saveButton()],
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
