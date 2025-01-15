import 'dart:io';

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> showToast(String msg) {
  return SmartDialog.showToast(
    msg,
    animationTime: const Duration(seconds: 0),
    displayTime: const Duration(seconds: 1),
  );
}

Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

Future<ProcessResult>? launchURL(String url) {
  if (!Platform.isWindows) {
    return null;
  }
  return Process.run('start', [url], runInShell: true);
}
