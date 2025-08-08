import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/wip/wip_part.dart';
import 'package:craft_stash/data/repository/wip_part_repository.dart';
import 'package:craft_stash/main.dart';
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

  int totalNumberOfRows = 0;

  final double spacing = 10;

  Future<void> load() async {
    try {
      _wipPart = await _wipPartRepository.getWipPartById(id: id);
      totalNumberOfRows = 0;
      for (PatternRow row in _wipPart!.part!.rows) {
        totalNumberOfRows += row.numberOfRows;
      }
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

  void setWipPartNb(int value) {
    _wipPart!.madeXTime = value;
    _wipPart!.stitchDoneNb =
        ((_wipPart!.part!.totalStitchNb / _wipPart!.part!.numbersToMake) *
                _wipPart!.madeXTime)
            .toInt();
    if (_wipPart!.madeXTime >= _wipPart!.part!.numbersToMake) {
      _wipPart!.finished = 1;
    } else {
      _wipPart!.currentRowIndex = _wipPart!.currentStitchNumber = 0;
      _wipPart!.currentRowNumber = _wipPart!.part!.rows.first.startRow;
    }
    notifyListeners();
  }

  void setCurrentRow(int value) {
    if (_wipPart!.finished == 1) return;
    PatternRow row = _wipPart!.part!.rows[_wipPart!.currentRowIndex];
    bool increase = value > _wipPart!.currentRowNumber;

    _wipPart!.currentRowNumber = value;

    // if finished last row, reset part
    if (_wipPart!.currentRowNumber >
        _wipPart!.part!.rows.last.startRow +
            (_wipPart!.part!.rows.last.numberOfRows - 1)) {
      setWipPartNb(_wipPart!.madeXTime + 1);
      return;
    } else if (_wipPart!.currentRowNumber >
        row.startRow + (row.numberOfRows - 1)) {
      _wipPart!.currentRowIndex++;
    } else if (_wipPart!.currentRowNumber < row.startRow) {
      _wipPart!.currentRowIndex--;
    }

    _wipPart!.stitchDoneNb -= _wipPart!.currentStitchNumber;

    _wipPart!.currentStitchNumber = 0;

    if (increase) {
      _wipPart!.stitchDoneNb += row.stitchesPerRow;
    } else {
      _wipPart!.stitchDoneNb -= row.stitchesPerRow;
    }
    notifyListeners();
  }

  void setCurrentStitch(int value) {
    if (_wipPart!.finished == 1) return;
    bool increase = value > _wipPart!.currentRowNumber;

    _wipPart!.stitchDoneNb -= _wipPart!.currentStitchNumber;

    _wipPart!.currentStitchNumber = value;

    if (increase) {
      _wipPart!.stitchDoneNb += value;
      if (value >=
          _wipPart!.part!.rows[_wipPart!.currentRowIndex].stitchesPerRow) {
        setCurrentRow(_wipPart!.currentRowNumber + 1);
        return;
      }
    }

    notifyListeners();
  }
}
