import 'package:craft_stash/class/yarn.dart';
import 'package:craft_stash/pages/patterns.dart';
import 'package:craft_stash/pages/yarn_stash.dart';
import 'package:craft_stash/services/database_service.dart';
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
  late TabController _tabController;
  List<String> actionButtonText = ["Add yarn", "Add pattern"];
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
    ThemeData theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(
          controller: _tabController,
          children: [YarnStashPage(), PatternsPage()],
        ),
        floatingActionButton: OutlinedButton(
          onPressed: () {},

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
            actionButtonText[_tabController.index],
            style: TextStyle(color: theme.colorScheme.secondary),
            textScaler: TextScaler.linear(1.25),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: theme.colorScheme.primary,

          child: TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.tertiary,
            indicatorColor: theme.colorScheme.tertiary,
            unselectedLabelColor: theme.colorScheme.secondary,
            dividerColor: theme.colorScheme.primary,
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
