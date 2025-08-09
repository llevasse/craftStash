import 'package:craft_stash/class/wip/wip.dart' as craft;

class WipStashRepository {
  const WipStashRepository();

  Future<List<craft.Wip>> getAllWip() async {
    return await craft.getAllWip();
  }
}
