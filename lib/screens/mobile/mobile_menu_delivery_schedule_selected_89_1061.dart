import 'package:flutter/material.dart';

const _bg = Color(0xFFF3F7F6);
const _ink = Color(0xFF1D1B20);
const _sub = Color(0xFF6B6F76);
const _purple = Color(0xFF673AB7);
const _purpleTint = Color(0xFFEDE7F6);
const _line = Color(0xFFE4E7EB);
const _cardLine = Color(0xFFEDF0F2);
const _lime = Color(0xFFDAFFAF);
const _limeLine = Color(0xFFB9EA80);
const _limeText = Color(0xFF1D3B00);
const _grey = Color(0xFF9AA0A6);
const _red = Color(0xFFE53935);
const _blue = Color(0xFF1E88E5);

TextStyle _ts(
  double size, {
  FontWeight w = FontWeight.w700,
  Color c = _ink,
  double? ls,
}) => TextStyle(
  fontSize: size,
  fontWeight: w,
  color: c,
  letterSpacing: ls,
  height: 1.3,
  decoration: TextDecoration.none,
);

Icon _ic(IconData d, double s, Color c) => Icon(d, size: s, color: c);

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    color: Colors.white,
    padding: const EdgeInsets.only(left: 30, right: 26),
    child: Row(
      children: [
        Text('9:41', style: _ts(15)),
        const Spacer(),
        _ic(Icons.signal_cellular_alt, 17, _ink),
        const SizedBox(width: 5),
        _ic(Icons.wifi, 17, _ink),
        const SizedBox(width: 5),
        _ic(Icons.battery_full, 17, _ink),
      ],
    ),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.icon,
    required this.title,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        _ic(icon, 20, _ink),
        const SizedBox(width: 16),
        Text(title, style: _ts(18)),
        const Spacer(),
        ...actions,
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, {this.selected = false, this.purple = false});

  final String label;
  final bool selected;
  final bool purple;

  @override
  Widget build(BuildContext context) {
    final Color bg = selected ? (purple ? _purple : _lime) : Colors.white;
    final Color border = selected ? (purple ? _purple : _limeLine) : _line;
    final Color fg = selected ? (purple ? Colors.white : _limeText) : _ink;
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(label, style: _ts(13, c: fg)),
      ),
    );
  }
}

class _HomeBar extends StatelessWidget {
  const _HomeBar();

  @override
  Widget build(BuildContext context) => Container(
    width: 134,
    height: 5,
    decoration: BoxDecoration(
      color: const Color(0xFF111111),
      borderRadius: BorderRadius.circular(2.5),
    ),
  );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav(this.selected);

  final int selected;

  static const _icons = [
    Icons.post_add,
    Icons.list_alt,
    Icons.local_shipping,
    Icons.people,
    Icons.apps,
  ];
  static const _labels = ['受注入力', '受注一覧', '配送予定', '顧客', 'メニュー'];

  @override
  Widget build(BuildContext context) => Container(
    height: 82,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: _line)),
    ),
    child: Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
            child: Row(
              children: [
                for (int i = 0; i < 5; i++)
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 30,
                          decoration: i == selected
                              ? BoxDecoration(
                                  color: _purpleTint,
                                  borderRadius: BorderRadius.circular(15),
                                )
                              : null,
                          child: Center(
                            child: _ic(
                              _icons[i],
                              20,
                              i == selected ? _purple : _sub,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _labels[i],
                          style: _ts(
                            10.5,
                            w: i == selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            c: i == selected ? _purple : _sub,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: Center(child: _HomeBar()),
        ),
      ],
    ),
  );
}

class _MenuDrawer extends StatelessWidget {
  const _MenuDrawer(this.selected);

  final int selected;

  static const _icons = [
    Icons.post_add,
    Icons.list_alt,
    Icons.inventory_2,
    Icons.local_shipping,
    Icons.analytics,
    Icons.people,
    Icons.restaurant,
    Icons.badge,
    Icons.settings,
  ];
  static const _labels = [
    '受注入力',
    '受注一覧',
    '調理・仕入れ計画',
    '配送予定',
    'データ分析',
    '顧客管理',
    'メニューマスタ',
    'スタッフ管理',
    '設定',
  ];

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Color(0x7A121218))),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 296,
          child: ColoredBox(
            color: Colors.black,
            child: Stack(
              children: [
                Positioned(
                  left: 18,
                  top: 58,
                  child: Container(
                    width: 120,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Positioned(
                  left: 258,
                  top: 70,
                  child: _ic(Icons.close, 20, Colors.white),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 124,
                  child: Center(
                    child: Text(
                      '- MENU -',
                      style: _ts(
                        17,
                        w: FontWeight.w900,
                        c: Colors.white,
                        ls: 2,
                      ),
                    ),
                  ),
                ),
                for (int i = 0; i < _icons.length; i++)
                  Positioned(
                    left: 12,
                    top: 159.0 + 50 * i,
                    width: 272,
                    height: 46,
                    child: Container(
                      padding: const EdgeInsets.only(left: 14),
                      decoration: BoxDecoration(
                        color: i == selected ? const Color(0xFF3A3A3A) : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _ic(_icons[i], 22, Colors.white),
                          const SizedBox(width: 14),
                          Text(_labels[i], style: _ts(15, c: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  left: 18,
                  bottom: 50,
                  width: 260,
                  height: 57,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF444444)),
                    ),
                    child: Row(
                      children: [
                        _ic(Icons.account_circle, 22, Colors.white),
                        const SizedBox(width: 10),
                        Text('スタッフ名', style: _ts(16, c: Colors.white)),
                        const Spacer(),
                        _ic(Icons.logout, 20, Colors.white),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: 36,
                  child: Text(
                    'Version 1.0.52',
                    style: _ts(
                      11,
                      w: FontWeight.w400,
                      c: const Color(0xFF999999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: Center(child: _HomeBar()),
        ),
      ],
    ),
  );
}

class MobileMenuDeliveryScheduleSelected891061 extends StatelessWidget {
  const MobileMenuDeliveryScheduleSelected891061({super.key});

  @override
  Widget build(BuildContext context) => const Stack(
    fit: StackFit.expand,
    children: [_DeliveryScheduleScaffold(), _MenuDrawer(3)],
  );
}

class _DeliveryScheduleScaffold extends StatelessWidget {
  const _DeliveryScheduleScaffold();

  static const _orange = Color(0xFFFF8A65);
  static const _weekdays = ['日', '月', '火', '水', '木', '金', '土'];
  // (日, 当月か, 配送予定あり)
  static const _delivery = {15, 16, 20, 22, 27};

  Color _dayColor(int col, bool inMonth) {
    if (!inMonth)
      return col == 0 ? _red : (col == 6 ? _blue : const Color(0xFFC4C8CD));
    return col == 0 ? _red : (col == 6 ? _blue : _ink);
  }

  Widget _cell(int col, int day, bool inMonth) {
    final bool today = inMonth && day == 14;
    final bool has = inMonth && _delivery.contains(day);
    return Expanded(
      child: Center(
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: today ? _lime : null,
            border: has ? Border.all(color: _orange) : null,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Center(
            child: Text(
              '$day',
              style: _ts(
                13,
                w: today ? FontWeight.w700 : FontWeight.w400,
                c: today ? const Color(0xFFF44336) : _dayColor(col, inMonth),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _legend(Widget box, String t) => Row(
    children: [
      box,
      const SizedBox(width: 4),
      Text(
        t,
        style: _ts(11, w: FontWeight.w400, c: _sub),
      ),
    ],
  );

  Widget _box({Color? fill, Color? border}) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: fill,
      border: border != null ? Border.all(color: border) : null,
      borderRadius: BorderRadius.circular(5),
    ),
  );

  Widget _row(String time, String name, String place) => Container(
    height: 64,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    color: Colors.white,
    child: Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            time,
            style: _ts(13, w: FontWeight.w900, c: _purple),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$name 様', style: _ts(14)),
              const SizedBox(height: 2),
              Text(
                place,
                style: _ts(11.5, w: FontWeight.w400, c: _sub),
              ),
            ],
          ),
        ),
        _ic(Icons.chevron_right, 20, const Color(0xFFB0B5BB)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    // 2026年10月: 9/27(日)始まりの6週
    final List<List<(int, bool)>> weeks = [
      [
        (27, false),
        (28, false),
        (29, false),
        (30, false),
        (1, true),
        (2, true),
        (3, true),
      ],
      [
        (4, true),
        (5, true),
        (6, true),
        (7, true),
        (8, true),
        (9, true),
        (10, true),
      ],
      [
        (11, true),
        (12, true),
        (13, true),
        (14, true),
        (15, true),
        (16, true),
        (17, true),
      ],
      [
        (18, true),
        (19, true),
        (20, true),
        (21, true),
        (22, true),
        (23, true),
        (24, true),
      ],
      [
        (25, true),
        (26, true),
        (27, true),
        (28, true),
        (29, true),
        (30, true),
        (31, true),
      ],
      [
        (1, false),
        (2, false),
        (3, false),
        (4, false),
        (5, false),
        (6, false),
        (7, false),
      ],
    ];
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const _BottomNav(2),
      body: Column(
        children: [
          const _StatusBar(),
          const _TopBar(icon: Icons.menu, title: '配送予定'),
          Expanded(
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(14, 12, 14, 0),
                      child: Row(
                        children: [
                          _Chip('岡崎店', selected: true),
                          SizedBox(width: 6),
                          _Chip('名古屋店'),
                          SizedBox(width: 6),
                          _Chip('岐阜店'),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _cardLine),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 28,
                            child: Row(
                              children: [
                                _ic(Icons.chevron_left, 20, _ink),
                                const Spacer(),
                                Text('2026年10月', style: _ts(16)),
                                const Spacer(),
                                _ic(Icons.chevron_right, 20, _ink),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 20,
                            child: Row(
                              children: [
                                for (int i = 0; i < 7; i++)
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        _weekdays[i],
                                        style: _ts(
                                          11,
                                          w: FontWeight.w400,
                                          c: i == 0
                                              ? _red
                                              : (i == 6 ? _blue : _sub),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 9),
                          for (int w = 0; w < weeks.length; w++) ...[
                            if (w > 0) const SizedBox(height: 8),
                            Row(
                              children: [
                                for (int c = 0; c < 7; c++)
                                  _cell(c, weeks[w][c].$1, weeks[w][c].$2),
                              ],
                            ),
                          ],
                          const SizedBox(height: 11),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _legend(_box(border: _orange), '配送予定あり'),
                              const SizedBox(width: 28),
                              _legend(
                                _box(fill: Colors.white, border: _red),
                                '今日',
                              ),
                              const SizedBox(width: 28),
                              _legend(_box(fill: _lime), '選択中'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const _SectionLabelPlain(
                      Icons.event_note,
                      '10/14(水) の受注 3件',
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _cardLine),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          _row('12:00', '山田 太郎', '岡崎市 · 岡崎市民病院'),
                          _row('13:30', '鈴木 花子', '幸田町 · 幸田町役場'),
                          _row('15:00', '佐藤 次郎', '岡崎市 · 康生通西4丁目'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    width: 132,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _purple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ic(Icons.route, 20, Colors.white),
                        const SizedBox(width: 6),
                        Text('ルート確認', style: _ts(14, c: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabelPlain extends StatelessWidget {
  const _SectionLabelPlain(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
    child: Row(
      children: [
        _ic(icon, 16, _purple),
        const SizedBox(width: 5),
        Text(text, style: _ts(12, c: _sub)),
      ],
    ),
  );
}
