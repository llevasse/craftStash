import 'package:craft_stash/widgets/patternButtons/add_detail_button.dart';
import 'package:craft_stash/widgets/stitches/stitch_form.dart';
import 'package:craft_stash/widgets/stitches/stitch_list.dart';
import 'package:flutter/material.dart';

class StitchesPage extends StatefulWidget {
  const StitchesPage({super.key});

  @override
  State<StatefulWidget> createState() => _StitchesPageState();
}

class _StitchesPageState extends State<StitchesPage> {
  Widget _createNewStitchButton() {
    ThemeData theme = Theme.of(context);
    return AddDetailButton(
      text: "New stitch",
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) => StitchForm(
            onValidate: () {
              setState(() {});
            },
          ),
        );
      },
      style: ButtonStyle(
        side: WidgetStatePropertyAll(
          BorderSide(color: theme.colorScheme.primary, width: 1),
        ),
        shape: WidgetStatePropertyAll(
          RoundedSuperellipseBorder(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(18)),
          ),
        ),

        backgroundColor: WidgetStateProperty.all(theme.colorScheme.tertiary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Stitches"),

        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: StitchList(
                  onPressed: (String) {},
                  customActions: [_createNewStitchButton()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
