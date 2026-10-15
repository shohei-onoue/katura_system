// Figma node 89:2160 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

class MobileStoreDeleteDialog892160 extends StatelessWidget {
  const MobileStoreDeleteDialog892160({super.key});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1D1B20);
    const gray = Color(0xFF6B6F76);
    const lgray = Color(0xFF9AA0A6);
    const purple = Color(0xFF673AB7);
    const red = Color(0xFFF44336);
    const w = Colors.white;
    const bold = FontWeight.w700;
    const reg = FontWeight.w400;

    Widget head(double y, IconData ic, String s) {
      return Stack(
        children: [
          _i(16, y - 0.5, ic, 16, purple),
          _t(37, y, s, 12, gray, bold),
        ],
      );
    }

    Widget tab(double ix, double lx, IconData ic, String s, {bool on = false}) {
      return Stack(
        children: [
          _i(ix, 774, ic, 20, on ? purple : gray),
          _t(lx, 802, s, 10.5, on ? purple : gray,
              on ? bold : FontWeight.w500),
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
                _i(16, 60, Icons.menu, 20, dark),
                _t(52, 59, '設定', 18, dark, bold),
                head(111.5, Icons.edit_note, '文字入力方式'),
                _r(14, 133, 362, 108, w, rad: 14, bc: Color(0xFFEDF0F2)),
                _t(29, 146, 'アプリ内すべての文字入力欄に、選択した入力方式が一括で反映されます。', 11.5,
                    gray, reg, width: 335),
                _r(29, 186, 332, 42, Color(0xFFECEFF1), rad: 12),
                _r(32, 189, 163, 36, purple, rad: 10),
                _t(87, 199.5, 'ペンタブ', 13, w, bold),
                _t(244, 199.5, 'キーボード', 13, gray, bold),
                head(256.5, Icons.mail_outline, '事前確認・事前連絡'),
                _r(14, 278, 362, 159, w, rad: 14, bc: Color(0xFFEDF0F2)),
                _t(
                  29,
                  291,
                  '事前確認メールを配達前日に自動送信する時刻と、事前電話連絡の担当者番号を設定します。担当者番号には、電話連絡のし忘れ防止リマインドSMSが送信されます。',
                  11.5,
                  gray,
                  reg,
                  width: 325,
                ),
                _r(15, 339, 360, 49, w),
                _i(29, 353, Icons.schedule, 20, gray),
                _t(59, 356, '送信時刻', 11.5, gray, reg),
                _t(254, 353.5, '前日 09:00', 16, dark, bold),
                _i(343, 354, Icons.edit, 18, purple),
                _r(15, 388, 360, 48, w),
                _i(29, 402, Icons.phone_forwarded, 20, gray),
                _t(59, 405, '担当者番号', 11.5, gray, reg),
                _t(285, 402.5, '未設定', 16, gray, reg),
                _i(343, 403, Icons.edit, 18, purple),
                head(452.5, Icons.storefront, '店舗登録'),
                _r(14, 478, 362, 208, w, rad: 14, bc: Color(0xFFEDF0F2)),
                _r(15, 479, 360, 110, Color(0xFFEEF0F2)),
                _i(177, 516, Icons.storefront, 36, Color(0xFFB5BAC0)),
                _r(316, 560, 49, 19, Color(0xFFFFEBEE), rad: 6),
                _i(323, 565, Icons.delete_outline, 12, Color(0xFFD32F2F)),
                _t(335, 563, '削除', 10.5, Color(0xFFD32F2F), bold),
                _t(29, 603.5, '岡崎店', 16, dark, bold),
                _t(29, 626, '株式会社OLDROOKIE 岡崎', 11.5, gray, reg),
                _t(29, 642, '愛知県岡崎市康生通西4丁目71', 11.5, gray, reg),
                _i(29, 661, Icons.call, 12, gray),
                _t(41, 658, '0564-00-0000', 11.5, gray, reg),
                _i(341, 627, Icons.more_vert, 20, lgray),
                _r(0, 762, 390, 82, w, bc: Color(0xFFE4E7EB)),
                tab(32, 21, Icons.post_add, '受注入力'),
                tab(109, 98, Icons.list_alt, '受注一覧'),
                tab(185, 174, Icons.local_shipping, '配送予定'),
                tab(261, 261, Icons.people, '顧客'),
                _r(320, 769, 56, 30, Color(0xFFEDE7F6), rad: 15),
                tab(338, 327, Icons.apps, 'メニュー', on: true),
                _r(0, 0, 390, 844, Color(0x7A121218)),
                _r(28, 303, 334, 239, w, rad: 22),
                _r(169, 325, 52, 52, Color(0xFFFFEBEE), rad: 26),
                _i(181, 337, Icons.storefront, 28, red),
                _t(110.5, 389.5, '店舗を削除しますか？', 17, dark, bold),
                _t(53, 420, '「岡崎店」を削除します。この操作は取り消せません。', 13, gray, reg,
                    width: 288),
                _r(48, 479, 143, 46, w, rad: 12, bc: Color(0xFFE4E7EB)),
                _t(85.5, 493.5, 'キャンセル', 14, dark, bold),
                _r(201, 479, 141, 46, red, rad: 12),
                _t(258.5, 493.5, '削除', 14, w, bold),
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
