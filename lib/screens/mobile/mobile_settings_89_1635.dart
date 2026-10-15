// Figma node 89:1635 (mobile UI, 390x844 design). Generated from Figma.
import 'package:flutter/material.dart';

const _ink = Color(0xFF1D1B20);
const _grey = Color(0xFF6B6F76);
const _purple = Color(0xFF673AB7);
const _edge = Color(0xFFEDF0F2);

class MobileSettings891635 extends StatelessWidget {
  const MobileSettings891635({super.key});

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
                _r(0, 0, 390, 844, const Color(0xFFF3F7F6)),
                ..._settingsBody(0, 0),
                ..._nav(762, 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// dy1: shift for the mail card area (card height differs by 1px in design)
List<Widget> _settingsBody(double dy, double dummy) {
  return [
    _r(0, 0, 390, 44, Colors.white),
    _t(30, 13.5, '9:41', 15, _ink, FontWeight.w700),
    _i(303, 14, Icons.signal_cellular_alt, 17, _ink),
    _i(325, 14, Icons.wifi, 17, _ink),
    _i(347, 14, Icons.battery_full, 17, _ink),
    _r(0, 44, 390, 52, Colors.white),
    _i(16, 60, Icons.menu, 20, _ink),
    _t(52, 59, '設定', 18, _ink, FontWeight.w700),
    _i(16, 111, Icons.edit_note, 16, _purple),
    _t(37, 111.5, '文字入力方式', 12, _grey, FontWeight.w700),
    _r(14, 133, 362, 109, Colors.white, rad: 14, bc: _edge),
    _t(29, 146, 'アプリ内すべての文字入力欄に、選択した入力方式が一括で反映されます。', 11.5, _grey,
        FontWeight.w400,
        width: 335),
    _r(29, 187, 332, 42, const Color(0xFFECEFF1), rad: 12),
    _r(32, 190, 163, 36, _purple, rad: 10),
    _t(87, 200.5, 'ペンタブ', 13, Colors.white, FontWeight.w700),
    _t(244, 200.5, 'キーボード', 13, _grey, FontWeight.w700),
    _i(16, 257, Icons.mail_outline, 16, _purple),
    _t(37, 257.5, '事前確認・事前連絡', 12, _grey, FontWeight.w700),
    _r(14, 279, 362, 161, Colors.white, rad: 14, bc: _edge),
    _t(
        29,
        292,
        '事前確認メールを配達前日に自動送信する時刻と、事前電話連絡の担当者番号を設定します。担当者番号には、電話連絡のし忘れ防止リマインドSMSが送信されます。',
        11.5,
        _grey,
        FontWeight.w400,
        width: 325),
    _r(15, 342, 360, 49, Colors.white),
    _i(29, 356, Icons.schedule, 20, _grey),
    _t(59, 359, '送信時刻', 11.5, _grey, FontWeight.w400),
    _t(254, 356.5, '前日 09:00', 16, _ink, FontWeight.w700),
    _i(343, 357, Icons.edit, 18, _purple),
    _r(15, 391, 360, 48, Colors.white),
    _i(29, 405, Icons.phone_forwarded, 20, _grey),
    _t(59, 408, '担当者番号', 11.5, _grey, FontWeight.w400),
    _t(285, 405.5, '未設定', 16, _grey, FontWeight.w400),
    _i(343, 406, Icons.edit, 18, _purple),
    _i(16, 455, Icons.storefront, 16, _purple),
    _t(37, 455.5, '店舗登録', 12, _grey, FontWeight.w700),
    ..._store(481, 0, '岡崎店', '株式会社OLDROOKIE 岡崎', '愛知県岡崎市康生通西4丁目71',
        '0564-00-0000'),
  ];
}

// y = card top. Offsets follow node 89:1635 (card 481).
List<Widget> _store(double y, double d, String name, String corp, String addr,
    String tel) {
  return [
    _r(14, y, 362, 208, Colors.white, rad: 14, bc: _edge),
    _r(15, y + 1, 360, 110, const Color(0xFFEEF0F2)),
    _i(177, y + 38, Icons.storefront, 36, const Color(0xFFB5BAC0)),
    _r(316, y + 81, 49, 20, const Color(0xFFFFEBEE), rad: 6),
    _i(323, y + 86, Icons.delete_outline, 12, const Color(0xFFD32F2F)),
    _t(335, y + 84, '削除', 10.5, const Color(0xFFD32F2F), FontWeight.w700),
    _t(29, y + 125.5, name, 16, _ink, FontWeight.w700),
    _t(29, y + 148, corp, 11.5, _grey, FontWeight.w400),
    _t(29, y + 164, addr, 11.5, _grey, FontWeight.w400),
    _i(29, y + 183, Icons.call, 12, _grey),
    _t(41, y + 180, tel, 11.5, _grey, FontWeight.w400),
    _i(341, y + 149, Icons.more_vert, 20, const Color(0xFF9AA0A6)),
  ];
}

List<Widget> _nav(double y, double d) {
  const items = [
    [32.0, 21.0, Icons.post_add, '受注入力'],
    [109.0, 98.0, Icons.list_alt, '受注一覧'],
    [185.0, 174.0, Icons.local_shipping, '配送予定'],
    [261.0, 261.0, Icons.people, '顧客'],
  ];
  return [
    _r(0, y, 390, 82, Colors.white, bc: const Color(0xFFE4E7EB)),
    for (final e in items) ...[
      _i(e[0] as double, y + 12, e[2] as IconData, 20, _grey),
      _t(e[1] as double, y + 40, e[3] as String, 10.5, _grey, FontWeight.w500),
    ],
    _r(320, y + 7, 56, 30, const Color(0xFFEDE7F6), rad: 15),
    _i(338, y + 12, Icons.apps, 20, _purple),
    _t(327, y + 40, 'メニュー', 10.5, _purple, FontWeight.w700),
    _r(128, y + 69, 134, 5, const Color(0xFF111111), rad: 2.5),
  ];
}

Widget _r(double l, double t, double w, double h, Color? c,
    {double rad = 0, Color? bc}) {
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

Widget _t(double l, double t, String s, double size, Color c, FontWeight w,
    {double? width}) {
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
        height: 1.0,
        decoration: TextDecoration.none,
      ),
    ),
  );
}

Widget _i(double l, double t, IconData i, double size, Color c) {
  return Positioned(left: l, top: t, child: Icon(i, size: size, color: c));
}
