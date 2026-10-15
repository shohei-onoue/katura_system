import 'package:flutter/material.dart';

Widget _b(
  double l,
  double t,
  double w,
  double h,
  Color? c, {
  double r = 0,
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
        borderRadius: BorderRadius.circular(r),
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
  Color c, {
  FontWeight w = FontWeight.w700,
  double? ls,
  double? width,
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
        decoration: TextDecoration.none,
      ),
    ),
  );
}

Widget _i(double l, double t, IconData icon, double size, Color c) {
  return Positioned(
    left: l,
    top: t,
    child: Icon(icon, size: size, color: c),
  );
}

Widget _frame(List<Widget> children) {
  return Scaffold(
    backgroundColor: const Color(0xFFF3F7F6),
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
}

class MobileDataAnalysisStoreBreakdown892542 extends StatelessWidget {
  const MobileDataAnalysisStoreBreakdown892542({super.key});

  @override
  Widget build(BuildContext context) {
    return _frame([
      _b(0, 0, 390, 44, Color(0xFFFFFFFF)),
      _t(30, 13.5, '9:41', 15, Color(0xFF1D1B20)),
      _i(303, 14, Icons.signal_cellular_alt, 17, Color(0xFF1D1B20)),
      _i(325, 14, Icons.wifi, 17, Color(0xFF1D1B20)),
      _i(347, 14, Icons.battery_full, 17, Color(0xFF1D1B20)),
      _b(0, 44, 390, 52, Color(0xFFFFFFFF)),
      _i(16, 60, Icons.menu, 20, Color(0xFF1D1B20)),
      _t(52, 59, 'データ分析', 18, Color(0xFF1D1B20)),
      _b(14, 106, 362, 42, Color(0xFFECEFF1), r: 12),
      _t(67, 119.5, 'ヒートマップ', 13, Color(0xFF6B6F76)),
      _b(195, 109, 178, 36, Color(0xFF673AB7), r: 10),
      _t(264, 119.5, 'グラフ', 13, Color(0xFFFFFFFF)),
      _b(14, 158, 67, 34, Color(0xFFDAFFAF), r: 10, bc: Color(0xFFB9EA80)),
      _t(28, 167.5, '全店舗', 13, Color(0xFF1D3B00)),
      _b(87, 158, 80, 34, Color(0xFFFFFFFF), r: 10, bc: Color(0xFFE4E7EB)),
      _t(101, 167.5, '岡崎本店', 13, Color(0xFF1D1B20)),
      _b(173, 158, 80, 34, Color(0xFFFFFFFF), r: 10, bc: Color(0xFFE4E7EB)),
      _t(187, 167.5, '名古屋店', 13, Color(0xFF1D1B20)),
      _b(259, 158, 67, 34, Color(0xFFFFFFFF), r: 10, bc: Color(0xFFE4E7EB)),
      _t(273, 167.5, '岐阜店', 13, Color(0xFF1D1B20)),
      _b(14, 204, 362, 265, Color(0xFFFFFFFF), r: 14, bc: Color(0xFFEDF0F2)),
      _t(29, 218.5, '店舗別 メニュー注文数', 14, Color(0xFF1D1B20)),
      _t(327, 220, '多い順', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _b(29, 247, 10, 10, Color(0xFF1E88E5), r: 5),
      _t(43, 244.5, '岡崎本店', 11, Color(0xFF6B6F76), w: FontWeight.w400),
      _b(99, 247, 10, 10, Color(0xFF4CAF50), r: 5),
      _t(113, 244.5, '名古屋店', 11, Color(0xFF6B6F76), w: FontWeight.w400),
      _b(169, 247, 10, 10, Color(0xFF9C27B0), r: 5),
      _t(183, 244.5, '岐阜店', 11, Color(0xFF6B6F76), w: FontWeight.w400),
      _t(29, 268, '特製ステーキ弁当', 11.5, Color(0xFF1D1B20), w: FontWeight.w400),
      _b(141, 268, 104, 14, Color(0xFF1E88E5)),
      _b(245, 268, 65, 14, Color(0xFF4CAF50)),
      _b(309, 268, 39, 14, Color(0xFF9C27B0)),
      _t(29, 289, '松花堂弁当', 11.5, Color(0xFF1D1B20), w: FontWeight.w400),
      _b(141, 289, 78, 14, Color(0xFF1E88E5)),
      _b(219, 289, 58, 14, Color(0xFF4CAF50)),
      _b(277, 289, 26, 14, Color(0xFF9C27B0)),
      _t(29, 310, '幕の内弁当', 11.5, Color(0xFF1D1B20), w: FontWeight.w400),
      _b(141, 310, 71, 14, Color(0xFF1E88E5)),
      _b(212, 310, 39, 14, Color(0xFF4CAF50)),
      _b(251, 310, 26, 14, Color(0xFF9C27B0)),
      _t(29, 331, '鶏から揚げオードブル', 11.5, Color(0xFF1D1B20), w: FontWeight.w400),
      _b(141, 331, 52, 14, Color(0xFF1E88E5)),
      _b(193, 331, 32, 14, Color(0xFF4CAF50)),
      _b(225, 331, 19, 14, Color(0xFF9C27B0)),
      _t(29, 352, '親子丼', 11.5, Color(0xFF1D1B20), w: FontWeight.w400),
      _b(141, 352, 45, 14, Color(0xFF1E88E5)),
      _b(186, 352, 19, 14, Color(0xFF4CAF50)),
      _b(206, 352, 16, 14, Color(0xFF9C27B0)),
      _t(29, 373, 'ギフト詰め合わせ', 11.5, Color(0xFF1D1B20), w: FontWeight.w400),
      _b(141, 373, 32, 14, Color(0xFF1E88E5)),
      _b(173, 373, 19, 14, Color(0xFF4CAF50)),
      _b(193, 373, 13, 14, Color(0xFF9C27B0)),
      _t(29, 394, 'ローストビーフ丼', 11.5, Color(0xFF1D1B20), w: FontWeight.w400),
      _b(141, 394, 32, 14, Color(0xFF1E88E5)),
      _b(173, 394, 16, 14, Color(0xFF4CAF50)),
      _b(190, 394, 10, 14, Color(0xFF9C27B0)),
      _t(29, 415, '海鮮ちらし弁当', 11.5, Color(0xFF1D1B20), w: FontWeight.w400),
      _b(141, 415, 29, 14, Color(0xFF1E88E5)),
      _b(170, 415, 13, 14, Color(0xFF4CAF50)),
      _b(183, 415, 10, 14, Color(0xFF9C27B0)),
      _t(29, 436, '唐揚げ弁当', 11.5, Color(0xFF1D1B20), w: FontWeight.w400),
      _b(141, 436, 26, 14, Color(0xFF1E88E5)),
      _b(167, 436, 13, 14, Color(0xFF4CAF50)),
      _b(180, 436, 8, 14, Color(0xFF9C27B0)),
      _b(14, 479, 362, 190, Color(0xFFFFFFFF), r: 14, bc: Color(0xFFEDF0F2)),
      _t(29, 493.5, '月別 人気メニュー', 14, Color(0xFF1D1B20)),
      _t(309, 495, '売上推移 ›', 11.5, Color(0xFF673AB7)),
      _t(29, 521, '10月', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _b(29, 540, 44, 44, Color(0xFFEEF0F2), r: 10),
      _i(41, 552, Icons.restaurant, 20, Color(0xFFB5BAC0)),
      _t(81, 543, '1位', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _t(81, 560.5, '特製ステーキ弁当', 16, Color(0xFF1D1B20)),
      _t(283, 546, '2位', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _t(301, 546, '松花堂弁当', 11.5, Color(0xFF1D1B20), w: FontWeight.w400),
      _t(283, 564, '3位', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _t(301, 564, '幕の内弁当', 11.5, Color(0xFF1D1B20), w: FontWeight.w400),
      _t(29, 593, '9月', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _b(29, 612, 44, 44, Color(0xFFEEF0F2), r: 10),
      _i(41, 624, Icons.restaurant, 20, Color(0xFFB5BAC0)),
      _t(81, 615, '1位', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _t(81, 632.5, '松花堂弁当', 16, Color(0xFF1D1B20)),
      _t(249, 618, '2位', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _t(266, 618, '特製ステーキ弁当', 11.5, Color(0xFF1D1B20), w: FontWeight.w400),
      _t(306, 636, '3位', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _t(324, 636, '親子丼', 11.5, Color(0xFF1D1B20), w: FontWeight.w400),
      _b(0, 762, 390, 82, Color(0xFFFFFFFF), bc: Color(0xFFE4E7EB)),
      _b(320, 769, 56, 30, Color(0xFFEDE7F6), r: 15),
      _i(32, 774, Icons.post_add, 20, Color(0xFF6B6F76)),
      _t(21, 802, '受注入力', 10.5, Color(0xFF6B6F76), w: FontWeight.w500),
      _i(109, 774, Icons.list_alt, 20, Color(0xFF6B6F76)),
      _t(98, 802, '受注一覧', 10.5, Color(0xFF6B6F76), w: FontWeight.w500),
      _i(185, 774, Icons.local_shipping, 20, Color(0xFF6B6F76)),
      _t(174, 802, '配送予定', 10.5, Color(0xFF6B6F76), w: FontWeight.w500),
      _i(261, 774, Icons.people, 20, Color(0xFF6B6F76)),
      _t(261, 802, '顧客', 10.5, Color(0xFF6B6F76), w: FontWeight.w500),
      _i(338, 774, Icons.apps, 20, Color(0xFF673AB7)),
      _t(327, 802, 'メニュー', 10.5, Color(0xFF673AB7)),
      _b(0, 0, 390, 844, Color(0x7A121218)),
      _b(0, 477, 390, 367, Color(0xFFFFFFFF), r: 22),
      _b(175, 485, 40, 5, Color(0xFFD4D7DC), r: 2.5),
      _t(30, 506.5, '特製ステーキ弁当', 17, Color(0xFF1D1B20)),
      _b(344, 498, 36, 36, Color(0xFFF1F3F5), r: 18),
      _i(352, 506, Icons.close, 20, Color(0xFF1D1B20)),
      _b(18, 544, 354, 199, Color(0xFFFFFFFF), r: 14, bc: Color(0xFFEDF0F2)),
      _b(19, 545, 352, 49, Color(0xFFFFFFFF)),
      _b(33, 563, 12, 12, Color(0xFF1E88E5), r: 3),
      _t(55, 560.5, '岡崎本店', 14, Color(0xFF1D1B20)),
      _t(313, 559.5, '160食', 16, Color(0xFF1D1B20)),
      _b(19, 594, 352, 49, Color(0xFFFFFFFF)),
      _b(33, 612, 12, 12, Color(0xFF4CAF50), r: 3),
      _t(55, 609.5, '名古屋店', 14, Color(0xFF1D1B20)),
      _t(313, 608.5, '100食', 16, Color(0xFF1D1B20)),
      _b(19, 643, 352, 49, Color(0xFFFFFFFF)),
      _b(33, 661, 12, 12, Color(0xFF9C27B0), r: 3),
      _t(55, 658.5, '岐阜店', 14, Color(0xFF1D1B20)),
      _t(322, 657.5, '60食', 16, Color(0xFF1D1B20)),
      _b(19, 692, 352, 50, Color(0xFFFFFFFF)),
      _t(33, 708.5, '合計', 14, Color(0xFF1D1B20)),
      _t(307, 706, '320食', 18, Color(0xFFF44336)),
      _b(0, 755, 390, 89, null, bc: Color(0xFFE4E7EB)),
      _b(18, 766, 354, 48, Color(0xFFFFFFFF), r: 12, bc: Color(0xFFE4E7EB)),
      _t(172.5, 781.5, '閉じる', 15, Color(0xFF1D1B20)),
      _b(128, 831, 134, 5, Color(0xFF111111), r: 2.5),
    ]);
  }
}
