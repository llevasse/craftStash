import 'package:craft_stash/class/patterns/patterns.dart' as craft;

class PatternStashRepository {
  const PatternStashRepository();

  Future<List<craft.Pattern>> getAllPattern() async {
    return await craft.getAllPattern();
  }
}
