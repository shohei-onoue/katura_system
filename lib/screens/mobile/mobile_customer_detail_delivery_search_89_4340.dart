// Figma node 89:4340 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

class MobileCustomerDetailDeliverySearch894340 extends StatelessWidget {
  const MobileCustomerDetailDeliverySearch894340({super.key});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1D1B20);
    const grey = Color(0xFF6B6F76);
    const purple = Color(0xFF673AB7);
    const line = Color(0xFFE4E7EB);
    const fields = [
      ['顧客名', '青木 一郎'],
      ['ふりがな', 'あおき いちろう'],
      ['電話番号', '0564-12-3456'],
      ['企業名', '株式会社アオキ'],
      ['住所', '愛知県岡崎市康生通西4丁目71'],
      ['座標', '34.9546, 137.1744'],
    ];
    final fieldWidgets = <Widget>[];
    for (var i = 0; i < fields.length; i++) {
      final y = 71.0 * i;
      fieldWidgets.addAll([
        _t(14, 107 + y, fields[i][0], 11.5, grey, FontWeight.w700),
        _r(14, 127 + y, 362, 44, const Color(0xFFF6F7F9), rad: 10, bc: line),
        _t(27, 140.5 + y, fields[i][1], 14, dark, FontWeight.w400),
        _i(345, 140 + y, Icons.edit, 18, grey),
      ]);
    }
    const history = [
      ['株式会社アオキ', '愛知県岡崎市康生通西4丁目71'],
      ['愛知県立病院', '愛知県岡崎市高隆寺町峠1'],
      ['個人宅', '愛知県岡崎市明大寺町字道城7'],
    ];
    final historyWidgets = <Widget>[];
    for (var i = 0; i < history.length; i++) {
      final y = 68.0 * i;
      historyWidgets.addAll([
        _r(
          14,
          563 + y,
          362,
          58,
          i == 0 ? const Color(0xFFDAFFAF) : Colors.white,
          rad: 14,
          bc: const Color(0xFFEDF0F2),
        ),
        _i(27, 582 + y, Icons.business, 20, const Color(0xFFFF7043)),
        _t(55, 575.5 + y, history[i][0], 14, dark, FontWeight.w700),
        _t(55, 595 + y, history[i][1], 11.5, grey, FontWeight.w400),
        _r(309, 577 + y, 54, 30, Colors.white, rad: 15, bc: const Color(0xFFF44336)),
        _t(323, 584.5 + y, '調整', 13, const Color(0xFFF44336), FontWeight.w700),
      ]);
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
                _r(0, 0, 390, 844, const Color(0xFFF3F7F6)),
                _r(0, 0, 390, 44, purple),
                _t(30, 13.5, '9:41', 15, Colors.white, FontWeight.w700),
                _i(303, 14, Icons.signal_cellular_alt, 17, Colors.white),
                _i(325, 14, Icons.wifi, 17, Colors.white),
                _i(347, 14, Icons.battery_full, 17, Colors.white),
                _r(0, 44, 390, 52, purple),
                _i(16, 60, Icons.close, 20, Colors.white),
                _t(52, 59, '顧客詳細', 18, Colors.white, FontWeight.w700),
                ...fieldWidgets,
                _t(16, 541.5, '配達先履歴', 12, grey, FontWeight.w700),
                ...historyWidgets,
                _r(0, 757, 390, 87, Colors.white, bc: line),
                _r(14, 768, 177, 48, Colors.white, rad: 12, bc: line),
                _t(80.5, 783.5, '閉じる', 15, dark, FontWeight.w700),
                _r(201, 768, 175, 48, purple, rad: 12),
                _t(273.5, 783.5, '保存', 15, Colors.white, FontWeight.w700),
                _r(0, 0, 390, 844, const Color(0x7A121218)),
                _r(0, 559, 390, 285, Colors.white, rad: 22),
                _r(175, 567, 40, 5, const Color(0xFFD4D7DC), rad: 2.5),
                _t(30, 588.5, '配達先の検索', 17, dark, FontWeight.w700),
                _r(344, 580, 36, 36, const Color(0xFFF1F3F5), rad: 18),
                _i(352, 588, Icons.close, 20, dark),
                _r(18, 626, 354, 42, const Color(0xFFECEFF1), rad: 12),
                _r(21, 629, 116, 36, const Color(0xFFDAFFAF), rad: 10),
                _i(71, 629, Icons.category, 16, const Color(0xFF1D3B00)),
                _t(33, 647.5, '地域・カテゴリ', 13, const Color(0xFF1D3B00), FontWeight.w700),
                _i(187, 629, Icons.search, 16, grey),
                _t(162, 647.5, 'キーワード', 13, grey, FontWeight.w700),
                _i(303, 629, Icons.pin_drop, 16, grey),
                _t(298, 647.5, '住所', 13, grey, FontWeight.w700),
                _t(18, 679, '地域・カテゴリ選択', 11.5, grey, FontWeight.w700),
                _r(18, 699, 274, 44, const Color(0xFFF6F7F9), rad: 10, bc: line),
                _t(31, 712.5, '未選択', 14, const Color(0xFF9AA0A6), FontWeight.w400),
                _i(261, 712, Icons.unfold_more, 18, grey),
                _r(300, 699, 72, 44, const Color(0xFF78909C), rad: 10),
                _i(313, 713, Icons.map, 16, Colors.white),
                _t(333, 713.5, '調整', 13, Colors.white, FontWeight.w700),
                _r(0, 755, 390, 89, null, bc: line),
                _r(18, 766, 173, 48, Colors.white, rad: 12, bc: line),
                _t(82.5, 781.5, '閉じる', 15, dark, FontWeight.w700),
                _r(201, 766, 171, 48, purple, rad: 12),
                _t(271.5, 781.5, '保存', 15, Colors.white, FontWeight.w700),
                _r(128, 831, 134, 5, const Color(0xFF111111), rad: 2.5),
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
        border: bc == null ? null : Border.all(color: bc),
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
