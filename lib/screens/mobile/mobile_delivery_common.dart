import 'package:flutter/material.dart';

// 配送予定・データ分析のスマホ画面で共通利用する部品（Figma 89:4540 の受注一覧と同じ見た目）
const mdBg = Color(0xFFF3F7F6);
const mdInk = Color(0xFF1D1B20);
const mdSub = Color(0xFF6B6F76);
const mdPurple = Color(0xFF673AB7);
const mdPurpleTint = Color(0xFFEDE7F6);
const mdLine = Color(0xFFE4E7EB);
const mdCardLine = Color(0xFFEDF0F2);
const mdLime = Color(0xFFDAFFAF);
const mdLimeLine = Color(0xFFB9EA80);
const mdLimeText = Color(0xFF1D3B00);

TextStyle mdTs(double size, {FontWeight w = FontWeight.w700, Color c = mdInk}) =>
    TextStyle(fontSize: size, fontWeight: w, color: c, height: 1.3, decoration: TextDecoration.none);

class MdStatusBar extends StatelessWidget {
  const MdStatusBar({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        color: Colors.white,
        padding: const EdgeInsets.only(left: 30, right: 26),
        child: Row(
          children: [
            Text('9:41', style: mdTs(15)),
            const Spacer(),
            const Icon(Icons.signal_cellular_alt, size: 17, color: mdInk),
            const SizedBox(width: 5),
            const Icon(Icons.wifi, size: 17, color: mdInk),
            const SizedBox(width: 5),
            const Icon(Icons.battery_full, size: 17, color: mdInk),
          ],
        ),
      );
}

class MdTopBar extends StatelessWidget {
  const MdTopBar({super.key, required this.title, this.icon = Icons.menu, this.onIconTap});

  final String title;
  final IconData icon;
  final VoidCallback? onIconTap;

  @override
  Widget build(BuildContext context) => Container(
        height: 52,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onIconTap,
              child: Icon(icon, size: 20, color: mdInk),
            ),
            const SizedBox(width: 16),
            Text(title, style: mdTs(18)),
          ],
        ),
      );
}

class MdChip extends StatelessWidget {
  const MdChip(this.label, {super.key, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? mdLime : Colors.white,
            border: Border.all(color: selected ? mdLimeLine : mdLine),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(widthFactor: 1, child: Text(label, style: mdTs(13, c: selected ? mdLimeText : mdInk))),
        ),
      );
}

/// 下部ナビ。selected: 0=受注入力 1=受注一覧 2=配送予定 3=顧客 4=メニュー（-1で選択なし）
class MdBottomNav extends StatelessWidget {
  const MdBottomNav(this.selected, {super.key, this.onNavigate});

  final int selected;
  final void Function(int)? onNavigate;
  static const _targets = [0, 1, 3, 6, 7];
  static const _icons = [Icons.post_add, Icons.list_alt, Icons.local_shipping, Icons.people, Icons.apps];
  static const _labels = ['受注入力', '受注一覧', '配送予定', '顧客', 'メニュー'];

  @override
  Widget build(BuildContext context) => Container(
        height: 82,
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: mdLine))),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Row(
                children: [
                  for (int i = 0; i < 5; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onNavigate?.call(_targets[i]),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 30,
                              decoration: i == selected
                                  ? BoxDecoration(color: mdPurpleTint, borderRadius: BorderRadius.circular(15))
                                  : null,
                              child: Center(child: Icon(_icons[i], size: 20, color: i == selected ? mdPurple : mdSub)),
                            ),
                            const SizedBox(height: 3),
                            Text(_labels[i],
                                style: mdTs(10.5,
                                    w: i == selected ? FontWeight.w700 : FontWeight.w500,
                                    c: i == selected ? mdPurple : mdSub)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(2.5)),
                ),
              ),
            ),
          ],
        ),
      );
}
