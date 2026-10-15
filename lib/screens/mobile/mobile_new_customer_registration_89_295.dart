// Figma node 89:295 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

class MobileNewCustomerRegistration89295 extends StatelessWidget {
  const MobileNewCustomerRegistration89295({super.key});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1D1B20);
    const gray = Color(0xFF6B6F76);
    const lgray = Color(0xFF9AA0A6);
    const purple = Color(0xFF673AB7);
    const orange = Color(0xFFFF6D00);
    const red = Color(0xFFF44336);
    const w = Colors.white;
    const bold = FontWeight.w700;
    const reg = FontWeight.w400;

    Widget step(double x, double lx, String n, String s, int state) {
      // state 0 done, 1 current, 2 todo
      return Stack(
        children: [
          if (state == 0) ...[
            _r(x, 104, 22, 22, Color(0xFF4CAF50),
                rad: 11, bc: Color(0xFF4CAF50)),
            _i(x + 4, 108, Icons.check, 14, w),
          ] else if (state == 1) ...[
            _r(x, 104, 22, 22, orange, rad: 11, bc: orange),
            _t(x + 8, 108.5, n, 11, w, bold),
          ] else ...[
            _r(x, 104, 22, 22, w, rad: 11, bc: Color(0xFFCFD3D8)),
            _t(x + 8, 108.5, n, 11, lgray, bold),
          ],
          _t(
            lx,
            130.5,
            s,
            10,
            state == 1 ? orange : (state == 0 ? dark : lgray),
            state == 1 ? bold : FontWeight.w500,
          ),
        ],
      );
    }

    Widget field(double y, String hint) {
      return Stack(
        children: [
          _r(29, y, 332, 44, Color(0xFFF6F7F9),
              rad: 10, bc: Color(0xFFE4E7EB)),
          _t(42, y + 13.5, hint, 14, lgray, reg),
          _i(330, y + 13, Icons.draw, 18, gray),
        ],
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
                _r(0, 0, 390, 844, Color(0xFFF3F7F6)),
                _r(0, 0, 390, 44, w),
                _t(30, 13.5, '9:41', 15, dark, bold),
                _i(303, 14, Icons.signal_cellular_alt, 17, dark),
                _i(325, 14, Icons.wifi, 17, dark),
                _i(347, 14, Icons.battery_full, 17, dark),
                _r(0, 44, 390, 52, w),
                _i(16, 60, Icons.close, 20, dark),
                _t(52, 59, '受注入力', 18, dark, bold),
                _r(0, 96, 390, 59, w),
                step(38, 29, '1', '番号確認', 0),
                step(111, 102, '2', '顧客確認', 1),
                step(184, 165, '3', '配達先の確定', 2),
                step(257, 248, '4', '注文内容', 2),
                step(330, 331, '5', '完了', 2),
                _r(14, 167, 362, 403, w, rad: 14, bc: Color(0xFFEDF0F2)),
                _r(15, 168, 360, 37, purple),
                _t(29, 178.5, '新規顧客の登録', 13, w, bold),
                _r(29, 217, 332, 65, Color(0xFFFFF5F0), rad: 10),
                _t(63, 229, '090-1234-5678', 34, red, FontWeight.w900, ls: 1),
                _t(29, 293, '企業・施設名', 11.5, gray, bold),
                field(313, '未入力の場合は「個人宅」になります'),
                _t(29, 368, '顧客名', 11.5, gray, bold),
                field(388, 'お名前を書いてください'),
                _t(29, 443, '所属企業・住所の確定', 11.5, gray, bold),
                _r(29, 463, 332, 42, Color(0xFFECEFF1), rad: 12),
                _r(32, 466, 109, 36, Color(0xFFDAFFAF), rad: 10),
                _i(78, 466, Icons.category, 16, Color(0xFF1D3B00)),
                _t(73, 484.5, '地域', 13, Color(0xFF1D3B00), bold),
                _i(187, 466, Icons.search, 16, gray),
                _t(163, 484.5, 'キーワード', 13, gray, bold),
                _i(296, 466, Icons.pin_drop, 16, gray),
                _t(291, 484.5, '住所', 13, gray, bold),
                _r(29, 513, 252, 44, Color(0xFFF6F7F9),
                    rad: 10, bc: Color(0xFFE4E7EB)),
                _t(42, 526.5, '愛知県 岡崎市', 14, dark, reg),
                _i(250, 526, Icons.unfold_more, 18, gray),
                _r(289, 513, 72, 44, Color(0xFF78909C), rad: 10),
                _i(302, 527, Icons.map, 16, w),
                _t(322, 527.5, '調整', 13, w, bold),
                _t(16, 585.5, '所属企業情報', 12, gray, bold),
                _r(14, 607, 362, 173, w, rad: 14, bc: Color(0xFFEDF0F2)),
                _r(15, 608, 360, 130, Color(0xFFCFE5D2)),
                _t(126.5, 665, '地図（Googleマップ）', 13, Color(0xFF5B8A65), bold),
                _i(29, 752, Icons.business, 15, red),
                _t(44, 751, '未確定', 11.5, red, bold),
                _i(93, 752, Icons.place, 15, red),
                _t(108, 751, '未確定', 11.5, red, bold),
                _r(0, 767, 390, 77, w, bc: Color(0xFFE4E7EB)),
                _r(14, 778, 101, 38, w, rad: 10, bc: orange),
                _t(32.5, 789.5, 'キャンセル', 13, orange, bold),
                _r(125, 778, 101, 38, w, rad: 10, bc: purple),
                _t(137.5, 789.5, '番号打ち直し', 13, purple, bold),
                _r(237, 778, 139, 38, purple, rad: 10),
                _t(261.5, 789.5, '登録して注文へ', 13, w, bold),
                _r(128, 831, 134, 5, Color(0xFF111111), rad: 2.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _r(
  double l,
  double t,
  double w,
  double h,
  Color? c, {
  double rad = 0,
  Color? bc,
  double bw = 1,
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
        border: bc == null ? null : Border.all(color: bc, width: bw),
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
