// Figma node 89:3894 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

class MobileDataAnalysisMonthlySalesTrend893894 extends StatelessWidget {
  const MobileDataAnalysisMonthlySalesTrend893894({super.key});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1D1B20);
    const grey = Color(0xFF6B6F76);
    const purple = Color(0xFF673AB7);
    const names = [
      '特製ステーキ弁当',
      '松花堂弁当',
      '幕の内弁当',
      '鶏から揚げオードブル',
      '親子丼',
      'ギフト詰め合わせ',
      'ローストビーフ丼',
      '海鮮ちらし弁当',
      '唐揚げ弁当',
    ];
    const bars = [
      [104.0, 65.0, 39.0],
      [78.0, 58.0, 26.0],
      [71.0, 39.0, 26.0],
      [52.0, 32.0, 19.0],
      [45.0, 19.0, 16.0],
      [32.0, 19.0, 13.0],
      [32.0, 16.0, 10.0],
      [29.0, 13.0, 10.0],
      [26.0, 13.0, 8.0],
    ];
    const barColors = [Color(0xFF1E88E5), Color(0xFF4CAF50), Color(0xFF9C27B0)];
    final barWidgets = <Widget>[];
    for (var i = 0; i < names.length; i++) {
      final top = 268.0 + 21 * i;
      barWidgets.add(_t(29, top, names[i], 11.5, dark, FontWeight.w400));
      var x = 141.0;
      for (var k = 0; k < 3; k++) {
        barWidgets.add(_r(x, top, bars[i][k], 14, barColors[k], rad: 0));
        x += bars[i][k];
      }
    }
    const navs = [
      [Icons.post_add, '受注入力'],
      [Icons.list_alt, '受注一覧'],
      [Icons.local_shipping, '配送予定'],
      [Icons.people, '顧客'],
    ];
    final navWidgets = <Widget>[];
    for (var i = 0; i < navs.length; i++) {
      final cx = 40.0 + 76 * i;
      navWidgets.add(_i(cx - 10 + (i == 0 ? 2 : 0), 774, navs[i][0] as IconData, 20, grey));
      navWidgets.add(
        _tc(cx, 802, navs[i][1] as String, 10.5, grey, FontWeight.w500),
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
                _r(0, 0, 390, 844, const Color(0xFFF3F7F6)),
                _r(0, 0, 390, 44, Colors.white),
                _t(30, 13.5, '9:41', 15, dark, FontWeight.w700),
                _i(303, 14, Icons.signal_cellular_alt, 17, dark),
                _i(325, 14, Icons.wifi, 17, dark),
                _i(347, 14, Icons.battery_full, 17, dark),
                _r(0, 44, 390, 52, Colors.white),
                _i(16, 60, Icons.menu, 20, dark),
                _t(52, 59, 'データ分析', 18, dark, FontWeight.w700),
                _r(14, 106, 362, 42, const Color(0xFFECEFF1), rad: 12),
                _t(67, 119.5, 'ヒートマップ', 13, grey, FontWeight.w700),
                _r(195, 109, 178, 36, purple, rad: 10),
                _t(264, 119.5, 'グラフ', 13, Colors.white, FontWeight.w700),
                _r(
                  14,
                  158,
                  67,
                  34,
                  const Color(0xFFDAFFAF),
                  rad: 10,
                  bc: const Color(0xFFB9EA80),
                ),
                _t(28, 167.5, '全店舗', 13, const Color(0xFF1D3B00), FontWeight.w700),
                _r(87, 158, 80, 34, Colors.white, rad: 10, bc: const Color(0xFFE4E7EB)),
                _t(101, 167.5, '岡崎本店', 13, dark, FontWeight.w700),
                _r(173, 158, 80, 34, Colors.white, rad: 10, bc: const Color(0xFFE4E7EB)),
                _t(187, 167.5, '名古屋店', 13, dark, FontWeight.w700),
                _r(259, 158, 67, 34, Colors.white, rad: 10, bc: const Color(0xFFE4E7EB)),
                _t(273, 167.5, '岐阜店', 13, dark, FontWeight.w700),
                _r(14, 204, 362, 265, Colors.white, rad: 14, bc: const Color(0xFFEDF0F2)),
                _t(29, 218.5, '店舗別 メニュー注文数', 14, dark, FontWeight.w700),
                _t(327, 220, '多い順', 11.5, grey, FontWeight.w400),
                _r(29, 247, 10, 10, barColors[0], rad: 5),
                _t(43, 244.5, '岡崎本店', 11, grey, FontWeight.w400),
                _r(99, 247, 10, 10, barColors[1], rad: 5),
                _t(113, 244.5, '名古屋店', 11, grey, FontWeight.w400),
                _r(169, 247, 10, 10, barColors[2], rad: 5),
                _t(183, 244.5, '岐阜店', 11, grey, FontWeight.w400),
                ...barWidgets,
                _r(14, 479, 362, 190, Colors.white, rad: 14, bc: const Color(0xFFEDF0F2)),
                _t(29, 493.5, '月別 人気メニュー', 14, dark, FontWeight.w700),
                _t(309, 495, '売上推移 ›', 11.5, purple, FontWeight.w700),
                _t(29, 521, '10月', 11.5, grey, FontWeight.w400),
                _r(29, 540, 44, 44, const Color(0xFFEEF0F2), rad: 10),
                _i(41, 552, Icons.restaurant, 20, const Color(0xFFB5BAC0)),
                _t(81, 543, '1位', 11.5, grey, FontWeight.w400),
                _t(81, 560.5, '特製ステーキ弁当', 16, dark, FontWeight.w700),
                _t(283, 546, '2位', 11.5, grey, FontWeight.w400),
                _t(301, 546, '松花堂弁当', 11.5, dark, FontWeight.w400),
                _t(283, 564, '3位', 11.5, grey, FontWeight.w400),
                _t(301, 564, '幕の内弁当', 11.5, dark, FontWeight.w400),
                _t(29, 593, '9月', 11.5, grey, FontWeight.w400),
                _r(29, 612, 44, 44, const Color(0xFFEEF0F2), rad: 10),
                _i(41, 624, Icons.restaurant, 20, const Color(0xFFB5BAC0)),
                _t(81, 615, '1位', 11.5, grey, FontWeight.w400),
                _t(81, 632.5, '松花堂弁当', 16, dark, FontWeight.w700),
                _t(249, 618, '2位', 11.5, grey, FontWeight.w400),
                _t(266, 618, '特製ステーキ弁当', 11.5, dark, FontWeight.w400),
                _t(306, 636, '3位', 11.5, grey, FontWeight.w400),
                _t(324, 636, '親子丼', 11.5, dark, FontWeight.w400),
                _r(0, 762, 390, 82, Colors.white, bc: const Color(0xFFE4E7EB)),
                ...navWidgets,
                _r(320, 769, 56, 30, const Color(0xFFEDE7F6), rad: 15),
                _i(338, 774, Icons.apps, 20, purple),
                _t(327, 802, 'メニュー', 10.5, purple, FontWeight.w700),
                _r(0, 0, 390, 844, const Color(0x7A121218)),
                _r(0, 420, 390, 424, Colors.white, rad: 22),
                _r(175, 428, 40, 5, const Color(0xFFD4D7DC), rad: 2.5),
                _t(30, 448.5, '2026年 月別販売推移', 17, dark, FontWeight.w700),
                _r(344, 441, 36, 36, const Color(0xFFF1F3F5), rad: 18),
                _i(352, 449, Icons.close, 20, dark),
                _r(18, 499, 10, 10, const Color(0xFFFF7043), rad: 5),
                _t(32, 496.5, '特製ステーキ弁当', 11, grey, FontWeight.w400),
                _r(132, 499, 10, 10, const Color(0xFF42A5F5), rad: 5),
                _t(146, 496.5, '松花堂弁当', 11, grey, FontWeight.w400),
                _r(213, 499, 10, 10, const Color(0xFF66BB6A), rad: 5),
                _t(227, 496.5, '幕の内弁当', 11, grey, FontWeight.w400),
                const Positioned(
                  left: 18,
                  top: 517,
                  width: 354,
                  height: 221,
                  child: CustomPaint(painter: _ChartPainter()),
                ),
                _r(0, 755, 390, 89, null, bc: const Color(0xFFE4E7EB)),
                _r(18, 766, 354, 48, Colors.white, rad: 12, bc: const Color(0xFFE4E7EB)),
                _t(172.5, 781.5, '閉じる', 15, dark, FontWeight.w700),
                _r(128, 831, 134, 5, const Color(0xFF111111), rad: 2.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter();

  static const _orange = [45.0, 39.0, 42.0, 33.0, 30.0, 24.0, 21.0, 15.0, 18.0, 12.0, 75.0, 75.0];
  static const _blue = [54.0, 51.0, 52.5, 48.0, 45.0, 43.5, 39.0, 36.0, 37.5, 33.0, 75.0, 75.0];
  static const _green = [69.0, 67.5, 66.0, 67.5, 63.0, 61.5, 60.0, 57.0, 58.5, 54.0, 82.5, 82.5];

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1;
    for (final p in [10.0, 30.0, 50.0, 70.0, 90.0]) {
      final y = size.height * p / 100;
      canvas.drawLine(
        Offset(size.width * 0.0313, y),
        Offset(size.width * 0.9687, y),
        grid,
      );
    }
    double xAt(int i) => size.width * 0.0313 + i * (size.width * 0.9375 / 11);
    void series(List<double> v, Color c) {
      final line = Paint()
        ..color = c
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      final path = Path();
      for (var i = 0; i < v.length; i++) {
        final o = Offset(xAt(i), size.height * v[i] / 100);
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      canvas.drawPath(path, line);
      final dot = Paint()..color = c;
      for (var i = 0; i < v.length; i++) {
        canvas.drawCircle(Offset(xAt(i), size.height * v[i] / 100), 3, dot);
      }
    }

    series(_green, const Color(0xFF66BB6A));
    series(_blue, const Color(0xFF42A5F5));
    series(_orange, const Color(0xFFFF7043));
    for (var i = 0; i < 12; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(fontSize: 9, color: Color(0xFF888888)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(xAt(i) - tp.width / 2, size.height * 0.935));
    }
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

Widget _tc(double cx, double t, String s, double size, Color c, FontWeight w) {
  return Positioned(
    left: cx - 50,
    top: t,
    width: 100,
    child: Text(
      s,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size,
        color: c,
        fontWeight: w,
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
