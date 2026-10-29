import 'package:flutter/material.dart';
import 'package:katura_system/utils/device_mode.dart';

/// スマホ横向き(画面が横長 かつ スマホ版)か。縦向き/PC/タブレットは false。
bool isPhoneLandscape(BuildContext context) {
  final s = MediaQuery.of(context).size;
  return isPhoneMode(context) && s.width > s.height;
}

/// スマホ横向き専用の色・寸法（Figma 168:6 の実値）。縦向きでは使わない。
class LS {
  LS._();
  static const primary = Color(0xFF5E35B1);
  static const orange = Color(0xFFC43E00);
  static const red = Color(0xFFD32F2F);
  static const green = Color(0xFF2E7D32);
  static const amberText = Color(0xFFFFD180);
  static const badgeOrangeText = Color(0xFF3E2200);
  static const bg = Color(0xFFF4F1FA);
  static const lilac = Color(0xFFF3EDFB);
  static const lilac2 = Color(0xFFEDE7F6);
  static const primary2 = Color(0xFF7E57C2);
  static const text = Color(0xFF14121A);
  static const textSub = Color(0xFF44474E);
  static const hint = Color(0xFF6B6F76);
  static const blue = Color(0xFF0D47A1);
  static const blueBg = Color(0xFFD6E9FF);
  static const gifuBg = Color(0xFFEAD3F2);
  static const gifuText = Color(0xFF5E1B7A);
  static const redBg = Color(0xFFFFEBEE);
  static const borderStrong = Color(0xFFD5D9DE);
  static const border = Color(0xFFDDE1E6);
  static const chipOff = Color(0xFFE3E7EA);
  static const inputBg = Color(0xFFF6F7F9);
  static const mapBg = Color(0xFFE8EEF4);
  static const overlay = Color(0x8C121218);
  static const navSelectedBg = Color(0x38FFFFFF);

  static const double navWidth = 104;
  static const double headerH = 56;
  static const double pad = 16;
  static const double gap = 12;
  static const double btnH = 56;
  static const double btnRadius = 14;
  static const double cardRadius = 14;
  static const double panelRadius = 16;
}
