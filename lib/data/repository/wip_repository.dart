import 'package:craft_stash/class/patterns/patterns.dart';
import 'package:craft_stash/class/wip/wip.dart' as craft;

class WipRepository {
  const WipRepository();

  Future<craft.Wip> getWipById({required int id}) async {
    craft.Wip wip = await craft.getWipById(id: id, withParts: true);
    wip.pattern = await getPatternById(id: wip.patternId);
    return wip;
  }

  Future<Map<int, String>> getYarnIdToName({required int id}) async {
    return await craft.getYarnIdToNameMapByWipId(id);
  }
}
