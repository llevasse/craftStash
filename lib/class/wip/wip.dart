import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/class/wip/wip_part.dart';

class Wip {
  int id;
  int patternId;
  int finished;
  int stitchDoneNb;
  String name;
  double? hookSize;
  craft.Pattern? pattern;
  Map<int, String> yarnIdToNameMap = {};
  List<WipPart> parts = List.empty(growable: true);
  Wip({
    this.id = 0,
    this.patternId = 0,
    this.finished = 0,
    this.stitchDoneNb = 0,
    this.name = "New wip",
    this.hookSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'finished': finished,
      'pattern_id': patternId,
      'stitch_done_nb': stitchDoneNb,
      "name": name,
      "hook_size": hookSize,
    };
  }

  @override
  String toString() {
    String tmp = "${pattern?.name} :\n";
    for (WipPart part in parts) {
      tmp += "\t${part.toString()}";
    }
    return tmp;
  }
}
