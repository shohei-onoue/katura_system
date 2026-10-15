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

class MobileOrderInputComplete892 extends StatelessWidget {
  const MobileOrderInputComplete892({super.key});

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: _ts(11.5, c: _sub)),
  );

  Widget _divider() => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(vertical: 12),
    color: _line,
  );

  Widget _wrap(List<Widget> chips) =>
      Wrap(spacing: 6, runSpacing: 6, children: chips);

  Widget _field(Widget child) => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 13),
    decoration: BoxDecoration(
      color: const Color(0xFFF6F7F9),
      border: Border.all(color: _line),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Align(alignment: Alignment.centerLeft, child: child),
  );

  Widget _confirmRow(
    IconData icon,
    Color ic,
    String label,
    String value, {
    double height = 49,
  }) => Container(
    height: height,
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Row(
      children: [
        _ic(icon, 20, ic),
        const SizedBox(width: 10),
        Text(
          label,
          style: _ts(11.5, w: FontWeight.w400, c: _sub),
        ),
        const Spacer(),
        Text(value, style: _ts(value.length > 6 ? 11.5 : 16)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    bottomNavigationBar: Container(
      height: 87,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _line)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('注文中止', style: _ts(15, c: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('確定', style: _ts(15, c: Colors.white)),
                  ),
                ),
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
    body: Column(
      children: [
        const _StatusBar(),
        _TopBar(
          icon: Icons.close,
          title: '受注入力',
          actions: [
            Text(
              '0564-12-3456',
              style: _ts(15, w: FontWeight.w900, c: _purple),
            ),
          ],
        ),
        const _Stepper([2, 2, 2, 1]),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _cardLine),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 37,
                      width: double.infinity,
                      color: _purple,
                      padding: const EdgeInsets.only(left: 14),
                      alignment: Alignment.centerLeft,
                      child: Text('梱包・確認設定', style: _ts(13, c: Colors.white)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('梱包方法'),
                          _wrap(const [
                            _Chip('個包装', selected: true),
                            _Chip('紙袋'),
                            _Chip('ダンボール'),
                            _Chip('小分け'),
                            _Chip('その他'),
                          ]),
                          _divider(),
                          _label('事前連絡'),
                          const Row(
                            children: [
                              _Chip('受電番号'),
                              SizedBox(width: 8),
                              Text(
                                'に',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: _ink,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 8),
                              _Chip('電話'),
                              SizedBox(width: 8),
                              Text(
                                'で連絡する',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: _ink,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 174,
                                child: _field(
                                  Text('0564-12-3456', style: _ts(16)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 150,
                                child: _field(
                                  Row(
                                    children: [
                                      _ic(Icons.event, 18, _purple),
                                      const SizedBox(width: 8),
                                      Text(
                                        '10/14 15:00',
                                        style: _ts(14, c: _purple),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _label('受取人の指定'),
                          Row(
                            children: [
                              const _Chip('ご本人', selected: true),
                              const SizedBox(width: 6),
                              const _Chip('指定'),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 34,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF6F7F9),
                                    border: Border.all(color: _line),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '青木 一郎',
                                    style: _ts(14, w: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _divider(),
                          Row(
                            children: [
                              Text('書類を選択', style: _ts(11.5, c: _sub)),
                              const Spacer(),
                              Text(
                                '領収書プレビュー ›',
                                style: _ts(11.5, c: const Color(0xFFFF6D00)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _wrap(const [
                            _Chip('領収書', selected: true),
                            _Chip('請求書'),
                            _Chip('レシート'),
                            _Chip('納品書'),
                            _Chip('印字領収書'),
                          ]),
                          const SizedBox(height: 10),
                          _label('支払い方法'),
                          _wrap(const [
                            _Chip('現金', selected: true),
                            _Chip('カード'),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text('最終確認', style: _ts(12, c: _sub)),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _cardLine),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _confirmRow(Icons.inventory_2, _purple, '梱包方法', '個包装'),
                    _confirmRow(
                      Icons.notifications_active,
                      _blue,
                      '事前連絡',
                      '青木 一郎 ・ 電話 ・ 10/14 15:00',
                      height: 45,
                    ),
                    Container(height: 53, color: const Color(0xFFFFF5F2)),
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
