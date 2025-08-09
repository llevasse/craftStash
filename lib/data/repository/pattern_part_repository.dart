import 'package:craft_stash/class/patterns/pattern_part.dart';
import 'package:craft_stash/data/repository/pattern_repository.dart';

class PatternPartRepository {
  const PatternPartRepository();

  Future<PatternPart> getPatternPartById({required int id}) async {
    PatternPart part = await getPatternPartByPartId(
      id: id,
      withRows: true,
      withDetails: true,
    );
    return part;
  }

  Future<Map<int, String>> getYarnIdToNameMap({required int patternId}) async {
    Map<int, String> yarnIdToNameMap = await PatternRepository()
        .getYarnIdToNameMapByPatternId(patternId);
    return yarnIdToNameMap;
  }

  Future<int> insertPart({required int patternId}) async {
    PatternPart part = PatternPart(name: "new part", patternId: patternId);
    return await insertPatternPartInDb(part);
  }
}
