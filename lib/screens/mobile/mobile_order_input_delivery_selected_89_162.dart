// Figma node 89:162 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

class MobileOrderInputDeliverySelected89162 extends StatelessWidget {
  const MobileOrderInputDeliverySelected89162({super.key});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1D1B20);
    const gray = Color(0xFF6B6F76);
    const pin = Color(0xFFB0B5BB);
    const w = Colors.white;
    const bold = FontWeight.w700;
    const reg = FontWeight.w400;

    Widget row(double y, double h, String name, String addr, bool sel) {
      return Stack(
        children: [
          _r(15, y, 360, h, sel ? Color(0xFFDAFFAF) : w),
          _i(29, y + 21, Icons.location_on, 20, sel ? Color(0xFF3D7A00) : pin),
          _t(59, y + 13.5, name, 14, dark, bold),
          _t(59, y + 34, addr, 11.5, gray, reg),
          if (sel) _i(268, y + 21, Icons.check_circle, 20, Color(0xFFFF7043)),
          _r(298, y + 15, 63, 32, Color(0xFF78909C), rad: 10),
          _i(307, y + 24, Icons.map, 15, w),
          _t(326, y + 23.5, '調整', 13, w, bold),
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
                _i(16, 60, Icons.close, 20, dark),
                _t(52, 59, '受注入力', 18, dark, bold),
                _t(273, 60.5, '0564-12-3456', 15, Color(0xFF673AB7), FontWeight.w900),
                _r(0, 96, 390, 59, w),
                _r(47, 104, 22, 22, Color(0xFF4CAF50),
                    rad: 11, bc: Color(0xFF4CAF50)),
                _i(51, 108, Icons.check, 14, w),
                _t(38, 130.5, '番号確認', 10, dark, FontWeight.w500),
                _r(138, 104, 22, 22, Color(0xFFFF6D00),
                    rad: 11, bc: Color(0xFFFF6D00)),
                _t(146, 108.5, '2', 11, w, bold),
                _t(119, 130.5, '配達先の確定', 10, Color(0xFFFF6D00), bold),
                _r(230, 104, 22, 22, w, rad: 11, bc: Color(0xFFCFD3D8)),
                _t(238, 108.5, '3', 11, Color(0xFF9AA0A6), bold),
                _t(221, 130.5, '注文内容', 10, Color(0xFF9AA0A6), FontWeight.w500),
                _r(321, 104, 22, 22, w, rad: 11, bc: Color(0xFFCFD3D8)),
                _t(329, 108.5, '4', 11, Color(0xFF9AA0A6), bold),
                _t(322, 130.5, '完了', 10, Color(0xFF9AA0A6), FontWeight.w500),
                _r(14, 165, 362, 42, Color(0xFFECEFF1), rad: 12),
                _r(17, 168, 178, 36, Color(0xFFDAFFAF), rad: 10),
                _t(67, 178.5, '履歴から選択', 13, Color(0xFF1D3B00), bold),
                _t(258, 178.5, '新規登録', 13, gray, bold),
                _r(14, 219, 362, 188, w, rad: 14, bc: Color(0xFFEDF0F2)),
                row(220, 63, '愛知県立病院', '愛知県岡崎市高隆寺町峠1', false),
                row(283, 62, '株式会社アオキ', '愛知県岡崎市康生通西4丁目71', true),
                row(345, 61, '個人宅', '愛知県岡崎市明大寺町字道城7', false),
                _t(16, 422.5, '配達先情報の確認', 12, gray, bold),
                _r(14, 444, 362, 258, w, rad: 14, bc: Color(0xFFEDF0F2)),
                _r(15, 445, 360, 170, Color(0xFFCFE5D2)),
                _t(126.5, 522, '地図（Googleマップ）', 13, Color(0xFF5B8A65), bold),
                _i(29, 631, Icons.store, 15, Color(0xFF1E88E5)),
                _t(44, 630, '岡崎本店 →', 11.5, dark, reg),
                _i(109, 631, Icons.location_on, 15, Color(0xFFF44336)),
                _i(29, 652, Icons.business, 15, dark),
                _t(44, 651, '株式会社アオキ', 11.5, dark, bold),
                _i(29, 673, Icons.place, 15, dark),
                _t(44, 671, '愛知県岡崎市康生通西4丁目71', 11.5, dark, bold),
                _r(0, 757, 390, 87, w, bc: Color(0xFFE4E7EB)),
                _r(14, 768, 176, 48, Color(0xFFF44336), rad: 12),
                _t(72.5, 783.5, '注文中止', 15, w, bold),
                _r(200, 768, 176, 48, Color(0xFF673AB7), rad: 12),
                _t(258.5, 783.5, '商品選択', 15, w, bold),
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
