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

class MobileOrderInputDeliveryNew89230 extends StatelessWidget {
  const MobileOrderInputDeliveryNew89230({super.key});

  @override
  Widget build(BuildContext context) {
    return _frame([
      ..._chrome('受注入力', lead: Icons.close),
      _t('0564-12-3456', 273, 60.5, 15, _h(0x673ab7), w: 900),
      _r(0, 96, 390, 59, _h(0xffffff)),
      _r(47, 104, 22, 22, _h(0x4caf50), r: 11, b: _h(0x4caf50)),
      _i(Icons.check, 51, 108, 14, _h(0xffffff)),
      _t('番号確認', 38, 130.5, 10, _h(0x1d1b20), w: 500),
      _r(138, 104, 22, 22, _h(0xff6d00), r: 11, b: _h(0xff6d00)),
      _t('2', 146, 108.5, 11, _h(0xffffff), w: 700),
      _t('配達先の確定', 119, 130.5, 10, _h(0xff6d00), w: 700),
      _r(230, 104, 22, 22, _h(0xffffff), r: 11, b: _h(0xcfd3d8)),
      _t('3', 238, 108.5, 11, _h(0x9aa0a6), w: 700),
      _t('注文内容', 221, 130.5, 10, _h(0x9aa0a6), w: 500),
      _r(321, 104, 22, 22, _h(0xffffff), r: 11, b: _h(0xcfd3d8)),
      _t('4', 329, 108.5, 11, _h(0x9aa0a6), w: 700),
      _t('完了', 322, 130.5, 10, _h(0x9aa0a6), w: 500),
      _r(14, 165, 362, 42, _h(0xeceff1), r: 12),
      _t('履歴から選択', 67, 178.5, 13, _h(0x6b6f76), w: 700),
      _r(195, 168, 178, 36, _h(0xdaffaf), r: 10),
      _t('新規登録', 258, 178.5, 13, _h(0x1d3b00), w: 700),
      _r(14, 219, 362, 219, _h(0xffffff), r: 14, b: _h(0xedf0f2)),
      _r(29, 232, 332, 42, _h(0xeceff1), r: 12),
      _r(32, 235, 109, 36, _h(0xdaffaf), r: 10),
      _i(Icons.category, 78, 235, 16, _h(0x1d3b00)),
      _t('地域・カテゴリ', 41, 253.5, 13, _h(0x1d3b00), w: 700),
      _i(Icons.search, 187, 235, 16, _h(0x6b6f76)),
      _t('キーワード', 163, 253.5, 13, _h(0x6b6f76), w: 700),
      _i(Icons.pin_drop, 296, 235, 16, _h(0x6b6f76)),
      _t('住所', 291, 253.5, 13, _h(0x6b6f76), w: 700),
      _t('地域・カテゴリ選択', 29, 285, 11.5, _h(0x6b6f76), w: 700),
      _r(29, 305, 252, 44, _h(0xf6f7f9), r: 10, b: _h(0xe4e7eb)),
      _t('愛知県 岡崎市', 42, 318.5, 14, _h(0x1d1b20)),
      _i(Icons.unfold_more, 250, 318, 18, _h(0x6b6f76)),
      _r(289, 305, 72, 44, _h(0x78909c), r: 10),
      _i(Icons.map, 302, 319, 16, _h(0xffffff)),
      _t('調整', 322, 319.5, 13, _h(0xffffff), w: 700),
      _t('備考（地図上の目印、搬入口情報など）', 29, 360, 11.5, _h(0x6b6f76), w: 700),
      _r(29, 381, 332, 44, _h(0xf6f7f9), r: 10, b: _h(0xe4e7eb)),
      _t('タップして詳細を入力してください', 42, 394.5, 14, _h(0x9aa0a6)),
      _i(Icons.delete_outline, 330, 394, 18, _h(0x6b6f76)),
      _t('配達先情報の確認', 16, 453.5, 12, _h(0x6b6f76), w: 700),
      _r(14, 475, 362, 238, _h(0xffffff), r: 14, b: _h(0xedf0f2)),
      _r(15, 476, 360, 150, _h(0xcfe5d2)),
      _t('地図（Googleマップ）', 126.5, 543, 13, _h(0x5b8a65), w: 700),
      _i(Icons.store, 29, 642, 15, _h(0x1e88e5)),
      _t('岡崎本店 →', 44, 641, 11.5, _h(0x1d1b20)),
      _i(Icons.location_on, 109, 642, 15, _h(0xf44336)),
      _i(Icons.business, 29, 663, 15, _h(0xf44336)),
      _t('未確定', 44, 662, 11.5, _h(0xf44336), w: 700),
      _i(Icons.place, 29, 684, 15, _h(0xf44336)),
      _t('未確定', 44, 682, 11.5, _h(0xf44336), w: 700),
      _r(0, 757, 390, 87, _h(0xffffff), b: _h(0xe4e7eb)),
      _r(14, 768, 176, 48, _h(0xf44336), r: 12),
      _t('注文中止', 72.5, 783.5, 15, _h(0xffffff), w: 700),
      _r(200, 768, 176, 48, _h(0xb8bcc2), r: 12),
      _t('商品選択', 258.5, 783.5, 15, _h(0xffffff), w: 700),
      _indicator(),
    ]);
  }
}
