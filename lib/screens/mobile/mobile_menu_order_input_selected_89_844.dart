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

class _Stepper extends StatelessWidget {
  /// states: 0=未到達, 1=現在, 2=完了
  const _Stepper(this.states);

  final List<int> states;

  static const _labels = ['番号確認', '配達先の確定', '注文内容', '完了'];
  static const _orange = Color(0xFFFF6D00);
  static const _green = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) => Container(
    height: 59,
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(11, 8, 11, 0),
    child: Row(
      children: [
        for (int i = 0; i < 4; i++)
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: states[i] == 2
                        ? _green
                        : states[i] == 1
                        ? _orange
                        : Colors.white,
                    border: Border.all(
                      color: states[i] == 2
                          ? _green
                          : states[i] == 1
                          ? _orange
                          : const Color(0xFFCFD3D8),
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: states[i] == 2
                        ? _ic(Icons.check, 14, Colors.white)
                        : Text(
                            '${i + 1}',
                            style: _ts(
                              11,
                              c: states[i] == 1 ? Colors.white : _grey,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _labels[i],
                  style: _ts(
                    10,
                    w: states[i] == 1 ? FontWeight.w700 : FontWeight.w500,
                    c: states[i] == 1
                        ? _orange
                        : states[i] == 2
                        ? _ink
                        : _grey,
                  ),
                ),
              ],
            ),
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

class MobileMenuOrderInputSelected89844 extends StatelessWidget {
  const MobileMenuOrderInputSelected89844({super.key});

  @override
  Widget build(BuildContext context) => const Stack(
    fit: StackFit.expand,
    children: [_OrderInputStep1(), _MenuDrawer(0)],
  );
}

class _OrderInputStep1 extends StatelessWidget {
  const _OrderInputStep1();

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

  Widget _key(Widget child, Color color) => Expanded(
    child: Container(
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: child),
    ),
  );

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF2E3440);
    const mid = Color(0xFF6C737E);
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          const _StatusBar(),
          const _TopBar(icon: Icons.close, title: '受注入力'),
          const _Stepper([1, 0, 0, 0]),
          Container(
            margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            height: 146,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _cardLine),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Container(
                  height: 37,
                  width: double.infinity,
                  color: _purple,
                  padding: const EdgeInsets.only(left: 14),
                  alignment: Alignment.centerLeft,
                  child: Text('下４桁を入力', style: _ts(13, c: Colors.white)),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '0000',
                      style: _ts(
                        52,
                        w: FontWeight.w900,
                        c: const Color(0xFFD5D8DC),
                        ls: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            height: 322,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _line)),
            ),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text('入力ダイヤル', style: _ts(11.5, c: _sub)),
                    ),
                    const SizedBox(height: 14),
                    for (int r = 0; r < 3; r++) ...[
                      Row(
                        children: [
                          for (int c = 0; c < 3; c++) ...[
                            if (c > 0) const SizedBox(width: 9),
                            _key(
                              Text(
                                _keys[r * 3 + c],
                                style: _ts(24, c: Colors.white),
                              ),
                              dark,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 9),
                    ],
                    Row(
                      children: [
                        _key(Text('クリア', style: _ts(15, c: Colors.white)), mid),
                        const SizedBox(width: 9),
                        _key(Text('0', style: _ts(24, c: Colors.white)), dark),
                        const SizedBox(width: 9),
                        _key(_ic(Icons.backspace, 24, Colors.white), mid),
                      ],
                    ),
                  ],
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: Center(child: _HomeBar()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
