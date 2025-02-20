import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:maple_aide/constants/color_type.dart';
import 'package:maple_aide/helpers/hotkey_helper.dart';
import 'package:maple_aide/helpers/preferences_helper.dart';
import 'package:maple_aide/pages/home/home_page.dart';
import 'package:window_manager/window_manager.dart';
// import 'package:window_manager/window_manager.dart';

import 'global.dart';

void main() {
  Global.initApp()
      .then(
        (_) => runApp(const MyApp()),
      )
      .catchError(
        (error) => runApp(ErrorApp(error: error)),
      );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    HotkeyHelper().register();
    windowManager.addListener(this);
  }

  @override
  Future<void> onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      await windowManager.hide();
    }
  }

  @override
  void dispose() {
    super.dispose();
    windowManager.removeListener(this);
    HotkeyHelper().unregisterAll();
  }

  @override
  Widget build(BuildContext context) {
    // final virtualWindowFrameBuilder = VirtualWindowFrameInit();

    var customColor = PreferencesHelper().customColor.value;
    var darkMode = PreferencesHelper().darkMode;
    Color defaultColor = colorThemeTypes[customColor]['color'];
    var lightColorScheme = ColorScheme.fromSeed(
      seedColor: defaultColor,
      brightness: Brightness.light,
    );
    var darkColorScheme = ColorScheme.fromSeed(
      seedColor: defaultColor,
      brightness: Brightness.dark,
    );
    return Obx(
      () => GetMaterialApp(
        title: Global.appName,
        debugShowCheckedModeBanner: false,
        navigatorObservers: [FlutterSmartDialog.observer],
        themeMode: darkMode.value ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          fontFamily: 'MiSans',
          platform: TargetPlatform.iOS,
          cupertinoOverrideTheme: const CupertinoThemeData(
            textTheme: CupertinoTextThemeData(), // This is required
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          fontFamily: 'MiSans',
          platform: TargetPlatform.iOS,
          cupertinoOverrideTheme: const CupertinoThemeData(
            textTheme: CupertinoTextThemeData(), // This is required
          ),
        ),
        builder: (context, child) {
          var c = FlutterSmartDialog.init(
            builder: (context, child) {
              return child!;
            },
          )(context, child);
          // c = virtualWindowFrameBuilder(context, c);
          return c;
        },
        translations: CustomTranslations(), // 你的翻译
        locale: CustomTranslations.local,
        fallbackLocale: CustomTranslations.local,
        localizationsDelegates: CustomTranslations.localizationsDelegates,
        home: const HomePage(),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final dynamic error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('启动异常'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 120,
              ),
              Text("$error"),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys {
    return {
      'zh_CN': {},
    };
  }

  static const local = Locale('zh', 'CN');

  static const localizationsDelegates = [
    DefaultMaterialLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
    DefaultCupertinoLocalizations.delegate, // This is required
  ];
}
