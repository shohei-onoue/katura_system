import 'package:flutter/material.dart';

/// アプリ全体の色をまとめたクラス。
/// ここの値を変えると、使っている画面すべての色が一括で変わる。
class AppColors {
  AppColors._();

  // 基本色
  static const MaterialColor primary = Colors.deepPurple;

  // 背景色
  static const Color mainBackground = Colors.white;
  static const Color popupBackground = Colors.white;
  static const Color menuBackground = Colors.black;
  static const Color labelBackground = Color(0xFF000038);

  // 選択ボタン（ON/OFF）
  static const Color offButton = Colors.white;
  static const Color offButtonText = Colors.black87;
  static const Color onButton = Colors.deepPurple;
  static const Color onButtonText = Colors.white;

  // 文字色
  static const Color accentText = Color(0xFFFF5722);
  static const Color primaryText = Colors.black;
  static const Color whiteText = Colors.white;
  static const Color secondaryText = Color(0xFF888888);

  // 強調色
  static const Color accentPurple = Colors.deepPurple;
  static const Color accentOrange = Colors.deepOrange;
  static const Color accentBlueGrey = Colors.blueGrey;
  static const Color accentOrangeLight = Colors.orange;

  // ベース色
  static const Color background = Colors.white;
  static const Color textPrimary = Colors.black;
  static const Color transparent = Colors.transparent;

  // カスタム色
  static const Color darkNavy = Color(0xFF000038);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color borderLight = Color(0xFFE8EAED);
  static const Color borderLight2 = Color(0xFFE5E5E5);
  static const Color surfaceMint = Color(0xFFF3F7F6);
  static const Color surfaceGrey = Color(0xFFEEEEEE);
  static const Color borderGrey = Color(0xFFE0E0E4);

  // 状態色
  static const Color error = Colors.red;
  static const Color success = Colors.green;
  static const Color info = Colors.blue;
  static const Color status = Colors.pink;
  static const Color warning = Colors.amber;
}
