import 'package:craft_stash/class/patterns/patterns.dart' as craft;

class PatternRepository {
  const PatternRepository();

  Future<craft.Pattern> getPatternById({required int id}) async {
    return (await craft.getPatternById(
      id: id,
      withYarnNames: true,
      withParts: true,
    ));
  }
}
