import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:maple_aide/global.dart';

var userScripts = UnmodifiableListView<UserScript>(
  [
    UserScript(
      source:
          "window.toggle = () => document.querySelector('video')?.paused? document.querySelector('video')?.play():document.querySelector('video')?.pause();"
          "window.fullScreen = () => document.querySelector('.bpx-player-ctrl-web-enter')?.click();"
          "window.prev = () => document.querySelector('.bpx-player-ctrl-prev')?.click();"
          "window.next = () => document.querySelector('.bpx-player-ctrl-next')?.click();"
          "window.forward = () => document.querySelector('video').currentTime += 5;"
          "window.back = () => document.querySelector('video').currentTime -= 5;"
          "window.muted = () => document.querySelector('video').muted = !document.querySelector('video').muted;"
          "window.setMuteToggle = () => document.querySelector('video')?.addEventListener('canplay', () => document.querySelector('video').muted = false);",
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
    ),
  ],
);

Map<GlobalEventType, String> userScriptsHandlers = {
  GlobalEventType.toggle: 'window.toggle()',
  GlobalEventType.fullScreen: 'window.fullScreen()',
  GlobalEventType.prev: 'window.prev()',
  GlobalEventType.next: 'window.next()',
  GlobalEventType.forward: 'window.forward()',
  GlobalEventType.back: 'window.back()',
  GlobalEventType.muted: 'window.muted()',
  GlobalEventType.setMuteToggle: 'window.setMuteToggle()',
};
