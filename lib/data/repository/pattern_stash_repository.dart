import 'package:craft_stash/class/patterns/patterns.dart' as craft;
import 'package:craft_stash/data/repository/pattern_repository.dart';

class PatternStashRepository {
  const PatternStashRepository();

  Future<List<craft.Pattern>> getAllPattern() async {
    return await PatternRepository().getAllPattern();
  }
}
