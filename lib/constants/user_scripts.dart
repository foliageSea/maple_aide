import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:maple_aide/global.dart';

var userScripts = UnmodifiableListView<UserScript>(
  [
    UserScript(
      source:
          "window.toggle = () => document.querySelector('video')?.paused? document.querySelector('video')?.play():document.querySelector('video')?.pause();"
          "window.fullScreen = () => document.querySelector('.bpx-player-ctrl-web-enter')?.click();"
          "window.next = () => document.querySelector('.bpx-player-ctrl-next')?.click();",
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
    ),
  ],
);

Map<GlobalEventType, String> userScriptsHandlers = {
  GlobalEventType.toggle: 'window.toggle()',
  GlobalEventType.fullScreen: 'window.fullScreen()',
  GlobalEventType.pre: 'window.pre()',
  GlobalEventType.next: 'window.next()',
};
