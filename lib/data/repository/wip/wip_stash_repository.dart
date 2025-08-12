import 'package:craft_stash/class/wip/wip.dart';
import 'package:craft_stash/data/repository/wip/wip_repository.dart';

class WipStashRepository {
  const WipStashRepository();

  Future<List<Wip>> getAllWip() async {
    return await WipRepository().getAllWip();
  }
}
