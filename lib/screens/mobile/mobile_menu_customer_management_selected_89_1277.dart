// Figma node 89:1277 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

class MobileMenuCustomerManagementSelected891277 extends StatelessWidget {
  const MobileMenuCustomerManagementSelected891277({super.key});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1D1B20);
    const gray = Color(0xFF6B6F76);
    const lgray = Color(0xFF9AA0A6);
    const purple = Color(0xFF673AB7);
    const blue = Color(0xFF1E88E5);
    const red = Color(0xFFF4511E);
    const w = Colors.white;
    const bold = FontWeight.w700;
    const reg = FontWeight.w400;
    const black = FontWeight.w900;

    // name, sub, days text, days x, days color
    const rows = <(String, String, String, double, Color)>[
      ('青木 一郎 様', '株式会社アオキ', '12日', 296, blue),
      ('伊藤 美咲 様', '愛知県立病院', '45日', 296, blue),
      ('上田 健太 様', '上田工業株式会社', '98日', 296, red),
      ('遠藤 由美 様', '個人宅', '150日', 286, red),
      ('大野 浩二 様', '大野商事', '200日', 286, red),
      ('加藤 真理 様', '岡崎市役所', '420日', 286, lgray),
      ('木村 拓也 様', '株式会社キムラ', '—', 316, lgray),
      ('久保田 愛 様', '個人宅', '7日', 305, blue),
      ('小林 誠 様', '小林建設', '120日', 286, red),
      ('斎藤 恵子 様', '斎藤医院', '30日', 296, blue),
      ('佐藤 次郎 様', '佐藤製作所', '85日', 296, red),
    ];

    final list = <Widget>[];
    for (var k = 0; k < rows.length; k++) {
      final y = 151.0 + 64 * k;
      final r = rows[k];
      list.addAll([
        _r(15, y, 360, k == rows.length - 1 ? 63 : 64, w),
        _r(29, y + 13, 38, 38, Color(0xFFEDE7F6), rad: 19),
        _i(38, y + 22, Icons.person, 20, purple),
        _t(77, y + 14.5, r.$1, 14, dark, bold),
        _t(77, y + 36, r.$2, 11.5, gray, reg),
        _t(r.$4, y + 14.5, r.$3, 16, r.$5, black),
        _t(291, y + 37.5, '前回から', 10, gray, reg),
        _i(341, y + 22, Icons.more_vert, 20, lgray),
      ]);
    }

    Widget tab(double x, double lx, double ix, IconData ic, String s,
        {bool on = false}) {
      return Stack(
        children: [
          _i(ix, 774, ic, 20, on ? purple : gray),
          _t(lx, 802, s, 10.5, on ? purple : gray,
              on ? bold : FontWeight.w500),
        ],
      );
    }

    Widget menu(double y, IconData ic, String s) {
      return Stack(
        children: [
          _i(26, y, ic, 22, w),
          _t(62, y + 2.5, s, 15, w, bold),
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
                _i(16, 60, Icons.menu, 20, dark),
                _t(52, 59, '顧客管理', 18, dark, bold),
                _i(306, 60, Icons.auto_awesome, 20, dark),
                _i(352, 60, Icons.search, 20, dark),
                _r(14, 106, 76, 34, Color(0xFFDAFFAF),
                    rad: 10, bc: Color(0xFFB9EA80)),
                _t(28, 114.5, '氏名順 ▾', 13, Color(0xFF1D3B00), bold),
                _r(96, 106, 76, 34, w, rad: 10, bc: Color(0xFFE4E7EB)),
                _t(110, 115.5, '企業名 ▾', 13, dark, bold),
                _r(179, 106, 102, 34, w, rad: 10, bc: Color(0xFFE4E7EB)),
                _t(193, 115.5, '前回経過日 ▾', 13, dark, bold),
                _r(14, 150, 362, 705, w, rad: 14, bc: Color(0xFFEDF0F2)),
                ...list,
                _r(0, 762, 390, 82, w, bc: Color(0xFFE4E7EB)),
                tab(21, 21, 32, Icons.post_add, '受注入力'),
                tab(98, 98, 109, Icons.list_alt, '受注一覧'),
                tab(174, 174, 185, Icons.local_shipping, '配送予定'),
                _r(243, 769, 56, 30, Color(0xFFEDE7F6), rad: 15),
                tab(261, 261, 261, Icons.people, '顧客', on: true),
                tab(327, 327, 338, Icons.apps, 'メニュー'),
                _r(0, 0, 390, 844, Color(0x7A121218)),
                _r(0, 0, 296, 844, Colors.black),
                _r(18, 58, 120, 44, Color(0xFF2A2A2A), rad: 10),
                _i(258, 70, Icons.close, 20, w),
                _t(105, 124.5, '- MENU -', 17, w, black, ls: 2),
                menu(171, Icons.post_add, '受注入力'),
                menu(221, Icons.list_alt, '受注一覧'),
                menu(271, Icons.inventory_2, '調理・仕入れ計画'),
                menu(321, Icons.local_shipping, '配送予定'),
                menu(371, Icons.analytics, 'データ分析'),
                _r(12, 409, 272, 46, Color(0xFF3A3A3A), rad: 12),
                menu(421, Icons.people, '顧客管理'),
                menu(471, Icons.restaurant, 'メニューマスタ'),
                menu(521, Icons.badge, 'スタッフ管理'),
                menu(571, Icons.settings, '設定'),
                _r(18, 737, 260, 57, null, bc: Color(0xFF444444)),
                _i(18, 755, Icons.account_circle, 22, w),
                _t(50, 756.5, 'スタッフ名', 16, w, bold),
                _i(258, 756, Icons.logout, 20, w),
                _t(18, 795.5, 'Version 1.0.52', 11, Color(0xFF999999), reg),
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
