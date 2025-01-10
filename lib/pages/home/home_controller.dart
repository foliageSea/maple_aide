import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:maple_aide/db/dao/tab_dao.dart';
import 'package:maple_aide/db/entity/tab_entity.dart';
import 'package:maple_aide/widgets/custom_app_web_view.dart';

class HomeController extends GetxController {
  var tabs = <Tab>[].obs;
  var index = 0.obs;

  void resetIndex() {
    index.value = 0;
    index.refresh();
  }

  Future loadData() async {
    try {
      var data = await TabDao().getAll();
      tabs.value = data.map(
        (e) {
          var tab = Tab();
          tab.key = GlobalKey<CustomAppWebViewState>();
          tab.url = e.url;
          tab.id = e.id;
          return tab;
        },
      ).toList();
      tabs.refresh();
    } catch (_) {}
  }

  Future addTab() async {
    try {
      var entity = TabEntity();

      await TabDao().add(entity);

      await loadData();
    } catch (_) {}
  }

  Future handleUpdateUrl(int id, String url) async {
    try {
      await TabDao().update(id, url);
    } catch (_) {}
  }

  GlobalKey<CustomAppWebViewState> getCustomAppWebViewState() {
    return tabs[index.value].key;
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }
}

class Tab extends TabEntity {
  late GlobalKey<CustomAppWebViewState> key;
}
