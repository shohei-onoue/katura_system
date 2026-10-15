// Figma node 89:6396 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

class MobileRegionKeywordSearch896396 extends StatelessWidget {
  const MobileRegionKeywordSearch896396({super.key});

  @override
  Widget build(BuildContext context) {
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
                ..._orderBase(),
                _r(0, 0, 390, 844, const Color(0x7A121218), rad: 0),
                _r(0, 44, 390, 800, const Color(0xFFFFFFFF), rad: 16),
                _r(175, 52, 40, 5, const Color(0xFFD4D7DC), rad: 2.5),
                _t(30, 73.5, '地域・キーワードの検索', 17, const Color(0xFF1D1B20),
                    FontWeight.w700),
                _r(344, 65, 36, 36, const Color(0xFFF1F3F5), rad: 18),
                _i(352, 73, Icons.close, 20, const Color(0xFF1D1B20)),
                for (final x in [18.0, 90.0, 162.0, 234.0])
                  _r(x, 111, 66, 37, const Color(0xFFEDE7F6), rad: 10),
                for (final x in [24.0, 96.0, 168.0, 240.0])
                  _i(x, 118, Icons.check_circle, 12, const Color(0xFF673AB7)),
                _t(36, 116.5, '都道府県', 10, const Color(0xFF1D1B20),
                    FontWeight.w400),
                _t(24, 130.5, '愛知県', 10, const Color(0xFF1D1B20),
                    FontWeight.w700),
                _t(108, 116.5, '市区町村', 10, const Color(0xFF1D1B20),
                    FontWeight.w400),
                _t(96, 130.5, '岡崎市', 10, const Color(0xFF1D1B20),
                    FontWeight.w700),
                _t(180, 116.5, '町名', 10, const Color(0xFF1D1B20),
                    FontWeight.w400),
                _t(168, 130.5, '(すべて)', 10, const Color(0xFF1D1B20),
                    FontWeight.w700),
                _t(252, 116.5, 'その他', 10, const Color(0xFF1D1B20),
                    FontWeight.w400),
                _t(240, 130.5, 'なし', 10, const Color(0xFF1D1B20),
                    FontWeight.w700),
                _r(306, 111, 66, 37, const Color(0xFFDAFFAF), rad: 10),
                _t(312, 116.5, 'キーワード', 10, const Color(0xFF1D1B20),
                    FontWeight.w700),
                _t(312, 129.5, '選択中', 10, const Color(0xFF1D1B20),
                    FontWeight.w900),
                _t(18, 159, '施設・企業名', 11.5, const Color(0xFF6B6F76),
                    FontWeight.w700),
                _field(179, '株式会社アオキ'),
                _t(18, 228, '未入力の場合は「個人宅」になります', 11.5,
                    const Color(0xFF6B6F76), FontWeight.w400),
                _t(18, 254, '最寄り施設', 11.5, const Color(0xFF6B6F76),
                    FontWeight.w700),
                _field(274, '岡崎駅'),
                _t(18, 329, 'その他', 11.5, const Color(0xFF6B6F76),
                    FontWeight.w700),
                _field(349, null),
                _r(0, 755, 390, 89, null, rad: 0, bc: const Color(0xFFE4E7EB)),
                _r(18, 766, 354, 48, const Color(0xFF673AB7), rad: 12),
                _i(129, 780, Icons.search, 20, const Color(0xFFFFFFFF)),
                _t(155.5, 781.5, 'この条件で検索', 15, const Color(0xFFFFFFFF),
                    FontWeight.w700),
                _r(128, 831, 134, 5, const Color(0xFF111111), rad: 2.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _field(double top, String? text) {
  return Stack(
    children: [
      _r(18, top, 354, 44, const Color(0xFFF6F7F9),
          rad: 10, bc: const Color(0xFFE4E7EB)),
      if (text != null)
        _t(31, top + 13.5, text, 14, const Color(0xFF673AB7), FontWeight.w700),
      _i(341, top + 13, Icons.delete_outline, 18, const Color(0xFF6B6F76)),
    ],
  );
}

List<Widget> _orderBase() {
  const dark = Color(0xFF1D1B20);
  const grey = Color(0xFF6B6F76);
  const light = Color(0xFF9AA0A6);
  const white = Color(0xFFFFFFFF);
  const purple = Color(0xFF673AB7);
  const orange = Color(0xFFFF6D00);
  const red = Color(0xFFF44336);
  Widget input(double top, String s, Color c) => Stack(children: [
        _r(29, top, 332, 44, const Color(0xFFF6F7F9),
            rad: 10, bc: const Color(0xFFE4E7EB)),
        _t(42, top + 13.5, s, 14, c, FontWeight.w400),
        _i(330, top + 13, Icons.draw, 18, grey),
      ]);
  Widget step(double x, double lx, String n, String label, int state) {
    final done = state == 0;
    final cur = state == 1;
    return Stack(children: [
      _r(x, 104, 22, 22, done ? const Color(0xFF4CAF50) : (cur ? orange : white),
          rad: 11,
          bc: done
              ? const Color(0xFF4CAF50)
              : (cur ? orange : const Color(0xFFCFD3D8))),
      if (done)
        _i(x + 4, 108, Icons.check, 14, white)
      else
        _t(x + 8, 108.5, n, 11, cur ? white : light, FontWeight.w700),
      _t(lx, 130.5, label, 10, done ? dark : (cur ? orange : light),
          cur ? FontWeight.w700 : FontWeight.w500),
    ]);
  }

  return [
    _r(0, 0, 390, 844, const Color(0xFFF3F7F6), rad: 0),
    _r(0, 0, 390, 44, white, rad: 0),
    _t(30, 13.5, '9:41', 15, dark, FontWeight.w700),
    _i(303, 14, Icons.signal_cellular_alt, 17, dark),
    _i(325, 14, Icons.wifi, 17, dark),
    _i(347, 14, Icons.battery_full, 17, dark),
    _r(0, 44, 390, 52, white, rad: 0),
    _i(16, 60, Icons.close, 20, dark),
    _t(52, 59, '受注入力', 18, dark, FontWeight.w700),
    _r(0, 96, 390, 59, white, rad: 0),
    step(38, 29, '1', '番号確認', 0),
    step(111, 102, '2', '顧客確認', 1),
    step(184, 165, '3', '配達先の確定', 2),
    step(257, 248, '4', '注文内容', 2),
    step(330, 331, '5', '完了', 2),
    _r(14, 167, 362, 403, white, rad: 14, bc: const Color(0xFFEDF0F2)),
    _r(15, 168, 360, 37, purple, rad: 0),
    _t(29, 178.5, '新規顧客の登録', 13, white, FontWeight.w700),
    _r(29, 217, 332, 65, const Color(0xFFFFF5F0), rad: 10),
    _t(63, 229, '090-1234-5678', 34, red, FontWeight.w900, ls: 1),
    _t(29, 293, '企業・施設名', 11.5, grey, FontWeight.w700),
    input(313, '未入力の場合は「個人宅」になります', light),
    _t(29, 368, '顧客名', 11.5, grey, FontWeight.w700),
    input(388, 'お名前を書いてください', light),
    _t(29, 443, '所属企業・住所の確定', 11.5, grey, FontWeight.w700),
    _r(29, 463, 332, 42, const Color(0xFFECEFF1), rad: 12),
    _r(32, 466, 109, 36, const Color(0xFFDAFFAF), rad: 10),
    _i(78, 466, Icons.category, 16, const Color(0xFF1D3B00)),
    _t(73, 484.5, '地域', 13, const Color(0xFF1D3B00), FontWeight.w700),
    _i(187, 466, Icons.search, 16, grey),
    _t(163, 484.5, 'キーワード', 13, grey, FontWeight.w700),
    _i(296, 466, Icons.pin_drop, 16, grey),
    _t(291, 484.5, '住所', 13, grey, FontWeight.w700),
    _r(29, 513, 252, 44, const Color(0xFFF6F7F9),
        rad: 10, bc: const Color(0xFFE4E7EB)),
    _t(42, 526.5, '愛知県 岡崎市', 14, dark, FontWeight.w400),
    _i(250, 526, Icons.unfold_more, 18, grey),
    _r(289, 513, 72, 44, const Color(0xFF78909C), rad: 10),
    _i(302, 527, Icons.map, 16, white),
    _t(322, 527.5, '調整', 13, white, FontWeight.w700),
    _t(16, 585.5, '所属企業情報', 12, grey, FontWeight.w700),
    _r(14, 607, 362, 173, white, rad: 14, bc: const Color(0xFFEDF0F2)),
    _r(15, 608, 360, 130, const Color(0xFFCFE5D2), rad: 0),
    _t(126.5, 665, '地図（Googleマップ）', 13, const Color(0xFF5B8A65),
        FontWeight.w700),
    _i(29, 752, Icons.business, 15, red),
    _t(44, 751, '未確定', 11.5, red, FontWeight.w700),
    _i(93, 752, Icons.place, 15, red),
    _t(108, 751, '未確定', 11.5, red, FontWeight.w700),
    _r(0, 767, 390, 77, white, rad: 0, bc: const Color(0xFFE4E7EB)),
    _r(14, 778, 101, 38, white, rad: 10, bc: orange),
    _t(32.5, 789.5, 'キャンセル', 13, orange, FontWeight.w700),
    _r(125, 778, 101, 38, white, rad: 10, bc: purple),
    _t(137.5, 789.5, '番号打ち直し', 13, purple, FontWeight.w700),
    _r(237, 778, 139, 38, purple, rad: 10),
    _t(261.5, 789.5, '登録して注文へ', 13, white, FontWeight.w700),
  ];
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
