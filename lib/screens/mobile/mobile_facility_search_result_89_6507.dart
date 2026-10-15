import 'package:flutter/material.dart';

/// Figma 89:6507 70_施設検索結果
class MobileFacilitySearchResult896507 extends StatelessWidget {
  const MobileFacilitySearchResult896507({super.key});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1D1B20);
    const grey = Color(0xFF6B6F76);
    const lgrey = Color(0xFF9AA0A6);
    const white = Colors.white;
    const bd = Color(0xFFEDF0F2);
    const chev = Color(0xFFB0B5BB);
    const blue = Color(0xFF1E88E5);
    const red = Color(0xFFF44336);
    const orange = Color(0xFFFF6D00);
    const inputBg = Color(0xFFF6F7F9);
    const inputBd = Color(0xFFE4E7EB);
    const lime = Color(0xFFDAFFAF);
    const limeText = Color(0xFF1D3B00);
    const reg = FontWeight.w400;
    const med = FontWeight.w500;

    Widget facility(
      double top,
      double h,
      String name,
      String addr, {
      bool selected = false,
    }) {
      final dx = selected ? 1.0 : 0.0;
      return Stack(
        children: [
          if (selected)
            _r(
              19,
              top,
              352,
              h,
              const Color(0xFFFFF5F0),
              r: 10,
              b: const Color(0xFFFF7043),
            )
          else
            _r(19, top, 352, h, white),
          _i(33 + dx, top + 21, Icons.local_hospital, 20, blue),
          _t(63 + dx, top + 13.5, name, 14, dark),
          _t(63 + dx, top + 34, addr, 11.5, grey, w: reg),
          if (selected)
            _i(336, top + 22, Icons.check_circle, 20, const Color(0xFFFF7043))
          else
            _i(337, top + 21, Icons.chevron_right, 20, chev),
        ],
      );
    }

    return _frame([
      _r(0, 0, 390, 844, const Color(0xFFF3F7F6)),
      _r(0, 0, 390, 44, white),
      _t(30, 13.5, '9:41', 15, dark),
      _i(303, 14, Icons.signal_cellular_alt, 17, dark),
      _i(325, 14, Icons.wifi, 17, dark),
      _i(347, 14, Icons.battery_full, 17, dark),
      _r(0, 44, 390, 52, white),
      _i(16, 60, Icons.close, 20, dark),
      _t(52, 59, '受注入力', 18, dark),
      _t(
        273,
        60.5,
        '0564-12-3456',
        15,
        const Color(0xFF673AB7),
        w: FontWeight.w900,
      ),
      _r(0, 96, 390, 59, white),
      _r(
        47,
        104,
        22,
        22,
        const Color(0xFF4CAF50),
        r: 11,
        b: const Color(0xFF4CAF50),
      ),
      _i(51, 108, Icons.check, 14, white),
      _t(38, 130.5, '番号確認', 10, dark, w: med),
      _r(138, 104, 22, 22, orange, r: 11, b: orange),
      _t(146, 108.5, '2', 11, white),
      _t(119, 130.5, '配達先の確定', 10, orange),
      _r(230, 104, 22, 22, white, r: 11, b: const Color(0xFFCFD3D8)),
      _t(238, 108.5, '3', 11, lgrey),
      _t(221, 130.5, '注文内容', 10, lgrey, w: med),
      _r(321, 104, 22, 22, white, r: 11, b: const Color(0xFFCFD3D8)),
      _t(329, 108.5, '4', 11, lgrey),
      _t(322, 130.5, '完了', 10, lgrey, w: med),
      _r(14, 165, 362, 42, const Color(0xFFECEFF1), r: 12),
      _t(67, 178.5, '履歴から選択', 13, grey),
      _r(195, 168, 178, 36, lime, r: 10),
      _t(258, 178.5, '新規登録', 13, limeText),
      _r(14, 219, 362, 218, white, r: 14, b: bd),
      _r(29, 232, 332, 42, const Color(0xFFECEFF1), r: 12),
      _r(32, 235, 109, 36, lime, r: 10),
      _i(78, 235, Icons.category, 16, limeText),
      _t(41, 253.5, '地域・カテゴリ', 13, limeText),
      _i(187, 235, Icons.search, 16, grey),
      _t(163, 253.5, 'キーワード', 13, grey),
      _i(296, 235, Icons.pin_drop, 16, grey),
      _t(291, 253.5, '住所', 13, grey),
      _t(29, 285, '地域・カテゴリ選択', 11.5, grey),
      _r(29, 305, 252, 44, inputBg, r: 10, b: inputBd),
      _t(42, 318.5, '愛知県 岡崎市', 14, dark, w: reg),
      _i(250, 318, Icons.unfold_more, 18, grey),
      _r(289, 305, 72, 44, const Color(0xFF78909C), r: 10),
      _i(302, 319, Icons.map, 16, white),
      _t(322, 319.5, '調整', 13, white),
      _t(29, 360, '備考（地図上の目印、搬入口情報など）', 11.5, grey),
      _r(29, 380, 332, 44, inputBg, r: 10, b: inputBd),
      _t(42, 393.5, 'タップして詳細を入力してください', 14, lgrey, w: reg),
      _i(330, 393, Icons.delete_outline, 18, grey),
      _t(16, 452.5, '配達先情報の確認', 12, grey),
      _r(14, 474, 362, 238, white, r: 14, b: bd),
      _r(15, 475, 360, 150, const Color(0xFFCFE5D2)),
      _t(126.5, 542, '地図（Googleマップ）', 13, const Color(0xFF5B8A65)),
      _i(29, 641, Icons.store, 15, blue),
      _t(44, 640, '岡崎本店 →', 11.5, dark, w: reg),
      _i(109, 641, Icons.location_on, 15, red),
      _i(29, 662, Icons.business, 15, red),
      _t(44, 661, '未確定', 11.5, red),
      _i(29, 683, Icons.place, 15, red),
      _t(44, 681, '未確定', 11.5, red),
      _r(0, 757, 390, 87, white, b: inputBd),
      _r(14, 768, 176, 48, red, r: 12),
      _t(72.5, 783.5, '注文中止', 15, white),
      _r(200, 768, 176, 48, const Color(0xFFB8BCC2), r: 12),
      _t(258.5, 783.5, '商品選択', 15, white),
      _r(0, 0, 390, 844, const Color(0x7A121218)),
      _r(0, 515, 390, 329, white, r: 22),
      _r(175, 523, 40, 5, const Color(0xFFD4D7DC), r: 2.5),
      _t(30, 544.5, '施設検索結果', 17, dark),
      _r(344, 536, 36, 36, const Color(0xFFF1F3F5), r: 18),
      _i(352, 544, Icons.close, 20, dark),
      _r(18, 582, 354, 250, white, r: 14, b: bd),
      facility(583, 62, '愛知県立病院', '愛知県岡崎市高隆寺町峠1'),
      facility(645, 63, '岡崎市民病院', '愛知県岡崎市高隆寺町五所合3-1', selected: true),
      facility(708, 62, '岡崎市役所', '愛知県岡崎市十王町2丁目9'),
      facility(770, 61, '東海病院（近隣）', '愛知県岡崎市志賀町'),
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
