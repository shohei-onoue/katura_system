import 'package:flutter/material.dart';

/// Figma 89:5658 配達詳細（スマホ版）
class MobileDeliveryDetail895658 extends StatelessWidget {
  const MobileDeliveryDetail895658({super.key});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1D1B20);
    const sub = Color(0xFF6B6F76);
    const purple = Color(0xFF673AB7);
    const blue = Color(0xFF2196F3);
    const line = Color(0xFFE4E7EB);
    const grid = Color(0xFFE3E6EA);
    const red = Color(0xFFF44336);
    const bold = FontWeight.w700;

    Widget chip(double l, double w, String s, bool on) => _r(
      l,
      104,
      w,
      34,
      color: on ? const Color(0xFFDAFFAF) : Colors.white,
      border: on ? const Color(0xFFB9EA80) : line,
      radius: 10,
    );

    Widget hour(double top, String s, double w) =>
        _r(10, top, w, 15, color: const Color(0xFFF3F7F6));

    Widget ev(double l, double t, String s) =>
        _r(l, t, 97, 26, color: blue, radius: 8);

    Widget move(double l, double t, String s) =>
        _i(l, t, Icons.directions_car_rounded, 12, purple);

    return _frame([
      _r(0, 0, 390, 44, color: Colors.white),
      _t(30, 13.5, '9:41', 15, dark, weight: bold),
      _i(303, 14, Icons.signal_cellular_alt_rounded, 17, dark),
      _i(325, 14, Icons.wifi_rounded, 17, dark),
      _i(347, 14, Icons.battery_full_rounded, 17, dark),
      _r(0, 44, 390, 52, color: Colors.white),
      _i(16, 60, Icons.arrow_back_ios_new_rounded, 20, dark),
      _t(52, 59, '配達予定 10/14(水)', 18, dark, weight: bold),
      _r(0, 96, 390, 51, color: Colors.white),
      chip(14, 98, '', true),
      _t(28, 113.5, '岡崎本店(5)', 13, const Color(0xFF1D3B00), weight: bold),
      chip(118, 98, '', false),
      _t(132, 113.5, '名古屋店(2)', 13, dark, weight: bold),
      chip(221, 85, '', false),
      _t(235, 113.5, '岐阜店(1)', 13, dark, weight: bold),
      for (final x in [52.0, 163.0, 275.0])
        _r(x, 155, 105, 27, color: const Color(0xFF333333), radius: 8),
      _t(89, 161.5, '1号車', 12, Colors.white, weight: bold),
      _t(200, 161.5, '2号車', 12, Colors.white, weight: bold),
      _t(312, 161.5, '3号車', 12, Colors.white, weight: bold),
      for (var i = 0; i < 5; i++) ...[
        _r(0, 188.0 + 72 * i, 380, 1, border: grid),
        hour(181.0 + 72 * i, '', i == 0 ? 24 : 30),
        _t(10, 182.0 + 72 * i, '${9 + i}:00', 10.5, sub),
      ],
      _r(105, 314, 2, 276, color: const Color(0xFF333333)),
      ev(56, 302, ''),
      _t(63, 308.5, '10:30 岡崎市', 11, Colors.white, weight: bold),
      move(58, 344, ''),
      _t(70, 343.5, '移動25分 余裕65分', 9.5, purple, weight: bold),
      ev(56, 410, ''),
      _t(63, 416.5, '12:00 幸田町', 11, Colors.white, weight: bold),
      move(58, 488, ''),
      _t(70, 487.5, '移動32分 余裕122分', 9.5, purple, weight: bold),
      ev(56, 590, ''),
      _t(63, 596.5, '14:30 岡崎市', 11, Colors.white, weight: bold),
      _r(163, 188, 105, 569, color: const Color(0xFFECEFF1), radius: 10),
      _r(216, 350, 2, 132, color: const Color(0xFF333333)),
      ev(167, 338, ''),
      _t(174, 344.5, '11:00 岡崎市', 11, Colors.white, weight: bold),
      move(169, 412, ''),
      _t(181, 411.5, '移動40分 余裕80分', 9.5, purple, weight: bold),
      ev(167, 482, ''),
      _t(174, 488.5, '13:00 幸田町', 11, Colors.white, weight: bold),
      ev(279, 626, ''),
      _t(286, 632.5, '15:00 予約枠', 11, Colors.white, weight: bold),
      _r(0, 757, 390, 87, color: Colors.white, border: line),
      _r(14, 768, 362, 48, color: Colors.white, border: line, radius: 12),
      _t(180.5, 783.5, '戻る', 15, dark, weight: bold),
      _r(0, 0, 390, 844, color: const Color(0x7A121218)),
      _r(0, 492, 390, 352, color: Colors.white, radius: 22),
      _r(175, 500, 40, 5, color: const Color(0xFFD4D7DC), radius: 2.5),
      _t(30, 521.5, '10:30 配達', 17, dark, weight: bold),
      _r(344, 513, 36, 36, color: const Color(0xFFF1F3F5), radius: 18),
      _i(352, 521, Icons.close_rounded, 20, dark),
      _r(
        18,
        559,
        354,
        184,
        color: Colors.white,
        border: const Color(0xFFEDF0F2),
        radius: 14,
      ),
      _r(19, 560, 352, 61, color: Colors.white),
      _t(33, 573, '顧客名', 11.5, red, weight: bold),
      _t(33, 589.5, '山田 太郎 様', 14, dark, weight: FontWeight.w500),
      _r(19, 621, 352, 61, color: Colors.white),
      _t(33, 634, '住所', 11.5, red, weight: bold),
      _t(
        33,
        650.5,
        '〒444-0036 愛知県岡崎市康生通西4丁目71',
        14,
        dark,
        weight: FontWeight.w500,
      ),
      _r(19, 682, 352, 60, color: Colors.white),
      _t(33, 695, '注文内容', 11.5, red, weight: bold),
      _t(
        33,
        711.5,
        '特製ステーキ弁当 x10 ／ 松花堂弁当 x5',
        14,
        dark,
        weight: FontWeight.w500,
      ),
      _r(0, 755, 390, 89, border: line),
      _r(18, 766, 354, 48, color: Colors.white, border: line, radius: 12),
      _t(172.5, 781.5, '閉じる', 15, dark, weight: bold),
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
