import 'dart:async';

import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/data/repository/pattern/pattern_part_repository.dart';
import 'package:craft_stash/main.dart';
import 'package:flutter/material.dart';

class PatternPartModel extends ChangeNotifier {
  PatternPartModel({
    required PatternPartRepository patternPartRepository,
    required this.patternId,
    this.id,
  }) : _patternPartRepository = patternPartRepository;
  final PatternPartRepository _patternPartRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int? id;
  final int patternId;
  Timer? timer;

  PatternPart? _part;
  PatternPart? get part => _part;

  Map<int, String>? _yarnNameMap;
  Map<int, String>? get yarnNameMap => _yarnNameMap;

  bool loaded = false;

  Future<void> load() async {
    try {
      if (id != null) {
        _part = await _patternPartRepository.getPartById(id: id!);
      } else {
        _part = PatternPart(name: "New part", patternId: patternId);
        id = await _patternPartRepository.insertPart(_part!);
        _part!.partId = id!;
      }
      _yarnNameMap = await _patternPartRepository.getYarnIdToNameMap(
        patternId: patternId,
      );
      loaded = true;
    } finally {
      notifyListeners();
    }
  }

  Future<void> reload() async {
    try {
      loaded = false;
      notifyListeners();

      if (id != null) {
        _part = await _patternPartRepository.getPartById(id: id!);
        loaded = true;
      }
    } finally {
      notifyListeners();
    }
  }

  void _setUpdateTimer() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
    if (formKey.currentState!.validate()) {
      timer = Timer(const Duration(seconds: 1), () async {
        if (debug) {
          print("Save part");
        }
        await savePart();
        timer = null;
      });
    }
  }

  void setTitle(String title) {
    _part?.name = title;
    _setUpdateTimer();
    notifyListeners();
  }

  void setNumberToMake(int value) {
    _part?.numbersToMake = value;
    _setUpdateTimer();
    notifyListeners();
  }

  void setNote(String note) {
    _part?.note = note;
    _setUpdateTimer();
    notifyListeners();
  }

  Future<void> savePart() async {
    _part!.totalStitchNb = 0;
    for (PatternRow row in _part!.rows) {
      _part!.totalStitchNb += row.stitchesPerRow * row.numberOfRows;
    }
    await PatternPartRepository().updatePart(_part!);
    if (debug) print("Part saved");
  }

  Future<void> deletePart() async {
    if (_part != null) {
      await PatternPartRepository().deletePart(_part!.partId);
    }
  }
}
