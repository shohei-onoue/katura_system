import 'package:flutter/material.dart';

Color _h(int v) => Color(0xFF000000 | v);

Widget _r(
  double l,
  double t,
  double w,
  double h,
  Color? c, {
  double r = 0,
  Color? b,
  bool top = false,
}) => Positioned(
  left: l,
  top: t,
  width: w,
  height: h,
  child: DecoratedBox(
    decoration: BoxDecoration(
      color: c,
      borderRadius: top
          ? BorderRadius.vertical(top: Radius.circular(r))
          : BorderRadius.circular(r),
      border: b == null ? null : Border.all(color: b, width: 1),
    ),
  ),
);

Widget _t(
  String s,
  double l,
  double t,
  double sz,
  Color c, {
  int w = 400,
  double? width,
  double ls = 0,
}) => Positioned(
  left: l,
  top: t,
  width: width,
  child: Text(
    s,
    softWrap: width != null,
    maxLines: width != null ? null : 1,
    style: TextStyle(
      fontSize: sz,
      color: c,
      fontWeight: FontWeight.values[w ~/ 100 - 1],
      letterSpacing: ls,
      decoration: TextDecoration.none,
    ),
  ),
);

Widget _i(IconData ic, double l, double t, double sz, Color c) => Positioned(
  left: l,
  top: t,
  child: Icon(ic, size: sz, color: c),
);

List<Widget> _chrome(String title, {IconData lead = Icons.menu}) => [
  _r(0, 0, 390, 844, _h(0xf3f7f6)),
  _r(0, 0, 390, 44, _h(0xffffff)),
  _t('9:41', 30, 13.5, 15, _h(0x1d1b20), w: 700),
  _i(Icons.signal_cellular_alt, 303, 14, 17, _h(0x1d1b20)),
  _i(Icons.wifi, 325, 14, 17, _h(0x1d1b20)),
  _i(Icons.battery_full, 347, 14, 17, _h(0x1d1b20)),
  _r(0, 44, 390, 52, _h(0xffffff)),
  _i(lead, 16, 60, 20, _h(0x1d1b20)),
  _t(title, 52, 59, 18, _h(0x1d1b20), w: 700),
];

Widget _indicator() => _r(128, 831, 134, 5, _h(0x111111), r: 2.5);

List<Widget> _nav(int active) {
  const icons = [
    Icons.post_add,
    Icons.list_alt,
    Icons.local_shipping,
    Icons.people,
    Icons.apps,
  ];
  const labels = ['受注入力', '受注一覧', '配送予定', '顧客', 'メニュー'];
  const il = [32.0, 109.0, 185.0, 261.0, 338.0];
  const tl = [21.0, 98.0, 174.0, 261.0, 327.0];
  return [
    _r(0, 762, 390, 82, _h(0xffffff), b: _h(0xe4e7eb)),
    _r(active == 3 ? 243 : 320, 769, 56, 30, _h(0xede7f6), r: 15),
    for (var k = 0; k < 5; k++) ...[
      _i(icons[k], il[k], 774, 20, k == active ? _h(0x673ab7) : _h(0x6b6f76)),
      _t(
        labels[k],
        tl[k],
        802,
        10.5,
        k == active ? _h(0x673ab7) : _h(0x6b6f76),
        w: k == active ? 700 : 500,
      ),
    ],
  ];
}

Widget _frame(List<Widget> children) => Scaffold(
  backgroundColor: _h(0xf3f7f6),
  body: Center(
    child: FittedBox(
      child: SizedBox(
        width: 390,
        height: 844,
        child: Stack(children: children),
      ),
    ),
  ),
);

class MobileDataAnalysisHeatmapCustomerRetention894857 extends StatelessWidget {
  const MobileDataAnalysisHeatmapCustomerRetention894857({super.key});

  @override
  Widget build(BuildContext context) {
    return _frame([
      ..._chrome('データ分析'),
      _r(14, 106, 362, 42, _h(0xeceff1), r: 12),
      _r(17, 109, 178, 36, _h(0x673ab7), r: 10),
      _t('ヒートマップ', 67, 119.5, 13, _h(0xffffff), w: 700),
      _t('グラフ', 264, 119.5, 13, _h(0x6b6f76), w: 700),
      _r(14, 158, 106, 34, _h(0xdaffaf), r: 10, b: _h(0xb9ea80)),
      _t('顧客継続状況', 28, 167.5, 13, _h(0x1d3b00), w: 700),
      _r(126, 158, 80, 34, _h(0xffffff), r: 10, b: _h(0xe4e7eb)),
      _t('配達実績', 140, 167.5, 13, _h(0x1d1b20), w: 700),
      _r(14, 202, 362, 546, _h(0xcfe5d2), r: 14),
      _t('地図（Googleマップ）', 126.5, 467, 13, _h(0x5b8a65), w: 700),
      _r(24, 212, 152, 52, _h(0xffffff), r: 10),
      _t('顧客継続状況', 34, 221.5, 11, _h(0x1d1b20), w: 700),
      _r(34, 244, 10, 10, _h(0x1e88e5), r: 5),
      _t('継続', 48, 241.5, 11, _h(0x6b6f76)),
      _r(82, 244, 10, 10, _h(0x43a047), r: 5),
      _t('新規', 96, 241.5, 11, _h(0x6b6f76)),
      _r(130, 244, 10, 10, _h(0x333333), r: 5),
      _t('離脱', 144, 241.5, 11, _h(0x6b6f76)),
      _r(326, 698, 40, 40, _h(0xffffff), r: 20),
      _i(Icons.my_location, 336, 708, 20, _h(0x1d1b20)),
      ..._nav(4),
      _indicator(),
    ]);
  }
}
