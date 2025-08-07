import 'package:craft_stash/class/yarns/yarn_collection.dart';

class YarnStashRepository {
  const YarnStashRepository();

  Future<List<YarnCollection>> getAllYarnInCollections() async {
    return await getAllYarnCollection(getYarn: true);
  }
}
