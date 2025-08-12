import 'package:craft_stash/class/patterns/pattern_row.dart';

Map<String, int> stitchToIdMap = {};

class Stitch {
  Stitch({
    this.id = 0,
    required this.abreviation,
    this.name,
    this.description,
    this.isSequence = 0,
    this.sequenceId,
    this.hidden = 0,
    this.stitchNb = 1,
  });
  int id;
  int stitchNb;
  String abreviation;
  String? name;
  String? description;
  int isSequence;
  int? sequenceId;
  PatternRow? row;
  int hidden;

  Map<String, dynamic> toMap() {
    return {
      "abreviation": abreviation,
      "name": name,
      "description": description,
      "is_sequence": isSequence,
      "sequence_id": sequenceId,
      "hidden": hidden,
      "hash": hashCode,
      "stitch_nb": stitchNb,
    };
  }

  @override
  String toString() {
    return abreviation;
  }

  void printDetails([int tab = 0]) {
    String s = "";
    for (int i = 0; i < tab; i++) {
      s += "\t";
    }
    print("${s}id $id");
    print("${s}abreviation $abreviation");
    print("${s}name $name");
    print("${s}description $description");
    print("${s}is_sequence $isSequence");
    if (isSequence == 1) {
      print("${s}sequence_id $sequenceId");
      row?.printDetails(tab + 1);
    }
    print("${s}hidden $hidden");
    print("${s}hash $hashCode");
    print("\r\n");
  }

  @override
  int get hashCode => Object.hash(abreviation, name, description);
}