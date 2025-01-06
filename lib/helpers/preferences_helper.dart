import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static PreferencesHelper? _helper;

  PreferencesHelper._();

  factory PreferencesHelper() {
    _helper ??= PreferencesHelper._();
    return _helper!;
  }

  late SharedPreferences prefs;
  Future init() async {
    prefs = await SharedPreferences.getInstance();
  }
}

enum PreferencesKey {
  url,
}
