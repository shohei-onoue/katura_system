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

class MobileMenuMaster894645 extends StatelessWidget {
  const MobileMenuMaster894645({super.key});

  // (名前, カテゴリ, 価格)
  static const _rows = [
    ('特製ステーキ弁当', '厳選牛ステーキ弁当', '¥1,800'),
    ('松花堂弁当', '高級弁当', '¥2,500'),
    ('幕の内弁当', '高級弁当', '¥1,500'),
    ('鶏から揚げオードブル', 'オードブル', '¥3,500'),
    ('親子丼', '丼もの', '¥900'),
    ('ギフト詰め合わせ', 'ギフト', '¥4,000'),
    ('お茶（500ml）', 'ドリンク・サイドメニュー', '¥150'),
  ];
  static const _cats = ['厳選牛ステーキ弁当', '高級弁当', 'オードブル', '丼もの', 'ギフト', 'ドリンク'];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    bottomNavigationBar: const _BottomNav(4),
    body: Column(
      children: [
        const _StatusBar(),
        _TopBar(
          icon: Icons.menu,
          title: 'メニューマスタ',
          actions: [_ic(Icons.search, 20, _ink)],
        ),
        Container(
          height: 50,
          color: Colors.white,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            children: [
              const _Chip('すべて', selected: true, purple: true),
              for (final c in _cats) ...[const SizedBox(width: 6), _Chip(c)],
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(14, 10, 14, 16),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: _cardLine),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < _rows.length; i++)
                          Container(
                            height: 77,
                            color: i == 0
                                ? const Color(0xFFF6F0FF)
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF0F2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: _ic(
                                      Icons.restaurant,
                                      20,
                                      const Color(0xFFB5BAC0),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _rows[i].$1,
                                        style: _ts(
                                          14,
                                          c: i == 0
                                              ? const Color(0xFFFF6D00)
                                              : _ink,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${_rows[i].$2} ・ ',
                                              style: _ts(
                                                11.5,
                                                w: FontWeight.w400,
                                                c: _sub,
                                              ),
                                            ),
                                            TextSpan(
                                              text: _rows[i].$3,
                                              style: _ts(
                                                11.5,
                                                c: const Color(0xFFF44336),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _ic(Icons.more_vert, 20, _grey),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
              Positioned(
                right: 16,
                bottom: 98,
                child: Container(
                  width: 118,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ic(Icons.add, 20, Colors.white),
                      const SizedBox(width: 6),
                      Text('新規登録', style: _ts(14, c: Colors.white)),
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
