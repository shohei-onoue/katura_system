// Figma node 89:6728 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

class MobileReceiptPreview896728 extends StatelessWidget {
  const MobileReceiptPreview896728({super.key});

  static const _dark = Color(0xFF1D1B20);
  static const _grey = Color(0xFF6B6F76);
  static const _purple = Color(0xFF673AB7);
  static const _line = Color(0xFFE4E7EB);
  static const _green = Color(0xFF4CAF50);
  static const _orange = Color(0xFFFF6D00);
  static const _selBg = Color(0xFFDAFFAF);
  static const _selBorder = Color(0xFFB9EA80);
  static const _selText = Color(0xFF1D3B00);

  // chip: left, top, width, label, selected
  static List<Widget> _chips(List<List<Object>> items) {
    final out = <Widget>[];
    for (final it in items) {
      final l = it[0] as double;
      final t = it[1] as double;
      final w = it[2] as double;
      final s = it[3] as String;
      final sel = it[4] as bool;
      out.add(
        _r(
          l,
          t,
          w,
          34,
          sel ? _selBg : Colors.white,
          rad: 10,
          bc: sel ? _selBorder : _line,
        ),
      );
      out.add(
        _t(l + 14, t + 9.5, s, 13, sel ? _selText : _dark, FontWeight.w700),
      );
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F7F6),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 390,
            height: 844,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                _r(0, 0, 390, 844, const Color(0xFFF3F7F6)),
                _r(0, 0, 390, 44, Colors.white),
                _t(30, 13.5, '9:41', 15, _dark, FontWeight.w700),
                _i(303, 14, Icons.signal_cellular_alt, 17, _dark),
                _i(325, 14, Icons.wifi, 17, _dark),
                _i(347, 14, Icons.battery_full, 17, _dark),
                _r(0, 44, 390, 52, Colors.white),
                _i(16, 60, Icons.close, 20, _dark),
                _t(52, 59, '受注入力', 18, _dark, FontWeight.w700),
                _t(273, 60.5, '0564-12-3456', 15, _purple, FontWeight.w900),
                _r(0, 96, 390, 59, Colors.white),
                _r(47, 104, 22, 22, _green, rad: 11, bc: _green),
                _i(51, 108, Icons.check, 14, Colors.white),
                _t(38, 130.5, '番号確認', 10, _dark, FontWeight.w500),
                _r(138, 104, 22, 22, _green, rad: 11, bc: _green),
                _i(142, 108, Icons.check, 14, Colors.white),
                _t(119, 130.5, '配達先の確定', 10, _dark, FontWeight.w500),
                _r(230, 104, 22, 22, _green, rad: 11, bc: _green),
                _i(234, 108, Icons.check, 14, Colors.white),
                _t(221, 130.5, '注文内容', 10, _dark, FontWeight.w500),
                _r(321, 104, 22, 22, _orange, rad: 11, bc: _orange),
                _t(329, 108.5, '4', 11, Colors.white, FontWeight.w700),
                _t(322, 130.5, '完了', 10, _orange, FontWeight.w700),
                _r(14, 167, 362, 541, Colors.white, rad: 14, bc: const Color(0xFFEDF0F2)),
                _r(15, 168, 360, 37, _purple),
                _t(29, 178.5, '梱包・確認設定', 13, Colors.white, FontWeight.w700),
                _t(29, 218, '梱包方法', 11.5, _grey, FontWeight.w700),
                ..._chips([
                  [29.0, 238.0, 67.0, '個包装', true],
                  [102.0, 238.0, 54.0, '紙袋', false],
                  [162.0, 238.0, 93.0, 'ダンボール', false],
                  [261.0, 238.0, 67.0, '小分け', false],
                  [29.0, 278.0, 67.0, 'その他', false],
                ]),
                _r(29, 324, 332, 1, _line),
                _t(29, 338, '事前連絡', 11.5, _grey, FontWeight.w700),
                ..._chips([
                  [29.0, 358.0, 80.0, '受電番号', false],
                  [137.0, 358.0, 54.0, '電話', false],
                ]),
                _t(117, 368, 'に', 11.5, _dark, FontWeight.w400),
                _t(199, 368, 'で連絡する', 11.5, _dark, FontWeight.w400),
                _r(29, 400, 174, 44, const Color(0xFFF6F7F9), rad: 10, bc: _line),
                _t(42, 412.5, '0564-12-3456', 16, _dark, FontWeight.w700),
                _r(211, 400, 150, 44, const Color(0xFFF6F7F9), rad: 10, bc: _line),
                _i(224, 413, Icons.event, 18, _purple),
                _t(250, 413.5, '10/14 15:00', 14, _purple, FontWeight.w700),
                _t(29, 455, '受取人の指定', 11.5, _grey, FontWeight.w700),
                ..._chips([
                  [29.0, 475.0, 67.0, 'ご本人', true],
                  [102.0, 475.0, 54.0, '指定', false],
                ]),
                _r(164, 475, 197, 34, const Color(0xFFF6F7F9), rad: 10, bc: _line),
                _t(177, 483.5, '青木 一郎', 14, _dark, FontWeight.w400),
                _r(29, 521, 332, 1, _line),
                _t(29, 535, '書類を選択', 11.5, _grey, FontWeight.w700),
                _t(263, 535, '領収書プレビュー ›', 11.5, _orange, FontWeight.w700),
                ..._chips([
                  [29.0, 556.0, 67.0, '領収書', true],
                  [102.0, 556.0, 67.0, '請求書', false],
                  [175.0, 556.0, 80.0, 'レシート', false],
                  [261.0, 556.0, 67.0, '納品書', false],
                  [29.0, 596.0, 93.0, '印字領収書', false],
                ]),
                _t(29, 641, '支払い方法', 11.5, _grey, FontWeight.w700),
                ..._chips([
                  [29.0, 661.0, 54.0, '現金', true],
                  [89.0, 661.0, 67.0, 'カード', false],
                ]),
                _t(16, 723.5, '最終確認', 12, _grey, FontWeight.w700),
                _r(14, 745, 362, 149, Colors.white, rad: 14, bc: const Color(0xFFEDF0F2)),
                _r(15, 746, 360, 49, Colors.white),
                _i(29, 760, Icons.inventory_2, 20, _purple),
                _t(59, 763, '梱包方法', 11.5, _grey, FontWeight.w400),
                _t(313, 760.5, '個包装', 16, _dark, FontWeight.w700),
                _r(15, 795, 360, 45, Colors.white),
                _i(29, 807, Icons.notifications_active, 20, const Color(0xFF1E88E5)),
                _t(59, 810, '事前連絡', 11.5, _grey, FontWeight.w400),
                _t(191, 810, '青木 一郎 ・ 電話 ・ 10/14 15:00', 11.5, _dark, FontWeight.w700),
                _r(15, 840, 360, 53, const Color(0xFFFFF5F2)),
                _r(0, 757, 390, 87, Colors.white, bc: _line),
                _r(14, 768, 176, 48, const Color(0xFFF44336), rad: 12),
                _t(72.5, 783.5, '注文中止', 15, Colors.white, FontWeight.w700),
                _r(200, 768, 176, 48, _purple, rad: 12),
                _t(273.5, 783.5, '確定', 15, Colors.white, FontWeight.w700),
                _r(0, 0, 390, 844, const Color(0x7A121218)),
                _r(0, 44, 390, 800, Colors.white, rad: 16),
                _r(175, 52, 40, 5, const Color(0xFFD4D7DC), rad: 2.5),
                _t(30, 73.5, '領収書プレビュー No.0001', 17, _dark, FontWeight.w700),
                _r(344, 65, 36, 36, const Color(0xFFF1F3F5), rad: 18),
                _i(352, 73, Icons.close, 20, _dark),
                _r(18, 111, 354, 312, const Color(0xFFECEFF1), rad: 12),
                _r(32, 125, 326, 284, Colors.white),
                _t(152.5, 148.5, '領収書', 22, _dark, FontWeight.w700, ls: 10),
                _t(50, 195, '株式会社アオキ', 14, _dark, FontWeight.w400),
                _t(152, 197, '御中', 11.5, _dark, FontWeight.w400),
                _t(250, 190, 'No. 0001', 11.5, _dark, FontWeight.w400),
                _t(250, 203, '発行日 2026/10/14', 11.5, _dark, FontWeight.w400),
                _t(130, 237.5, '金額 ¥6,000-', 22, _dark, FontWeight.w700),
                _t(62, 277, '但 特製ステーキ弁当2個分 / 厳選牛ステーキ重1個分', 11.5, _dark, FontWeight.w400),
                _t(120, 298, '上記正に領収いたしました。', 11.5, _dark, FontWeight.w400),
                _t(201, 333, '株式会社OLDROOKIE 岡崎', 11.5, _dark, FontWeight.w400),
                _t(185, 352, '愛知県岡崎市康生通西4丁目71', 11.5, _dark, FontWeight.w400),
                _t(251, 370, 'TEL 0564-00-0000', 11.5, _dark, FontWeight.w400),
                _r(0, 755, 390, 89, null, bc: _line),
                _r(18, 766, 173, 48, Colors.white, rad: 12, bc: _line),
                _t(82.5, 781.5, '閉じる', 15, _dark, FontWeight.w700),
                _r(201, 766, 171, 48, _purple, rad: 12),
                _i(258, 780, Icons.print, 20, Colors.white),
                _t(284.5, 781.5, '印刷', 15, Colors.white, FontWeight.w700),
                _r(128, 831, 134, 5, const Color(0xFF111111), rad: 2.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _r(
  double l,
  double t,
  double w,
  double h,
  Color? c, {
  double rad = 0,
  Color? bc,
}) {
  return Positioned(
    left: l,
    top: t,
    width: w,
    height: h,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(rad),
        border: bc == null ? null : Border.all(color: bc),
      ),
    ),
  );
}

Widget _t(
  double l,
  double t,
  String s,
  double size,
  Color c,
  FontWeight w, {
  double? width,
  double? ls,
}) {
  return Positioned(
    left: l,
    top: t,
    width: width,
    child: Text(
      s,
      softWrap: width != null,
      style: TextStyle(
        fontSize: size,
        color: c,
        fontWeight: w,
        letterSpacing: ls,
        height: 1.0,
        decoration: TextDecoration.none,
      ),
    ),
  );
}

Widget _i(double l, double t, IconData i, double size, Color c) {
  return Positioned(
    left: l,
    top: t,
    child: Icon(i, size: size, color: c),
  );
}
