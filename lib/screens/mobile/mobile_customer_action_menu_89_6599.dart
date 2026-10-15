import 'package:flutter/material.dart';

const _ink = Color(0xFF1D1B20);
const _gray = Color(0xFF6B6F76);
const _lgray = Color(0xFF9AA0A6);
const _purple = Color(0xFF673AB7);
const _lime = Color(0xFFDAFFAF);
const _limeInk = Color(0xFF1D3B00);
const _red = Color(0xFFF44336);
const _line = Color(0xFFE4E7EB);
const _line2 = Color(0xFFEDF0F2);

/// 顧客の操作メニュー Figma 89:6599
class MobileCustomerActionMenu896599 extends StatelessWidget {
  const MobileCustomerActionMenu896599({super.key});

  @override
  Widget build(BuildContext context) {
    return _frame([
      _box(0, 0, 390, 844, color: const Color(0xFFF3F7F6)),
      _box(0, 0, 390, 44, color: Colors.white),
      _txt(30, 13.5, '9:41', 15, _ink),
      _ico(303, 14, Icons.signal_cellular_alt_rounded, 17, _ink),
      _ico(325, 14, Icons.wifi_rounded, 17, _ink),
      _ico(347, 14, Icons.battery_full_rounded, 17, _ink),
      _box(0, 44, 390, 52, color: Colors.white),
      _ico(16, 60, Icons.menu_rounded, 20, _ink),
      _txt(52, 59, '顧客管理', 18, _ink),
      _ico(306, 60, Icons.auto_awesome_rounded, 20, _ink),
      _ico(352, 60, Icons.search_rounded, 20, _ink),
      _box(
        14,
        106,
        76,
        34,
        color: _lime,
        radius: 10,
        border: const Color(0xFFB9EA80),
      ),
      _txt(28, 115.5, '氏名順 ▾', 13, _limeInk),
      _box(96, 106, 76, 34, color: Colors.white, radius: 10, border: _line),
      _txt(110, 115.5, '企業名 ▾', 13, _ink),
      _box(179, 106, 102, 34, color: Colors.white, radius: 10, border: _line),
      _txt(193, 115.5, '前回経過日 ▾', 13, _ink),
      _box(14, 150, 362, 705, color: Colors.white, radius: 14, border: _line2),
      _box(15, 151, 360, 64, color: const Color(0xFFF6F0FF)),
      _box(29, 164, 38, 38, color: const Color(0xFFEDE7F6), radius: 19),
      _ico(38, 173, Icons.person_rounded, 20, _purple),
      _txt(77, 165.5, '青木 一郎 様', 14, _purple),
      _txt(77, 186, '株式会社アオキ', 11.5, _gray, FontWeight.w400),
      _txt(296, 165.5, '12日', 16, const Color(0xFF1E88E5), FontWeight.w900),
      _txt(291, 188.5, '前回から', 10, _gray, FontWeight.w400),
      _ico(341, 173, Icons.more_vert_rounded, 20, _lgray),
      _box(15, 215, 360, 64, color: Colors.white),
      _box(29, 228, 38, 38, color: const Color(0xFFEDE7F6), radius: 19),
      _ico(38, 237, Icons.person_rounded, 20, _purple),
      _txt(77, 229.5, '伊藤 美咲 様', 14, _ink),
      _txt(77, 250, '愛知県立病院', 11.5, _gray, FontWeight.w400),
      _txt(296, 229.5, '45日', 16, const Color(0xFF1E88E5), FontWeight.w900),
      _txt(291, 252.5, '前回から', 10, _gray, FontWeight.w400),
      _ico(341, 237, Icons.more_vert_rounded, 20, _lgray),
      _box(15, 279, 360, 64, color: Colors.white),
      _box(29, 292, 38, 38, color: const Color(0xFFEDE7F6), radius: 19),
      _ico(38, 301, Icons.person_rounded, 20, _purple),
      _txt(77, 293.5, '上田 健太 様', 14, _ink),
      _txt(77, 314, '上田工業株式会社', 11.5, _gray, FontWeight.w400),
      _txt(296, 293.5, '98日', 16, const Color(0xFFF4511E), FontWeight.w900),
      _txt(291, 316.5, '前回から', 10, _gray, FontWeight.w400),
      _ico(341, 301, Icons.more_vert_rounded, 20, _lgray),
      _box(15, 343, 360, 64, color: Colors.white),
      _box(29, 356, 38, 38, color: const Color(0xFFEDE7F6), radius: 19),
      _ico(38, 365, Icons.person_rounded, 20, _purple),
      _txt(77, 357.5, '遠藤 由美 様', 14, _ink),
      _txt(77, 378, '個人宅', 11.5, _gray, FontWeight.w400),
      _txt(286, 357.5, '150日', 16, const Color(0xFFF4511E), FontWeight.w900),
      _txt(291, 380.5, '前回から', 10, _gray, FontWeight.w400),
      _ico(341, 365, Icons.more_vert_rounded, 20, _lgray),
      _box(15, 407, 360, 64, color: Colors.white),
      _box(29, 420, 38, 38, color: const Color(0xFFEDE7F6), radius: 19),
      _ico(38, 429, Icons.person_rounded, 20, _purple),
      _txt(77, 421.5, '大野 浩二 様', 14, _ink),
      _txt(77, 442, '大野商事', 11.5, _gray, FontWeight.w400),
      _txt(286, 421.5, '200日', 16, const Color(0xFFF4511E), FontWeight.w900),
      _txt(291, 444.5, '前回から', 10, _gray, FontWeight.w400),
      _ico(341, 429, Icons.more_vert_rounded, 20, _lgray),
      _box(15, 471, 360, 64, color: Colors.white),
      _box(29, 484, 38, 38, color: const Color(0xFFEDE7F6), radius: 19),
      _ico(38, 493, Icons.person_rounded, 20, _purple),
      _txt(77, 485.5, '加藤 真理 様', 14, _ink),
      _txt(77, 506, '岡崎市役所', 11.5, _gray, FontWeight.w400),
      _txt(286, 485.5, '420日', 16, _lgray, FontWeight.w900),
      _txt(291, 508.5, '前回から', 10, _gray, FontWeight.w400),
      _ico(341, 493, Icons.more_vert_rounded, 20, _lgray),
      _box(15, 535, 360, 64, color: Colors.white),
      _box(29, 548, 38, 38, color: const Color(0xFFEDE7F6), radius: 19),
      _ico(38, 557, Icons.person_rounded, 20, _purple),
      _txt(77, 549.5, '木村 拓也 様', 14, _ink),
      _txt(77, 570, '株式会社キムラ', 11.5, _gray, FontWeight.w400),
      _txt(316, 549.5, '—', 16, _lgray, FontWeight.w900),
      _txt(291, 572.5, '前回から', 10, _gray, FontWeight.w400),
      _ico(341, 557, Icons.more_vert_rounded, 20, _lgray),
      _box(15, 599, 360, 64, color: Colors.white),
      _box(29, 612, 38, 38, color: const Color(0xFFEDE7F6), radius: 19),
      _ico(38, 621, Icons.person_rounded, 20, _purple),
      _txt(77, 613.5, '久保田 愛 様', 14, _ink),
      _txt(77, 634, '個人宅', 11.5, _gray, FontWeight.w400),
      _txt(305, 613.5, '7日', 16, const Color(0xFF1E88E5), FontWeight.w900),
      _txt(291, 636.5, '前回から', 10, _gray, FontWeight.w400),
      _ico(341, 621, Icons.more_vert_rounded, 20, _lgray),
      _box(15, 663, 360, 64, color: Colors.white),
      _box(29, 676, 38, 38, color: const Color(0xFFEDE7F6), radius: 19),
      _ico(38, 685, Icons.person_rounded, 20, _purple),
      _txt(77, 677.5, '小林 誠 様', 14, _ink),
      _txt(77, 698, '小林建設', 11.5, _gray, FontWeight.w400),
      _txt(286, 677.5, '120日', 16, const Color(0xFFF4511E), FontWeight.w900),
      _txt(291, 700.5, '前回から', 10, _gray, FontWeight.w400),
      _ico(341, 685, Icons.more_vert_rounded, 20, _lgray),
      _box(15, 727, 360, 64, color: Colors.white),
      _box(29, 740, 38, 38, color: const Color(0xFFEDE7F6), radius: 19),
      _ico(38, 749, Icons.person_rounded, 20, _purple),
      _txt(77, 741.5, '斎藤 恵子 様', 14, _ink),
      _txt(77, 762, '斎藤医院', 11.5, _gray, FontWeight.w400),
      _txt(296, 741.5, '30日', 16, const Color(0xFF1E88E5), FontWeight.w900),
      _txt(291, 764.5, '前回から', 10, _gray, FontWeight.w400),
      _ico(341, 749, Icons.more_vert_rounded, 20, _lgray),
      _box(15, 791, 360, 63, color: Colors.white),
      _box(29, 804, 38, 38, color: const Color(0xFFEDE7F6), radius: 19),
      _ico(38, 813, Icons.person_rounded, 20, _purple),
      _txt(77, 805.5, '佐藤 次郎 様', 14, _ink),
      _txt(77, 826, '佐藤製作所', 11.5, _gray, FontWeight.w400),
      _txt(296, 805.5, '85日', 16, const Color(0xFFF4511E), FontWeight.w900),
      _txt(291, 828.5, '前回から', 10, _gray, FontWeight.w400),
      _ico(341, 813, Icons.more_vert_rounded, 20, _lgray),
      _box(0, 762, 390, 82, color: Colors.white, border: _line),
      _ico(32, 774, Icons.post_add_rounded, 20, _gray),
      _txt(21, 802, '受注入力', 10.5, _gray, FontWeight.w500),
      _ico(109, 774, Icons.list_alt_rounded, 20, _gray),
      _txt(98, 802, '受注一覧', 10.5, _gray, FontWeight.w500),
      _ico(185, 774, Icons.local_shipping_rounded, 20, _gray),
      _txt(174, 802, '配送予定', 10.5, _gray, FontWeight.w500),
      _box(243, 769, 56, 30, color: const Color(0xFFEDE7F6), radius: 15),
      _ico(261, 774, Icons.people_rounded, 20, _purple),
      _txt(261, 802, '顧客', 10.5, _purple),
      _ico(338, 774, Icons.apps_rounded, 20, _gray),
      _txt(327, 802, 'メニュー', 10.5, _gray, FontWeight.w500),
      _box(0, 0, 390, 844, color: const Color(0x7A121218)),
      _box(10, 608, 370, 146, color: Colors.white, radius: 16),
      _txt(162, 621.5, '青木 一郎 様', 12, _gray, FontWeight.w500),
      _ico(166, 666, Icons.info_rounded, 20, _ink),
      _txt(194.5, 666.5, '詳細', 15, _ink, FontWeight.w500),
      _ico(166, 718, Icons.delete_outline_rounded, 20, _red),
      _txt(194.5, 718.5, '削除', 15, _red, FontWeight.w500),
      _box(10, 762, 370, 52, color: Colors.white, radius: 16),
      _txt(157.5, 778.5, 'キャンセル', 15, _purple, FontWeight.w500),
      _box(128, 831, 134, 5, color: const Color(0xFF111111), radius: 2.5),
    ]);
  }
}

Widget _box(
  double l,
  double t,
  double w,
  double h, {
  Color? color,
  double radius = 0,
  Color? border,
}) {
  return Positioned(
    left: l,
    top: t,
    width: w,
    height: h,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border == null ? null : Border.all(color: border, width: 1),
      ),
    ),
  );
}

Widget _txt(
  double l,
  double t,
  String s,
  double size,
  Color c, [
  FontWeight w = FontWeight.w700,
]) {
  return Positioned(
    left: l,
    top: t,
    child: Text(
      s,
      softWrap: false,
      style: TextStyle(fontSize: size, color: c, fontWeight: w, height: 1.2),
    ),
  );
}

Widget _ico(double l, double t, IconData i, double size, Color c) {
  return Positioned(
    left: l,
    top: t,
    child: Icon(i, size: size, color: c),
  );
}

Widget _frame(List<Widget> children) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Center(
        child: FittedBox(
          child: SizedBox(
            width: 390,
            height: 844,
            child: Stack(children: children),
          ),
        ),
      ),
    ),
  );
}
