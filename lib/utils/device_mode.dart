import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// スマホ版UIにするか。
/// アプリ(Android/iOS)は画面の短い辺が600未満（横向きでも切り替わらず、タブレットはPC版）。
/// Web(PCのブラウザ)は窓の横幅が600未満（窓を狭めるとスマホ版）。
/// Web(スマホ/タブレットのブラウザ)はアプリと同じく短い辺で判定（横向きでもスマホ版のまま）。
bool isPhoneMode(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final bool mobileBrowser = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  return (kIsWeb && !mobileBrowser ? size.width : size.shortestSide) < 600;
}
