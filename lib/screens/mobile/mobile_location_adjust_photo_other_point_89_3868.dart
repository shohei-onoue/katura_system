import 'package:flutter/material.dart';

/// Figma 89:3868 61_場所の微調整と写真撮影（別地点）
class MobileLocationAdjustPhotoOtherPoint893868 extends StatelessWidget {
  const MobileLocationAdjustPhotoOtherPoint893868({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF673AB7);
    const dark = Color(0xFF1D1B20);
    const white = Colors.white;

    Widget fab(double top, IconData icon) => Stack(
      children: [
        _r(332, top, 44, 44, white, r: 22),
        _i(344, top + 12, icon, 20, dark),
      ],
    );

    return _frame([
      _r(0, 0, 390, 844, const Color(0xFFF3F7F6)),
      _r(0, 0, 390, 44, purple),
      _t(30, 13.5, '9:41', 15, white),
      _i(303, 14, Icons.signal_cellular_alt, 17, white),
      _i(325, 14, Icons.wifi, 17, white),
      _i(347, 14, Icons.battery_full, 17, white),
      _r(0, 44, 390, 52, purple),
      _i(16, 60, Icons.close, 20, white),
      _t(52, 59, '場所の微調整と写真撮影', 18, white),
      _r(0, 96, 390, 55, const Color(0xFFF6F2FC)),
      _i(16, 106, Icons.location_on, 20, const Color(0xFFF44336)),
      _t(44, 108.5, '愛知県岡崎市康生通西4丁目71', 13, dark),
      _t(
        44,
        127,
        'ピンをドラッグして配達先の位置を調整できます',
        10.5,
        const Color(0xFF6B6F76),
        w: FontWeight.w400,
      ),
      _r(0, 151, 390, 606, const Color(0xFFCFE5D2)),
      _t(126.5, 446, '地図（Googleマップ）', 13, const Color(0xFF5B8A65)),
      fab(595, Icons.add_a_photo),
      fab(647, Icons.my_location),
      fab(699, Icons.layers),
      _r(0, 757, 390, 87, white, b: const Color(0xFFE4E7EB)),
      _r(14, 768, 362, 48, purple, r: 12),
      _t(120.5, 783.5, 'この地点と写真で確定', 15, white),
      _r(128, 831, 134, 5, const Color(0xFF111111), r: 2.5),
    ]);
  }
}

Widget _r(
  double l,
  double t,
  double w,
  double h,
  Color c, {
  double r = 0,
  Color? b,
}) => Positioned(
  left: l,
  top: t,
  child: Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: c,
      borderRadius: BorderRadius.circular(r),
      border: b == null ? null : Border.all(color: b),
    ),
  ),
);

Widget _t(
  double l,
  double t,
  String s,
  double size,
  Color c, {
  FontWeight w = FontWeight.w700,
}) => Positioned(
  left: l,
  top: t,
  child: Text(
    s,
    style: TextStyle(fontSize: size, color: c, fontWeight: w, height: 1.0),
  ),
);

Widget _i(double l, double t, IconData d, double size, Color c) => Positioned(
  left: l,
  top: t,
  child: Icon(d, size: size, color: c),
);

Widget _frame(List<Widget> children) => Scaffold(
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
