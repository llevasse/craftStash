import 'package:craft_stash/class/wip/wip.dart';
import 'package:craft_stash/class/wip/wip_part.dart' as craft;

class WipPartRepository {
  const WipPartRepository();

  Future<craft.WipPart> getWipPartById({required int id}) async {
    craft.WipPart part = await craft.getWipPartByWipPartId(
      id: id,
      withRows: true,
    );
    return part;
  }

  Future<Map<int, String>> getYarnIdToNameMap({required int wipId}) async {
    Map<int, String> yarnIdToNameMap = await getYarnIdToNameMapByWipId(wipId);
    return yarnIdToNameMap;
  }
}
