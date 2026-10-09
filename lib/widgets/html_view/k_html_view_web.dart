import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

int _seq = 0;

/// HTML表示の操作役（Web版：iframe）。[channelName] を指定すると、
/// HTML内の `window.<channelName>.postMessage(文字列)` が [onMessage] に届く。
class KHtmlController {
  KHtmlController({this.channelName, this.onMessage, this.backgroundColor, this.enableZoom = true}) {
    viewType = 'k-html-view-${_seq++}';
    final doc = globalContext['document'] as JSObject;
    _iframe = doc.callMethod<JSObject>('createElement'.toJS, 'iframe'.toJS);
    final style = _iframe['style'] as JSObject;
    style['border'] = 'none'.toJS;
    style['width'] = '100%'.toJS;
    style['height'] = '100%'.toJS;
    if (backgroundColor != null) {
      final hex = backgroundColor!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
      style['background'] = '#$hex'.toJS;
    }
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) => _iframe);

    if (channelName != null) {
      // iframe内の postMessage を親ページで受け取り、onMessage へ渡す
      _listener = ((JSObject e) {
        final data = e['data'];
        if (data == null || !data.isA<JSObject>()) return;
        final obj = data as JSObject;
        if ((obj['__id'] as JSString?)?.toDart != viewType) return;
        onMessage?.call((obj['data'] as JSString?)?.toDart ?? '');
      }).toJS;
      globalContext.callMethod('addEventListener'.toJS, 'message'.toJS, _listener);
    }
  }

  final String? channelName;
  final void Function(String message)? onMessage;
  final Color? backgroundColor;
  final bool enableZoom;
  late final String viewType;
  late final JSObject _iframe;
  JSFunction? _listener;

  /// `window.チャンネル名.postMessage(...)` を使えるようにする小さなスクリプトを head タグの直後に差し込む。
  String _withChannel(String html) {
    if (channelName == null) return html;
    final shim = '<script>window.$channelName={postMessage:function(m){'
        'parent.postMessage({__id:"$viewType",data:m},"*");}};</script>';
    final head = RegExp('<head[^>]*>', caseSensitive: false).firstMatch(html);
    if (head == null) return '$shim$html';
    return html.replaceRange(head.end, head.end, shim);
  }

  Future<void> loadHtml(String html) async {
    _iframe['srcdoc'] = _withChannel(html).toJS;
  }

  Future<void> runJavaScript(String js) async {
    final win = _iframe['contentWindow'] as JSObject?;
    win?.callMethod('eval'.toJS, js.toJS);
  }

  void dispose() {
    final l = _listener;
    if (l != null) {
      globalContext.callMethod('removeEventListener'.toJS, 'message'.toJS, l);
    }
  }
}

class KHtmlView extends StatelessWidget {
  final KHtmlController controller;
  const KHtmlView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: controller.viewType);
}
