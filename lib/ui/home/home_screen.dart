import 'package:craft_stash/ui/core/loading_screen.dart';
import 'package:craft_stash/ui/home/home_model.dart';
import 'package:craft_stash/ui/home/widget/tab_bar_button.dart';
import 'package:craft_stash/ui/pattern_stash/stash_screen.dart';
import 'package:craft_stash/ui/wip_stash/stash_screen.dart';
import 'package:craft_stash/ui/yarn_stash/yarn_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late HomeModel homeModel;

  @override
  void initState() {
    homeModel = HomeModel(vsync: this);
    homeModel.load();
    super.initState();
  }

  @override
  void dispose() {
    homeModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: homeModel,
      builder: (context, child) {
        if (homeModel.loaded == false) {
          return LoadingScreen();
        } else {
          return DefaultTabController(
            length: 3,
            child: Scaffold(
              body: TabBarView(
                controller: homeModel.tabController,
                children: [
                  WipStashScreen(wipStashModel: homeModel.wsm),
                  PatternStashScreen(patternStashModel: homeModel.psm),
                  YarnStashScreen(yarnStashModel: homeModel.ysm),
                ],
              ),
              floatingActionButton: HomeFloatActionButton(
                model: homeModel.homeButtonModel,
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomAppBar(
                color: theme.colorScheme.primary,

                child: TabBar(
                  controller: homeModel.tabController,
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
      },
    );
  }
}
