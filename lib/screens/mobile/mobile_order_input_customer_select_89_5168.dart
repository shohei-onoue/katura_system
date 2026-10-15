import 'package:flutter/material.dart';

class MobileOrderInputCustomerSelect895168 extends StatelessWidget {
  const MobileOrderInputCustomerSelect895168({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(width: 390, height: 844, child: _o2Body()),
          ),
        ),
      ),
    );
  }
}

Widget _o2Box(
  double l,
  double t,
  double w,
  double h,
  Color c, {
  double r = 0,
  Color? border,
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
        border: border == null ? null : Border.all(color: border, width: 1),
      ),
    ),
  );
}

Widget _o2Text(
  double l,
  double t,
  String s,
  double size,
  Color c, {
  FontWeight w = FontWeight.w700,
  double? ls,
}) {
  return Positioned(
    left: l,
    top: t,
    child: Text(
      s,
      softWrap: false,
      style: TextStyle(
        fontSize: size,
        color: c,
        fontWeight: w,
        letterSpacing: ls,
        height: 1.2,
      ),
    ),
  );
}

Widget _o2Icon(double l, double t, IconData i, double size, Color c) {
  return Positioned(
    left: l,
    top: t,
    child: Icon(i, size: size, color: c),
  );
}

Widget _o2Head(String title, IconData lead) {
  const ink = Color(0xFF1D1B20);
  return Stack(
    children: [
      _o2Box(0, 0, 390, 44, Colors.white),
      _o2Text(30, 13.5, '9:41', 15, ink),
      _o2Icon(303, 14, Icons.signal_cellular_alt, 17, ink),
      _o2Icon(325, 14, Icons.wifi, 17, ink),
      _o2Icon(347, 14, Icons.battery_full, 17, ink),
      _o2Box(0, 44, 390, 52, Colors.white),
      _o2Icon(16, 60, lead, 20, ink),
      _o2Text(52, 59, title, 18, ink),
    ],
  );
}

Widget _o2Dial() {
  const key = Color(0xFF2E3440);
  const sub = Color(0xFF6C737E);
  final xs = [14.0, 138.0, 261.0];
  final ws = <Widget>[
    _o2Box(0, 522, 390, 322, Colors.white, border: const Color(0xFFE4E7EB)),
    _o2Text(16, 532, '入力ダイヤル', 11.5, const Color(0xFF6B6F76)),
  ];
  for (var i = 0; i < 9; i++) {
    final x = xs[i % 3];
    final y = 559.0 + 65 * (i ~/ 3);
    ws.add(_o2Box(x, y, 115, 56, key, r: 14));
    ws.add(
      Positioned(
        left: x,
        top: y,
        width: 115,
        height: 56,
        child: Center(
          child: Text(
            '${i + 1}',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
  ws.add(_o2Box(14, 754, 115, 56, sub, r: 14));
  ws.add(
    const Positioned(
      left: 14,
      top: 754,
      width: 115,
      height: 56,
      child: Center(
        child: Text(
          'クリア',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
  ws.add(_o2Box(138, 754, 115, 56, key, r: 14));
  ws.add(
    const Positioned(
      left: 138,
      top: 754,
      width: 115,
      height: 56,
      child: Center(
        child: Text(
          '0',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
  ws.add(_o2Box(261, 754, 115, 56, sub, r: 14));
  ws.add(
    const Positioned(
      left: 261,
      top: 754,
      width: 115,
      height: 56,
      child: Center(
        child: Icon(Icons.backspace, size: 24, color: Colors.white),
      ),
    ),
  );
  ws.add(_o2Box(128, 831, 134, 5, const Color(0xFF111111), r: 2.5));
  return Stack(children: ws);
}

Widget _o2Stepper() {
  const org = Color(0xFFFF6D00);
  const gr = Color(0xFF9AA0A6);
  final ws = <Widget>[_o2Box(0, 96, 390, 59, Colors.white)];
  const xs = [47.0, 138.0, 230.0, 321.0];
  const labels = ['番号確認', '配達先の確定', '注文内容', '完了'];
  const lx = [38.0, 119.0, 221.0, 322.0];
  for (var i = 0; i < 4; i++) {
    final on = i == 0;
    ws.add(
      _o2Box(
        xs[i],
        104,
        22,
        22,
        on ? org : Colors.white,
        r: 11,
        border: on ? org : const Color(0xFFCFD3D8),
      ),
    );
    ws.add(_o2Text(xs[i] + 8, 108.5, '${i + 1}', 11, on ? Colors.white : gr));
    ws.add(
      _o2Text(
        lx[i],
        130.5,
        labels[i],
        10,
        on ? org : gr,
        w: on ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
  return Stack(children: ws);
}

Widget _o2Body() {
  const ink = Color(0xFF1D1B20);
  const grey = Color(0xFF6B6F76);
  const red = Color(0xFFF44336);
  const blue = Color(0xFF1E88E5);
  const purple = Color(0xFF673AB7);
  return Stack(
    children: [
      _o2Box(0, 0, 390, 844, const Color(0xFFF3F7F6)),
      _o2Head('受注入力', Icons.close),
      _o2Stepper(),
      _o2Box(
        14,
        167,
        362,
        173,
        Colors.white,
        r: 14,
        border: const Color(0xFFEDF0F2),
      ),
      _o2Box(15, 168, 360, 37, purple),
      _o2Text(29, 178.5, 'お客様電話番号', 13, Colors.white),
      _o2Text(67, 225.5, '0564-12-3456', 36, red, w: FontWeight.w900, ls: 1),
      _o2Box(29, 285, 162, 38, red, r: 10),
      Positioned(
        left: 29,
        top: 285,
        width: 162,
        height: 38,
        child: const Center(
          child: Text(
            '受注中止',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      _o2Box(199, 285, 162, 38, purple, r: 10),
      Positioned(
        left: 199,
        top: 285,
        width: 162,
        height: 38,
        child: const Center(
          child: Text(
            '日程調整',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      _o2Text(16, 355.5, '選択中の顧客', 12, grey),
      _o2Box(
        14,
        377,
        362,
        66,
        const Color(0xFFDAFFAF),
        r: 14,
        border: const Color(0xFFB9EA80),
      ),
      _o2Text(29, 391.5, '株式会社アオキ / 青木 一郎 様', 15, ink, w: FontWeight.w900),
      _o2Text(29, 412.5, '0564-12-3456', 13, red),
      _o2Text(280, 409.5, '前回から', 10, grey, w: FontWeight.w400),
      _o2Text(324, 397, '12', 22, blue),
      _o2Text(350, 408, '日', 11.5, blue, w: FontWeight.w400),
      _o2Dial(),
    ],
  );
}
