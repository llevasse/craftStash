import 'package:craft_stash/data/repository/pattern/pattern_stash_repository.dart';
import 'package:craft_stash/data/repository/wip/wip_stash_repository.dart';
import 'package:craft_stash/data/repository/yarn/yarn_stash_repository.dart';
import 'package:craft_stash/ui/pattern_stash/stash_model.dart';
import 'package:craft_stash/ui/pattern_stash/widget/add_pattern_button.dart';
import 'package:craft_stash/ui/wip_stash/stash_model.dart';
import 'package:craft_stash/ui/wip_stash/widget/add_wip_button.dart';
import 'package:craft_stash/ui/yarn_stash/widget/add_yarn_button.dart';
import 'package:craft_stash/ui/yarn_stash/yarn_model.dart';
import 'package:flutter/material.dart';

class HomeModel extends ChangeNotifier {
  HomeModel({required this.vsync});

  TickerProvider vsync;
  late Future<void> Function() updateYarn;
  late Future<void> Function() updatePatternListView;
  late Future<void> Function() updateWipListView;
  late TabController tabController;
  late HomeFloatActionButtonModel homeButtonModel;
  late List<Widget> actionButtons;
  late PatternStashModel psm;
  late YarnStashModel ysm;
  late WipStashModel wsm;

  bool loaded = false;

  Future<void> load() async {
    tabController = TabController(length: 3, vsync: vsync);

    psm = PatternStashModel(patternStashRepository: PatternStashRepository());
    ysm = YarnStashModel(yarnStashRepository: YarnStashRepository());
    wsm = WipStashModel(wipStashRepository: WipStashRepository());
    actionButtons = [
      AddWipButton(onQuitPage: wsm.reload),
      AddPatternButton(onQuitPage: psm.reload),
      AddYarnButton(onQuitPage: ysm.reload),
    ];
    homeButtonModel = HomeFloatActionButtonModel(button: actionButtons[0]);
    tabController.addListener(() {
      homeButtonModel.setButton(actionButtons[tabController.index]);
    });
    loaded = true;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    tabController.dispose();
  }
}

class HomeFloatActionButtonModel extends ChangeNotifier {
  HomeFloatActionButtonModel({required this.button});

  Widget button;

  void setButton(Widget newButton) {
    button = newButton;
    notifyListeners();
  }
}
