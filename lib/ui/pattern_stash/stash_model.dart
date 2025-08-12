import 'package:craft_stash/data/repository/pattern/pattern_stash_repository.dart';
import 'package:flutter/material.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;

class PatternStashModel extends ChangeNotifier {
  PatternStashModel({required PatternStashRepository patternStashRepository})
    : _patternStashRepository = patternStashRepository;
  final PatternStashRepository _patternStashRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<craft.Pattern>? _patterns;
  List<craft.Pattern>? get patterns => _patterns;

  bool loaded = false;

  Future<void> load() async {
    print("Pattern stash state");
    print("Loaded : $loaded");
    print("Pattern : $_patterns");
    try {
      _patterns = await _patternStashRepository.getAllPattern();

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
