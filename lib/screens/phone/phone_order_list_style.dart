import 'package:flutter/material.dart';

/// スマホ版「受注一覧」グループ共通の色（Figmaの値）
class PL {
  PL._();
  static const Color bg = Color(0xFFF4F1FA);
  static const Color border = Color(0xFFE4E7EB);
  static const Color cardBorder = Color(0xFFEDF0F2);
  static const Color ink = Color(0xFF1D1B20);
  static const Color grey = Color(0xFF6B6F76);
  static const Color iconGrey = Color(0xFF9AA0A6);
  static const Color purple = Color(0xFF673AB7);
  static const Color purpleSoft = Color(0xFFEDE7F6);
  static const Color purpleBar = Color(0xFFF6F2FC);
  static const Color red = Color(0xFFF44336);
  static const Color redText = Color(0xFFE53935);
  static const Color redSoft = Color(0xFFFFEBEE);
  static const Color orangeSoft = Color(0xFFFFF3E0);
  static const Color orange = Color(0xFFE65100);
  static const Color blue = Color(0xFF1E88E5);
  static const Color sat = Color(0xFF1E88E5);
  static const Color scrim = Color(0x7A121218);

  static Color branchBg(String n) => n.contains('名古屋') ? const Color(0xFFE8F5E9) : (n.contains('岐阜') ? const Color(0xFFF3E5F5) : const Color(0xFFE3F2FD));
  static Color branchFg(String n) => n.contains('名古屋') ? const Color(0xFF2E7D32) : (n.contains('岐阜') ? const Color(0xFF8E24AA) : const Color(0xFF1565C0));
}
