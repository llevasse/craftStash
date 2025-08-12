import 'dart:async';

import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';
import 'package:craft_stash/class/patterns/pattern_row_detail.dart';
import 'package:craft_stash/class/stitch.dart';
import 'package:craft_stash/data/repository/pattern/pattern_detail_repository.dart';
import 'package:craft_stash/data/repository/pattern/pattern_row_repository.dart';
import 'package:craft_stash/data/repository/stitch_repository.dart';
import 'package:craft_stash/main.dart';
import 'package:craft_stash/ui/row/widget/stitch_count_button.dart';
import 'package:flutter/material.dart';

class PatternRowModel extends ChangeNotifier {
  PatternRowModel({
    required PatternRowRepository patternRowRepository,
    this.yarnNameMap,
    this.part,
    this.isSubRow = false,
    this.stitchId,
    this.id,
  }) : _patternRowRepository = patternRowRepository;
  final PatternRowRepository _patternRowRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Map<int, String>? yarnNameMap;
  final bool isSubRow;
  final int? stitchId;

  int? id;
  final PatternPart? part;

  PatternRow? _row;
  PatternRow? get row => _row;

  double buttonHeight = 50;
  bool needScroll = false;

  Timer? timer;

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
        _row = await _patternRowRepository.getRowById(id: id!);
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
              index: detailsCountButtonList.length,
              text: text,
              showCount: !isColorChange,
              allowDecrease: !isColorChange,
              allowIncrease: !isColorChange,
            ),
          );
        }
      } else {
        _row = PatternRow(
          startRow: part!.rows.isEmpty
              ? 1
              : part!.rows.last.startRow + part!.rows.last.numberOfRows,
          numberOfRows: 1,
          stitchesPerRow: 0,
          partId: isSubRow == false ? part!.partId : null,
        );
        _row?.rowId = await _patternRowRepository.insertRow(patternRow: _row!);
      }
      String preview = _row!.detailsAsString();
      if (yarnNameMap != null) {
        for (MapEntry<int, String> entry in yarnNameMap!.entries) {
          preview = preview.replaceAll("\${${entry.key}}", entry.value);
        }
      }
      previewControler.text = preview;
      if (previewScrollController.hasClients) {
        scrollDown(ctrl: previewScrollController);
      }
      if (stitchDetailsScrollController.hasClients) {
        scrollDown(ctrl: stitchDetailsScrollController);
      }
      loaded = true;
    } finally {
      notifyListeners();
    }
  }

  Future<void> reload() async {
    loaded = false;
    await load();
  }

  void _setUpdateTimer() {
    print("Set timer");
    if (timer != null) {
      timer!.cancel();
    }
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      timer = Timer(const Duration(seconds: 1), () async {
        await saveRow();
        timer = null;
      });
    }
  }

  void setStartRow(int value) {
    _row?.startRow = value;
    _setUpdateTimer();
    notifyListeners();
  }

  void setStitchNb(int value) {
    _row?.stitchesPerRow = value;
    _setUpdateTimer();
    notifyListeners();
  }

  void setNumberOfRows(int value) {
    _row?.numberOfRows = value;
    _setUpdateTimer();
    notifyListeners();
  }

  void setPreview(String text) {
    if (yarnNameMap != null) {
      for (MapEntry<int, String> entry in yarnNameMap!.entries) {
        text = text.replaceAll("\${${entry.key}}", entry.value);
      }
    }
    _row?.preview = text;
    previewControler.text = text;
    _setUpdateTimer();
    notifyListeners();
  }

  void setRow(PatternRow newRow) {
    _setUpdateTimer();
    _row = newRow;
  }

  void scrollDown({required ScrollController ctrl, int duration = 0}) {
    ctrl.animateTo(
      ctrl.position.maxScrollExtent,
      duration: Duration(milliseconds: duration),
      curve: Curves.linear,
    );
    notifyListeners();
  }

  Future<Stitch?> addStitch(Stitch stitch) async {
    if (_row!.details.isNotEmpty &&
        _row!.details.last.stitch?.abreviation == stitch.abreviation) {
      _row!.details.last.repeatXTime += 1;
      detailsCountButtonList.removeLast();
    } else {
      PatternRowDetail prd = PatternRowDetail(
        rowId: _row!.rowId,
        stitchId: stitch.id,
        stitch: stitch,
      );
      prd.rowDetailId = await PatternDetailRepository().insertDetail(prd);
      _row!.details.add(prd);
    }
    _row!.stitchesPerRow += stitch.stitchNb;

    if (debug) print("Row stitch nb : ${_row!.stitchesPerRow}");

    detailsCountButtonList.add(
      RowStitchCountButton(
        patternRowModel: this,
        detail: _row!.details.last,
        index: detailsCountButtonList.length,
      ),
    );
    needScroll = true;
    setPreview(_row!.detailsAsString());
    return null;
  }

  Future<void> addSubrow(PatternRowDetail? detail) async {
    if (detail == null) return;
    if (row!.details.isNotEmpty &&
        row!.details.last.hashCode == detail.hashCode) {
      await PatternDetailRepository().deleteDetail(detail.rowDetailId);
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
        index: detailsCountButtonList.length,
      ),
    );

    needScroll = true;
    setPreview(_row!.detailsAsString());
  }

  Future<void> addColorChange(PatternRowDetail? detail) async {
    if (detail == null) return;
    if (_row!.details.isNotEmpty) {
      if (_row!.details.last.hashCode == detail.hashCode) {
        await PatternDetailRepository().deleteDetail(detail.rowDetailId);
      } else if (_row!.details.last.stitchId == stitchToIdMap['color change']) {
        await PatternDetailRepository().deleteDetail(
          _row!.details.last.rowDetailId,
        );
        _row!.details.removeLast();
        detailsCountButtonList.removeLast();
        _row!.details.add(detail);
        detailsCountButtonList.add(
          RowStitchCountButton(
            patternRowModel: this,
            detail: detail,
            index: detailsCountButtonList.length,
            allowIncrease: false,
            allowDecrease: false,
            showCount: false,
          ),
        );
      } else if (_row!.details.last.stitchId == stitchToIdMap['start color']) {
        _row!.details.last.inPatternYarnId = detail.inPatternYarnId;
        await PatternDetailRepository().updateDetail(_row!.details.last);
      } else {
        _row!.details.add(detail);
        detailsCountButtonList.add(
          RowStitchCountButton(
            patternRowModel: this,
            detail: detail,
            index: detailsCountButtonList.length,
            allowIncrease: false,
            allowDecrease: false,
            showCount: false,
          ),
        );
      }
    }

    needScroll = true;
    setPreview(_row!.detailsAsString());
  }

  Future<void> addStartColor(PatternRowDetail? detail) async {
    if (detail == null) return;
    if (_row!.details.isNotEmpty) {
      if (_row!.details.first.stitchId == stitchToIdMap["start color"]) {
        _row!.details.first.inPatternYarnId = detail.inPatternYarnId;
        await PatternDetailRepository().updateDetail(_row!.details.first);
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
    needScroll = true;
    setPreview(_row!.detailsAsString());
  }

  Future<void> saveRow() async {
    if (debug) print("Row stitch nb : ${_row?.stitchesPerRow}");
    if (_row!.stitchesPerRow < 1) {
      await _patternRowRepository.deleteRow(_row!.rowId);
    } else {
      _row?.preview = _row?.detailsAsString();
      await _patternRowRepository.updateRow(row!);
      for (int i = 0; i < _row!.details.length; i++) {
        if (_row?.details[i].repeatXTime != 0) {
          _row?.details[i].order = i;
          await PatternDetailRepository().updateDetail(_row!.details[i]);
        } else {
          if (_row?.details[i].rowDetailId != 0) {
            await PatternDetailRepository().deleteDetail(
              _row!.details[i].rowDetailId,
            );
          }
        }
      }
    }
  }

  Future<PatternRowDetail?> saveSequence(BuildContext context) async {
    if (formKey.currentState!.mounted && formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (debug) print("Row stitch nb : ${_row!.stitchesPerRow}");
      PatternRowDetail detail = PatternRowDetail(rowId: 0, stitchId: 0);

      if (row?.rowId != null) {
        detail.rowId = row!.rowId;
      }
      if (id == null) {
        for (PatternRowDetail e in _row!.details) {
          if (e.repeatXTime != 0) {
            e.rowId = _row!.rowId;
            await PatternDetailRepository().insertDetail(e);
          }
        }
        detail.stitch = Stitch(
          abreviation: _row!.toString(),
          isSequence: 1,
          sequenceId: _row!.rowId,
          stitchNb: _row!.stitchesPerRow,
        );
        detail.stitchId = await StitchRepository().insertStitch(detail.stitch!);
      } else {
        await _patternRowRepository.updateRow(row!);
        await StitchRepository().updateStitch(
          Stitch(
            id: stitchId as int,
            abreviation: _row!.toString(),
            isSequence: 1,
            sequenceId: _row!.rowId,
          ),
        );
        for (PatternRowDetail e in _row!.details) {
          if (e.repeatXTime != 0) {
            e.rowId = _row!.rowId;
            if (e.rowDetailId == 0) {
              await PatternDetailRepository().insertDetail(e);
            } else {
              await PatternDetailRepository().updateDetail(e);
            }
          } else {
            if (e.rowDetailId != 0) {
              await PatternDetailRepository().deleteDetail(e.rowDetailId);
            }
          }
        }
      }

      Navigator.pop(context, detail);
    }
    return null;
  }

  Future<void> deleteRow() async {
    if (_row != null) {
      await _patternRowRepository.deleteRow(_row!.rowId);
    }
  }
}
