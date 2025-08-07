import 'package:craft_stash/class/wip/wip_part.dart';
import 'package:craft_stash/data/repository/wip_part_repository%20copy.dart';
import 'package:flutter/material.dart';

class WipPartModel extends ChangeNotifier {
  WipPartModel({
    required WipPartRepository wipPartRepository,
    required this.id,
    required this.wipId,
  }) : _wipPartRepository = wipPartRepository;
  final WipPartRepository _wipPartRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int id;
  int wipId;

  WipPart? _wipPart;
  WipPart? get wipPart => _wipPart;

  Map<int, String>? _yarnNameMap;
  Map<int, String>? get yarnNameMap => _yarnNameMap;

  bool loaded = false;

  final double spacing = 10;

  Future<void> load() async {
    try {
      _wipPart = await _wipPartRepository.getWipPartById(id: id);
      _yarnNameMap = await _wipPartRepository.getYarnIdToNameMap(wipId: wipId);
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
