import 'dart:io';

import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/pages/patterns_stash.dart';
import 'package:craft_stash/pages/wip_stash.dart';
import 'package:craft_stash/pages/yarn_stash.dart';
import 'package:craft_stash/widgets/patternButtons/add_pattern_button.dart';
import 'package:craft_stash/widgets/wips/add_wip_button.dart';
import 'package:craft_stash/widgets/yarnButtons/add_yarn_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

bool debug = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    PackageInfo.fromPlatform().then((value) {
      if (value.packageName.endsWith(".dev")) {
        debug = true;
      } else if (value.packageName == "com.example.app.prod") {
        debug = false;
      }
    });
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await setStitchToIdMap();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'craft stash',
      debugShowCheckedModeBanner: debug,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.amber,
          secondary: Colors.brown,
          tertiary: Colors.amber.shade100,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late Future<void> Function() updateYarn;
  late Future<void> Function() updatePatternListView;
  late Future<void> Function() updateWipListView;
  late TabController _tabController;

  void update() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    List<Widget> actionButtons = [
      AddWipButton(
        updateWipListView: () async {
          updateWipListView.call();
        },
      ),

      AddPatternButton(
        updatePatternListView: () async {
          updatePatternListView.call();
        },
      ),
      AddYarnButton(
        updateYarn: () async {
          updateYarn.call();
        },
      ),
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: TabBarView(
          controller: _tabController,
          children: [
            WipStashPage(
              builder: (BuildContext context, Future<void> Function() method) {
                updateWipListView = method;
              },
            ),
            PatternsStashPage(
              builder: (BuildContext context, Future<void> Function() method) {
                updatePatternListView = method;
              },
            ),
            YarnStashPage(
              builder: (BuildContext context, Future<void> Function() method) {
                updateYarn = method;
              },
            ),
          ],
        ),
        floatingActionButton: actionButtons[_tabController.index],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: theme.colorScheme.primary,

          child: TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.tertiary,
            indicatorColor: theme.colorScheme.tertiary,
            unselectedLabelColor: theme.colorScheme.secondary,
            dividerColor: theme.colorScheme.primary,
            textScaler: TextScaler.linear(1.25),
            tabs: [
              Tab(text: "Wips"),
              Tab(text: "Patterns"),
              Tab(text: "Yarn"),
            ],
          ),
        ),
      ),
    );
  }
}
