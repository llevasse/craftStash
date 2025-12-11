import 'package:craft_stash/class/patterns/pattern_row_detail.dart';

class PatternRow {
  int rowId;
  int? partId;
  String? preview;
  int inSameStitch;
  int startRow, numberOfRows;
  int stitchesPerRow;
  int stitchesUsedFromPreviousRow =
      0; // if previous row was 6sc, and current row is 6inc, current row used 6sts from previous row and has 12sts in this row
  String? note;
  List<PatternRowDetail> details = List.empty(growable: true);
  PatternRow({
    this.rowId = 0,
    this.inSameStitch = 0, // non zero if is a subrow in done in the same stitch
    this.partId,
    required this.startRow,
    required this.numberOfRows,
    required this.stitchesPerRow,
    this.preview,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'part_id': partId,
      'start_row': startRow,
      'number_of_rows': numberOfRows,
      'preview': preview,
      'in_same_stitch': inSameStitch,
      'stitches_count_per_row': stitchesPerRow,
      'note': note,
      // 'hash': hashCode,
    };
  }

  String getSpecAsString() {
    return "rowId : $rowId | partId : $partId | startRow : $startRow | numberOfRows : $numberOfRows";
  }

  @override
  String toString() {
    String tmp = inSameStitch == 0 ? "(" : "[";
    for (PatternRowDetail detail in details) {
      if (detail.repeatXTime > 0) tmp += "${detail.toString()}, ";
    }
    if (details.isNotEmpty) {
      tmp = tmp.substring(0, tmp.length - 2);
    }
    tmp += inSameStitch == 0 ? ")" : "]";
    return tmp;
  }

  toJson() {
    var obj = toMap();
    obj.remove('part_id');
    obj['details'] = [];
    obj['stitches'] = {};
    Map<String, dynamic> stitches = {};
    for (final detail in details) {
      Map<String, dynamic> detailObj = detail.toJson();
      stitches[detail.stitchId.toString()] = detailObj['stitch'];
      detailObj.remove('stitch');
      obj['details'].add(detailObj);
    }
    obj['stitches'] = stitches;
    return obj;
  }

  @override
  int get hashCode => Object.hash(
    partId,
    startRow,
    numberOfRows,
    inSameStitch,
    stitchesPerRow,
    toString(),
  );

  String detailsAsString() {
    String tmp = "";
    if (details.isNotEmpty) {
      for (PatternRowDetail detail in details) {
        // detail.printDetail();
        // print("\n\r");
        tmp += "${detail.toString()}, ";
      }
      tmp = tmp.substring(0, tmp.length - 2);
      tmp += ". (${stitchesPerRow}sts)";
    }
    return tmp;
  }

  void printDetails([int tab = 0]) {
    String s = "";
    for (int i = 0; i < tab; i++) {
      s += "\t";
    }
    print("${s}row_id $rowId");
    print("${s}part_id $partId");
    print("${s}in_same_stitch $inSameStitch");
    print("${s}start_row $startRow");
    print("${s}number_of_rows $numberOfRows");
    print("${s}stitches_per_row $stitchesPerRow");
    print("${s}stitches_used_from_previous_row $stitchesUsedFromPreviousRow");
    for (PatternRowDetail detail in details) {
      detail.printDetail(tab + 1);
    }

    print("${s}hash $hashCode");
    print("\r\n");
  }
}
