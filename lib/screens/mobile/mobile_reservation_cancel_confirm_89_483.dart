import 'package:flutter/material.dart';

Widget _b(
  double l,
  double t,
  double w,
  double h,
  Color? c, {
  double r = 0,
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
        borderRadius: BorderRadius.circular(r),
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
  Color c, {
  FontWeight w = FontWeight.w700,
  double? ls,
  double? width,
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
        decoration: TextDecoration.none,
      ),
    ),
  );
}

Widget _i(double l, double t, IconData icon, double size, Color c) {
  return Positioned(
    left: l,
    top: t,
    child: Icon(icon, size: size, color: c),
  );
}

Widget _frame(List<Widget> children) {
  return Scaffold(
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
}

class MobileReservationCancelConfirm89483 extends StatelessWidget {
  const MobileReservationCancelConfirm89483({super.key});

  @override
  Widget build(BuildContext context) {
    return _frame([
      _b(0, 0, 390, 44, Color(0xFFFFFFFF)),
      _t(30, 13.5, '9:41', 15, Color(0xFF1D1B20)),
      _i(303, 14, Icons.signal_cellular_alt, 17, Color(0xFF1D1B20)),
      _i(325, 14, Icons.wifi, 17, Color(0xFF1D1B20)),
      _i(347, 14, Icons.battery_full, 17, Color(0xFF1D1B20)),
      _b(0, 44, 390, 52, Color(0xFFFFFFFF)),
      _i(16, 60, Icons.menu, 20, Color(0xFF1D1B20)),
      _t(52, 59, '受注一覧', 18, Color(0xFF1D1B20)),
      _i(352, 60, Icons.search, 20, Color(0xFF1D1B20)),
      _b(0, 96, 390, 103, Color(0xFFFFFFFF)),
      _i(12, 108, Icons.chevron_left, 20, Color(0xFF1D1B20)),
      _t(40, 109.5, '2026年10月', 14, Color(0xFF1D1B20)),
      _i(126, 108, Icons.chevron_right, 20, Color(0xFF1D1B20)),
      _b(290, 104, 52, 28, Color(0xFFDAFFAF), r: 10),
      _t(303, 110.5, '今日', 13, Color(0xFF1D1B20)),
      _i(358, 108, Icons.refresh, 20, Color(0xFF6B6F76)),
      _b(173, 138, 44, 50, Color(0xFFDAFFAF), r: 12),
      _t(25.5, 145.5, '11', 16, Color(0xFFE53935)),
      _t(29.5, 168.5, '日', 11, Color(0xFFE53935), w: FontWeight.w400),
      _t(78.5, 145.5, '12', 16, Color(0xFF1D1B20)),
      _t(82.5, 168.5, '月', 11, Color(0xFF1D1B20), w: FontWeight.w400),
      _t(132.5, 145.5, '13', 16, Color(0xFF1D1B20)),
      _t(136.5, 168.5, '火', 11, Color(0xFF1D1B20), w: FontWeight.w400),
      _t(186.5, 145.5, '14', 16, Color(0xFF1D1B20)),
      _t(189.5, 168.5, '水', 11, Color(0xFF1D1B20)),
      _t(239.5, 145.5, '15', 16, Color(0xFF1D1B20)),
      _t(243.5, 168.5, '木', 11, Color(0xFF1D1B20), w: FontWeight.w400),
      _t(293.5, 145.5, '16', 16, Color(0xFF1D1B20)),
      _t(297.5, 168.5, '金', 11, Color(0xFF1D1B20), w: FontWeight.w400),
      _t(346.5, 145.5, '17', 16, Color(0xFF1E88E5)),
      _t(350.5, 168.5, '土', 11, Color(0xFF1E88E5), w: FontWeight.w400),
      _b(14, 209, 67, 34, Color(0xFF673AB7), r: 10, bc: Color(0xFF673AB7)),
      _t(28, 218.5, '全店舗', 13, Color(0xFFFFFFFF)),
      _b(87, 209, 67, 34, Color(0xFFFFFFFF), r: 10, bc: Color(0xFFE4E7EB)),
      _t(101, 218.5, '岡崎店', 13, Color(0xFF1D1B20)),
      _b(160, 209, 80, 34, Color(0xFFFFFFFF), r: 10, bc: Color(0xFFE4E7EB)),
      _t(174, 218.5, '名古屋店', 13, Color(0xFF1D1B20)),
      _b(246, 209, 67, 34, Color(0xFFFFFFFF), r: 10, bc: Color(0xFFE4E7EB)),
      _t(260, 218.5, '岐阜店', 13, Color(0xFF1D1B20)),
      _i(16, 260, Icons.directions_car, 16, Color(0xFF673AB7)),
      _t(37, 260.5, '配達 3件', 12, Color(0xFF6B6F76)),
      _b(14, 282, 362, 154, Color(0xFFFFFFFF), r: 14, bc: Color(0xFFEDF0F2)),
      _t(29, 297.5, '山田 太郎', 17, Color(0xFF1D1B20), w: FontWeight.w900),
      _t(109, 301, '様', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _b(284, 298, 46, 19, Color(0xFFE3F2FD), r: 6),
      _t(291, 301, '岡崎店', 10.5, Color(0xFF1565C0)),
      _i(343, 299, Icons.edit, 18, Color(0xFF9AA0A6)),
      _t(
        29,
        324,
        '愛知県岡崎市康生通西4丁目71',
        11.5,
        Color(0xFF6B6F76),
        w: FontWeight.w400,
      ),
      _i(29, 349, Icons.event, 15, Color(0xFFE53935)),
      _t(44, 348, '10/14 12:00', 11.5, Color(0xFFE53935)),
      _i(124, 349, Icons.notifications_active, 15, Color(0xFF6B6F76)),
      _t(139, 348, '電話', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _b(29, 372, 86, 19, Color(0xFFEDE7F6), r: 6),
      _t(36, 375, '幕の内弁当 x10', 10.5, Color(0xFF673AB7), w: FontWeight.w500),
      _b(121, 372, 80, 19, Color(0xFFEDE7F6), r: 6),
      _t(128, 375, '松花堂弁当 x5', 10.5, Color(0xFF673AB7), w: FontWeight.w500),
      _b(208, 372, 55, 19, Color(0xFFEDE7F6), r: 6),
      _t(215, 375, 'お茶 x15', 10.5, Color(0xFF673AB7), w: FontWeight.w500),
      _t(29, 404, '合計金額', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _t(247, 401.5, '15 個 / ¥18,750', 16, Color(0xFFF44336)),
      _b(14, 446, 362, 70, Color(0xFFFFFFFF), r: 14, bc: Color(0xFFEDF0F2)),
      _t(29, 461.5, '鈴木 花子', 17, Color(0xFF1D1B20), w: FontWeight.w900),
      _t(109, 465, '様', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _b(273, 462, 56, 19, Color(0xFFE8F5E9), r: 6),
      _t(280, 465, '名古屋店', 10.5, Color(0xFF2E7D32)),
      _i(343, 463, Icons.edit, 18, Color(0xFF9AA0A6)),
      _t(
        29,
        488,
        '愛知県名古屋市中区栄3丁目15-33',
        11.5,
        Color(0xFF6B6F76),
        w: FontWeight.w400,
      ),
      _b(14, 526, 362, 70, Color(0xFFFFFFFF), r: 14, bc: Color(0xFFEDF0F2)),
      _t(29, 541.5, '佐藤 次郎', 17, Color(0xFF1D1B20), w: FontWeight.w900),
      _t(109, 545, '様', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _b(284, 542, 46, 19, Color(0xFFF3E5F5), r: 6),
      _t(291, 545, '岐阜店', 10.5, Color(0xFF8E24AA)),
      _i(343, 543, Icons.edit, 18, Color(0xFF9AA0A6)),
      _t(29, 568, '岐阜県岐阜市神田町6丁目1', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _i(16, 611, Icons.volunteer_activism, 16, Color(0xFF673AB7)),
      _t(37, 611.5, '引取り 2件', 12, Color(0xFF6B6F76)),
      _b(14, 633, 362, 70, Color(0xFFFFFFFF), r: 14, bc: Color(0xFFEDF0F2)),
      _t(29, 648.5, '高橋 一郎', 17, Color(0xFF1D1B20), w: FontWeight.w900),
      _t(109, 652, '様', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _b(284, 649, 46, 19, Color(0xFFE3F2FD), r: 6),
      _t(291, 652, '岡崎店', 10.5, Color(0xFF1565C0)),
      _i(343, 650, Icons.edit, 18, Color(0xFF9AA0A6)),
      _t(29, 675, '愛知県岡崎市大手町1丁目4', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _b(14, 713, 362, 70, Color(0xFFFFFFFF), r: 14, bc: Color(0xFFEDF0F2)),
      _t(29, 728.5, '伊藤 美咲', 17, Color(0xFF1D1B20), w: FontWeight.w900),
      _t(109, 732, '様', 11.5, Color(0xFF6B6F76), w: FontWeight.w400),
      _b(273, 729, 56, 19, Color(0xFFE8F5E9), r: 6),
      _t(280, 732, '名古屋店', 10.5, Color(0xFF2E7D32)),
      _i(343, 730, Icons.edit, 18, Color(0xFF9AA0A6)),
      _t(
        29,
        755,
        '愛知県名古屋市東区葵1丁目13-3',
        11.5,
        Color(0xFF6B6F76),
        w: FontWeight.w400,
      ),
      _b(0, 762, 390, 82, Color(0xFFFFFFFF), bc: Color(0xFFE4E7EB)),
      _b(91, 769, 56, 30, Color(0xFFEDE7F6), r: 15),
      _i(32, 774, Icons.post_add, 20, Color(0xFF6B6F76)),
      _t(21, 802, '受注入力', 10.5, Color(0xFF6B6F76), w: FontWeight.w500),
      _i(109, 774, Icons.list_alt, 20, Color(0xFF673AB7)),
      _t(98, 802, '受注一覧', 10.5, Color(0xFF673AB7)),
      _i(185, 774, Icons.local_shipping, 20, Color(0xFF6B6F76)),
      _t(174, 802, '配送予定', 10.5, Color(0xFF6B6F76), w: FontWeight.w500),
      _i(261, 774, Icons.people, 20, Color(0xFF6B6F76)),
      _t(261, 802, '顧客', 10.5, Color(0xFF6B6F76), w: FontWeight.w500),
      _i(338, 774, Icons.apps, 20, Color(0xFF6B6F76)),
      _t(327, 802, 'メニュー', 10.5, Color(0xFF6B6F76), w: FontWeight.w500),
      _b(0, 0, 390, 844, Color(0x7A121218)),
      _b(28, 303, 334, 239, Color(0xFFFFFFFF), r: 22),
      _b(169, 325, 52, 52, Color(0xFFFFEBEE), r: 26),
      _i(181, 337, Icons.event_busy, 28, Color(0xFFF44336)),
      _t(110.5, 389.5, '予約キャンセルの確認', 17, Color(0xFF1D1B20)),
      _t(
        49,
        420,
        '山田 太郎 様の予約をキャンセルし、登録内容を削除します。元に戻せません。よろしいですか？',
        13,
        Color(0xFF6B6F76),
        w: FontWeight.w400,
        width: 295,
      ),
      _b(48, 479, 143, 46, Color(0xFFFFFFFF), r: 12, bc: Color(0xFFE4E7EB)),
      _t(99.5, 493.5, 'いいえ', 14, Color(0xFF1D1B20)),
      _b(201, 479, 141, 46, Color(0xFFF44336), r: 12),
      _t(223.5, 493.5, 'キャンセルする', 14, Color(0xFFFFFFFF)),
      _b(128, 831, 134, 5, Color(0xFF111111), r: 2.5),
    ]);
  }
}
