// HTMLを表示する部品。スマホ/タブレットは WebView、Web(Chrome等)は iframe で表示する。
export 'k_html_view_native.dart' if (dart.library.js_interop) 'k_html_view_web.dart';
