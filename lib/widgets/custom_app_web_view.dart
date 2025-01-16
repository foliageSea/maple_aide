import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:maple_aide/constants/user_scripts.dart';
import 'package:maple_aide/global.dart';
import 'package:maple_aide/helpers/flutter_inappwebview_helper.dart';
import 'package:maple_aide/helpers/hotkey_helper.dart';
import 'package:maple_aide/helpers/preferences_helper.dart';
import 'package:maple_aide/helpers/window_manager_helper.dart';
import 'package:maple_aide/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart' show parse;

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
  final Function(int id, String url, String? title)? onUpdateVisitedHistory;
  final Function(int id)? onCloseTab;
  final List<Widget>? actions;

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
        URLRequest(url: WebUri(widget.url ?? 'https://www.bilibili.com/'));
  }

  void _initEvent() {
    Global.eventBus.on<GlobalEvent>().listen((event) async {
      if (HotkeyHelper().id.value != widget.id) {
        return;
      }

      var visible = await WindowManagerHelper().isVisible();
      if (!visible) {
        return;
      }

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
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        _buildWebView(),
        _buildProgress(),
      ],
    );
  }

  Widget _buildProgress() {
    return progress < 1.0
        ? LinearProgressIndicator(value: progress)
        : Container();
  }

  Widget _buildWebView() {
    var webViewEnvironment = FlutterInappwebviewHelper().webViewEnvironment;
    return InAppWebView(
      key: webViewKey,
      initialUrlRequest: urlRequest,
      webViewEnvironment: webViewEnvironment,
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
        this.url = url.toString();
        urlController.text = this.url;
        setState(() {});

        Future.delayed(const Duration(seconds: 1), () async {
          var html = await controller.getHtml() ?? "";
          final document = parse(html);
          final titleElement = document.querySelector('title');
          final title = titleElement?.text;
          widget.onUpdateVisitedHistory?.call(widget.id, this.url, title);
        });
      },
      onConsoleMessage: (controller, consoleMessage) {},
      onLoadStop: (controller, url) async {
        if (url != null && url.host.contains("bilibili.com")) {
          Future.delayed(const Duration(seconds: 1), () {
            Global.eventBus.fire(GlobalEvent(widget.id, GlobalEventType.muted));
          });
        }
      },
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
        // IconButton(
        //   icon: const Icon(Icons.volume_down_alt),
        //   onPressed: () {
        //     Global.eventBus.fire(GlobalEvent(widget.id, GlobalEventType.muted));
        //     showToast('静音模式切换');
        //   },
        // ),
        IconButton(
          icon: const Icon(Icons.fullscreen),
          onPressed: () {
            Global.eventBus
                .fire(GlobalEvent(widget.id, GlobalEventType.fullScreen));
            showToast('全屏模式切换');
          },
        ),
        const SizedBox(
          height: 15,
          child: VerticalDivider(
            width: 5,
            color: Colors.grey,
          ),
        ),
        ...(widget.actions ?? []),
      ],
    );
  }

  Widget _buildTag() {
    return Container(
      width: 25,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${widget.id}',
        style: const TextStyle(
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Padding _buildLocationBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8),
      child: TextField(
        controller: urlController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(suffix: _buildTag()),
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
