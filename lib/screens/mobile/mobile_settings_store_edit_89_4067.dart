// Figma node 89:4067 (mobile UI, 390x1500 design). Generated from Figma.
import 'package:flutter/material.dart';

class MobileSettingsStoreEdit894067 extends StatelessWidget {
  const MobileSettingsStoreEdit894067({super.key});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1D1B20);
    const grey = Color(0xFF6B6F76);
    const white = Color(0xFFFFFFFF);
    const purple = Color(0xFF673AB7);
    const border = Color(0xFFEDF0F2);
    const fieldBg = Color(0xFFF6F7F9);
    const fieldBd = Color(0xFFE4E7EB);
    const ph = Color(0xFFEEF0F2);
    const phIcon = Color(0xFFB5BAC0);
    Widget label(double top, String s) =>
        _t(29, top, s, 11.5, grey, FontWeight.w700);
    Widget field(double top, String s, {IconData? icon}) => Stack(children: [
          _r(29, top, 332, 44, fieldBg, rad: 10, bc: fieldBd),
          _t(42, top + 13.5, s, 14, dark, FontWeight.w400),
          if (icon != null) _i(330, top + 13, icon, 18, grey),
        ]);
    Widget storeCard(double top, String name, String company, String addr,
            String tel) =>
        Stack(children: [
          _r(14, top, 362, 208, white, rad: 14, bc: border),
          _r(15, top + 1, 360, 110, ph, rad: 0),
          _i(177, top + 38, Icons.storefront, 36, phIcon),
          _r(316, top + 82, 49, 19, const Color(0xFFFFEBEE), rad: 6),
          _i(323, top + 87, Icons.delete_outline, 12, const Color(0xFFD32F2F)),
          _t(335, top + 85, '削除', 10.5, const Color(0xFFD32F2F),
              FontWeight.w700),
          _t(29, top + 125.5, name, 16, dark, FontWeight.w700),
          _t(29, top + 148, company, 11.5, grey, FontWeight.w400),
          _t(29, top + 164, addr, 11.5, grey, FontWeight.w400),
          _i(29, top + 183, Icons.call, 12, grey),
          _t(41, top + 180, tel, 11.5, grey, FontWeight.w400),
          _i(341, top + 149, Icons.more_vert, 20, const Color(0xFF9AA0A6)),
        ]);
    Widget nav(double x, double lx, IconData ic, String s) => Stack(children: [
          _i(x, 1430, ic, 20, grey),
          _t(lx, 1458, s, 10.5, grey, FontWeight.w500),
        ]);

    return Material(
      color: const Color(0xFFF3F7F6),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 390,
            height: 1500,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                _r(0, 0, 390, 1500, const Color(0xFFF3F7F6), rad: 0),
                _r(0, 0, 390, 44, white, rad: 0),
                _t(30, 13.5, '9:41', 15, dark, FontWeight.w700),
                _i(303, 14, Icons.signal_cellular_alt, 17, dark),
                _i(325, 14, Icons.wifi, 17, dark),
                _i(347, 14, Icons.battery_full, 17, dark),
                _r(0, 44, 390, 52, white, rad: 0),
                _i(16, 60, Icons.menu, 20, dark),
                _t(52, 59, '設定', 18, dark, FontWeight.w700),
                _i(16, 111, Icons.edit_note, 16, purple),
                _t(37, 111.5, '文字入力方式', 12, grey, FontWeight.w700),
                _r(14, 133, 362, 108, white, rad: 14, bc: border),
                _t(29, 146, 'アプリ内すべての文字入力欄に、選択した入力方式が一括で反映されます。', 11.5, grey,
                    FontWeight.w400,
                    width: 335),
                _r(29, 186, 332, 42, const Color(0xFFECEFF1), rad: 12),
                _r(32, 189, 163, 36, purple, rad: 10),
                _t(87, 199.5, 'ペンタブ', 13, white, FontWeight.w700),
                _t(244, 199.5, 'キーボード', 13, grey, FontWeight.w700),
                _i(16, 256, Icons.mail_outline, 16, purple),
                _t(37, 256.5, '事前確認・事前連絡', 12, grey, FontWeight.w700),
                _r(14, 278, 362, 159, white, rad: 14, bc: border),
                _t(
                    29,
                    291,
                    '事前確認メールを配達前日に自動送信する時刻と、事前電話連絡の担当者番号を設定します。担当者番号には、電話連絡のし忘れ防止リマインドSMSが送信されます。',
                    11.5,
                    grey,
                    FontWeight.w400,
                    width: 325),
                _r(15, 339, 360, 49, white, rad: 0),
                _i(29, 353, Icons.schedule, 20, grey),
                _t(59, 356, '送信時刻', 11.5, grey, FontWeight.w400),
                _t(254, 353.5, '前日 09:00', 16, dark, FontWeight.w700),
                _i(343, 354, Icons.edit, 18, purple),
                _r(15, 388, 360, 48, white, rad: 0),
                _i(29, 402, Icons.phone_forwarded, 20, grey),
                _t(59, 405, '担当者番号', 11.5, grey, FontWeight.w400),
                _t(285, 402.5, '未設定', 16, grey, FontWeight.w400),
                _i(343, 403, Icons.edit, 18, purple),
                _i(16, 452, Icons.storefront, 16, purple),
                _t(37, 452.5, '店舗登録', 12, grey, FontWeight.w700),
                _r(14, 478, 362, 531, white, rad: 14, bc: border),
                _r(15, 479, 360, 110, ph, rad: 0),
                _i(177, 516, Icons.storefront, 36, phIcon),
                label(606, '店舗名'),
                field(626, '岡崎店'),
                label(675, '社名'),
                field(695, '株式会社OLDROOKIE 岡崎'),
                label(744, '住所'),
                field(764, '愛知県岡崎市康生通西4丁目71', icon: Icons.edit_location_alt),
                label(813, '電話番号'),
                field(833, '0564-00-0000'),
                label(882, '配送車両数'),
                field(902, '2'),
                _r(29, 958, 163, 38, white, rad: 10, bc: fieldBd),
                _t(78.5, 969.5, 'キャンセル', 13, dark, FontWeight.w700),
                _r(200, 958, 161, 38, purple, rad: 10),
                _t(267.5, 969.5, '完了', 13, white, FontWeight.w700),
                storeCard(1019, '名古屋店', '株式会社OLDROOKIE 名古屋',
                    '愛知県名古屋市中区栄3丁目15-33', '052-000-0000'),
                storeCard(1237, '岐阜店', '株式会社OLDROOKIE 岐阜',
                    '岐阜県岐阜市神田町6丁目1', '058-000-0000'),
                _i(143, 1464, Icons.add, 20, const Color(0xFFFF6D00)),
                _t(165.5, 1461.5, '店舗を追加', 16, const Color(0xFFFF6D00),
                    FontWeight.w700),
                _r(0, 1418, 390, 82, white, rad: 0, bc: fieldBd),
                nav(32, 21, Icons.post_add, '受注入力'),
                nav(109, 98, Icons.list_alt, '受注一覧'),
                nav(185, 174, Icons.local_shipping, '配送予定'),
                nav(261, 261, Icons.people, '顧客'),
                _r(320, 1425, 56, 30, const Color(0xFFEDE7F6), rad: 15),
                _i(338, 1430, Icons.apps, 20, purple),
                _t(327, 1458, 'メニュー', 10.5, purple, FontWeight.w700),
                _r(128, 1487, 134, 5, const Color(0xFF111111), rad: 2.5),
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
