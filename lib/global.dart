import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hotkey_system/hotkey_system.dart';
import 'package:maple_aide/helpers/preferences_helper.dart';

import 'helpers/window_manager_helper.dart';

class Global {
  static WebViewEnvironment? webViewEnvironment;
  static String userDataFolder = 'userData';
  static EventBus eventBus = EventBus();

  static Future initApp() async {
    WidgetsFlutterBinding.ensureInitialized();

    await PreferencesHelper().init();

    await hotKeySystem.unregisterAll();

    await _initWebView();

    var windowManagerHelper = WindowManagerHelper();
    await windowManagerHelper.ensureInitialized();
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
        userDataFolder: userDataFolder,
      ));
    }
  }
}

class GlobalEvent {
  late GlobalEventType type;

  GlobalEvent(this.type);
}

enum GlobalEventType { toggle, fullScreen, pre, next }
