import 'package:isar/isar.dart';
import 'package:maple_aide/db/db.dart';
import 'package:maple_aide/db/entity/tab_entity.dart';

class TabDao {
  static TabDao? _dao;

  TabDao._();

  factory TabDao() {
    _dao ??= TabDao._();

    return _dao!;
  }

  final isar = Db().isar;

  Future add(TabEntity obj) async {
    await isar.writeTxn(() async {
      await isar.tabEntitys.put(obj);
    });
  }

  Future update(int id, String url, String? title) async {
    var entity = await isar.tabEntitys.get(id);
    if (entity == null) {
      return;
    }

    entity.url = url;
    if (title != null && title.isNotEmpty) {
      entity.title = title;
    }

    await isar.writeTxn(() async {
      await isar.tabEntitys.put(entity);
    });
  }

  Future<List<TabEntity>> getAll() async {
    return isar.tabEntitys.where().findAll();
  }

  Future<TabEntity?> get(int id) async {
    return isar.tabEntitys.get(id);
  }

  Future delete(int id) async {
    await isar.writeTxn(() async {
      await isar.tabEntitys.delete(id);
    });
  }
}
