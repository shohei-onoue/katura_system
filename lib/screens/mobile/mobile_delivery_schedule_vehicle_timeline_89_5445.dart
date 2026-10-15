import 'package:flutter/material.dart';

class MobileDeliveryScheduleVehicleTimeline895445 extends StatelessWidget {
  const MobileDeliveryScheduleVehicleTimeline895445({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(width: 390, height: 844, child: _d2Body()),
          ),
        ),
      ),
    );
  }
}

Widget _d2Box(
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

Widget _d2Text(
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

Widget _d2Icon(double l, double t, IconData i, double size, Color c) {
  return Positioned(
    left: l,
    top: t,
    child: Icon(i, size: size, color: c),
  );
}

Widget _d2Head(String title, IconData lead) {
  const ink = Color(0xFF1D1B20);
  return Stack(
    children: [
      _d2Box(0, 0, 390, 44, Colors.white),
      _d2Text(30, 13.5, '9:41', 15, ink),
      _d2Icon(303, 14, Icons.signal_cellular_alt, 17, ink),
      _d2Icon(325, 14, Icons.wifi, 17, ink),
      _d2Icon(347, 14, Icons.battery_full, 17, ink),
      _d2Box(0, 44, 390, 52, Colors.white),
      _d2Icon(16, 60, lead, 20, ink),
      _d2Text(52, 59, title, 18, ink),
    ],
  );
}

Widget _d2Body() {
  const ink = Color(0xFF1D1B20);
  const grey = Color(0xFF6B6F76);
  const line = Color(0xFFE3E6EA);
  const blue = Color(0xFF2196F3);
  const purple = Color(0xFF673AB7);
  const dark = Color(0xFF333333);
  final ws = <Widget>[
    _d2Box(0, 0, 390, 844, const Color(0xFFF3F7F6)),
    _d2Head('配達予定 10/14(水)', Icons.arrow_back_ios_new),
    _d2Box(0, 96, 390, 51, Colors.white),
    _d2Box(
      14,
      104,
      98,
      34,
      const Color(0xFFDAFFAF),
      r: 10,
      border: const Color(0xFFB9EA80),
    ),
    _d2Text(28, 113.5, '岡崎本店(5)', 13, const Color(0xFF1D3B00)),
    _d2Box(
      118,
      104,
      98,
      34,
      Colors.white,
      r: 10,
      border: const Color(0xFFE4E7EB),
    ),
    _d2Text(132, 113.5, '名古屋店(2)', 13, ink),
    _d2Box(
      221,
      104,
      85,
      34,
      Colors.white,
      r: 10,
      border: const Color(0xFFE4E7EB),
    ),
    _d2Text(235, 113.5, '岐阜店(1)', 13, ink),
    _d2Box(163, 188, 105, 569, const Color(0xFFECEFF1), r: 10),
  ];
  const cars = [
    (52.0, 89.0, '1号車'),
    (163.0, 200.0, '2号車'),
    (275.0, 312.0, '3号車'),
  ];
  for (final c in cars) {
    ws.add(_d2Box(c.$1, 155, 105, 27, dark, r: 8));
    ws.add(_d2Text(c.$2, 161.5, c.$3, 12, Colors.white));
  }
  for (var i = 0; i < 5; i++) {
    final y = 188.0 + 72 * i;
    ws.add(_d2Box(0, y, 380, 1, Colors.transparent, border: line));
    ws.add(_d2Box(10, y - 7, i == 0 ? 24 : 30, 15, const Color(0xFFF3F7F6)));
    ws.add(_d2Text(10, y - 6, '${9 + i}:00', 10.5, grey, w: FontWeight.w400));
  }
  const conns = [(105.0, 314.0, 276.0), (216.0, 350.0, 132.0)];
  for (final c in conns) {
    ws.add(_d2Box(c.$1, c.$2, 2, c.$3, dark));
  }
  const events = [
    (56.0, 302.0, '10:30 岡崎市'),
    (56.0, 410.0, '12:00 幸田町'),
    (56.0, 590.0, '14:30 岡崎市'),
    (167.0, 338.0, '11:00 岡崎市'),
    (167.0, 482.0, '13:00 幸田町'),
    (279.0, 626.0, '15:00 予約枠'),
  ];
  for (final e in events) {
    ws.add(_d2Box(e.$1, e.$2, 97, 26, blue, r: 8));
    ws.add(_d2Text(e.$1 + 7, e.$2 + 6.5, e.$3, 11, Colors.white));
  }
  const moves = [
    (58.0, 344.0, '移動25分 余裕65分'),
    (58.0, 488.0, '移動32分 余裕122分'),
    (169.0, 412.0, '移動40分 余裕80分'),
  ];
  for (final m in moves) {
    ws.add(_d2Icon(m.$1, m.$2, Icons.directions_car, 12, purple));
    ws.add(_d2Text(m.$1 + 12, m.$2 - 0.5, m.$3, 9.5, purple));
  }
  ws.addAll([
    _d2Box(0, 757, 390, 87, Colors.white, border: const Color(0xFFE4E7EB)),
    _d2Box(
      14,
      768,
      362,
      48,
      Colors.white,
      r: 12,
      border: const Color(0xFFE4E7EB),
    ),
    Positioned(
      left: 14,
      top: 768,
      width: 362,
      height: 48,
      child: const Center(
        child: Text(
          '戻る',
          style: TextStyle(
            fontSize: 15,
            color: ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
    _d2Box(128, 831, 134, 5, const Color(0xFF111111), r: 2.5),
  ]);
  return Stack(children: ws);
}
