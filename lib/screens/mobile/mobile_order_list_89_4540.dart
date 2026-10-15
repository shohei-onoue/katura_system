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

class _OrderListScaffold extends StatelessWidget {
  const _OrderListScaffold();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    bottomNavigationBar: const _BottomNav(1),
    body: Column(
      children: [
        const _StatusBar(),
        _TopBar(
          icon: Icons.menu,
          title: '受注一覧',
          actions: [_ic(Icons.search, 20, _ink)],
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const _DateStrip(),
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Row(
                  children: [
                    _Chip('全店舗', selected: true, purple: true),
                    SizedBox(width: 6),
                    _Chip('岡崎店'),
                    SizedBox(width: 6),
                    _Chip('名古屋店'),
                    SizedBox(width: 6),
                    _Chip('岐阜店'),
                  ],
                ),
              ),
              const _SectionLabel(Icons.directions_car, '配達 3件'),
              const _OrderCard(
                name: '山田 太郎',
                address: '愛知県岡崎市康生通西4丁目71',
                store: 0,
                detailed: true,
              ),
              const _OrderCard(
                name: '鈴木 花子',
                address: '愛知県名古屋市中区栄3丁目15-33',
                store: 1,
              ),
              const _OrderCard(
                name: '佐藤 次郎',
                address: '岐阜県岐阜市神田町6丁目1',
                store: 2,
              ),
              const _SectionLabel(Icons.volunteer_activism, '引取り 2件'),
              const _OrderCard(
                name: '高橋 一郎',
                address: '愛知県岡崎市大手町1丁目4',
                store: 0,
              ),
              const _OrderCard(
                name: '伊藤 美咲',
                address: '愛知県名古屋市東区葵1丁目13-3',
                store: 1,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DateStrip extends StatelessWidget {
  const _DateStrip();

  static const _days = [
    ('11', '日'),
    ('12', '月'),
    ('13', '火'),
    ('14', '水'),
    ('15', '木'),
    ('16', '金'),
    ('17', '土'),
  ];

  Color _color(int i) => i == 0 ? _red : (i == 6 ? _blue : _ink);

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(0, 8, 0, 11),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: 28,
            child: Row(
              children: [
                _ic(Icons.chevron_left, 20, _ink),
                const SizedBox(width: 8),
                Text('2026年10月', style: _ts(14)),
                const SizedBox(width: 8),
                _ic(Icons.chevron_right, 20, _ink),
                const Spacer(),
                Container(
                  width: 52,
                  decoration: BoxDecoration(
                    color: _lime,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text('今日', style: _ts(13))),
                ),
                const SizedBox(width: 16),
                _ic(Icons.refresh, 20, _sub),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Row(
            children: [
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 50,
                      decoration: i == 3
                          ? BoxDecoration(
                              color: _lime,
                              borderRadius: BorderRadius.circular(12),
                            )
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_days[i].$1, style: _ts(16, c: _color(i))),
                          Text(
                            _days[i].$2,
                            style: _ts(
                              11,
                              w: i == 3 ? FontWeight.w700 : FontWeight.w400,
                              c: _color(i),
                            ),
                          ),
                        ],
                      ),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Row(
      children: [
        _ic(icon, 16, _purple),
        const SizedBox(width: 5),
        Text(text, style: _ts(12, c: _sub)),
      ],
    ),
  );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.name,
    required this.address,
    required this.store,
    this.detailed = false,
  });

  final String name;
  final String address;
  final int store; // 0=岡崎 1=名古屋 2=岐阜
  final bool detailed;

  static const _storeNames = ['岡崎店', '名古屋店', '岐阜店'];
  static const _storeBg = [
    Color(0xFFE3F2FD),
    Color(0xFFE8F5E9),
    Color(0xFFF3E5F5),
  ];
  static const _storeFg = [
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFF8E24AA),
  ];

  Widget _tag(String t) => Container(
    height: 19,
    padding: const EdgeInsets.symmetric(horizontal: 7),
    decoration: BoxDecoration(
      color: _purpleTint,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Center(
      widthFactor: 1,
      child: Text(
        t,
        style: _ts(10.5, w: FontWeight.w500, c: _purple),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
    padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _cardLine),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: name,
                      style: _ts(17, w: FontWeight.w900),
                    ),
                    TextSpan(
                      text: ' 様',
                      style: _ts(11.5, w: FontWeight.w400, c: _sub),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 19,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                color: _storeBg[store],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                widthFactor: 1,
                child: Text(
                  _storeNames[store],
                  style: _ts(10.5, c: _storeFg[store]),
                ),
              ),
            ),
            const SizedBox(width: 13),
            _ic(Icons.edit, 18, _grey),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          address,
          style: _ts(11.5, w: FontWeight.w400, c: _sub),
        ),
        if (detailed) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              _ic(Icons.event, 15, _red),
              const SizedBox(width: 0),
              Text('10/14 12:00', style: _ts(11.5, c: _red)),
              const SizedBox(width: 18),
              _ic(Icons.notifications_active, 15, _sub),
              Text(
                '電話',
                style: _ts(11.5, w: FontWeight.w400, c: _sub),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [_tag('幕の内弁当 x10'), _tag('松花堂弁当 x5'), _tag('お茶 x15')],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '合計金額',
                style: _ts(11.5, w: FontWeight.w400, c: _sub),
              ),
              const Spacer(),
              Text(
                '15 個 / ¥18,750',
                style: _ts(16, c: const Color(0xFFF44336)),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

class MobileOrderList894540 extends StatelessWidget {
  const MobileOrderList894540({super.key});

  @override
  Widget build(BuildContext context) => const _OrderListScaffold();
}
