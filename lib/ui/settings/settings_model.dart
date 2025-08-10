import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/data/repository/pattern/pattern_stash_repository.dart';
import 'package:craft_stash/data/repository/settings_repository.dart';
import 'package:craft_stash/data/repository/yarn/yarn_stash_repository.dart';
import 'package:flutter/material.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;

class SettingsModel extends ChangeNotifier {
  SettingsModel({
    required this.onQuit,
    required SettingsRepository SettingsRepository,
  }) : _SettingsRepository = SettingsRepository;
  final SettingsRepository _SettingsRepository;

  final Future<void> Function() onQuit;

  bool loaded = false;

  Future<void> load() async {
    loaded = true;
    notifyListeners();
  }

  Future<void> reload() async {
    loaded = false;
    notifyListeners();
    load();
  }
}
