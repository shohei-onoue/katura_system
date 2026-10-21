import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// スマホ版UIにするか。
/// アプリ(Android/iOS)は画面の短い辺が600未満（横向きでも切り替わらず、タブレットはPC版）。
/// Web(ブラウザ)は窓の横幅が600未満（窓を狭めるとスマホ版）。
bool isPhoneMode(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return (kIsWeb ? size.width : size.shortestSide) < 600;
}
