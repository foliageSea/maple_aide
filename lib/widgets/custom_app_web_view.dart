import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:maple_aide/constants/user_scripts.dart';
import 'package:maple_aide/global.dart';
import 'package:maple_aide/helpers/preferences_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAppWebView extends StatefulWidget {
  const CustomAppWebView({
    super.key,
    required this.id,
    required this.url,
    this.actions,
    this.onUpdateVisitedHistory,
    this.onCloseTab,
  });

  final int id;
  final String? url;
  final Function(String url)? onUpdateVisitedHistory;
  final Function(int id)? onCloseTab;
  final Widget? actions;

  @override
  State<CustomAppWebView> createState() => CustomAppWebViewState();
}

class CustomAppWebViewState extends State<CustomAppWebView> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
  );

  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  final prefs = PreferencesHelper().prefs;

  bool showBar = true;

  URLRequest? urlRequest;

  @override
  void initState() {
    super.initState();

    _initEvent();

    _loadConfig();
  }

  Future _loadConfig() async {
    urlRequest =
        URLRequest(url: WebUri(widget.url ?? 'https://www.google.com/'));
  }

  void _initEvent() {
    Global.eventBus.on<GlobalEvent>().listen((event) async {
      var handler = userScriptsHandlers[event.type];
      if (handler == null) {
        return;
      }
      await webViewController?.evaluateJavascript(source: handler);
    });
  }

  void toggleShowActionBar() {
    showBar = !showBar;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Visibility(
              visible: showBar,
              child: _buildActionBar(),
            ),
            const SizedBox(
              height: 4,
            ),
            Expanded(
              child: Stack(
                children: [
                  _buildWebView(),
                  _buildProgress(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return progress < 1.0
        ? LinearProgressIndicator(value: progress)
        : Container();
  }

  Widget _buildWebView() {
    return InAppWebView(
      key: webViewKey,
      initialUrlRequest: urlRequest,
      webViewEnvironment: Global.webViewEnvironment,
      initialUserScripts: userScripts,
      initialSettings: settings,
      onWebViewCreated: (controller) async {
        webViewController = controller;
      },
      onLoadStart: (controller, url) {
        setState(() {
          this.url = url.toString();
          urlController.text = this.url;
        });
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var uri = navigationAction.request.url!;

        if (!["http", "https", "file", "chrome", "data", "javascript", "about"]
            .contains(uri.scheme)) {
          if (await canLaunchUrl(uri)) {
            // Launch the App
            await launchUrl(
              uri,
            );
            // and cancel the request
            return NavigationActionPolicy.CANCEL;
          }
        }

        return NavigationActionPolicy.ALLOW;
      },
      onProgressChanged: (controller, progress) {
        setState(() {
          this.progress = progress / 100;
          urlController.text = url;
        });
      },
      onUpdateVisitedHistory: (controller, url, isReload) async {
        setState(() {
          this.url = url.toString();
          urlController.text = this.url;
          widget.onUpdateVisitedHistory?.call(this.url);
        });
      },
      onConsoleMessage: (controller, consoleMessage) {},
    );
  }

  Row _buildActionBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            webViewController?.goBack();
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            webViewController?.goForward();
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            webViewController?.reload();
          },
        ),
        Flexible(
          child: _buildLocationBar(),
        ),
        IconButton(
          icon: const Icon(Icons.fullscreen),
          onPressed: () {
            Global.eventBus.fire(GlobalEvent(GlobalEventType.fullScreen));
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: () {
            Global.eventBus.fire(GlobalEvent(GlobalEventType.next));
          },
        ),
        widget.actions ?? Container(),
      ],
    );
  }

  Padding _buildLocationBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8),
      child: TextField(
        controller: urlController,
        keyboardType: TextInputType.text,
        onSubmitted: (value) {
          var url = WebUri(value);
          if (url.scheme.isEmpty) {
            url = WebUri((!kIsWeb
                    ? "https://www.google.com/search?q="
                    : "https://www.bing.com/search?q=") +
                value);
          }
          webViewController?.loadUrl(urlRequest: URLRequest(url: url));
        },
      ),
    );
  }
}
