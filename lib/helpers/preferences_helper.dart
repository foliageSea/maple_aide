import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static PreferencesHelper? _helper;

  PreferencesHelper._();

  factory PreferencesHelper() {
    _helper ??= PreferencesHelper._();
    return _helper!;
  }

  late SharedPreferences prefs;
  RxBool darkMode = false.obs;
  RxInt customColor = 0.obs;

  Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future loadConfig() async {
    darkMode.value = prefs.getBool(PreferencesKey.darkMode.name) ?? false;
    customColor.value = prefs.getInt(PreferencesKey.customColor.name) ?? 0;
  }

  Future toggleDarkMode() async {
    darkMode.value = !darkMode.value;
    darkMode.refresh();
    await prefs.setBool(PreferencesKey.darkMode.name, darkMode.value);
  }

  Future setCustomColor(int index) async {
    customColor.value = index;
    customColor.refresh();
    await prefs.setInt(PreferencesKey.customColor.name, customColor.value);
  }
}

enum PreferencesKey {
  darkMode,
  customColor,
}
