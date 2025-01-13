import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:maple_aide/db/db.dart';
import 'package:path/path.dart' as p;

class FlutterInappwebviewHelper {
  static FlutterInappwebviewHelper? _helper;

  FlutterInappwebviewHelper._();

  factory FlutterInappwebviewHelper() {
    _helper ??= FlutterInappwebviewHelper._();
    return _helper!;
  }

  WebViewEnvironment? webViewEnvironment;
  String userDataFolder = 'userData';

  Future init() async {
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
