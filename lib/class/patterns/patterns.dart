import 'package:craft_stash/class/patterns/pattern_part.dart';

class Pattern {
  int patternId;
  double? hookSize;
  String name;
  String? note;
  int totalStitchNb;
  Map<int, String> yarnIdToNameMap = {};
  List<PatternPart> parts = List.empty(growable: true);
  Pattern({
    this.patternId = 0,
    this.name = "New pattern",
    this.note,
    this.hookSize,
    this.totalStitchNb = 0,
  });

  Map<String, dynamic> toMap() {
    // return {'pattern_id': patternId, 'name': name};
    return {
      'name': name,
      'note': note,
      'hook_size': hookSize,
      'total_stitch_nb': totalStitchNb,
    };
  }

  @override
  String toString() {
    String tmp = "$name :\n";
    for (PatternPart part in parts) {
      tmp += "\t${part.toString()}";
    }
    return tmp;
  }

  @override
  int get hashCode => Object.hash(name, 0);
}
