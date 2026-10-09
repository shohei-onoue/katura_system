import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// 端末判定を1か所にまとめる。
/// Android/iOSの実機アプリ（タブレット）なら true。
/// Web(Chrome等)と macOS/Windows/Linux デスクトップは false。
bool get useOnScreenKeyboard =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);
