import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// 端末の回転角（度）。ブラウザの screen.orientation.angle を読む（0 / 90 / 180 / 270）。
int screenAngle() {
  try {
    final screen = globalContext['screen'] as JSObject?;
    final orientation = screen?['orientation'] as JSObject?;
    final angle = orientation?['angle'] as JSNumber?;
    return angle?.toDartInt ?? 0;
  } catch (_) {
    return 0;
  }
}
