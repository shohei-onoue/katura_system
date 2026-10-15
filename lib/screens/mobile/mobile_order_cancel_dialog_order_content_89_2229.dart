// Figma node 89:2229 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

class MobileOrderCancelDialogOrderContent892229 extends StatelessWidget {
  const MobileOrderCancelDialogOrderContent892229({super.key});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1D1B20);
    const gray = Color(0xFF6B6F76);
    const lgray = Color(0xFF9AA0A6);
    const purple = Color(0xFF673AB7);
    const red = Color(0xFFF44336);
    const w = Colors.white;
    const bold = FontWeight.w700;
    const reg = FontWeight.w400;
    const imgBg = Color(0xFFEEF0F2);
    const imgIc = Color(0xFFB5BAC0);
    const line = Color(0xFFE4E7EB);

    Widget done(double x, double lx, String s) {
      return Stack(
        children: [
          _r(x, 104, 22, 22, Color(0xFF4CAF50),
              rad: 11, bc: Color(0xFF4CAF50)),
          _i(x + 4, 108, Icons.check, 14, w),
          _t(lx, 130.5, s, 10, dark, FontWeight.w500),
        ],
      );
    }

    Widget chip(double x, double wd, double tx, String s, bool on) {
      return Stack(
        children: [
          _r(x, 165, wd, 34, on ? Color(0xFFDAFFAF) : w,
              rad: 10, bc: on ? Color(0xFFB9EA80) : line),
          _t(tx, 174.5, s, 13, on ? Color(0xFF1D3B00) : dark, bold),
        ],
      );
    }

    Widget stepper(double x, double y, double nx, String n, double ax,
        {bool active = false}) {
      return Stack(
        children: [
          _r(x, y, 28, 28, null, rad: 14, bc: line),
          _i(x + 6, y + 6, Icons.remove, 16, dark),
          _t(nx, y + 5.5, n, 15, active ? purple : dark, bold),
          _r(ax, y, 28, 28, purple, rad: 14),
          _i(ax + 6, y + 6, Icons.add, 16, w),
        ],
      );
    }

    Widget card(double x, double y, double wd, double h, double cw, String name,
        String price, String n, double nx,
        {bool selected = false}) {
      return Stack(
        children: [
          _r(x, y, wd, h, w,
              rad: 14,
              bc: selected ? purple : Color(0xFFEDF0F2),
              bw: selected ? 2 : 1),
          _r(x + (selected ? 2 : 1), y + (selected ? 2 : 1), cw, 84, imgBg),
          _i(x + 73, y + 29, Icons.restaurant, 30, imgIc),
          _t(x + 12, y + 95.5, name, 13, dark, bold),
          _t(x + 12, y + 114.5, price, 13, red, bold),
          stepper(x + 12, y + 138, nx, n, x + (selected ? 136 : 138),
              active: selected),
        ],
      );
    }

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
                _r(0, 0, 390, 844, Color(0xFFF3F7F6)),
                _r(0, 0, 390, 44, w),
                _t(30, 13.5, '9:41', 15, dark, bold),
                _i(303, 14, Icons.signal_cellular_alt, 17, dark),
                _i(325, 14, Icons.wifi, 17, dark),
                _i(347, 14, Icons.battery_full, 17, dark),
                _r(0, 44, 390, 52, w),
                _i(16, 60, Icons.close, 20, dark),
                _t(52, 59, '受注入力', 18, dark, bold),
                _t(273, 60, '0564-12-3456', 15, purple, FontWeight.w900),
                _r(0, 96, 390, 59, w),
                done(47, 38, '番号確認'),
                done(138, 119, '配達先の確定'),
                _r(230, 104, 22, 22, Color(0xFFFF6D00),
                    rad: 11, bc: Color(0xFFFF6D00)),
                _t(238, 108.5, '3', 11, w, bold),
                _t(221, 130.5, '注文内容', 10, Color(0xFFFF6D00), bold),
                _r(321, 104, 22, 22, w, rad: 11, bc: Color(0xFFCFD3D8)),
                _t(329, 108.5, '4', 11, lgray, bold),
                _t(322, 130.5, '完了', 10, lgray, FontWeight.w500),
                chip(14, 145, 28, '厳選牛ステーキ弁当', true),
                chip(165, 80, 179, '高級弁当', false),
                chip(251, 93, 265, 'オードブル', false),
                chip(350, 67, 364, '丼もの', false),
                chip(423, 67, 437, 'ギフト', false),
                card(14, 211, 176, 176, 172, '特製ステーキ弁当', '¥1,800', '2', 98,
                    selected: true),
                card(200, 211, 176, 176, 172, '厳選牛ステーキ重', '¥2,400', '1', 284,
                    selected: true),
                card(14, 397, 176, 174, 174, 'ステーキ弁当 大盛', '¥2,800', '0', 98),
                card(200, 397, 176, 174, 174, 'ステーキ弁当 並', '¥1,500', '0', 284),
                _r(22, 219, 56, 19, Color(0xFFFF7043), rad: 6),
                _t(29, 222, '前回注文', 10.5, w, bold),
                _r(0, 720, 390, 124, w, rad: 18, bc: line),
                _i(14, 736, Icons.shopping_cart, 20, purple),
                _t(42, 737.5, 'カートの中身', 13, dark, bold),
                _r(128, 736, 31, 19, Color(0xFFEDE7F6), rad: 6),
                _t(135, 739, '2品', 10.5, purple, bold),
                _t(223, 739, '合計 3個', 11.5, gray, reg),
                _t(283, 733.5, '¥6,000', 20, red, bold),
                _i(356, 736, Icons.expand_less, 20, lgray),
                _r(14, 768, 178, 48, w, rad: 12, bc: line),
                _i(93, 782, Icons.delete_outline, 20, dark),
                _r(200, 768, 176, 48, purple, rad: 12),
                _t(220.5, 783.5, '注文内容を確定する', 15, w, bold),
                _r(0, 0, 390, 844, Color(0x7A121218)),
                _r(28, 313, 334, 218, w, rad: 22),
                _r(169, 335, 52, 52, Color(0xFFFFEBEE), rad: 26),
                _i(181, 347, Icons.remove_shopping_cart, 28, red),
                _t(110.5, 399.5, '注文を中止しますか？', 17, dark, bold),
                _t(105.5, 431.5, '入力中の内容は破棄されます。', 13, gray, reg),
                _r(48, 469, 143, 46, w, rad: 12, bc: line),
                _t(85.5, 483.5, '入力に戻る', 14, dark, bold),
                _r(201, 469, 141, 46, red, rad: 12),
                _t(223.5, 483.5, '注文キャンセル', 14, w, bold),
                _r(128, 831, 134, 5, Color(0xFF111111), rad: 2.5),
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
  double bw = 1,
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
        border: bc == null ? null : Border.all(color: bc, width: bw),
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
