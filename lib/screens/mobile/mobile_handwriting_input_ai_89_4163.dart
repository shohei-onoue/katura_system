import 'package:flutter/material.dart';

/// Figma 89:4163 64_手書き入力（AI判定）
class MobileHandwritingInputAi894163 extends StatelessWidget {
  const MobileHandwritingInputAi894163({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF111111);
    const white = Colors.white;
    const purple = Color(0xFF673AB7);

    Widget btn(double l, String s, Color c, double tx) => Stack(
      children: [_r(l, 772, 86, 38, c, r: 10), _t(tx, 783.5, s, 13, white)],
    );

    return _frame([
      _r(0, 0, 390, 844, const Color(0xFFF3F7F6)),
      _r(0, 0, 390, 44, bg),
      _t(30, 13.5, '9:41', 15, white),
      _i(303, 14, Icons.signal_cellular_alt, 17, white),
      _i(325, 14, Icons.wifi, 17, white),
      _i(347, 14, Icons.battery_full, 17, white),
      _r(0, 44, 390, 52, bg),
      _i(16, 60, Icons.close, 20, white),
      _i(52, 61, Icons.edit_note, 20, white),
      _t(72, 60.5, '手書き入力（AI判定）', 15, white),
      _r(304, 54, 37, 32, purple, r: 10, b: purple),
      _i(314, 62, Icons.edit, 17, white),
      _r(347, 54, 35, 32, const Color(0xFF333333), r: 10),
      _i(356, 62, Icons.auto_fix_normal, 17, white),
      _r(0, 96, 390, 724, bg),
      _r(12, 106, 366, 48, white, r: 10),
      _t(69, 123.5, 'ここにAIにより判定された文字が表示されます', 12, const Color(0xFFB0B5BB)),
      _r(12, 164, 366, 598, white, r: 12),
      _t(
        109,
        456,
        'ここに指やペンで書いてください',
        11.5,
        const Color(0xFFC4C8CD),
        w: FontWeight.w400,
      ),
      btn(12, '戻る', const Color(0xFFFF6D00), 42.5),
      btn(106, '削除', const Color(0xFFB8BCC2), 135.5),
      btn(199, '空白', const Color(0xFF607D8B), 229.5),
      btn(293, '完了', purple, 322.5),
      _r(0, 820, 390, 24, bg),
      _r(128, 831, 134, 5, bg, r: 2.5),
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
