import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/data/repository/pattern_row_repository.dart';
import 'package:craft_stash/main.dart';
import 'package:craft_stash/ui/row/widget/stitch_count_button.dart';
import 'package:flutter/material.dart';

class PatternRowModel extends ChangeNotifier {
  PatternRowModel({
    required PatternRowRepository patternRowRepository,
    required this.yarnNameMap,
    required this.partId,
    required this.patternId,
    this.id,
  }) : _patternRowRepository = patternRowRepository;
  final PatternRowRepository _patternRowRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Map<int, String>? yarnNameMap;

  int? id;
  final int partId;
  final int patternId;

  PatternRow? _row;
  PatternRow? get row => _row;

  ScrollController stitchDetailsScrollController = ScrollController();
  ScrollController previewScrollController = ScrollController();
  TextEditingController previewControler = TextEditingController();

  List<RowStitchCountButton> detailsCountButtonList = List.empty(
    growable: true,
  );

  bool loaded = false;

  Future<void> load() async {
    try {
      if (id != null) {
        _row = await _patternRowRepository.getPatternRowById(id: id!);
        for (PatternRowDetail detail in _row!.details) {
          String text = detail.stitch!.abreviation;
          bool isColorChange = false;
          if (detail.stitchId == stitchToIdMap['color change']) {
            text = "change to ${yarnNameMap![detail.inPatternYarnId]}";
            isColorChange = true;
          } else if (detail.stitchId == stitchToIdMap['start color']) {
            text = "start with ${yarnNameMap![detail.inPatternYarnId]}";
            isColorChange = true;
          }
          detailsCountButtonList.add(
            RowStitchCountButton(
              patternRowModel: this,
              detail: detail,
              index: detailsCountButtonList.length - 1,
              text: text,
              showCount: !isColorChange,
              allowDecrease: !isColorChange,
              allowIncrease: !isColorChange,
            ),
          );
        }
      } else {
        _row = PatternRow(startRow: 0, numberOfRows: 0, stitchesPerRow: 0);
        _row?.rowId = await _patternRowRepository.insertRow(partId: partId);
      }
      String preview = _row!.detailsAsString();
      for (MapEntry<int, String> entry in yarnNameMap!.entries) {
        preview = preview.replaceAll("\${${entry.key}}", entry.value);
      }
      previewControler.text = preview;
      loaded = true;
    } finally {
      notifyListeners();
    }
  }

  Future<void> reload() async {
    loaded = false;
    await load();
  }

  void setStartRow(int value) {
    _row?.startRow = value;
    notifyListeners();
  }

  void setStitchNb(int value) {
    _row?.stitchesPerRow = value;
    notifyListeners();
  }

  void setNumberOfRows(int value) {
    _row?.numberOfRows = value;
    notifyListeners();
  }

  void setPreview(String text) {
    _row?.preview = text;
    notifyListeners();
  }

  Future<Stitch?> addStitch(Stitch stitch) async {
    if (_row!.details.isNotEmpty &&
        _row!.details.last.stitch?.abreviation == stitch.abreviation) {
      _row!.details.last.repeatXTime += 1;
      detailsCountButtonList.removeLast();
    } else {
      _row!.details.add(
        PatternRowDetail(rowId: -1, stitchId: stitch.id, stitch: stitch),
      );
    }
    _row!.stitchesPerRow += stitch.stitchNb;

    if (debug) print("Row stitch nb : ${_row!.stitchesPerRow}");

    detailsCountButtonList.add(
      RowStitchCountButton(
        patternRowModel: this,
        detail: _row!.details.last,
        index: detailsCountButtonList.length - 1,
      ),
    );
    String preview = _row!.detailsAsString();
    for (MapEntry<int, String> entry in yarnNameMap!.entries) {
      preview = preview.replaceAll("\${${entry.key}}", entry.value);
    }
    previewControler.text = preview;
    notifyListeners();
    return null;
  }

  Future<void> addSubrow(PatternRowDetail? detail) async {
    if (detail == null) return;
    if (row!.details.isNotEmpty &&
        row!.details.last.hashCode == detail.hashCode) {
      await deletePatternRowDetailInDb(detail.rowDetailId);
      row!.details.last.repeatXTime += 1;
      detailsCountButtonList.removeLast();
    } else {
      row!.details.add(detail);
    }
    row!.stitchesPerRow += detail.stitch!.stitchNb;
    if (debug) {
      print("Row stitch nb : ${row!.stitchesPerRow}");
    }
    detailsCountButtonList.add(
      RowStitchCountButton(
        patternRowModel: this,
        detail: detail,
        index: detailsCountButtonList.length - 1,
      ),
    );

    String preview = _row!.detailsAsString();
    for (MapEntry<int, String> entry in yarnNameMap!.entries) {
      preview = preview.replaceAll("\${${entry.key}}", entry.value);
    }
    previewControler.text = preview;
    notifyListeners();
  }

  Future<void> addColorChange(PatternRowDetail? detail) async {
    if (detail == null) return;
    if (_row!.details.isNotEmpty) {
      if (_row!.details.last.hashCode == detail.hashCode) {
        await deletePatternRowDetailInDb(detail.rowDetailId);
      } else if (_row!.details.last.stitchId == stitchToIdMap['color change']) {
        await deletePatternRowDetailInDb(_row!.details.last.rowDetailId);
        _row!.details.removeLast();
        detailsCountButtonList.removeLast();
        _row!.details.add(detail);
        detailsCountButtonList.add(
          RowStitchCountButton(
            patternRowModel: this,
            detail: detail,
            index: detailsCountButtonList.length - 1,
            allowIncrease: false,
            allowDecrease: false,
            showCount: false,
          ),
        );
      } else if (_row!.details.last.stitchId == 'start color') {
        _row!.details.last.inPatternYarnId = detail.inPatternYarnId;
        await updatePatternRowDetailInDb(_row!.details.last);
      } else {
        _row!.details.add(detail);
        detailsCountButtonList.add(
          RowStitchCountButton(
            patternRowModel: this,
            detail: detail,
            index: detailsCountButtonList.length - 1,
            allowIncrease: false,
            allowDecrease: false,
            showCount: false,
          ),
        );
      }
    }

    String preview = _row!.detailsAsString();
    for (MapEntry<int, String> entry in yarnNameMap!.entries) {
      preview = preview.replaceAll("\${${entry.key}}", entry.value);
    }
    previewControler.text = preview;
    notifyListeners();
  }

  Future<void> addStartColor(PatternRowDetail? detail) async {
    if (detail == null) return;
    if (_row!.details.isNotEmpty) {
      if (_row!.details.first.stitchId == stitchToIdMap["start color"]) {
        _row!.details.first.inPatternYarnId = detail.inPatternYarnId;
        await updatePatternRowDetailInDb(_row!.details.first);
      } else {
        _row!.details.insert(0, detail);
        detailsCountButtonList.insert(
          0,
          RowStitchCountButton(
            patternRowModel: this,
            detail: detail,
            index: 0,
            allowIncrease: false,
            allowDecrease: false,
            showCount: false,
          ),
        );
      }
    } else {
      _row!.details.add(detail);
      detailsCountButtonList.add(
        RowStitchCountButton(
          patternRowModel: this,
          detail: detail,
          index: 0,
          allowIncrease: false,
          allowDecrease: false,
          showCount: false,
        ),
      );
    }
    String preview = _row!.detailsAsString();
    for (MapEntry<int, String> entry in yarnNameMap!.entries) {
      preview = preview.replaceAll("\${${entry.key}}", entry.value);
    }
    previewControler.text = preview;
    notifyListeners();
  }

  Future<bool> saveRow() async {
    if (formKey.currentState!.validate()) {
      if (debug) print("Row stitch nb : ${_row?.stitchesPerRow}");
      if (_row!.stitchesPerRow < 1) {
        await deletePatternRowInDb(_row!.rowId);
      } else {
        _row?.preview = _row?.detailsAsString();
        await updatePatternRowInDb(row!);
        for (int i = 0; i < _row!.details.length; i++) {
          if (_row?.details[i].repeatXTime != 0) {
            _row?.details[i].rowId = _row!.rowId;
            _row?.details[i].order = i;
            if (_row?.details[i].rowDetailId == 0) {
              await insertPatternRowDetailInDb(_row!.details[i]);
            } else {
              await updatePatternRowDetailInDb(_row!.details[i]);
            }
          } else {
            if (_row?.details[i].rowDetailId != 0) {
              await deletePatternRowDetailInDb(_row!.details[i].rowDetailId);
            }
          }
        }
      }
      return true;
    }
    return false;
  }

  Future<void> deleteRow() async {
    if (_row != null) await deletePatternRowInDb(_row!.rowId);
  }
}
