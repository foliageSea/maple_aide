import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:maple_aide/db/dao/tab_dao.dart';
import 'package:maple_aide/db/entity/tab_entity.dart';
import 'package:maple_aide/helpers/hotkey_helper.dart';
import 'package:maple_aide/widgets/custom_app_web_view.dart';

class HomeController extends GetxController {
  var tabs = <Tab>[].obs;
  var index = 0.obs;
  final HotkeyHelper hotkeyHelper = HotkeyHelper();

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
          tab.title = e.title;
          tab.id = e.id;
          return tab;
        },
      ).toList();
      tabs.refresh();

      if (tabs.isNotEmpty) {
        hotkeyHelper.id = tabs.first.id;
      }
    } catch (_) {}
  }

  Future addTab() async {
    try {
      var entity = TabEntity();

      await TabDao().add(entity);

      var tab = Tab();
      tab.id = entity.id;
      tab.url = entity.url;
      tab.title = entity.title;
      tab.key = GlobalKey<CustomAppWebViewState>();
      tabs.add(tab);
      tabs.refresh();
    } catch (_) {}
  }

  Future handleUpdateUrl(int id, String url, String? title) async {
    try {
      await TabDao().update(id, url, title);
    } catch (_) {}
  }

  GlobalKey<CustomAppWebViewState> getCustomAppWebViewState() {
    return tabs[index.value].key;
  }

  Future removeTab(int id) async {
    await TabDao().delete(id);

    var tab = tabs.firstWhereOrNull((e) => e.id == id);

    if (tab != null) {
      tabs.remove(tab);
      tabs.refresh();
    }
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
