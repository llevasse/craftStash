import 'package:craft_stash/class/yarns/yarn_collection.dart';
import 'package:craft_stash/data/repository/yarn/collection_repository.dart';

class YarnStashRepository {
  const YarnStashRepository();

  Future<List<YarnCollection>> getAllYarnInCollections() async {
    return await CollectionRepository().getAllYarnCollection(getYarn: true);
  }
}
