import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:maple_aide/db/db.dart';
import 'package:maple_aide/helpers/flutter_inappwebview_helper.dart';
import 'package:maple_aide/helpers/hotkey_helper.dart';
import 'package:maple_aide/helpers/preferences_helper.dart';
import 'package:maple_aide/helpers/tray_manager_helper.dart';
import 'helpers/window_manager_helper.dart';

class Global {
  static String appName = 'maple_aide';

  static EventBus eventBus = EventBus();

  static Future initApp() async {
    WidgetsFlutterBinding.ensureInitialized();

    var windowManagerHelper = WindowManagerHelper();
    windowManagerHelper.setSingleInstance([]);

    await Db().init();

    await PreferencesHelper().init();

    await HotkeyHelper().unregisterAll();

    await FlutterInappwebviewHelper().init();

    await windowManagerHelper.ensureInitialized();

    var trayManagerHelper = TrayManagerHelper();
    await trayManagerHelper.init();
  }
}

class GlobalEvent {
  late int id;
  late GlobalEventType type;

  GlobalEvent(this.id, this.type);
}

enum GlobalEventType {
  toggle,
  fullScreen,
  prev,
  next,
  forward,
  back,
  muted,
}
