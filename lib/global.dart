import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:maple_aide/db/db.dart';
import 'package:maple_aide/helpers/hotkey_helper.dart';
import 'package:maple_aide/helpers/preferences_helper.dart';
import 'package:maple_aide/helpers/tray_manager_helper.dart';
import 'package:path/path.dart' as p;
import 'helpers/window_manager_helper.dart';

class Global {
  static String appName = 'maple_aide';
  static WebViewEnvironment? webViewEnvironment;
  static String userDataFolder = 'userData';
  static EventBus eventBus = EventBus();

  static Future initApp() async {
    WidgetsFlutterBinding.ensureInitialized();

    var windowManagerHelper = WindowManagerHelper();
    windowManagerHelper.setSingleInstance([]);

    await Db().init();

    await PreferencesHelper().init();

    await HotkeyHelper().unregisterAll();

    await _initWebView();

    await windowManagerHelper.ensureInitialized();

    var trayManagerHelper = TrayManagerHelper();
    await trayManagerHelper.init();
  }

  static Future _initWebView() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      final availableVersion = await WebViewEnvironment.getAvailableVersion();
      assert(availableVersion != null,
          'Failed to find an installed WebView2 runtime or non-stable Microsoft Edge installation.');

      webViewEnvironment = await WebViewEnvironment.create(
        settings: WebViewEnvironmentSettings(
          additionalBrowserArguments: kDebugMode
              ? '--enable-features=msEdgeDevToolsWdpRemoteDebugging'
              : null,
          userDataFolder: p.join(Db().path.path, userDataFolder),
        ),
      );
    }
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
}
