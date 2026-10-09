import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// HTML表示の操作役。[channelName] を指定すると、HTML内の `window.<channelName>.postMessage(文字列)` が [onMessage] に届く。
class KHtmlController {
  KHtmlController({this.channelName, this.onMessage, this.backgroundColor, this.enableZoom = true}) {
    _c = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
    if (!enableZoom) _c.enableZoom(false);
    if (backgroundColor != null) _c.setBackgroundColor(backgroundColor!);
    if (channelName != null) {
      _c.addJavaScriptChannel(channelName!, onMessageReceived: (m) => onMessage?.call(m.message));
    }
  }

  final String? channelName;
  final void Function(String message)? onMessage;
  final Color? backgroundColor;
  final bool enableZoom;
  late final WebViewController _c;

  Future<void> loadHtml(String html) => _c.loadHtmlString(html);
  Future<void> runJavaScript(String js) => _c.runJavaScript(js);
}

class KHtmlView extends StatelessWidget {
  final KHtmlController controller;
  const KHtmlView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: controller._c);
}
