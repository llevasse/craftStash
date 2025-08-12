import 'package:craft_stash/class/stitch.dart';


class PatternRowDetail {
  int rowId;
  int rowDetailId;
  int stitchId;
  Stitch? stitch;
  int repeatXTime;
  int? inPatternYarnId; //only used for color change
  int? order;
  int? patternId;
  PatternRowDetail({
    required this.rowId,
    required this.stitchId,
    this.stitch,
    this.rowDetailId = 0,
    this.repeatXTime = 1,
    this.patternId,
    this.inPatternYarnId,
    this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'row_id': rowId,
      'stitch_id': stitchId,
      'repeat_x_time': repeatXTime,
      'yarn_id': inPatternYarnId,
      'in_row_order': order,
      'pattern_id': patternId,
    };
  }

  @override
  String toString() {
    if (stitchId == stitchToIdMap['color change']) {
      return ("change to \${$inPatternYarnId}");
    }
    if (stitchId == stitchToIdMap['start color']) {
      return ("start with \${$inPatternYarnId}");
    }
    if (stitch != null && repeatXTime >= 1) {
      if (repeatXTime == 1) return (stitch.toString());
      if (stitch!.isSequence == 1) {
        return ("${stitch.toString()}x${repeatXTime.toString()}");
      }
      return ("${repeatXTime.toString()}${stitch.toString()}");
    }
    return "";
  }

  void printDetail([int tab = 0]) {
    String s = "";
    for (int i = 0; i < tab; i++) {
      s += "\t";
    }
    print("${s}rowId : ${rowId.toString()}");
    print("${s}rowDetailId : ${rowDetailId.toString()}");
    print("${s}stitchId : ${stitchId.toString()}");
    stitch?.printDetails(tab + 1);
    print("${s}repeat : ${repeatXTime.toString()}");
    print("${s}yarn_id : ${inPatternYarnId.toString()}");
    print("\r\n");
  }

  @override
  int get hashCode =>
      Object.hash(rowId, stitch.hashCode, inPatternYarnId, repeatXTime);
}