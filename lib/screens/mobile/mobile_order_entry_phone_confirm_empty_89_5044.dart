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

class MobileOrderEntryPhoneConfirmEmpty895044 extends StatelessWidget {
  const MobileOrderEntryPhoneConfirmEmpty895044({super.key});

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
      _b(0, 96, 390, 59, Color(0xFFFFFFFF)),
      _b(47, 104, 22, 22, Color(0xFFFF6D00), r: 11, bc: Color(0xFFFF6D00)),
      _t(55, 108.5, '1', 11, Color(0xFFFFFFFF)),
      _t(38, 130.5, '番号確認', 10, Color(0xFFFF6D00)),
      _b(138, 104, 22, 22, Color(0xFFFFFFFF), r: 11, bc: Color(0xFFCFD3D8)),
      _t(146, 108.5, '2', 11, Color(0xFF9AA0A6)),
      _t(119, 130.5, '配達先の確定', 10, Color(0xFF9AA0A6), w: FontWeight.w500),
      _b(230, 104, 22, 22, Color(0xFFFFFFFF), r: 11, bc: Color(0xFFCFD3D8)),
      _t(238, 108.5, '3', 11, Color(0xFF9AA0A6)),
      _t(221, 130.5, '注文内容', 10, Color(0xFF9AA0A6), w: FontWeight.w500),
      _b(321, 104, 22, 22, Color(0xFFFFFFFF), r: 11, bc: Color(0xFFCFD3D8)),
      _t(329, 108.5, '4', 11, Color(0xFF9AA0A6)),
      _t(322, 130.5, '完了', 10, Color(0xFF9AA0A6), w: FontWeight.w500),
      _b(14, 167, 362, 146, Color(0xFFFFFFFF), r: 14, bc: Color(0xFFEDF0F2)),
      _b(15, 168, 360, 37, Color(0xFF673AB7)),
      _t(29, 178.5, '下４桁を入力', 13, Color(0xFFFFFFFF)),
      _t(
        129.5,
        227.5,
        '0000',
        52,
        Color(0xFFD5D8DC),
        w: FontWeight.w900,
        ls: 2,
      ),
      _b(0, 522, 390, 322, Color(0xFFFFFFFF), bc: Color(0xFFE4E7EB)),
      _t(16, 532, '入力ダイヤル', 11.5, Color(0xFF6B6F76)),
      _b(14, 559, 115, 56, Color(0xFF2E3440), r: 14),
      _t(64, 573, '1', 24, Color(0xFFFFFFFF)),
      _b(138, 559, 115, 56, Color(0xFF2E3440), r: 14),
      _t(188, 573, '2', 24, Color(0xFFFFFFFF)),
      _b(261, 559, 115, 56, Color(0xFF2E3440), r: 14),
      _t(312, 573, '3', 24, Color(0xFFFFFFFF)),
      _b(14, 624, 115, 56, Color(0xFF2E3440), r: 14),
      _t(64, 638, '4', 24, Color(0xFFFFFFFF)),
      _b(138, 624, 115, 56, Color(0xFF2E3440), r: 14),
      _t(188, 638, '5', 24, Color(0xFFFFFFFF)),
      _b(261, 624, 115, 56, Color(0xFF2E3440), r: 14),
      _t(312, 638, '6', 24, Color(0xFFFFFFFF)),
      _b(14, 689, 115, 56, Color(0xFF2E3440), r: 14),
      _t(64, 703, '7', 24, Color(0xFFFFFFFF)),
      _b(138, 689, 115, 56, Color(0xFF2E3440), r: 14),
      _t(188, 703, '8', 24, Color(0xFFFFFFFF)),
      _b(261, 689, 115, 56, Color(0xFF2E3440), r: 14),
      _t(312, 703, '9', 24, Color(0xFFFFFFFF)),
      _b(14, 754, 115, 56, Color(0xFF6C737E), r: 14),
      _t(49, 773.5, 'クリア', 15, Color(0xFFFFFFFF)),
      _b(138, 754, 115, 56, Color(0xFF2E3440), r: 14),
      _t(188, 768, '0', 24, Color(0xFFFFFFFF)),
      _b(261, 754, 115, 56, Color(0xFF6C737E), r: 14),
      _i(307, 770, Icons.backspace, 24, Color(0xFFFFFFFF)),
      _b(128, 831, 134, 5, Color(0xFF111111), r: 2.5),
    ]);
  }
}
