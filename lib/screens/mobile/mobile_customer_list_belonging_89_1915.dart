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

class MobileCustomerListBelonging891915 extends StatelessWidget {
  const MobileCustomerListBelonging891915({super.key});

  @override
  Widget build(BuildContext context) {
    return _frame([
      ..._chrome('顧客管理'),
      _i(Icons.auto_awesome, 306, 60, 20, _h(0x1d1b20)),
      _i(Icons.search, 352, 60, 20, _h(0x1d1b20)),
      _r(14, 106, 76, 34, _h(0xdaffaf), r: 10, b: _h(0xb9ea80)),
      _t('氏名順 ▾', 28, 115.5, 13, _h(0x1d3b00), w: 700),
      _r(96, 106, 76, 34, _h(0xffffff), r: 10, b: _h(0xe4e7eb)),
      _t('企業名 ▾', 110, 115.5, 13, _h(0x1d1b20), w: 700),
      _r(179, 106, 102, 34, _h(0xffffff), r: 10, b: _h(0xe4e7eb)),
      _t('前回経過日 ▾', 193, 115.5, 13, _h(0x1d1b20), w: 700),
      _r(14, 150, 362, 705, _h(0xffffff), r: 14, b: _h(0xedf0f2)),
      _r(15, 151, 360, 64, _h(0xf6f0ff)),
      _r(29, 164, 38, 38, _h(0xede7f6), r: 19),
      _i(Icons.person, 38, 173, 20, _h(0x673ab7)),
      _t('青木 一郎 様', 77, 165.5, 14, _h(0x673ab7), w: 700),
      _t('株式会社アオキ', 77, 186, 11.5, _h(0x6b6f76)),
      _t('12日', 296, 165.5, 16, _h(0x1e88e5), w: 900),
      _t('前回から', 291, 188.5, 10, _h(0x6b6f76)),
      _i(Icons.more_vert, 341, 173, 20, _h(0x9aa0a6)),
      _r(15, 215, 360, 64, _h(0xffffff)),
      _r(29, 228, 38, 38, _h(0xede7f6), r: 19),
      _i(Icons.person, 38, 237, 20, _h(0x673ab7)),
      _t('伊藤 美咲 様', 77, 229.5, 14, _h(0x1d1b20), w: 700),
      _t('愛知県立病院', 77, 250, 11.5, _h(0x6b6f76)),
      _t('45日', 296, 229.5, 16, _h(0x1e88e5), w: 900),
      _t('前回から', 291, 252.5, 10, _h(0x6b6f76)),
      _i(Icons.more_vert, 341, 237, 20, _h(0x9aa0a6)),
      _r(15, 279, 360, 64, _h(0xffffff)),
      _r(29, 292, 38, 38, _h(0xede7f6), r: 19),
      _i(Icons.person, 38, 301, 20, _h(0x673ab7)),
      _t('上田 健太 様', 77, 293.5, 14, _h(0x1d1b20), w: 700),
      _t('上田工業株式会社', 77, 314, 11.5, _h(0x6b6f76)),
      _t('98日', 296, 293.5, 16, _h(0xf4511e), w: 900),
      _t('前回から', 291, 316.5, 10, _h(0x6b6f76)),
      _i(Icons.more_vert, 341, 301, 20, _h(0x9aa0a6)),
      _r(15, 343, 360, 64, _h(0xffffff)),
      _r(29, 356, 38, 38, _h(0xede7f6), r: 19),
      _i(Icons.person, 38, 365, 20, _h(0x673ab7)),
      _t('遠藤 由美 様', 77, 357.5, 14, _h(0x1d1b20), w: 700),
      _t('個人宅', 77, 378, 11.5, _h(0x6b6f76)),
      _t('150日', 286, 357.5, 16, _h(0xf4511e), w: 900),
      _t('前回から', 291, 380.5, 10, _h(0x6b6f76)),
      _i(Icons.more_vert, 341, 365, 20, _h(0x9aa0a6)),
      _r(15, 407, 360, 64, _h(0xffffff)),
      _r(29, 420, 38, 38, _h(0xede7f6), r: 19),
      _i(Icons.person, 38, 429, 20, _h(0x673ab7)),
      _t('大野 浩二 様', 77, 421.5, 14, _h(0x1d1b20), w: 700),
      _t('大野商事', 77, 442, 11.5, _h(0x6b6f76)),
      _t('200日', 286, 421.5, 16, _h(0xf4511e), w: 900),
      _t('前回から', 291, 444.5, 10, _h(0x6b6f76)),
      _i(Icons.more_vert, 341, 429, 20, _h(0x9aa0a6)),
      _r(15, 471, 360, 64, _h(0xffffff)),
      _r(29, 484, 38, 38, _h(0xede7f6), r: 19),
      _i(Icons.person, 38, 493, 20, _h(0x673ab7)),
      _t('加藤 真理 様', 77, 485.5, 14, _h(0x1d1b20), w: 700),
      _t('岡崎市役所', 77, 506, 11.5, _h(0x6b6f76)),
      _t('420日', 286, 485.5, 16, _h(0x9aa0a6), w: 900),
      _t('前回から', 291, 508.5, 10, _h(0x6b6f76)),
      _i(Icons.more_vert, 341, 493, 20, _h(0x9aa0a6)),
      _r(15, 535, 360, 64, _h(0xffffff)),
      _r(29, 548, 38, 38, _h(0xede7f6), r: 19),
      _i(Icons.person, 38, 557, 20, _h(0x673ab7)),
      _t('木村 拓也 様', 77, 549.5, 14, _h(0x1d1b20), w: 700),
      _t('株式会社キムラ', 77, 570, 11.5, _h(0x6b6f76)),
      _t('—', 316, 549.5, 16, _h(0x9aa0a6), w: 900),
      _t('前回から', 291, 572.5, 10, _h(0x6b6f76)),
      _i(Icons.more_vert, 341, 557, 20, _h(0x9aa0a6)),
      _r(15, 599, 360, 64, _h(0xffffff)),
      _r(29, 612, 38, 38, _h(0xede7f6), r: 19),
      _i(Icons.person, 38, 621, 20, _h(0x673ab7)),
      _t('久保田 愛 様', 77, 613.5, 14, _h(0x1d1b20), w: 700),
      _t('個人宅', 77, 634, 11.5, _h(0x6b6f76)),
      _t('7日', 305, 613.5, 16, _h(0x1e88e5), w: 900),
      _t('前回から', 291, 636.5, 10, _h(0x6b6f76)),
      _i(Icons.more_vert, 341, 621, 20, _h(0x9aa0a6)),
      _r(15, 663, 360, 64, _h(0xffffff)),
      _r(29, 676, 38, 38, _h(0xede7f6), r: 19),
      _i(Icons.person, 38, 685, 20, _h(0x673ab7)),
      _t('小林 誠 様', 77, 677.5, 14, _h(0x1d1b20), w: 700),
      _t('小林建設', 77, 698, 11.5, _h(0x6b6f76)),
      _t('120日', 286, 677.5, 16, _h(0xf4511e), w: 900),
      _t('前回から', 291, 700.5, 10, _h(0x6b6f76)),
      _i(Icons.more_vert, 341, 685, 20, _h(0x9aa0a6)),
      _r(15, 727, 360, 64, _h(0xffffff)),
      _r(29, 740, 38, 38, _h(0xede7f6), r: 19),
      _i(Icons.person, 38, 749, 20, _h(0x673ab7)),
      _t('斎藤 恵子 様', 77, 741.5, 14, _h(0x1d1b20), w: 700),
      _t('斎藤医院', 77, 762, 11.5, _h(0x6b6f76)),
      _t('30日', 296, 741.5, 16, _h(0x1e88e5), w: 900),
      _t('前回から', 291, 764.5, 10, _h(0x6b6f76)),
      _i(Icons.more_vert, 341, 749, 20, _h(0x9aa0a6)),
      _r(15, 791, 360, 63, _h(0xffffff)),
      _r(29, 804, 38, 38, _h(0xede7f6), r: 19),
      _i(Icons.person, 38, 813, 20, _h(0x673ab7)),
      _t('佐藤 次郎 様', 77, 805.5, 14, _h(0x1d1b20), w: 700),
      _t('佐藤製作所', 77, 826, 11.5, _h(0x6b6f76)),
      _t('85日', 296, 805.5, 16, _h(0xf4511e), w: 900),
      _t('前回から', 291, 828.5, 10, _h(0x6b6f76)),
      _i(Icons.more_vert, 341, 813, 20, _h(0x9aa0a6)),
      ..._nav(3),
      _r(0, 0, 390, 844, const Color(0x7A121218)),
      _r(0, 549, 390, 295, _h(0xffffff), r: 22, top: true),
      _r(175, 557, 40, 5, _h(0xd4d7dc), r: 2.5),
      _t('「株式会社アオキ」の登録顧客', 30, 578.5, 17, _h(0x1d1b20), w: 700),
      _r(344, 570, 36, 36, _h(0xf1f3f5), r: 18),
      _i(Icons.close, 352, 578, 20, _h(0x1d1b20)),
      _r(18, 616, 354, 127, _h(0xffffff), r: 14, b: _h(0xedf0f2)),
      _r(19, 617, 352, 63, _h(0xffffff)),
      _r(33, 629, 38, 38, _h(0xede7f6), r: 19),
      _i(Icons.person, 42, 638, 20, _h(0x673ab7)),
      _t('青木 二郎 様', 81, 631.5, 14, _h(0x1d1b20), w: 700),
      _t('0564-22-3344', 81, 652, 11.5, _h(0x6b6f76)),
      _i(Icons.call, 337, 638, 20, _h(0x673ab7)),
      _r(19, 680, 352, 62, _h(0xffffff)),
      _r(33, 692, 38, 38, _h(0xede7f6), r: 19),
      _i(Icons.person, 42, 701, 20, _h(0x673ab7)),
      _t('青木 三郎 様', 81, 694.5, 14, _h(0x1d1b20), w: 700),
      _t('0564-55-6677', 81, 715, 11.5, _h(0x6b6f76)),
      _i(Icons.call, 337, 701, 20, _h(0x673ab7)),
      _r(0, 755, 390, 89, null, b: _h(0xe4e7eb)),
      _r(18, 766, 354, 48, _h(0xffffff), r: 12, b: _h(0xe4e7eb)),
      _t('閉じる', 172.5, 781.5, 15, _h(0x1d1b20), w: 700),
      _indicator(),
    ]);
  }
}
