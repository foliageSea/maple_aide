import 'package:isar/isar.dart';

part 'tab_entity.g.dart';

@collection
class TabEntity {
  Id id = Isar.autoIncrement;
  String? url;
}
