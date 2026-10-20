import 'package:flutter/material.dart';

/// 顧客管理・住所/施設検索（スマホ版）で共通に使う色（Figmaの値）
class PcColors {
  PcColors._();
  static const bg = Color(0xFFF4F1FA);
  static const purple = Color(0xFF673AB7);
  static const purpleSoft = Color(0xFFEDE7F6);
  static const purpleRow = Color(0xFFF6F0FF);
  static const green = Color(0xFFDAFFAF);
  static const greenBorder = Color(0xFFB9EA80);
  static const greenText = Color(0xFF1D3B00);
  static const text = Color(0xFF1D1B20);
  static const sub = Color(0xFF6B6F76);
  static const hint = Color(0xFF9AA0A6);
  static const line = Color(0xFFE4E7EB);
  static const line2 = Color(0xFFEDF0F2);
  static const field = Color(0xFFF6F7F9);
  static const segment = Color(0xFFECEFF1);
  static const chipOff = Color(0xFFF1F3F5);
  static const orange = Color(0xFFFF6D00);
  static const orangeSoft = Color(0xFFFF7043);
  static const red = Color(0xFFF44336);
  static const blue = Color(0xFF1E88E5);
  static const redOrange = Color(0xFFF4511E);
  static const slate = Color(0xFF78909C);
  static const chevron = Color(0xFFB0B5BB);
  static const handle = Color(0xFFD4D7DC);
}

/// 下から出るシート（角丸22・つまみ付き）の共通枠。[footer] は下の固定ボタン領域。
class PcSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? footer;
  final bool full; // true: 画面いっぱい（角丸16）
  final VoidCallback? onClose;
  const PcSheet({super.key, required this.title, required this.child, this.footer, this.full = false, this.onClose});

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(full ? 16 : 22);
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: radius)),
      child: SafeArea(
        top: full,
        child: Column(
          mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 5, decoration: BoxDecoration(color: PcColors.handle, borderRadius: BorderRadius.circular(2.5))),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 12, 10, 8),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: PcColors.text))),
                  GestureDetector(
                    onTap: onClose ?? () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(color: PcColors.chipOff, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 20, color: PcColors.text),
                    ),
                  ),
                ],
              ),
            ),
            if (full) Expanded(child: child) else Flexible(child: child),
            if (footer != null)
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: PcColors.line))),
                padding: const EdgeInsets.fromLTRB(18, 11, 18, 12),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

/// 高さ48・角丸12のシート下ボタン。
class PcButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color fill;
  final Color textColor;
  final Color? border;
  final IconData? icon;
  final double height;
  final double fontSize;
  final double radius;
  const PcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.fill = PcColors.purple,
    this.textColor = Colors.white,
    this.border,
    this.icon,
    this.height = 48,
    this.fontSize = 15,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: onTap == null ? fill.withValues(alpha: 0.5) : fill,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: border == null ? BorderSide.none : BorderSide(color: border!)),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 20, color: textColor), const SizedBox(width: 6)],
                Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 白地・枠線のキャンセル/閉じるボタン
class PcOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final Color border;
  const PcOutlineButton({super.key, required this.label, required this.onTap, this.color = PcColors.text, this.border = PcColors.line});

  @override
  Widget build(BuildContext context) => PcButton(label: label, onTap: onTap, fill: Colors.white, textColor: color, border: border);
}

/// 角丸の入力枠（#f6f7f9・枠線・高さ44）。右端にアイコン。
class PcFieldBox extends StatelessWidget {
  final String text;
  final bool isHint;
  final bool bold;
  final Color? color;
  final IconData? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onTrailingTap;
  const PcFieldBox({super.key, required this.text, this.isHint = false, this.bold = false, this.color, this.trailing, this.onTap, this.onTrailingTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        padding: const EdgeInsets.only(left: 13, right: 8),
        decoration: BoxDecoration(color: PcColors.field, border: Border.all(color: PcColors.line), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color ?? (isHint ? PcColors.hint : PcColors.text)),
              ),
            ),
            if (trailing != null)
              GestureDetector(
                onTap: onTrailingTap ?? onTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(padding: const EdgeInsets.all(6), child: Icon(trailing, size: 18, color: PcColors.sub)),
              ),
          ],
        ),
      ),
    );
  }
}

/// 小さなラベル（11.5pt 太字グレー）
class PcLabel extends StatelessWidget {
  final String text;
  const PcLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: PcColors.sub));
}

/// 切り替えタブ（#eceff1 の帯に、選択中だけ色が付く）
class PcSegment extends StatelessWidget {
  final List<String> labels;
  final List<IconData>? icons;
  final int index;
  final ValueChanged<int> onChanged;
  final Color selectedFill;
  final Color selectedText;
  const PcSegment({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    this.icons,
    this.selectedFill = PcColors.green,
    this.selectedText = PcColors.greenText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: PcColors.segment, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  decoration: BoxDecoration(color: i == index ? selectedFill : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icons != null) Icon(icons![i], size: 16, color: i == index ? selectedText : PcColors.sub),
                      Text(
                        labels[i],
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: i == index ? selectedText : PcColors.sub),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ステップ表示のチップ（完了=紫薄・選択中=緑・未=灰）
class PcStepChip extends StatelessWidget {
  final String title;
  final String value; // 完了時の値
  final bool done;
  final bool active;
  final VoidCallback? onTap;
  const PcStepChip({super.key, required this.title, required this.value, required this.done, required this.active, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = active ? PcColors.green : (done ? PcColors.purpleSoft : PcColors.chipOff);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (done && !active) ...[const Icon(Icons.check_circle, size: 12, color: PcColors.purple), const SizedBox(width: 2)],
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: (done || active) ? PcColors.text : PcColors.hint),
                  ),
                ),
              ],
            ),
            Text(
              active ? '選択中' : (done ? value : '-'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w900 : FontWeight.bold, color: (done || active) ? PcColors.text : PcColors.hint),
            ),
          ],
        ),
      ),
    );
  }
}

/// 数字キー（3x4）。'⌫' は橙の削除キー、'-' は灰色。
class PcNumPad extends StatelessWidget {
  final ValueChanged<String> onKey;
  const PcNumPad({super.key, required this.onKey});

  @override
  Widget build(BuildContext context) {
    const labels = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '-', '0', '⌫'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 9,
        crossAxisSpacing: 9,
        childAspectRatio: 103 / 56,
        children: [
          for (final l in labels)
            Material(
              color: l == '⌫' ? PcColors.orange : (l == '-' ? PcColors.segment : Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: l == '⌫' ? PcColors.orange : PcColors.line),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onKey(l),
                child: Center(
                  child: l == '⌫'
                      ? const Icon(Icons.backspace, size: 24, color: Colors.white)
                      : Text(l, style: TextStyle(fontSize: l == '-' ? 15 : 24, fontWeight: FontWeight.bold, color: PcColors.text)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 五十音キー（あ〜わ・すべて・戻る）
class PcKanaPad extends StatelessWidget {
  final String selected; // 選択中の頭文字（'すべて' など）
  final Map<String, List<String>> kanaMap;
  final void Function(String base, List<String> cycle, bool isMatch) onKana;
  final VoidCallback onAll;
  final VoidCallback? onBack;
  const PcKanaPad({super.key, required this.selected, required this.kanaMap, required this.onKana, required this.onAll, required this.onBack});

  @override
  Widget build(BuildContext context) {
    Widget key(String label, VoidCallback? onTap, {Color fill = Colors.white, Color text = PcColors.text, Color? border = PcColors.line2, double size = 18}) {
      return Material(
        color: fill,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: border == null ? BorderSide.none : BorderSide(color: border)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Center(child: Text(label, style: TextStyle(fontSize: size, fontWeight: FontWeight.bold, color: text))),
        ),
      );
    }

    final keys = <Widget>[];
    for (final e in kanaMap.entries) {
      final match = e.value.contains(selected);
      keys.add(key(match ? selected : e.key, () => onKana(e.key, e.value, match), fill: match ? PcColors.purpleSoft : Colors.white, text: match ? PcColors.purple : PcColors.text));
    }
    keys.add(key('すべて', onAll, fill: PcColors.purple, text: Colors.white, border: null, size: 16));
    keys.add(key('戻る', onBack, fill: PcColors.orange, text: Colors.white, border: null, size: 16));
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 113 / 50,
        children: keys,
      ),
    );
  }
}

/// 白カードの中に並ぶ「1行＋右矢印」リスト
class PcChevronList extends StatelessWidget {
  final List<String> items;
  final ValueChanged<String> onTap;
  final String? selected;
  const PcChevronList({super.key, required this.items, required this.onTap, this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: PcColors.line2), borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: items.isEmpty
          ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('該当する項目がありません', style: TextStyle(color: PcColors.hint))))
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (_, i) => InkWell(
                onTap: () => onTap(items[i]),
                child: Container(
                  height: 43,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Expanded(child: Text(items[i], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PcColors.text))),
                      const Icon(Icons.chevron_right, size: 20, color: PcColors.chevron),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
