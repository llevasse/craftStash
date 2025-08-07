import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/data/repository/pattern_stash_repository.dart';
import 'package:craft_stash/data/repository/yarn_stash_repository.dart';
import 'package:flutter/material.dart';
import 'package:craft_stash/class/patterns/patterns.dart' as craft;

class YarnStashModel extends ChangeNotifier {
  YarnStashModel({required YarnStashRepository yarnStashRepository})
    : _yarnStashRepository = yarnStashRepository;
  final YarnStashRepository _yarnStashRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<YarnCollection>? _yarns;
  List<YarnCollection>? get yarns => _yarns;

  bool loaded = false;

  Future<void> load() async {
    try {
      _yarns = await _yarnStashRepository.getAllYarnInCollections();

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
