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

class MobileCustomerList894737 extends StatelessWidget {
  const MobileCustomerList894737({super.key});

  static const _blueDays = _blue;
  static const _orangeDays = Color(0xFFF4511E);

  // (名前, 会社, 日数表記, 色)
  static const _rows = [
    ('青木 一郎', '株式会社アオキ', '12日', _blueDays),
    ('伊藤 美咲', '愛知県立病院', '45日', _blueDays),
    ('上田 健太', '上田工業株式会社', '98日', _orangeDays),
    ('遠藤 由美', '個人宅', '150日', _orangeDays),
    ('大野 浩二', '大野商事', '200日', _orangeDays),
    ('加藤 真理', '岡崎市役所', '420日', _grey),
    ('木村 拓也', '株式会社キムラ', '—', _grey),
    ('久保田 愛', '個人宅', '7日', _blueDays),
    ('小林 誠', '小林建設', '120日', _orangeDays),
    ('斎藤 恵子', '斎藤医院', '30日', _blueDays),
    ('佐藤 次郎', '佐藤製作所', '85日', _orangeDays),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    bottomNavigationBar: const _BottomNav(3),
    body: Column(
      children: [
        const _StatusBar(),
        _TopBar(
          icon: Icons.menu,
          title: '顧客管理',
          actions: [
            _ic(Icons.auto_awesome, 20, _ink),
            const SizedBox(width: 26),
            _ic(Icons.search, 20, _ink),
          ],
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Row(
                  children: [
                    _Chip('氏名順 ▾', selected: true),
                    SizedBox(width: 6),
                    _Chip('企業名 ▾'),
                    SizedBox(width: 6),
                    _Chip('前回経過日 ▾'),
                  ],
                ),
              ),
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
                        height: 64,
                        color: i == 0 ? const Color(0xFFF6F0FF) : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: _purpleTint,
                                borderRadius: BorderRadius.circular(19),
                              ),
                              child: Center(
                                child: _ic(Icons.person, 20, _purple),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_rows[i].$1} 様',
                                    style: _ts(14, c: i == 0 ? _purple : _ink),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _rows[i].$2,
                                    style: _ts(
                                      11.5,
                                      w: FontWeight.w400,
                                      c: _sub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _rows[i].$3,
                                  style: _ts(
                                    16,
                                    w: FontWeight.w900,
                                    c: _rows[i].$4,
                                  ),
                                ),
                                Text(
                                  '前回から',
                                  style: _ts(10, w: FontWeight.w400, c: _sub),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            _ic(Icons.more_vert, 20, _grey),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
