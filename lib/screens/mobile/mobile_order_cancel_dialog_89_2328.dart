// Figma node 89:2328 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

const _ink = Color(0xFF1D1B20);
const _grey = Color(0xFF6B6F76);
const _purple = Color(0xFF673AB7);
const _line = Color(0xFFE4E7EB);

class MobileOrderCancelDialog892328 extends StatelessWidget {
  const MobileOrderCancelDialog892328({super.key});

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
                _t(30, 13.5, '9:41', 15, _ink, FontWeight.w700),
                _i(303, 14, Icons.signal_cellular_alt, 17, _ink),
                _i(325, 14, Icons.wifi, 17, _ink),
                _i(347, 14, Icons.battery_full, 17, _ink),
                _r(0, 44, 390, 52, Colors.white),
                _i(16, 60, Icons.close, 20, _ink),
                _t(52, 59, '受注入力', 18, _ink, FontWeight.w700),
                _t(273, 60.5, '0564-12-3456', 15, _purple, FontWeight.w900),
                _r(0, 96, 390, 59, Colors.white),
                ..._step(47, 38, 0, '1', '番号確認'),
                ..._step(138, 119, 0, '2', '配達先の確定'),
                ..._step(230, 221, 1, '3', '注文内容'),
                ..._step(321, 322, 2, '4', '完了'),
                _r(14, 165, 145, 34, const Color(0xFFDAFFAF),
                    rad: 10, bc: const Color(0xFFB9EA80)),
                _t(28, 174.5, '厳選牛ステーキ弁当', 13,
                    const Color(0xFF1D3B00), FontWeight.w700),
                _r(165, 165, 80, 34, Colors.white, rad: 10, bc: _line),
                _t(179, 174.5, '高級弁当', 13, _ink, FontWeight.w700),
                _r(251, 165, 93, 34, Colors.white, rad: 10, bc: _line),
                _t(265, 174.5, 'オードブル', 13, _ink, FontWeight.w700),
                _r(350, 165, 67, 34, Colors.white, rad: 10, bc: _line),
                _t(364, 174.5, '丼もの', 13, _ink, FontWeight.w700),
                _r(423, 165, 67, 34, Colors.white, rad: 10, bc: _line),
                _t(437, 174.5, 'ギフト', 13, _ink, FontWeight.w700),
                ..._card(14, 211, true, '特製ステーキ弁当', '¥1,800', '2', true),
                ..._card(200, 211, true, '厳選牛ステーキ重', '¥2,400', '1', false),
                ..._card(14, 397, false, 'ステーキ弁当 大盛', '¥2,800', '0', false),
                ..._card(200, 397, false, 'ステーキ弁当 並', '¥1,500', '0', false),
                _r(0, 720, 390, 124, Colors.white, rad: 18, bc: _line),
                _i(14, 736, Icons.shopping_cart, 20, _purple),
                _t(42, 737.5, 'カートの中身', 13, _ink, FontWeight.w700),
                _r(128, 736, 31, 19, const Color(0xFFEDE7F6), rad: 6),
                _t(135, 739, '2品', 10.5, _purple, FontWeight.w700),
                _t(223, 739, '合計 3個', 11.5, _grey, FontWeight.w400),
                _t(283, 733.5, '¥6,000', 20, const Color(0xFFF44336),
                    FontWeight.w700),
                _i(356, 736, Icons.expand_less, 20, const Color(0xFF9AA0A6)),
                _r(14, 768, 178, 48, Colors.white, rad: 12, bc: _line),
                _i(93, 782, Icons.delete_outline, 20, _ink),
                _r(200, 768, 176, 48, _purple, rad: 12),
                _t(220.5, 783.5, '注文内容を確定する', 15, Colors.white,
                    FontWeight.w700),
                _r(0, 0, 390, 844, const Color(0x7A121218)),
                _r(28, 313, 334, 218, Colors.white, rad: 22),
                _r(169, 335, 52, 52, const Color(0xFFFFEBEE), rad: 26),
                _i(181, 347, Icons.logout, 28, const Color(0xFFF44336)),
                _t(93.5, 399.5, '注文入力を中止しますか？', 17, _ink, FontWeight.w700),
                _t(105.5, 431.5, '入力中の内容は破棄されます。', 13, _grey, FontWeight.w400),
                _r(48, 469, 143, 46, Colors.white, rad: 12, bc: _line),
                _t(106.5, 483.5, '戻る', 14, _ink, FontWeight.w700),
                _r(201, 469, 141, 46, const Color(0xFFF44336), rad: 12),
                _t(244.5, 483.5, '中止する', 14, Colors.white, FontWeight.w700),
                _r(128, 831, 134, 5, const Color(0xFF111111), rad: 2.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// state 0=done, 1=active, 2=inactive
List<Widget> _step(double x, double lx, int state, String n, String label) {
  const green = Color(0xFF4CAF50);
  const orange = Color(0xFFFF6D00);
  const g = Color(0xFF9AA0A6);
  return [
    if (state == 0) ...[
      _r(x, 104, 22, 22, green, rad: 11, bc: green),
      _i(x + 4, 108, Icons.check, 14, Colors.white),
      _t(lx, 130.5, label, 10, _ink, FontWeight.w500),
    ] else if (state == 1) ...[
      _r(x, 104, 22, 22, orange, rad: 11, bc: orange),
      _t(x + 8, 108.5, n, 11, Colors.white, FontWeight.w700),
      _t(lx, 130.5, label, 10, orange, FontWeight.w700),
    ] else ...[
      _r(x, 104, 22, 22, Colors.white, rad: 11, bc: const Color(0xFFCFD3D8)),
      _t(x + 8, 108.5, n, 11, g, FontWeight.w700),
      _t(lx, 130.5, label, 10, g, FontWeight.w500),
    ],
  ];
}

List<Widget> _card(double x, double y, bool sel, String name, String price,
    String qty, bool badge) {
  final k = sel ? 0.0 : -1.0;
  final qc = qty == '0' ? _ink : _purple;
  return [
    if (sel)
      _r(x, y, 176, 176, Colors.white, rad: 14, bc: _purple, bw: 2)
    else
      _r(x, y, 176, 174, Colors.white, rad: 14, bc: const Color(0xFFEDF0F2)),
    _r(x + (sel ? 2 : 1), y + (sel ? 2 : 1), sel ? 172 : 174, 84,
        const Color(0xFFEEF0F2)),
    _i(x + 73, y + 29 + k, Icons.restaurant, 30, const Color(0xFFB5BAC0)),
    if (badge) ...[
      _r(x + 8, y + 8, 56, 19, const Color(0xFFFF7043), rad: 6),
      _t(x + 15, y + 11, '前回注文', 10.5, Colors.white, FontWeight.w700),
    ],
    _t(x + 12 + k, y + 95.5 + k, name, 13, _ink, FontWeight.w700),
    _t(x + 12 + k, y + 114.5 + k, price, 13, const Color(0xFFF44336),
        FontWeight.w700),
    _r(x + 12 + k, y + 138 + k, 28, 28, null, rad: 14, bc: _line),
    _i(x + 18 + k, y + 144 + k, Icons.remove, 16, _ink),
    _t(x + 84, y + 143.5 + k, qty, 15, qc, FontWeight.w700),
    _r(x + 136 - k, y + 138 + k, 28, 28, _purple, rad: 14),
    _i(x + 142 - k, y + 144 + k, Icons.add, 16, Colors.white),
  ];
}

Widget _r(double l, double t, double w, double h, Color? c,
    {double rad = 0, Color? bc, double bw = 1}) {
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

Widget _t(double l, double t, String s, double size, Color c, FontWeight w,
    {double? ls}) {
  return Positioned(
    left: l,
    top: t,
    child: Text(
      s,
      softWrap: false,
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
  return Positioned(left: l, top: t, child: Icon(i, size: size, color: c));
}
