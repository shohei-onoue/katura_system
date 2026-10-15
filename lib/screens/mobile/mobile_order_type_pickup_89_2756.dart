// Figma node 89:2756 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

const _ink = Color(0xFF1D1B20);
const _grey = Color(0xFF6B6F76);
const _purple = Color(0xFF673AB7);
const _red = Color(0xFFF44336);
const _line = Color(0xFFE4E7EB);

class MobileOrderTypePickup892756 extends StatelessWidget {
  const MobileOrderTypePickup892756({super.key});

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
                _r(0, 96, 390, 59, Colors.white),
                ..._step(47, 38, 1, '1', '番号確認'),
                ..._step(138, 119, 2, '2', '配達先の確定'),
                ..._step(230, 221, 2, '3', '注文内容'),
                ..._step(321, 322, 2, '4', '完了'),
                _r(14, 167, 362, 173, Colors.white,
                    rad: 14, bc: const Color(0xFFEDF0F2)),
                _r(15, 168, 360, 37, _purple),
                _t(29, 178.5, 'お客様電話番号', 13, Colors.white, FontWeight.w700),
                _t(67, 225.5, '0564-12-3456', 36, _red, FontWeight.w900, ls: 1),
                _r(29, 285, 162, 38, _red, rad: 10),
                _t(84.5, 296.5, '受注中止', 13, Colors.white, FontWeight.w700),
                _r(199, 285, 162, 38, _purple, rad: 10),
                _t(254.5, 296.5, '日程調整', 13, Colors.white, FontWeight.w700),
                _t(16, 355.5, '選択中の顧客', 12, _grey, FontWeight.w700),
                _r(14, 377, 362, 66, const Color(0xFFDAFFAF),
                    rad: 14, bc: const Color(0xFFB9EA80)),
                _t(29, 391.5, '株式会社アオキ / 青木 一郎 様', 15, _ink, FontWeight.w900),
                _t(29, 412.5, '0564-12-3456', 13, _red, FontWeight.w700),
                _t(280, 409.5, '前回から', 10, _grey, FontWeight.w400),
                _t(324, 397, '12', 22, const Color(0xFF1E88E5), FontWeight.w700),
                _t(350, 408, '日', 11.5, const Color(0xFF1E88E5), FontWeight.w400),
                _r(0, 522, 390, 322, Colors.white, bc: _line),
                _t(16, 532, '入力ダイヤル', 11.5, _grey, FontWeight.w700),
                ..._keys(),
                _r(0, 0, 390, 844, const Color(0x7A121218)),
                _r(0, 613, 390, 231, Colors.white, rad: 22),
                _r(175, 621, 40, 5, const Color(0xFFD4D7DC), rad: 2.5),
                _t(30, 642.5, '受注区分', 17, _ink, FontWeight.w700),
                _r(344, 634, 36, 36, const Color(0xFFF1F3F5), rad: 18),
                _i(352, 642, Icons.close, 20, _ink),
                _t(18, 681, '受け渡し方法', 11.5, _grey, FontWeight.w700),
                _r(18, 701, 354, 42, const Color(0xFFECEFF1), rad: 12),
                _t(95, 714.5, '配達', 13, _grey, FontWeight.w700),
                _r(195, 704, 174, 36, const Color(0xFFDAFFAF), rad: 10),
                _t(262, 714.5, '引取り', 13, const Color(0xFF1D3B00),
                    FontWeight.w700),
                _r(0, 755, 390, 89, null, bc: _line),
                _r(18, 766, 173, 48, Colors.white, rad: 12, bc: _line),
                _t(67.5, 781.5, 'キャンセル', 15, _ink, FontWeight.w700),
                _r(201, 766, 171, 48, _purple, rad: 12),
                _t(271.5, 781.5, '次へ', 15, Colors.white, FontWeight.w700),
                _r(128, 831, 134, 5, const Color(0xFF111111), rad: 2.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Widget> _keys() {
  const xs = [14.0, 138.0, 261.0];
  const tx = [64.0, 188.0, 312.0];
  const ys = [559.0, 624.0, 689.0, 754.0];
  final w = <Widget>[];
  for (var r = 0; r < 3; r++) {
    for (var c = 0; c < 3; c++) {
      w.add(_r(xs[c], ys[r], 115, 56, const Color(0xFF2E3440), rad: 14));
      w.add(_t(tx[c], ys[r] + 14, '${r * 3 + c + 1}', 24, Colors.white,
          FontWeight.w700));
    }
  }
  w.add(_r(14, 754, 115, 56, const Color(0xFF6C737E), rad: 14));
  w.add(_t(49, 773.5, 'クリア', 15, Colors.white, FontWeight.w700));
  w.add(_r(138, 754, 115, 56, const Color(0xFF2E3440), rad: 14));
  w.add(_t(188, 768, '0', 24, Colors.white, FontWeight.w700));
  w.add(_r(261, 754, 115, 56, const Color(0xFF6C737E), rad: 14));
  w.add(_i(307, 770, Icons.backspace, 24, Colors.white));
  return w;
}

// state 0=done, 1=active, 2=inactive
List<Widget> _step(double x, double lx, int state, String n, String label) {
  const orange = Color(0xFFFF6D00);
  const g = Color(0xFF9AA0A6);
  return [
    if (state == 1) ...[
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

Widget _r(double l, double t, double w, double h, Color? c,
    {double rad = 0, Color? bc}) {
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
