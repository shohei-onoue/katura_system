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

class MobileMenuDelete892057 extends StatelessWidget {
  const MobileMenuDelete892057({super.key});

  @override
  Widget build(BuildContext context) {
    return _frame([
      ..._chrome('メニューマスタ'),
      _i(Icons.search, 352, 60, 20, _h(0x1d1b20)),
      _r(0, 96, 390, 50, _h(0xffffff)),
      _r(14, 106, 66, 34, _h(0x673ab7), r: 10, b: _h(0x673ab7)),
      _t('すべて', 28, 115.5, 13, _h(0xffffff), w: 700),
      _r(86, 106, 145, 34, _h(0xffffff), r: 10, b: _h(0xe4e7eb)),
      _t('厳選牛ステーキ弁当', 100, 115.5, 13, _h(0x1d1b20), w: 700),
      _r(237, 106, 80, 34, _h(0xffffff), r: 10, b: _h(0xe4e7eb)),
      _t('高級弁当', 251, 115.5, 13, _h(0x1d1b20), w: 700),
      _r(323, 106, 93, 34, _h(0xffffff), r: 10, b: _h(0xe4e7eb)),
      _t('オードブル', 337, 115.5, 13, _h(0x1d1b20), w: 700),
      _r(422, 106, 67, 34, _h(0xffffff), r: 10, b: _h(0xe4e7eb)),
      _t('丼もの', 436, 115.5, 13, _h(0x1d1b20), w: 700),
      _r(495, 106, 67, 34, _h(0xffffff), r: 10, b: _h(0xe4e7eb)),
      _t('ギフト', 509, 115.5, 13, _h(0x1d1b20), w: 700),
      _r(568, 106, 80, 34, _h(0xffffff), r: 10, b: _h(0xe4e7eb)),
      _t('ドリンク', 582, 115.5, 13, _h(0x1d1b20), w: 700),
      _r(14, 156, 362, 540, _h(0xffffff), r: 14, b: _h(0xedf0f2)),
      _r(15, 157, 360, 77, _h(0xf6f0ff)),
      _r(29, 169, 52, 52, _h(0xeef0f2), r: 10),
      _i(Icons.restaurant, 45, 185, 20, _h(0xb5bac0)),
      _t('特製ステーキ弁当', 91, 178.5, 14, _h(0xff6d00), w: 700),
      _t('厳選牛ステーキ弁当 ・', 91, 199, 11.5, _h(0x6b6f76)),
      _t('¥1,800', 211, 199, 11.5, _h(0xf44336), w: 700),
      _i(Icons.more_vert, 341, 185, 20, _h(0x9aa0a6)),
      _r(15, 234, 360, 77, _h(0xffffff)),
      _r(29, 246, 52, 52, _h(0xeef0f2), r: 10),
      _i(Icons.restaurant, 45, 262, 20, _h(0xb5bac0)),
      _t('松花堂弁当', 91, 255.5, 14, _h(0x1d1b20), w: 700),
      _t('高級弁当 ・', 91, 276, 11.5, _h(0x6b6f76)),
      _t('¥2,500', 154, 276, 11.5, _h(0xf44336), w: 700),
      _i(Icons.more_vert, 341, 262, 20, _h(0x9aa0a6)),
      _r(15, 311, 360, 77, _h(0xffffff)),
      _r(29, 323, 52, 52, _h(0xeef0f2), r: 10),
      _i(Icons.restaurant, 45, 339, 20, _h(0xb5bac0)),
      _t('幕の内弁当', 91, 332.5, 14, _h(0x1d1b20), w: 700),
      _t('高級弁当 ・', 91, 353, 11.5, _h(0x6b6f76)),
      _t('¥1,500', 154, 353, 11.5, _h(0xf44336), w: 700),
      _i(Icons.more_vert, 341, 339, 20, _h(0x9aa0a6)),
      _r(15, 388, 360, 77, _h(0xffffff)),
      _r(29, 400, 52, 52, _h(0xeef0f2), r: 10),
      _i(Icons.restaurant, 45, 416, 20, _h(0xb5bac0)),
      _t('鶏から揚げオードブル', 91, 409.5, 14, _h(0x1d1b20), w: 700),
      _t('オードブル ・', 91, 430, 11.5, _h(0x6b6f76)),
      _t('¥3,500', 165, 430, 11.5, _h(0xf44336), w: 700),
      _i(Icons.more_vert, 341, 416, 20, _h(0x9aa0a6)),
      _r(15, 465, 360, 77, _h(0xffffff)),
      _r(29, 477, 52, 52, _h(0xeef0f2), r: 10),
      _i(Icons.restaurant, 45, 493, 20, _h(0xb5bac0)),
      _t('親子丼', 91, 486.5, 14, _h(0x1d1b20), w: 700),
      _t('丼もの ・', 91, 507, 11.5, _h(0x6b6f76)),
      _t('¥900', 142, 507, 11.5, _h(0xf44336), w: 700),
      _i(Icons.more_vert, 341, 493, 20, _h(0x9aa0a6)),
      _r(15, 542, 360, 77, _h(0xffffff)),
      _r(29, 554, 52, 52, _h(0xeef0f2), r: 10),
      _i(Icons.restaurant, 45, 570, 20, _h(0xb5bac0)),
      _t('ギフト詰め合わせ', 91, 563.5, 14, _h(0x1d1b20), w: 700),
      _t('ギフト ・', 91, 584, 11.5, _h(0x6b6f76)),
      _t('¥4,000', 142, 584, 11.5, _h(0xf44336), w: 700),
      _i(Icons.more_vert, 341, 570, 20, _h(0x9aa0a6)),
      _r(15, 619, 360, 76, _h(0xffffff)),
      _r(29, 631, 52, 52, _h(0xeef0f2), r: 10),
      _i(Icons.restaurant, 45, 647, 20, _h(0xb5bac0)),
      _t('お茶（500ml）', 91, 640.5, 14, _h(0x1d1b20), w: 700),
      _t('ドリンク・サイドメニュー ・', 91, 661, 11.5, _h(0x6b6f76)),
      _t('¥150', 245, 661, 11.5, _h(0xf44336), w: 700),
      _i(Icons.more_vert, 341, 647, 20, _h(0x9aa0a6)),
      _r(256, 612, 118, 52, _h(0x673ab7), r: 16),
      _i(Icons.add, 274, 628, 20, _h(0xffffff)),
      _t('新規登録', 300, 629.5, 14, _h(0xffffff), w: 700),
      ..._nav(4),
      _r(0, 0, 390, 844, const Color(0x7A121218)),
      _r(28, 303, 334, 239, _h(0xffffff), r: 22),
      _r(169, 325, 52, 52, _h(0xffebee), r: 26),
      _i(Icons.delete_outline, 181, 337, 28, _h(0xf44336)),
      _t('メニューの削除', 136.5, 389.5, 17, _h(0x1d1b20), w: 700),
      _t('特製ステーキ弁当を削除してもよろしいですか？', 53.5, 421.5, 13, _h(0x6b6f76)),
      _t('この操作は取り消せません。', 111.5, 442.5, 13, _h(0x6b6f76)),
      _r(48, 479, 143, 46, _h(0xffffff), r: 12, b: _h(0xe4e7eb)),
      _t('キャンセル', 85.5, 493.5, 14, _h(0x1d1b20), w: 700),
      _r(201, 479, 141, 46, _h(0xf44336), r: 12),
      _t('削除する', 244.5, 493.5, 14, _h(0xffffff), w: 700),
      _indicator(),
    ]);
  }
}
