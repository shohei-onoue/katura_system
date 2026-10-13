import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

/// 端末判定を1か所にまとめる。
/// Android/iOSの実機アプリ（タブレット）なら true。
/// タブレットのブラウザ（Web）もAndroid/iOSなら true。PCのブラウザと macOS/Windows/Linux デスクトップは false。
bool get useOnScreenKeyboard =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;
