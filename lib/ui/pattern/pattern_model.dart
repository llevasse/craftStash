import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/data/repository/pattern_repository.dart';
import 'package:flutter/material.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;

class PatternModel extends ChangeNotifier {
  PatternModel({required PatternRepository patternRepository, this.id})
    : _patternRepository = patternRepository;
  final PatternRepository _patternRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int? id;

  craft.Pattern? _pattern;
  craft.Pattern? get pattern => _pattern;

  bool loaded = false;

  Future<void> load() async {
    try {
      if (id != null) {
        _pattern = await _patternRepository.getPatternById(id: id!);
        loaded = true;
      } else {
        _pattern = craft.Pattern(
          patternId: await _patternRepository.insertPattern(
            pattern: craft.Pattern(),
          ),
        );
        loaded = true;
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> reload() async {
    try {
      loaded = false;
      notifyListeners();

      if (id != null) {
        _pattern = await _patternRepository.getPatternById(id: id!);
        loaded = true;
      }
    } finally {
      notifyListeners();
    }
  }

  void setTitle(String title) {
    _pattern?.name = title;
    notifyListeners();
  }

  void setHookSize(String? value) {
    if (value != null) {
      pattern?.hookSize = double.tryParse(value);
    } else {
      pattern?.hookSize = null;
    }
    notifyListeners();
  }

  Future<bool> savePattern() async {
    if (formKey.currentState!.validate()) {
      if (pattern == null) return true;
      formKey.currentState!.save();
      pattern?.totalStitchNb = 0;
      for (PatternPart part in pattern!.parts) {
        pattern?.totalStitchNb += part.totalStitchNb * part.numbersToMake;
      }
      await _patternRepository.updatePattern(pattern!);
      return true;
    }
    return false;
  }

  Future<void> deletePattern() async {
    if (_pattern != null) {
      await _patternRepository.deletePattern(id: _pattern!.patternId);
    }
  }

  Future<void> insertYarn({
    required int yarnId,
    required int inPreviewId,
  }) async {
    await _patternRepository.insertYarnInPattern(
      yarnId: yarnId,
      patternId: _pattern!.patternId,
      inPreviewId: inPreviewId,
    );
  }

  Future<void> updateYarn({
    required int yarnId,
    required int inPreviewId,
  }) async {
    await _patternRepository.updateYarnInPattern(
      yarnId: yarnId,
      patternId: _pattern!.patternId,
      inPreviewId: inPreviewId,
    );
  }

  Future<void> deleteYarn({
    required int yarnId,
    required int inPatternYarnId,
  }) async {
    await _patternRepository.deleteYarnInPattern(
      yarnId: yarnId,
      patternId: _pattern!.patternId,
      inPatternYarnId: inPatternYarnId,
    );
  }
}
