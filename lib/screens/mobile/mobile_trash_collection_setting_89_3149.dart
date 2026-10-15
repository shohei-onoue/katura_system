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

class MobileTrashCollectionSetting893149 extends StatelessWidget {
  const MobileTrashCollectionSetting893149({super.key});

  @override
  Widget build(BuildContext context) {
    return _frame([
      _b(0, 0, 390, 44, Color(0xFFFFFFFF)),
      _t(30, 13.5, '9:41', 15, Color(0xFF1D1B20)),
      _i(303, 14, Icons.signal_cellular_alt, 17, Color(0xFF1D1B20)),
      _i(325, 14, Icons.wifi, 17, Color(0xFF1D1B20)),
      _i(347, 14, Icons.battery_full, 17, Color(0xFF1D1B20)),
      _b(0, 44, 390, 52, Color(0xFFFFFFFF)),
      _i(16, 60, Icons.close, 20, Color(0xFF1D1B20)),
      _t(52, 59, '受注入力', 18, Color(0xFF1D1B20)),
      _t(273, 60.5, '0564-12-3456', 15, Color(0xFF673AB7), w: FontWeight.w900),
      _b(0, 96, 390, 59, Color(0xFFFFFFFF)),
      _b(47, 104, 22, 22, Color(0xFF4CAF50), r: 11, bc: Color(0xFF4CAF50)),
      _i(51, 108, Icons.check, 14, Color(0xFFFFFFFF)),
      _t(38, 130.5, '番号確認', 10, Color(0xFF1D1B20), w: FontWeight.w500),
      _b(138, 104, 22, 22, Color(0xFF4CAF50), r: 11, bc: Color(0xFF4CAF50)),
      _i(142, 108, Icons.check, 14, Color(0xFFFFFFFF)),
      _t(119, 130.5, '配達先の確定', 10, Color(0xFF1D1B20), w: FontWeight.w500),
      _b(230, 104, 22, 22, Color(0xFFFF6D00), r: 11, bc: Color(0xFFFF6D00)),
      _t(238, 108.5, '3', 11, Color(0xFFFFFFFF)),
      _t(221, 130.5, '注文内容', 10, Color(0xFFFF6D00)),
      _b(321, 104, 22, 22, Color(0xFFFFFFFF), r: 11, bc: Color(0xFFCFD3D8)),
      _t(329, 108.5, '4', 11, Color(0xFF9AA0A6)),
      _t(322, 130.5, '完了', 10, Color(0xFF9AA0A6), w: FontWeight.w500),
      _b(14, 165, 145, 34, Color(0xFFDAFFAF), r: 10, bc: Color(0xFFB9EA80)),
      _t(28, 174.5, '厳選牛ステーキ弁当', 13, Color(0xFF1D3B00)),
      _b(165, 165, 80, 34, Color(0xFFFFFFFF), r: 10, bc: Color(0xFFE4E7EB)),
      _t(179, 174.5, '高級弁当', 13, Color(0xFF1D1B20)),
      _b(251, 165, 93, 34, Color(0xFFFFFFFF), r: 10, bc: Color(0xFFE4E7EB)),
      _t(265, 174.5, 'オードブル', 13, Color(0xFF1D1B20)),
      _b(350, 165, 67, 34, Color(0xFFFFFFFF), r: 10, bc: Color(0xFFE4E7EB)),
      _t(364, 174.5, '丼もの', 13, Color(0xFF1D1B20)),
      _b(423, 165, 67, 34, Color(0xFFFFFFFF), r: 10, bc: Color(0xFFE4E7EB)),
      _t(437, 174.5, 'ギフト', 13, Color(0xFF1D1B20)),
      _b(
        14,
        211,
        176,
        176,
        Color(0xFFFFFFFF),
        r: 14,
        bc: Color(0xFF673AB7),
        bw: 2,
      ),
      _b(16, 213, 172, 84, Color(0xFFEEF0F2)),
      _i(87, 240, Icons.restaurant, 30, Color(0xFFB5BAC0)),
      _b(22, 219, 56, 19, Color(0xFFFF7043), r: 6),
      _t(29, 222, '前回注文', 10.5, Color(0xFFFFFFFF)),
      _t(26, 306.5, '特製ステーキ弁当', 13, Color(0xFF1D1B20)),
      _t(26, 325.5, '¥1,800', 13, Color(0xFFF44336)),
      _b(26, 349, 28, 28, null, r: 14, bc: Color(0xFFE4E7EB)),
      _i(32, 355, Icons.remove, 16, Color(0xFF1D1B20)),
      _t(98, 354.5, '2', 15, Color(0xFF673AB7)),
      _b(150, 349, 28, 28, Color(0xFF673AB7), r: 14),
      _i(156, 355, Icons.add, 16, Color(0xFFFFFFFF)),
      _b(
        200,
        211,
        176,
        176,
        Color(0xFFFFFFFF),
        r: 14,
        bc: Color(0xFF673AB7),
        bw: 2,
      ),
      _b(202, 213, 172, 84, Color(0xFFEEF0F2)),
      _i(273, 240, Icons.restaurant, 30, Color(0xFFB5BAC0)),
      _t(212, 306.5, '厳選牛ステーキ重', 13, Color(0xFF1D1B20)),
      _t(212, 325.5, '¥2,400', 13, Color(0xFFF44336)),
      _b(212, 349, 28, 28, null, r: 14, bc: Color(0xFFE4E7EB)),
      _i(218, 355, Icons.remove, 16, Color(0xFF1D1B20)),
      _t(284, 354.5, '1', 15, Color(0xFF673AB7)),
      _b(336, 349, 28, 28, Color(0xFF673AB7), r: 14),
      _i(342, 355, Icons.add, 16, Color(0xFFFFFFFF)),
      _b(14, 397, 176, 174, Color(0xFFFFFFFF), r: 14, bc: Color(0xFFEDF0F2)),
      _b(15, 398, 174, 84, Color(0xFFEEF0F2)),
      _i(87, 425, Icons.restaurant, 30, Color(0xFFB5BAC0)),
      _t(25, 491.5, 'ステーキ弁当 大盛', 13, Color(0xFF1D1B20)),
      _t(25, 510.5, '¥2,800', 13, Color(0xFFF44336)),
      _b(25, 534, 28, 28, null, r: 14, bc: Color(0xFFE4E7EB)),
      _i(31, 540, Icons.remove, 16, Color(0xFF1D1B20)),
      _t(98, 539.5, '0', 15, Color(0xFF1D1B20)),
      _b(151, 534, 28, 28, Color(0xFF673AB7), r: 14),
      _i(157, 540, Icons.add, 16, Color(0xFFFFFFFF)),
      _b(200, 397, 176, 174, Color(0xFFFFFFFF), r: 14, bc: Color(0xFFEDF0F2)),
      _b(201, 398, 174, 84, Color(0xFFEEF0F2)),
      _i(273, 425, Icons.restaurant, 30, Color(0xFFB5BAC0)),
      _t(211, 491.5, 'ステーキ弁当 並', 13, Color(0xFF1D1B20)),
      _t(211, 510.5, '¥1,500', 13, Color(0xFFF44336)),
      _b(211, 534, 28, 28, null, r: 14, bc: Color(0xFFE4E7EB)),
      _i(217, 540, Icons.remove, 16, Color(0xFF1D1B20)),
      _t(284, 539.5, '0', 15, Color(0xFF1D1B20)),
      _b(337, 534, 28, 28, Color(0xFF673AB7), r: 14),
      _i(343, 540, Icons.add, 16, Color(0xFFFFFFFF)),
      _b(0, 720, 390, 124, Color(0xFFFFFFFF), r: 18, bc: Color(0xFFE4E7EB)),
      _i(14, 736, Icons.shopping_cart, 20, Color(0xFF673AB7)),
      _t(42, 737.5, 'カートの中身', 13, Color(0xFF1D1B20)),
      _b(128, 736, 31, 19, Color(0xFFEDE7F6), r: 6),
      _t(135, 739, '2品', 10.5, Color(0xFF673AB7)),
      _t(223, 739, '合計 3個', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _t(283, 733.5, '¥6,000', 20, Color(0xFFF44336)),
      _i(356, 736, Icons.expand_less, 20, Color(0xFF9AA0A6)),
      _b(14, 768, 178, 48, Color(0xFFFFFFFF), r: 12, bc: Color(0xFFE4E7EB)),
      _i(93, 782, Icons.delete_outline, 20, Color(0xFF1D1B20)),
      _b(200, 768, 176, 48, Color(0xFF673AB7), r: 12),
      _t(220.5, 783.5, '注文内容を確定する', 15, Color(0xFFFFFFFF)),
      _b(0, 0, 390, 844, Color(0x7A121218)),
      _b(0, 634, 390, 210, Color(0xFFFFFFFF), r: 22),
      _b(175, 642, 40, 5, Color(0xFFD4D7DC), r: 2.5),
      _t(30, 663.5, 'ゴミ回収の設定', 17, Color(0xFF1D1B20)),
      _b(344, 655, 36, 36, Color(0xFFF1F3F5), r: 18),
      _i(352, 663, Icons.close, 20, Color(0xFF1D1B20)),
      _b(18, 701, 354, 42, Color(0xFFECEFF1), r: 12),
      _b(21, 704, 174, 36, Color(0xFFDAFFAF), r: 10),
      _t(95, 714.5, 'なし', 13, Color(0xFF1D3B00)),
      _t(269, 714.5, 'あり', 13, Color(0xFF6B6F76)),
      _b(0, 755, 390, 89, null, bc: Color(0xFFE4E7EB)),
      _b(18, 766, 172, 48, Color(0xFFF44336), r: 12),
      _t(66.5, 781.5, 'キャンセル', 15, Color(0xFFFFFFFF)),
      _b(200, 766, 172, 48, Color(0xFF673AB7), r: 12),
      _t(271.5, 781.5, '次へ', 15, Color(0xFFFFFFFF)),
      _b(128, 831, 134, 5, Color(0xFF111111), r: 2.5),
    ]);
  }
}
