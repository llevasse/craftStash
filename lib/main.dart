import 'package:craft_stash/class/yarn.dart';
import 'package:craft_stash/pages/patterns.dart';
import 'package:craft_stash/pages/yarn_stash.dart';
import 'package:craft_stash/services/database_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await insertYarnInDb(
  //   Yarn(
  //     color: Colors.pink.toARGB32(),
  //     brand: "Phildart",
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

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(children: [YarnStashPage(), PatternsPage()]),
        bottomNavigationBar: BottomAppBar(
          color: theme.colorScheme.primary,

          child: TabBar(
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
