import 'dart:io';

import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/data/repository/pattern_stash_repository.dart';
import 'package:craft_stash/data/repository/wip_stash_repository.dart';
import 'package:craft_stash/data/repository/yarn_stash_repository.dart';
import 'package:craft_stash/ui/pattern_stash/stash_model.dart';
import 'package:craft_stash/ui/pattern_stash/stash_screen.dart';
import 'package:craft_stash/ui/wip_stash/stash_model.dart';
import 'package:craft_stash/ui/wip_stash/stash_screen.dart';
import 'package:craft_stash/ui/yarn_stash/yarn_model.dart';
import 'package:craft_stash/ui/yarn_stash/yarn_screen.dart';
import 'package:craft_stash/ui/pattern_stash/widget/add_pattern_button.dart';
import 'package:craft_stash/ui/wip_stash/widget/add_wip_button.dart';
import 'package:craft_stash/ui/yarn_stash/widget/add_yarn_button.dart';
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
    PatternStashModel psm = PatternStashModel(
      patternStashRepository: PatternStashRepository(),
    );
    YarnStashModel ysm = YarnStashModel(
      yarnStashRepository: YarnStashRepository(),
    );
    WipStashModel wsm = WipStashModel(wipStashRepository: WipStashRepository());
    List<Widget> actionButtons = [
      AddWipButton(onQuitPage: wsm.reload),
      AddPatternButton(onQuitPage: psm.reload),
      AddYarnButton(onQuitPage: ysm.reload),
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: TabBarView(
          controller: _tabController,
          children: [
            WipStashScreen(wipStashModel: wsm),
            PatternStashScreen(patternStashModel: psm),
            YarnStashScreen(yarnStashModel: ysm),
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
