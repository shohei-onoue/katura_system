// Figma node 88:126 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

const _dark = Color(0xFF1D1B20);
const _grey = Color(0xFF6B6F76);
const _purple = Color(0xFF673AB7);
const _line = Color(0xFFE4E7EB);
const _orange = Color(0xFFFF6D00);
const _red = Color(0xFFF44336);
const _selBg = Color(0xFFDAFFAF);
const _selText = Color(0xFF1D3B00);

class MobileAddressSearchStreetNumber88126 extends StatelessWidget {
  const MobileAddressSearchStreetNumber88126({super.key});

  @override
  Widget build(BuildContext context) {
    const summary = [
      ['都道府県', '愛知県'],
      ['市区町村', '岡崎市'],
      ['町名', '康生通西'],
    ];
    final summaryWidgets = <Widget>[];
    for (var i = 0; i < summary.length; i++) {
      final x = 18.0 + 90 * i;
      summaryWidgets.addAll([
        _r(x, 163, 84, 37, const Color(0xFFEDE7F6), rad: 10),
        _i(x + 6, 170, Icons.check_circle, 12, _purple),
        _t(x + 18, 168.5, summary[i][0], 10, _dark, FontWeight.w400),
        _t(x + 6, 182.5, summary[i][1], 10, _dark, FontWeight.w700),
      ]);
    }
    // keypad: label, left, top, textLeft, textTop
    const keys = [
      ['1', 32.0, 344.0, 76.0],
      ['2', 144.0, 344.0, 188.0],
      ['3', 255.0, 344.0, 300.0],
      ['4', 32.0, 409.0, 76.0],
      ['5', 144.0, 409.0, 188.0],
      ['6', 255.0, 409.0, 300.0],
      ['7', 32.0, 474.0, 76.0],
      ['8', 144.0, 474.0, 188.0],
      ['9', 255.0, 474.0, 300.0],
    ];
    final keyWidgets = <Widget>[];
    for (final k in keys) {
      final y = k[2] as double;
      keyWidgets.addAll([
        _r(k[1] as double, y, 103, 56, Colors.white, rad: 14, bc: _line),
        _t(k[3] as double, y + 14, k[0] as String, 24, _dark, FontWeight.w700),
      ]);
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
                ..._orderBase(),
                _r(0, 0, 390, 844, const Color(0x7A121218)),
                _r(0, 44, 390, 800, Colors.white, rad: 16),
                _r(175, 52, 40, 5, const Color(0xFFD4D7DC), rad: 2.5),
                _t(30, 73.5, '住所・郵便番号で検索', 17, _dark, FontWeight.w700),
                _r(344, 65, 36, 36, const Color(0xFFF1F3F5), rad: 18),
                _i(352, 73, Icons.close, 20, _dark),
                _r(18, 111, 354, 42, const Color(0xFFECEFF1), rad: 12),
                _r(21, 114, 174, 36, _purple, rad: 10),
                _t(82, 124.5, '住所検索', 13, Colors.white, FontWeight.w700),
                _t(243, 124.5, '郵便番号検索', 13, _grey, FontWeight.w700),
                ...summaryWidgets,
                _r(288, 163, 84, 37, _selBg, rad: 10),
                _t(294, 168.5, '番地住所', 10, _dark, FontWeight.w700),
                _t(294, 181.5, '選択中', 10, _dark, FontWeight.w900),
                _t(121.5, 221, '詳細住所を入力してください', 11.5, _grey, FontWeight.w400),
                _t(115.5, 242.5, '愛知県岡崎市康生通西', 16, _dark, FontWeight.w700),
                _t(151, 269, '4-71', 40, _purple, FontWeight.w900),
                ...keyWidgets,
                _r(32, 539, 103, 56, const Color(0xFFECEFF1), rad: 14, bc: _line),
                _t(81, 558.5, '-', 15, _dark, FontWeight.w700),
                _r(144, 539, 103, 56, Colors.white, rad: 14, bc: _line),
                _t(188, 553, '0', 24, _dark, FontWeight.w700),
                _r(255, 539, 103, 56, _orange, rad: 14, bc: _orange),
                _i(295, 555, Icons.backspace, 24, Colors.white),
                _r(0, 755, 390, 89, null, bc: _line),
                _r(18, 766, 354, 48, _purple, rad: 12),
                _t(142.5, 781.5, 'この内容で確定', 15, Colors.white, FontWeight.w700),
                _r(128, 831, 134, 5, const Color(0xFF111111), rad: 2.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Widget> _orderBase() {
  return [
    _r(0, 0, 390, 844, const Color(0xFFF3F7F6)),
    _r(0, 0, 390, 44, Colors.white),
    _t(30, 13.5, '9:41', 15, _dark, FontWeight.w700),
    _i(303, 14, Icons.signal_cellular_alt, 17, _dark),
    _i(325, 14, Icons.wifi, 17, _dark),
    _i(347, 14, Icons.battery_full, 17, _dark),
    _r(0, 44, 390, 52, Colors.white),
    _i(16, 60, Icons.close, 20, _dark),
    _t(52, 59, '受注入力', 18, _dark, FontWeight.w700),
    _t(273, 60.5, '0564-12-3456', 15, _purple, FontWeight.w900),
    _r(0, 96, 390, 59, Colors.white),
    _r(47, 104, 22, 22, const Color(0xFF4CAF50), rad: 11, bc: const Color(0xFF4CAF50)),
    _i(51, 108, Icons.check, 14, Colors.white),
    _t(38, 130.5, '番号確認', 10, _dark, FontWeight.w500),
    _r(138, 104, 22, 22, _orange, rad: 11, bc: _orange),
    _t(146, 108.5, '2', 11, Colors.white, FontWeight.w700),
    _t(119, 130.5, '配達先の確定', 10, _orange, FontWeight.w700),
    _r(230, 104, 22, 22, Colors.white, rad: 11, bc: const Color(0xFFCFD3D8)),
    _t(238, 108.5, '3', 11, const Color(0xFF9AA0A6), FontWeight.w700),
    _t(221, 130.5, '注文内容', 10, const Color(0xFF9AA0A6), FontWeight.w500),
    _r(321, 104, 22, 22, Colors.white, rad: 11, bc: const Color(0xFFCFD3D8)),
    _t(329, 108.5, '4', 11, const Color(0xFF9AA0A6), FontWeight.w700),
    _t(322, 130.5, '完了', 10, const Color(0xFF9AA0A6), FontWeight.w500),
    _r(14, 165, 362, 42, const Color(0xFFECEFF1), rad: 12),
    _t(67, 178.5, '履歴から選択', 13, _grey, FontWeight.w700),
    _r(195, 168, 178, 36, _selBg, rad: 10),
    _t(258, 178.5, '新規登録', 13, _selText, FontWeight.w700),
    _r(14, 219, 362, 218, Colors.white, rad: 14, bc: const Color(0xFFEDF0F2)),
    _r(29, 232, 332, 42, const Color(0xFFECEFF1), rad: 12),
    _r(32, 235, 109, 36, _selBg, rad: 10),
    _i(78, 235, Icons.category, 16, _selText),
    _t(41, 253.5, '地域・カテゴリ', 13, _selText, FontWeight.w700),
    _i(187, 235, Icons.search, 16, _grey),
    _t(163, 253.5, 'キーワード', 13, _grey, FontWeight.w700),
    _i(296, 235, Icons.pin_drop, 16, _grey),
    _t(291, 253.5, '住所', 13, _grey, FontWeight.w700),
    _t(29, 285, '地域・カテゴリ選択', 11.5, _grey, FontWeight.w700),
    _r(29, 305, 252, 44, const Color(0xFFF6F7F9), rad: 10, bc: _line),
    _t(42, 318.5, '愛知県 岡崎市', 14, _dark, FontWeight.w400),
    _i(250, 318, Icons.unfold_more, 18, _grey),
    _r(289, 305, 72, 44, const Color(0xFF78909C), rad: 10),
    _i(302, 319, Icons.map, 16, Colors.white),
    _t(322, 319.5, '調整', 13, Colors.white, FontWeight.w700),
    _t(29, 360, '備考（地図上の目印、搬入口情報など）', 11.5, _grey, FontWeight.w700),
    _r(29, 380, 332, 44, const Color(0xFFF6F7F9), rad: 10, bc: _line),
    _t(42, 393.5, 'タップして詳細を入力してください', 14, const Color(0xFF9AA0A6), FontWeight.w400),
    _i(330, 393, Icons.delete_outline, 18, _grey),
    _t(16, 452.5, '配達先情報の確認', 12, _grey, FontWeight.w700),
    _r(14, 474, 362, 238, Colors.white, rad: 14, bc: const Color(0xFFEDF0F2)),
    _r(15, 475, 360, 150, const Color(0xFFCFE5D2)),
    _t(126.5, 542, '地図（Googleマップ）', 13, const Color(0xFF5B8A65), FontWeight.w700),
    _i(29, 641, Icons.store, 15, const Color(0xFF1E88E5)),
    _t(44, 640, '岡崎本店 →', 11.5, _dark, FontWeight.w400),
    _i(109, 641, Icons.location_on, 15, _red),
    _i(29, 662, Icons.business, 15, _red),
    _t(44, 661, '未確定', 11.5, _red, FontWeight.w700),
    _i(29, 683, Icons.place, 15, _red),
    _t(44, 681, '未確定', 11.5, _red, FontWeight.w700),
    _r(0, 757, 390, 87, Colors.white, bc: _line),
    _r(14, 768, 176, 48, _red, rad: 12),
    _t(72.5, 783.5, '注文中止', 15, Colors.white, FontWeight.w700),
    _r(200, 768, 176, 48, const Color(0xFFB8BCC2), rad: 12),
    _t(258.5, 783.5, '商品選択', 15, Colors.white, FontWeight.w700),
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
