// Figma node 89:5977 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

const _ink = Color(0xFF1D1B20);
const _grey = Color(0xFF6B6F76);
const _purple = Color(0xFF673AB7);
const _red = Color(0xFFF44336);
const _line = Color(0xFFE4E7EB);
const _sun = Color(0xFFE53935);
const _sat = Color(0xFF1E88E5);
const _dim = Color(0xFFC4C8CD);
const _ring = Color(0xFFFF8A65);

class MobilePickupDatetimeSelect895977 extends StatelessWidget {
  const MobilePickupDatetimeSelect895977({super.key});

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
                ..._step(47, 38, true, '1', '番号確認'),
                ..._step(138, 119, false, '2', '配達先の確定'),
                ..._step(230, 221, false, '3', '注文内容'),
                ..._step(321, 322, false, '4', '完了'),
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
                _t(324, 397, '12', 22, _sat, FontWeight.w700),
                _t(350, 408, '日', 11.5, _sat, FontWeight.w400),
                _r(0, 522, 390, 322, Colors.white, bc: _line),
                _t(16, 532, '入力ダイヤル', 11.5, _grey, FontWeight.w700),
                ..._keys(),
                _r(0, 0, 390, 844, const Color(0x7A121218)),
                _r(0, 253, 390, 591, Colors.white, rad: 22),
                _r(175, 261, 40, 5, const Color(0xFFD4D7DC), rad: 2.5),
                _t(30, 282.5, '引取り日時', 17, _ink, FontWeight.w700),
                _r(344, 274, 36, 36, const Color(0xFFF1F3F5), rad: 18),
                _i(352, 282, Icons.close, 20, _ink),
                _i(18, 322, Icons.chevron_left, 20, _ink),
                _t(151, 322.5, '2026年10月', 16, _ink, FontWeight.w700),
                _i(352, 322, Icons.chevron_right, 20, _ink),
                _t(38.5, 355.5, '日', 11, _sun, FontWeight.w400),
                _t(88.5, 355.5, '月', 11, _grey, FontWeight.w400),
                _t(139.5, 355.5, '火', 11, _grey, FontWeight.w400),
                _t(189.5, 355.5, '水', 11, _grey, FontWeight.w400),
                _t(240.5, 355.5, '木', 11, _grey, FontWeight.w400),
                _t(291.5, 355.5, '金', 11, _grey, FontWeight.w400),
                _t(341.5, 355.5, '土', 11, _sat, FontWeight.w400),
                _r(229, 464, 34, 34, const Color(0xFFDAFFAF), rad: 17),
                _r(279, 464, 34, 34, null, rad: 17, bc: _ring),
                _r(127, 506, 34, 34, null, rad: 17, bc: _ring),
                _r(229, 506, 34, 34, null, rad: 17, bc: _ring),
                _r(127, 548, 34, 34, null, rad: 17, bc: _ring),
                ..._days(389.5, [
                  [36, '27', _sun], [87, '28', _dim], [137, '29', _dim],
                  [188, '30', _dim], [242, '1', _ink], [293, '2', _ink],
                  [343, '3', _sat],
                ]),
                ..._days(431.5, [
                  [40, '4', _sun], [90, '5', _ink], [141, '6', _ink],
                  [191, '7', _ink], [242, '8', _ink], [293, '9', _ink],
                  [339, '10', _sat],
                ]),
                ..._days(473.5, [
                  [36, '11', _sun], [87, '12', _ink], [137, '13', _ink],
                  [289, '16', _ink], [339, '17', _sat],
                ]),
                _t(187.5, 473.5, '14', 13, _red, FontWeight.w900),
                _t(238, 473.5, '15', 13, _ink, FontWeight.w700),
                ..._days(515.5, [
                  [36, '18', _sun], [87, '19', _ink], [137, '20', _ink],
                  [188, '21', _ink], [238, '22', _ink], [289, '23', _ink],
                  [339, '24', _sat],
                ]),
                ..._days(557.5, [
                  [36, '25', _sun], [87, '26', _ink], [137, '27', _ink],
                  [188, '28', _ink], [238, '29', _ink], [289, '30', _ink],
                  [339, '31', _sat],
                ]),
                ..._days(599.5, [
                  [40, '1', _sun], [90, '2', _dim], [141, '3', _dim],
                  [191, '4', _dim], [242, '5', _dim], [293, '6', _dim],
                  [343, '7', _sat],
                ]),
                _r(131, 638, 10, 10, null, rad: 5, bc: _ring),
                _t(145, 635.5, '引取りあり', 11, _grey, FontWeight.w400),
                _r(212, 638, 10, 10, const Color(0xFFDAFFAF), rad: 5),
                _t(226, 635.5, '選択中', 11, _grey, FontWeight.w400),
                _t(20, 665.5, '10/15(木) の引取り 1件', 12, _grey, FontWeight.w700),
                _r(18, 687, 354, 56, Colors.white,
                    rad: 14, bc: const Color(0xFFEDF0F2)),
                _r(19, 688, 352, 54, Colors.white),
                _t(33, 708.5, '12:00', 12, _purple, FontWeight.w700),
                _t(83, 698.5, '高橋 一郎 様', 13, _ink, FontWeight.w700),
                _t(83, 718, '岡崎本店', 11.5, _grey, FontWeight.w400),
                _r(0, 755, 390, 89, null, bc: _line),
                _r(18, 766, 354, 48, _purple, rad: 12),
                _t(165.5, 781.5, '時間設定', 15, Colors.white, FontWeight.w700),
                _r(128, 831, 134, 5, const Color(0xFF111111), rad: 2.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Widget> _days(double y, List<List<Object>> d) {
  return [
    for (final e in d)
      _t((e[0] as num).toDouble(), y, e[1] as String, 13, e[2] as Color,
          FontWeight.w400),
  ];
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

List<Widget> _step(double x, double lx, bool active, String n, String label) {
  const orange = Color(0xFFFF6D00);
  const g = Color(0xFF9AA0A6);
  return [
    if (active) ...[
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
