import 'package:craft_stash/data/repository/wip_stash_repository.dart';
import 'package:flutter/material.dart';
import 'package:craft_stash/class/wip/wip.dart' as craft;

class WipStashModel extends ChangeNotifier {
  WipStashModel({required WipStashRepository wipStashRepository})
    : _wipStashRepository = wipStashRepository;
  final WipStashRepository _wipStashRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<craft.Wip>? _wips;
  List<craft.Wip>? get wips => _wips;

  bool loaded = false;

  Future<void> load() async {
    try {
      _wips = await _wipStashRepository.getAllWip();

      loaded = true;
    } finally {
      notifyListeners();
    }
  }

  Future<void> reload() async {
    loaded = false;
    notifyListeners();
    load();
  }
}
