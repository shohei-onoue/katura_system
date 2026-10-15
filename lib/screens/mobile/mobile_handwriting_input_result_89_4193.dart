// Figma node 89:4193 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

class MobileHandwritingInputResult894193 extends StatelessWidget {
  const MobileHandwritingInputResult894193({super.key});

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFFFFFFF);
    const purple = Color(0xFF673AB7);
    const black = Color(0xFF111111);
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
                _r(0, 0, 390, 844, const Color(0xFFF3F7F6), rad: 0),
                _r(0, 0, 390, 44, black, rad: 0),
                _t(30, 13.5, '9:41', 15, white, FontWeight.w700),
                _i(303, 14, Icons.signal_cellular_alt, 17, white),
                _i(325, 14, Icons.wifi, 17, white),
                _i(347, 14, Icons.battery_full, 17, white),
                _r(0, 44, 390, 52, black, rad: 0),
                _i(16, 60, Icons.close, 20, white),
                _i(52, 61, Icons.edit_note, 20, white),
                _t(72, 60.5, '手書き入力（AI判定）', 15, white, FontWeight.w700),
                _r(304, 54, 37, 32, purple, rad: 10, bc: purple),
                _i(314, 62, Icons.edit, 17, white),
                _r(347, 54, 35, 32, const Color(0xFF333333), rad: 10),
                _i(356, 62, Icons.auto_fix_normal, 17, white),
                _r(0, 96, 390, 724, black, rad: 0),
                _r(12, 106, 366, 48, white, rad: 10),
                _t(157, 119, '山田 太郎', 18, purple, FontWeight.w700),
                _r(12, 164, 366, 598, white, rad: 12),
                Positioned(
                  left: 65,
                  top: 393,
                  width: 260,
                  height: 140,
                  child: CustomPaint(painter: _GlyphPainter()),
                ),
                _r(12, 772, 86, 38, const Color(0xFFFF6D00), rad: 10),
                _t(42.5, 783.5, '戻る', 13, white, FontWeight.w700),
                _r(106, 772, 86, 38, const Color(0xFFB8BCC2), rad: 10),
                _t(135.5, 783.5, '削除', 13, white, FontWeight.w700),
                _r(199, 772, 86, 38, const Color(0xFF607D8B), rad: 10),
                _t(229.5, 783.5, '空白', 13, white, FontWeight.w700),
                _r(293, 772, 86, 38, purple, rad: 10),
                _t(322.5, 783.5, '完了', 13, white, FontWeight.w700),
                _r(0, 820, 390, 24, black, rad: 0),
                _r(128, 831, 134, 5, black, rad: 2.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;
    // 山
    canvas.drawLine(const Offset(40, 30), const Offset(40, 112), p);
    canvas.drawLine(const Offset(70, 18), const Offset(70, 112), p);
    canvas.drawLine(const Offset(102, 30), const Offset(102, 112), p);
    canvas.drawLine(const Offset(40, 112), const Offset(102, 112), p);
    // 田
    canvas.drawRect(const Rect.fromLTRB(150, 25, 220, 112), p);
    canvas.drawLine(const Offset(185, 25), const Offset(185, 112), p);
    canvas.drawLine(const Offset(150, 68), const Offset(220, 68), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
