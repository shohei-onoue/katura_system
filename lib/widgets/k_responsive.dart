import 'package:flutter/material.dart';

/// 画面全体を比率ベースで拡大縮小するためのユーティリティ
class KR {
  /// 基準とする画面幅 (iPad Pro 11インチなどの横幅を想定)
  static const double baseWidth = 1280.0;
  
  /// 現在の画面幅に基づくスケーリング係数を取得
  static double scale(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / baseWidth;
  }

  /// レスポンシブなフォントサイズを計算
  static double rf(BuildContext context, double baseFontSize) {
    double s = scale(context);
    return (baseFontSize * s).clamp(4.0, 500.0);
  }

  /// レスポンシブな寸法（パディング、マージン、アイコンサイズ、高さ）を計算
  static double rs(BuildContext context, double baseSize) {
    return baseSize * scale(context);
  }

  // --- 標準フォントサイズ定義 ---
  static double fontTiny(BuildContext context) => rf(context, 11);
  static double fontSmall(BuildContext context) => rf(context, 13);
  static double fontMedium(BuildContext context) => rf(context, 15);
  static double fontLarge(BuildContext context) => rf(context, 18);
  static double fontXLarge(BuildContext context) => rf(context, 24);
  static double fontHuge(BuildContext context) => rf(context, 48);

  // --- 共通カラー定義 ---
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color cardBorder = Color(0xFFE0E0E4);
}

/// 短縮関数
double rf(BuildContext context, double baseSize) => KR.rf(context, baseSize);
double rs(BuildContext context, double baseSize) => KR.rs(context, baseSize);
