import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/class/patterns/pattern_row.dart';

class WipPart {
  int id;
  int wipId;
  int partId;
  int madeXTime;
  int finished;
  int currentRowNumber;
  int currentRowIndex;
  int currentStitchNumber;
  int stitchDoneNb;
  PatternPart? part;
  WipPart({
    this.id = 0,
    required this.wipId,
    required this.partId,
    this.madeXTime = 0,
    this.currentRowNumber = 1,
    this.currentRowIndex = 0,
    this.currentStitchNumber = 0,
    this.finished = 0,
    this.stitchDoneNb = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'wip_id': wipId,
      'part_id': partId,
      'made_x_time': madeXTime,
      'finished': finished,
      'current_row_number': currentRowNumber,
      'current_row_index': currentRowIndex,
      'current_stitch_number': currentStitchNumber,
      'stitch_done_nb': stitchDoneNb,
    };
  }

  toJson() {
    var obj = toMap();
    obj.remove('wip_id');
    obj.remove('part_id');
    obj['name'] = part?.name;
    // obj['rows'] = [];
    // obj['stitches'] = {};
    // for (final row in rows) {
    //   Map<String, dynamic> rowObj = row.toJson();
    //   obj['stitches'].addAll(rowObj['stitches']);
    //   rowObj.remove('stitches');
    //   obj['rows'].add(rowObj);
    // }
    return obj;
  }

  @override
  String toString() {
    if (part == null) return "";
    String tmp = "${part?.name} $madeXTime/${part?.numbersToMake}:\n";
    for (PatternRow row in part!.rows) {
      tmp += "\t\t${row.toString()}";
    }

    return tmp;
  }
}
