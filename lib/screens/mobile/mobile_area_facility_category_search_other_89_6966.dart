import 'package:flutter/material.dart';

const _ink = Color(0xFF1D1B20);
const _gray = Color(0xFF6B6F76);
const _lgray = Color(0xFF9AA0A6);
const _purple = Color(0xFF673AB7);
const _orange = Color(0xFFFF6D00);
const _lime = Color(0xFFDAFFAF);
const _limeInk = Color(0xFF1D3B00);
const _red = Color(0xFFF44336);
const _line = Color(0xFFE4E7EB);
const _line2 = Color(0xFFEDF0F2);
const _field = Color(0xFFF6F7F9);
const _chip = Color(0xFFECEFF1);
const _chip2 = Color(0xFFF1F3F5);

/// 地域・施設カテゴリの検索（その他） Figma 89:6966
class MobileAreaFacilityCategorySearchOther896966 extends StatelessWidget {
  const MobileAreaFacilityCategorySearchOther896966({super.key});

  @override
  Widget build(BuildContext context) {
    return _frame([
      _box(0, 0, 390, 844, color: const Color(0xFFF3F7F6)),
      _box(0, 0, 390, 44, color: Colors.white),
      _txt(30, 13.5, '9:41', 15, _ink),
      _ico(303, 14, Icons.signal_cellular_alt_rounded, 17, _ink),
      _ico(325, 14, Icons.wifi_rounded, 17, _ink),
      _ico(347, 14, Icons.battery_full_rounded, 17, _ink),

      _box(0, 44, 390, 52, color: Colors.white),
      _ico(16, 60, Icons.close_rounded, 20, _ink),
      _txt(52, 59, '受注入力', 18, _ink),
      _txt(273, 60.5, '0564-12-3456', 15, _purple, FontWeight.w900),
      _box(0, 96, 390, 59, color: Colors.white),
      _box(
        47,
        104,
        22,
        22,
        color: const Color(0xFF4CAF50),
        radius: 11,
        border: const Color(0xFF4CAF50),
      ),
      _ico(51, 108, Icons.check_rounded, 14, Colors.white),
      _txt(38, 130.5, '番号確認', 10, _ink, FontWeight.w500),
      _box(138, 104, 22, 22, color: _orange, radius: 11, border: _orange),
      _txt(146, 108.5, '2', 11, Colors.white),
      _txt(119, 130.5, '配達先の確定', 10, _orange),
      _box(
        230,
        104,
        22,
        22,
        color: Colors.white,
        radius: 11,
        border: const Color(0xFFCFD3D8),
      ),
      _txt(238, 108.5, '3', 11, _lgray),
      _txt(221, 130.5, '注文内容', 10, _lgray, FontWeight.w500),
      _box(
        321,
        104,
        22,
        22,
        color: Colors.white,
        radius: 11,
        border: const Color(0xFFCFD3D8),
      ),
      _txt(329, 108.5, '4', 11, _lgray),
      _txt(322, 130.5, '完了', 10, _lgray, FontWeight.w500),
      _box(14, 165, 362, 42, color: _chip, radius: 12),
      _txt(67, 178.5, '履歴から選択', 13, _gray),
      _box(195, 168, 178, 36, color: _lime, radius: 10),
      _txt(258, 178.5, '新規登録', 13, _limeInk),
      _box(14, 219, 362, 218, color: Colors.white, radius: 14, border: _line2),
      _box(29, 232, 332, 42, color: _chip, radius: 12),
      _box(32, 235, 109, 36, color: _lime, radius: 10),
      _ico(78, 235, Icons.category_rounded, 16, _limeInk),
      _txt(41, 253.5, '地域・カテゴリ', 13, _limeInk),
      _ico(187, 235, Icons.search_rounded, 16, _gray),
      _txt(163, 253.5, 'キーワード', 13, _gray),
      _ico(296, 235, Icons.pin_drop_rounded, 16, _gray),
      _txt(291, 253.5, '住所', 13, _gray),
      _txt(29, 285, '地域・カテゴリ選択', 11.5, _gray),
      _box(29, 305, 252, 44, color: _field, radius: 10, border: _line),
      _txt(42, 318.5, '愛知県 岡崎市', 14, _ink, FontWeight.w400),
      _ico(250, 318, Icons.unfold_more_rounded, 18, _gray),
      _box(289, 305, 72, 44, color: const Color(0xFF78909C), radius: 10),
      _ico(302, 319, Icons.map_rounded, 16, Colors.white),
      _txt(322, 319.5, '調整', 13, Colors.white),
      _txt(29, 360, '備考（地図上の目印、搬入口情報など）', 11.5, _gray),
      _box(29, 380, 332, 44, color: _field, radius: 10, border: _line),
      _txt(42, 393.5, 'タップして詳細を入力してください', 14, _lgray, FontWeight.w400),
      _ico(330, 393, Icons.delete_outline_rounded, 18, _gray),
      _txt(16, 452.5, '配達先情報の確認', 12, _gray),
      _box(14, 474, 362, 238, color: Colors.white, radius: 14, border: _line2),
      _box(15, 475, 360, 150, color: const Color(0xFFCFE5D2)),
      _txt(126.5, 542, '地図（Googleマップ）', 13, const Color(0xFF5B8A65)),
      _ico(29, 641, Icons.store_rounded, 15, const Color(0xFF1E88E5)),
      _txt(44, 640, '岡崎本店 →', 11.5, _ink, FontWeight.w400),
      _ico(109, 641, Icons.location_on_rounded, 15, _red),
      _ico(29, 662, Icons.business_rounded, 15, _red),
      _txt(44, 661, '未確定', 11.5, _red),
      _ico(29, 683, Icons.place_rounded, 15, _red),
      _txt(44, 681, '未確定', 11.5, _red),
      _box(0, 757, 390, 87, color: Colors.white, border: _line),
      _box(14, 768, 176, 48, color: _red, radius: 12),
      _txt(72.5, 783.5, '注文中止', 15, Colors.white),
      _box(200, 768, 176, 48, color: const Color(0xFFB8BCC2), radius: 12),
      _txt(258.5, 783.5, '商品選択', 15, Colors.white),
      _box(0, 0, 390, 844, color: const Color(0x7A121218)),
      _box(0, 44, 390, 800, color: Colors.white, radius: 16),
      _box(175, 52, 40, 5, color: const Color(0xFFD4D7DC), radius: 2.5),
      _box(344, 65, 36, 36, color: _chip2, radius: 18),
      _ico(352, 73, Icons.close_rounded, 20, _ink),
      _txt(30, 73.5, '地域・施設カテゴリの検索', 17, _ink),
      _box(18, 111, 66, 37, color: const Color(0xFFEDE7F6), radius: 10),
      _ico(24, 118, Icons.check_circle_rounded, 12, _purple),
      _txt(36, 116.5, '都道府県', 10, _ink, FontWeight.w400),
      _txt(24, 130.5, '愛知県', 10, _ink),
      _box(90, 111, 66, 37, color: const Color(0xFFEDE7F6), radius: 10),
      _ico(96, 118, Icons.check_circle_rounded, 12, _purple),
      _txt(108, 116.5, '市区町村', 10, _ink, FontWeight.w400),
      _txt(96, 130.5, '岡崎市', 10, _ink),
      _box(162, 111, 66, 37, color: const Color(0xFFEDE7F6), radius: 10),
      _ico(168, 118, Icons.check_circle_rounded, 12, _purple),
      _txt(180, 116.5, '町名', 10, _ink, FontWeight.w400),
      _txt(168, 130.5, '康生通西', 10, _ink),
      _box(234, 111, 66, 37, color: _lime, radius: 10),
      _txt(240, 116.5, 'その他', 10, _ink),
      _txt(240, 129.5, '選択中', 10, _ink, FontWeight.w900),
      _box(306, 111, 66, 37, color: _chip2, radius: 10),
      _txt(312, 116.5, 'カテゴリ', 10, _lgray, FontWeight.w400),
      _txt(312, 129.5, '-', 10, _lgray),
      _txt(18, 159, 'その他（字・丁目など）の項目', 11.5, _gray, FontWeight.w400),
      _box(18, 180, 354, 173, color: Colors.white, radius: 12, border: _line2),
      _box(19, 181, 352, 43, color: _lime),
      _txt(33, 193.5, 'なし', 14, _ink),
      _ico(337, 192, Icons.check_circle_rounded, 20, _purple),
      _box(19, 224, 352, 43, color: Colors.white),
      _txt(33, 236.5, '字峠', 14, _ink),
      _ico(337, 235, Icons.chevron_right_rounded, 20, const Color(0xFFB0B5BB)),
      _box(19, 267, 352, 43, color: Colors.white),
      _txt(33, 279.5, '字五所合', 14, _ink),
      _ico(337, 278, Icons.chevron_right_rounded, 20, const Color(0xFFB0B5BB)),
      _box(19, 310, 352, 42, color: Colors.white),
      _txt(33, 322.5, '字下ノ山', 14, _ink),
      _ico(337, 321, Icons.chevron_right_rounded, 20, const Color(0xFFB0B5BB)),
      _box(0, 765, 390, 79, color: Colors.white, border: _line),
      _box(18, 776, 113, 38, color: Colors.white, radius: 10, border: _purple),
      _txt(48.5, 787.5, '追加登録', 13, _purple),
      _box(141, 776, 111, 38, color: _orange, radius: 10),
      _txt(183.5, 787.5, '戻る', 13, Colors.white),
      _box(261, 776, 111, 38, color: _purple, radius: 10),
      _txt(304.5, 787.5, '次へ', 13, Colors.white),
      _box(128, 831, 134, 5, color: const Color(0xFF111111), radius: 2.5),
    ]);
  }
}

Widget _box(
  double l,
  double t,
  double w,
  double h, {
  Color? color,
  double radius = 0,
  Color? border,
}) {
  return Positioned(
    left: l,
    top: t,
    width: w,
    height: h,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border == null ? null : Border.all(color: border, width: 1),
      ),
    ),
  );
}

Widget _txt(
  double l,
  double t,
  String s,
  double size,
  Color c, [
  FontWeight w = FontWeight.w700,
]) {
  return Positioned(
    left: l,
    top: t,
    child: Text(
      s,
      softWrap: false,
      style: TextStyle(fontSize: size, color: c, fontWeight: w, height: 1.2),
    ),
  );
}

Widget _ico(double l, double t, IconData i, double size, Color c) {
  return Positioned(
    left: l,
    top: t,
    child: Icon(i, size: size, color: c),
  );
}

Widget _frame(List<Widget> children) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Center(
        child: FittedBox(
          child: SizedBox(
            width: 390,
            height: 844,
            child: Stack(children: children),
          ),
        ),
      ),
    ),
  );
}
