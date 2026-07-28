import 'package:flutter/material.dart';

/// 画面全体を比率ベースで拡大縮小するためのユーティリティ
class KR {
  /// 基準とする画面幅 (iPad Pro 11インチなどの横幅を想定)
  static const double baseWidth = 1280.0;
  
  /// 現在の画面幅に基づくスケーリング係数を取得
  static double scale(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // 制限を外して「同じ比率」を優先 (極端なサイズでも比率を維持)
    return screenWidth / baseWidth;
  }

  /// レスポンシブなフォントサイズを計算
  static double rf(BuildContext context, double baseFontSize) {
    double s = scale(context);
    // 文字が消えないよう、最低 4px 程度は維持
    return (baseFontSize * s).clamp(4.0, 500.0);
  }

  /// レスポンシブな寸法（パディング、マージン、アイコンサイズ、高さ）を計算
  static double rs(BuildContext context, double baseSize) {
    return baseSize * scale(context);
  }
}

/// 短縮関数
double rf(BuildContext context, double baseSize) => KR.rf(context, baseSize);
double rs(BuildContext context, double baseSize) => KR.rs(context, baseSize);
