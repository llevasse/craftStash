import 'package:craft_stash/class/patterns/pattern_row.dart';

class PatternPart {
  int partId;
  int patternId;
  int numbersToMake;
  String name;
  String? note;
  int totalStitchNb;
  List<PatternRow> rows = List.empty(growable: true);
  PatternPart({
    this.partId = 0,
    required this.name,
    required this.patternId,
    this.numbersToMake = 1,
    this.note,
    this.totalStitchNb = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'pattern_id': patternId,
      'numbers_to_make': numbersToMake,
      'name': name,
      'note': note,
      'total_stitch_nb': totalStitchNb,
    };
  }

  @override
  String toString() {
    String tmp = "$name x$numbersToMake:\n";
    for (PatternRow row in rows) {
      tmp += "\t\t${row.toString()}";
    }

    return tmp;
  }

  toJson() {
    var obj = toMap();
    obj.remove('pattern_id');
    obj['rows'] = [];
    obj['stitches'] = {};
    for (final row in rows) {
      Map<String, dynamic> rowObj = row.toJson();
      obj['stitches'].addAll(rowObj['stitches']);
      rowObj.remove('stitches');
      obj['rows'].add(rowObj);
    }
    return obj;
  }

  @override
  int get hashCode => Object.hash(name, patternId, numbersToMake);
}
