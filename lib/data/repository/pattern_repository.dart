import 'package:craft_stash/class/patterns/patterns.dart' as craft;

class PatternRepository {
  const PatternRepository();

  Future<craft.Pattern> getPatternById({required int id}) async {
    craft.Pattern pattern = await craft.getPatternById(
      id: id,
      withYarnNames: true,
      withParts: true,
    );
    pattern.yarnIdToNameMap = await craft.getYarnIdToNameMapByPatternId(id);
    return pattern;
  }

  Future<int> insertPattern() async {
    craft.Pattern pattern = craft.Pattern();
    return await craft.insertPatternInDb(pattern);
  }
}
