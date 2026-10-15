import 'package:flutter/material.dart';

/// Figma 89:1779 顧客検索（スマホ版）
class MobileCustomerSearch891779 extends StatelessWidget {
  const MobileCustomerSearch891779({super.key});

  static const _rows = <List<Object>>[
    ['青木 一郎', '株式会社アオキ', '12日', 296.0, 0xFF1E88E5],
    ['伊藤 美咲', '愛知県立病院', '45日', 296.0, 0xFF1E88E5],
    ['上田 健太', '上田工業株式会社', '98日', 296.0, 0xFFF4511E],
    ['遠藤 由美', '個人宅', '150日', 286.0, 0xFFF4511E],
    ['大野 浩二', '大野商事', '200日', 286.0, 0xFFF4511E],
    ['加藤 真理', '岡崎市役所', '420日', 286.0, 0xFF9AA0A6],
    ['木村 拓也', '株式会社キムラ', '—', 316.0, 0xFF9AA0A6],
    ['久保田 愛', '個人宅', '7日', 305.0, 0xFF1E88E5],
    ['小林 誠', '小林建設', '120日', 286.0, 0xFFF4511E],
    ['斎藤 恵子', '斎藤医院', '30日', 296.0, 0xFF1E88E5],
    ['佐藤 次郎', '佐藤製作所', '85日', 296.0, 0xFFF4511E],
  ];

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1D1B20);
    const sub = Color(0xFF6B6F76);
    const grey = Color(0xFF9AA0A6);
    const purple = Color(0xFF673AB7);
    const line = Color(0xFFE4E7EB);
    const bold = FontWeight.w700;

    final rows = <Widget>[];
    for (var i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      final top = 151.0 + 64 * i;
      final first = i == 0;
      rows.addAll([
        _r(
          15,
          top,
          360,
          i == _rows.length - 1 ? 63 : 64,
          color: first ? const Color(0xFFF6F0FF) : Colors.white,
        ),
        _r(29, top + 13, 38, 38, color: const Color(0xFFEDE7F6), radius: 19),
        _i(38, top + 22, Icons.person_rounded, 20, purple),
        _t(
          77,
          top + 14.5,
          '${r[0]} 様',
          14,
          first ? purple : dark,
          weight: bold,
        ),
        _t(77, top + 35, r[1] as String, 11.5, sub),
        _t(
          r[3] as double,
          top + 14.5,
          r[2] as String,
          16,
          Color(r[4] as int),
          weight: FontWeight.w900,
        ),
        _t(291, top + 37.5, '前回から', 10, sub),
        _i(341, top + 22, Icons.more_vert_rounded, 20, grey),
      ]);
    }

    Widget nav(double x, double iconX, IconData ic, String label) {
      return _i(iconX, 774, ic, 20, sub);
    }

    return _frame([
      _r(0, 0, 390, 44, color: Colors.white),
      _t(30, 13.5, '9:41', 15, dark, weight: bold),
      _i(303, 14, Icons.signal_cellular_alt_rounded, 17, dark),
      _i(325, 14, Icons.wifi_rounded, 17, dark),
      _i(347, 14, Icons.battery_full_rounded, 17, dark),
      _r(0, 44, 390, 52, color: Colors.white),
      _i(16, 60, Icons.menu_rounded, 20, dark),
      _t(52, 59, '顧客管理', 18, dark, weight: bold),
      _i(306, 60, Icons.auto_awesome_rounded, 20, dark),
      _i(352, 60, Icons.search_rounded, 20, dark),
      _r(
        14,
        106,
        76,
        34,
        color: const Color(0xFFDAFFAF),
        border: const Color(0xFFB9EA80),
        radius: 10,
      ),
      _t(28, 115.5, '氏名順 ▾', 13, const Color(0xFF1D3B00), weight: bold),
      _r(96, 106, 76, 34, color: Colors.white, border: line, radius: 10),
      _t(110, 115.5, '企業名 ▾', 13, dark, weight: bold),
      _r(179, 106, 102, 34, color: Colors.white, border: line, radius: 10),
      _t(193, 115.5, '前回経過日 ▾', 13, dark, weight: bold),
      _r(
        14,
        150,
        362,
        705,
        color: Colors.white,
        border: const Color(0xFFEDF0F2),
        radius: 14,
      ),
      ...rows,
      _r(0, 762, 390, 82, color: Colors.white, border: line),
      nav(0, 32, Icons.post_add_rounded, '受注入力'),
      _t(21, 802, '受注入力', 10.5, sub, weight: FontWeight.w500),
      nav(0, 109, Icons.list_alt_rounded, ''),
      _t(98, 802, '受注一覧', 10.5, sub, weight: FontWeight.w500),
      nav(0, 185, Icons.local_shipping_rounded, ''),
      _t(174, 802, '配送予定', 10.5, sub, weight: FontWeight.w500),
      _r(243, 769, 56, 30, color: const Color(0xFFEDE7F6), radius: 15),
      _i(261, 774, Icons.people_rounded, 20, purple),
      _t(261, 802, '顧客', 10.5, purple, weight: bold),
      nav(0, 338, Icons.apps_rounded, ''),
      _t(327, 802, 'メニュー', 10.5, sub, weight: FontWeight.w500),
      _r(0, 0, 390, 844, color: const Color(0x7A121218)),
      _r(0, 607, 390, 237, color: Colors.white, radius: 22),
      _r(175, 615, 40, 5, color: const Color(0xFFD4D7DC), radius: 2.5),
      _t(30, 636.5, '名前・企業・電話番号で検索', 17, dark, weight: bold),
      _r(344, 628, 36, 36, color: const Color(0xFFF1F3F5), radius: 18),
      _i(352, 636, Icons.close_rounded, 20, dark),
      _r(
        18,
        674,
        354,
        44,
        color: const Color(0xFFF6F7F9),
        border: line,
        radius: 10,
      ),
      _t(31, 687.5, 'タップして詳細を入力して下さい', 14, grey),
      _i(341, 687, Icons.draw_rounded, 18, sub),
      _i(18, 729, Icons.history_rounded, 14, sub),
      _t(32, 727, '最近の検索：アオキ ／ 0564 ／ 伊藤', 11.5, sub),
      _r(0, 755, 390, 89, border: line),
      _r(
        18,
        766,
        173,
        48,
        color: Colors.white,
        border: const Color(0xFFFF6D00),
        radius: 12,
      ),
      _t(82.5, 781.5, 'クリア', 15, const Color(0xFFFF6D00), weight: bold),
      _r(201, 766, 171, 48, color: purple, radius: 12),
      _t(271.5, 781.5, '検索', 15, Colors.white, weight: bold),
      _r(128, 831, 134, 5, color: const Color(0xFF111111), radius: 2.5),
    ]);
  }
}

Widget _r(
  double l,
  double t,
  double w,
  double h, {
  Color? color,
  Color? border,
  double radius = 0,
}) {
  return Positioned(
    left: l,
    top: t,
    width: w,
    height: h,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: border == null ? null : Border.all(color: border, width: 1),
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}

Widget _t(
  double l,
  double t,
  String s,
  double size,
  Color color, {
  FontWeight weight = FontWeight.w400,
}) {
  return Positioned(
    left: l,
    top: t,
    child: Text(
      s,
      maxLines: 1,
      softWrap: false,
      style: TextStyle(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: 1.0,
        decoration: TextDecoration.none,
      ),
    ),
  );
}

Widget _i(double l, double t, IconData icon, double size, Color color) {
  return Positioned(
    left: l,
    top: t,
    child: Icon(icon, size: size, color: color),
  );
}

Widget _frame(List<Widget> children, {Color bg = const Color(0xFFF3F7F6)}) {
  return Scaffold(
    backgroundColor: bg,
    body: SafeArea(
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 390,
            height: 844,
            child: ClipRect(child: Stack(children: children)),
          ),
        ),
      ),
    ),
  );
}
