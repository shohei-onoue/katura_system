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
  static const Color labelBackground = Color(0xFF999999);

  // 選択ボタン（ON/OFF）
  static const Color offButton = Colors.white;
  static const Color offButtonText = Colors.black87;
  static const Color onButton = Colors.deepPurple;
  static const Color onButtonText = Colors.white;

  // 文字色
  static const Color accentText = Colors.deepOrange;
  static const Color primaryText = Colors.black;
  static const Color secondaryText = Color(0xFF444444);
  static const Color whiteText = Colors.white;

  // 強調色
  static const Color accentPurple = Colors.deepPurple;
  static const Color accentOrange = Colors.deepOrange;

  // 店舗色
  static const Color okazaki = Colors.blue;
  static const Color nagoya = Colors.green;
  static const Color gifu = Colors.purple;

  // ヒートマップ
  static const Color heatmapGreen = Colors.greenAccent;
  static const Color heatmapBlue = Colors.blueAccent;
  static const Color heatmapRed = Colors.redAccent;
}
