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

List<Widget> _drawer(int active) {
  const icons = [
    Icons.post_add,
    Icons.list_alt,
    Icons.inventory_2,
    Icons.local_shipping,
    Icons.analytics,
    Icons.people,
    Icons.restaurant,
    Icons.badge,
    Icons.settings,
  ];
  const labels = [
    '受注入力',
    '受注一覧',
    '調理・仕入れ計画',
    '配送予定',
    'データ分析',
    '顧客管理',
    'メニューマスタ',
    'スタッフ管理',
    '設定',
  ];
  final w = _h(0xffffff);
  return [
    _r(0, 0, 390, 844, const Color(0x7A121218)),
    _r(0, 0, 296, 844, _h(0x000000)),
    _r(18, 58, 120, 44, _h(0x2a2a2a), r: 10),
    _i(Icons.close, 258, 70, 20, w),
    _t('- MENU -', 105, 124.5, 17, w, w: 900, ls: 2),
    for (var k = 0; k < 9; k++) ...[
      if (k == active)
        _r(12, 171.0 + 50 * k - 12, 272, 46, _h(0x3a3a3a), r: 12),
      _i(icons[k], 26, 171.0 + 50 * k, 22, w),
      _t(labels[k], 62, 173.5 + 50 * k, 15, w, w: 700),
    ],
    _r(18, 737, 260, 57, null, b: _h(0x444444)),
    _i(Icons.account_circle, 18, 755, 22, w),
    _t('スタッフ名', 50, 756.5, 16, w, w: 700),
    _i(Icons.logout, 258, 756, 20, w),
    _t('Version 1.0.52', 18, 795.5, 11, _h(0x999999)),
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

class MobileMenuSettingsSelected891547 extends StatelessWidget {
  const MobileMenuSettingsSelected891547({super.key});

  @override
  Widget build(BuildContext context) {
    return _frame([
      ..._chrome('設定'),
      _i(Icons.edit_note, 16, 111, 16, _h(0x673ab7)),
      _t('文字入力方式', 37, 111.5, 12, _h(0x6b6f76), w: 700),
      _r(14, 133, 362, 109, _h(0xffffff), r: 14, b: _h(0xedf0f2)),
      _t(
        'アプリ内すべての文字入力欄に、選択した入力方式が一括で反映されます。',
        29,
        146,
        11.5,
        _h(0x6b6f76),
        width: 335,
      ),
      _r(29, 187, 332, 42, _h(0xeceff1), r: 12),
      _r(32, 190, 163, 36, _h(0x673ab7), r: 10),
      _t('ペンタブ', 87, 200.5, 13, _h(0xffffff), w: 700),
      _t('キーボード', 244, 200.5, 13, _h(0x6b6f76), w: 700),
      _i(Icons.mail_outline, 16, 257, 16, _h(0x673ab7)),
      _t('事前確認・事前連絡', 37, 257.5, 12, _h(0x6b6f76), w: 700),
      _r(14, 279, 362, 161, _h(0xffffff), r: 14, b: _h(0xedf0f2)),
      _t(
        '事前確認メールを配達前日に自動送信する時刻と、事前電話連絡の担当者番号を設定します。担当者番号には、電話連絡のし忘れ防止リマインドSMSが送信されます。',
        29,
        292,
        11.5,
        _h(0x6b6f76),
        width: 325,
      ),
      _r(15, 342, 360, 49, _h(0xffffff)),
      _i(Icons.schedule, 29, 356, 20, _h(0x6b6f76)),
      _t('送信時刻', 59, 359, 11.5, _h(0x6b6f76)),
      _t('前日 09:00', 254, 356.5, 16, _h(0x1d1b20), w: 700),
      _i(Icons.edit, 343, 357, 18, _h(0x673ab7)),
      _r(15, 391, 360, 48, _h(0xffffff)),
      _i(Icons.phone_forwarded, 29, 405, 20, _h(0x6b6f76)),
      _t('担当者番号', 59, 408, 11.5, _h(0x6b6f76)),
      _t('未設定', 285, 405.5, 16, _h(0x6b6f76)),
      _i(Icons.edit, 343, 406, 18, _h(0x673ab7)),
      _i(Icons.storefront, 16, 455, 16, _h(0x673ab7)),
      _t('店舗登録', 37, 455.5, 12, _h(0x6b6f76), w: 700),
      _r(14, 481, 362, 208, _h(0xffffff), r: 14, b: _h(0xedf0f2)),
      _r(15, 482, 360, 110, _h(0xeef0f2)),
      _i(Icons.storefront, 177, 519, 36, _h(0xb5bac0)),
      _r(316, 562, 49, 20, _h(0xffebee), r: 6),
      _i(Icons.delete_outline, 323, 567, 12, _h(0xd32f2f)),
      _t('削除', 335, 565, 10.5, _h(0xd32f2f), w: 700),
      _t('岡崎店', 29, 606.5, 16, _h(0x1d1b20), w: 700),
      _t('株式会社OLDROOKIE 岡崎', 29, 629, 11.5, _h(0x6b6f76)),
      _t('愛知県岡崎市康生通西4丁目71', 29, 645, 11.5, _h(0x6b6f76)),
      _i(Icons.call, 29, 664, 12, _h(0x6b6f76)),
      _t('0564-00-0000', 41, 661, 11.5, _h(0x6b6f76)),
      _i(Icons.more_vert, 341, 630, 20, _h(0x9aa0a6)),
      ..._nav(4),
      ..._drawer(8),
      _indicator(),
    ]);
  }
}
