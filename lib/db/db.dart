import 'dart:io';

import 'package:isar/isar.dart';
import 'package:maple_aide/db/entity/tab_entity.dart';
import 'package:maple_aide/global.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class Db {
  static Db? _db;

  Db._();

  factory Db() {
    _db ??= Db._();
    return _db!;
  }

  late Isar isar;

  Future init() async {
    final dir = await getApplicationDocumentsDirectory();
    var path = Directory(p.join(dir.path, Global.appName));

    if (!path.existsSync()) {
      path.createSync(recursive: true);
    }

    isar = await Isar.open(
      [TabEntitySchema],
      directory: path.path,
      name: Global.appName,
    );
  }
}
