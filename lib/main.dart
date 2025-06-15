import 'package:craft_stash/pages/patterns.dart';
import 'package:craft_stash/pages/yarn_stash.dart';
import 'package:craft_stash/widgets/yarnButtons/add_yarn_button.dart';
import 'package:craft_stash/widgets/add_item_button.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await removeAllYarn();
  // await insertYarnInDb(
  //   Yarn(
  //     color: Colors.pink.toARGB32(),
  //     brand: "Phildar",
  //     material: "Coton",
  //     colorName: "Pink",
  //     minHook: 2.5,
  //     maxHook: 3.5,
  //     thickness: 3,
  //     nbOfSkeins: 1,
  //   ),
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'craft stash',
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
  late TabController _tabController;

  void update() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    List<Widget> actionButtons = [
      AddYarnButton(
        updateYarn: () async {
          updateYarn.call();
        },
      ),
      AddItemButton(text: "Add pattern", onPressed: () {}),
    ];

    ThemeData theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(
          controller: _tabController,
          children: [
            YarnStashPage(
              builder: (BuildContext context, Future<void> Function() method) {
                updateYarn = method;
              },
            ),
            PatternsPage(),
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
              Tab(text: "Yarn"),
              Tab(text: "Patterns"),
            ],
          ),
        ),
      ),
    );
  }
}
