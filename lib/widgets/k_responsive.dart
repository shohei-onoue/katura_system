import 'package:flutter/material.dart';

/// 画面全体を比率ベースで拡大縮小するためのユーティリティ
class KR {
  /// 基準とする画面寸法 (iPad Pro 11インチなどの横幅を想定)
  static const double baseWidth = 1280.0;
  static const double baseHeight = 832.0;
  
  /// 現在の画面幅に基づくスケーリング係数を取得
  static double scale(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / baseWidth;
  }

  /// 現在の画面高さに基づくスケーリング係数を取得
  static double hScale(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return screenHeight / baseHeight;
  }

  /// レスポンシブなフォントサイズを計算 (幅基準)
  static double rf(BuildContext context, double baseFontSize) {
    double s = scale(context);
    return (baseFontSize * s).clamp(4.0, 500.0);
  }

  /// レスポンシブな寸法（パディング、マージン、アイコンサイズ、高さ）を計算 (幅基準)
  static double rs(BuildContext context, double baseSize) {
    return baseSize * scale(context);
  }

  /// レスポンシブな寸法を計算 (高さ基準)
  static double rh(BuildContext context, double baseSize) {
    return baseSize * hScale(context);
  }

  /// 縦横の小さい方を基準にする適応型サイズ
  static double rav(BuildContext context, double baseSize) {
    double s = scale(context);
    double hs = hScale(context);
    return baseSize * (s < hs ? s : hs);
  }

  /// 画面幅に対する割合 (0.0 to 1.0)
  static double wp(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * percent;
  }

  /// 画面高さに対する割合 (0.0 to 1.0)
  static double hp(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * percent;
  }

  // --- 標準フォントサイズ定義 ---
  static double fontTiny(BuildContext context) => rf(context, 11);
  static double fontSmall(BuildContext context) => rf(context, 13);
  static double fontMedium(BuildContext context) => rf(context, 15);
  static double fontLarge(BuildContext context) => rf(context, 18);
  static double fontXLarge(BuildContext context) => rf(context, 24);
  static double fontHuge(BuildContext context) => rf(context, 48);

  // --- 共通カラー定義 ---
  static const Color backgroundLight = Color(0xFFF3F7F6);
  static const Color cardBorder = Color(0xFFE0E0E4);

  /// ボタン・選択肢の標準色（主要アクション）
  static const Color primaryColor = Colors.deepPurple;

  /// 入力フィールド・選択肢グループ・ボタンなど、1行の操作コンポーネントの標準高さ
  static const double fieldHeight = 50.0;
}

/// 標準フィールド高さ（レスポンシブ換算済み）
double kFieldHeight(BuildContext context) => KR.rs(context, KR.fieldHeight);

/// ステップタイトルバー(KStepper)とサイドバー見出し帯の共通高さ。
/// rav はスマホ幅だと極端に縮みタップ領域が不足するため 48 を下限にクランプする。
/// 両者でこの関数を使うことで、下のコンテンツのY位置が揃う。
double kStepBarHeight(BuildContext context) =>
    KR.rav(context, 56).clamp(48.0, 160.0);

/// 短縮関数
double rf(BuildContext context, double baseSize) => KR.rf(context, baseSize);
double rs(BuildContext context, double baseSize) => KR.rs(context, baseSize);
double rh(BuildContext context, double baseSize) => KR.rh(context, baseSize);
double rav(BuildContext context, double baseSize) => KR.rav(context, baseSize);
double wp(BuildContext context, double percent) => KR.wp(context, percent);
double hp(BuildContext context, double percent) => KR.hp(context, percent);
