import 'package:craft_stash/class/wip/wip.dart';
import 'package:craft_stash/data/repository/wip/wip_repository.dart';
import 'package:flutter/material.dart';

class WipModel extends ChangeNotifier {
  WipModel({required WipRepository wipRepository, required this.id})
    : _wipRepository = wipRepository;
  final WipRepository _wipRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int id;

  Wip? _wip;
  Wip? get wip => _wip;

  Map<int, String>? _yarnNameMap;
  Map<int, String>? get yarnNameMap => _yarnNameMap;

  bool loaded = false;

  final double spacing = 10;

  Future<void> load() async {
    try {
      _wip = await _wipRepository.getWipById(id: id, withPattern: true, withParts: true);
      _yarnNameMap = await _wipRepository.getYarnIdToName(id);
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

  void setTitle(String title) {
    _wip?.name = title;
    notifyListeners();
  }

  void setHookSize(String? value) {
    if (value != null) {
      _wip?.hookSize = double.tryParse(value);
    } else {
      _wip?.hookSize = null;
    }
    notifyListeners();
  }

  Future<void> deleteWip() async {
    await _wipRepository.deleteWip(_wip!.id);
  }

  Future<bool> saveWip() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      await _wipRepository.updateWip(_wip!);
      return true;
    }
    return false;
  }
}
