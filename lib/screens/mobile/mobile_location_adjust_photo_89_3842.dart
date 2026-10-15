import 'package:flutter/material.dart';

/// Figma 89:3842 場所の微調整と写真撮影（スマホ版）
class MobileLocationAdjustPhoto893842 extends StatelessWidget {
  const MobileLocationAdjustPhoto893842({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF673AB7);
    const dark = Color(0xFF1D1B20);
    const bold = FontWeight.w700;
    Widget fab(double top, IconData ic) => _i(344, top + 12, ic, 20, dark);
    Widget circle(double top) =>
        _r(332, top, 44, 44, color: Colors.white, radius: 22);

    return _frame([
      _r(0, 0, 390, 44, color: purple),
      _t(30, 13.5, '9:41', 15, Colors.white, weight: bold),
      _i(303, 14, Icons.signal_cellular_alt_rounded, 17, Colors.white),
      _i(325, 14, Icons.wifi_rounded, 17, Colors.white),
      _i(347, 14, Icons.battery_full_rounded, 17, Colors.white),
      _r(0, 44, 390, 52, color: purple),
      _i(16, 60, Icons.close_rounded, 20, Colors.white),
      _t(52, 59, '場所の微調整と写真撮影', 18, Colors.white, weight: bold),
      _r(0, 96, 390, 55, color: const Color(0xFFF6F2FC)),
      _i(16, 106, Icons.location_on_rounded, 20, const Color(0xFFF44336)),
      _t(44, 108.5, '愛知県岡崎市康生通西4丁目71', 13, dark, weight: bold),
      _t(44, 127, 'ピンをドラッグして配達先の位置を調整できます', 10.5, const Color(0xFF6B6F76)),
      _r(0, 151, 390, 606, color: const Color(0xFFCFE5D2)),
      _t(
        126.5,
        446,
        '地図（Googleマップ）',
        13,
        const Color(0xFF5B8A65),
        weight: bold,
      ),
      circle(595),
      fab(595, Icons.add_a_photo_rounded),
      circle(647),
      fab(647, Icons.my_location_rounded),
      circle(699),
      fab(699, Icons.layers_rounded),
      _r(0, 757, 390, 87, color: Colors.white, border: const Color(0xFFE4E7EB)),
      _r(14, 768, 362, 48, color: purple, radius: 12),
      _t(120.5, 783.5, 'この地点と写真で確定', 15, Colors.white, weight: bold),
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
