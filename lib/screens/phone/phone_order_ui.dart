import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../utils/name_format.dart';

/// スマホ版「受注入力」(Figma 89-xxxx) 用の色・部品・ボトムシート。
class PO {
  PO._();
  static const bg = Color(0xFFF3F7F6);
  static const text = Color(0xFF1D1B20);
  static const sub = Color(0xFF6B6F76);
  static const hint = Color(0xFF9AA0A6);
  static const purple = Color(0xFF673AB7);
  static const purpleLight = Color(0xFFEDE7F6);
  static const orange = Color(0xFFFF6D00);
  static const green = Color(0xFF4CAF50);
  static const red = Color(0xFFF44336);
  static const blue = Color(0xFF1E88E5);
  static const selBg = Color(0xFFDAFFAF);
  static const selBorder = Color(0xFFB9EA80);
  static const selText = Color(0xFF1D3B00);
  static const line = Color(0xFFE4E7EB);
  static const cardLine = Color(0xFFEDF0F2);
  static const stepLine = Color(0xFFCFD3D8);
  static const segBg = Color(0xFFECEFF1);
  static const field = Color(0xFFF6F7F9);
  static const dark = Color(0xFF2E3440);
  static const darkGray = Color(0xFF6C737E);
  static const slate = Color(0xFF78909C);
  static const grayBtn = Color(0xFFB8BCC2);
  static const overlay = Color(0x7A121218);
  static const mapBg = Color(0xFFCFE5D2);
  static const mapText = Color(0xFF5B8A65);
  static const imgBg = Color(0xFFEEF0F2);
  static const imgIcon = Color(0xFFB5BAC0);
  static const warnBg = Color(0xFFFFF8E1);
  static const warnLine = Color(0xFFFFB300);
  static const warnText = Color(0xFFE65100);
  static const orderRing = Color(0xFFFF8A65);

  static TextStyle ts(double size, {Color color = text, FontWeight w = FontWeight.w700, double? ls, double? h}) =>
      TextStyle(fontSize: size, color: color, fontWeight: w, letterSpacing: ls, height: h);
}

/// 画面上部：× と タイトル（受注入力）、右に受電番号
class PoHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;
  final String phone;
  final Color bg;
  final Color fg;
  const PoHeader({super.key, this.title = '受注入力', this.onClose, this.phone = '', this.bg = Colors.white, this.fg = PO.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: bg,
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: SizedBox(width: 36, height: 52, child: Align(alignment: Alignment.centerLeft, child: Icon(Icons.close_rounded, size: 20, color: fg))),
          ),
          Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: PO.ts(18, color: fg))),
          if (phone.isNotEmpty) Text(phone, style: PO.ts(15, color: PO.purple, w: FontWeight.w900)),
        ],
      ),
    );
  }
}

/// ステップ表示（番号確認 / 配達先の確定 / 注文内容 / 完了）
class PoStepper extends StatelessWidget {
  final List<String> labels;
  final int current;
  final int maxReached;
  final ValueChanged<int>? onTap;
  const PoStepper({super.key, required this.labels, required this.current, required this.maxReached, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 59,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12.5, 8, 12.5, 0),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap == null ? null : () => onTap!(i),
                child: Column(
                  children: [
                    _circle(i),
                    const SizedBox(height: 4.5),
                    Text(
                      labels[i],
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                      style: i == current
                          ? PO.ts(10, color: PO.orange)
                          : i < current
                              ? PO.ts(10, w: FontWeight.w500)
                              : PO.ts(10, color: PO.hint, w: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _circle(int i) {
    final bool done = i < current;
    final bool cur = i == current;
    final Color c = done ? PO.green : (cur ? PO.orange : Colors.white);
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        border: Border.all(color: (done || cur) ? c : PO.stepLine),
      ),
      child: done
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : Text('${i + 1}', style: PO.ts(11, color: cur ? Colors.white : PO.hint)),
    );
  }
}

/// 紫の見出し付きカード
class PoCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets padding;
  const PoCard({super.key, required this.title, this.trailing, required this.child, this.padding = const EdgeInsets.fromLTRB(14, 14, 14, 14)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PO.cardLine),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 37,
              color: PO.purple,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: PO.ts(13, color: Colors.white))),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// 白い角丸カード（見出しなし）
class PoPlainCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color? borderColor;
  const PoPlainCard({super.key, required this.child, this.color = Colors.white, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? PO.cardLine),
      ),
      child: child,
    );
  }
}

class PoSectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  const PoSectionTitle(this.text, {super.key, this.padding = const EdgeInsets.fromLTRB(2, 14, 0, 8)});
  @override
  Widget build(BuildContext context) => Padding(padding: padding, child: Text(text, style: PO.ts(12, color: PO.sub)));
}

class PoLabel extends StatelessWidget {
  final String text;
  const PoLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: PO.ts(11.5, color: PO.sub)));
}

/// 選択チップ（選択中は淡い緑）
class PoChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool outlineOrange;
  const PoChip({super.key, required this.label, required this.selected, this.onTap, this.outlineOrange = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? PO.selBg : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? PO.selBorder : (outlineOrange ? PO.orange : PO.line), width: outlineOrange && !selected ? 1.5 : 1),
        ),
        child: Text(label, style: PO.ts(13, color: selected ? PO.selText : PO.text)),
      ),
    );
  }
}

/// 2〜4択のセグメント（外枠グレー・選択は淡い緑）
class PoSegment extends StatelessWidget {
  final List<String> options;
  final int index;
  final ValueChanged<int> onChanged;
  const PoSegment({super.key, required this.options, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: PO.segBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: i == index ? PO.selBg : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                  child: Text(options[i], style: PO.ts(13, color: i == index ? PO.selText : PO.sub)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 画面下のボタン（塗り／枠）
class PoButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool outline;
  final Color? outlineColor;
  final double height;
  final double fontSize;
  final double radius;
  const PoButton({
    super.key,
    required this.label,
    this.color = PO.purple,
    this.onTap,
    this.outline = false,
    this.outlineColor,
    this.height = 48,
    this.fontSize = 15,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final Color oc = outlineColor ?? PO.line;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outline ? Colors.white : color,
          borderRadius: BorderRadius.circular(radius),
          border: outline ? Border.all(color: oc) : null,
        ),
        child: Text(label, style: PO.ts(fontSize, color: outline ? (outlineColor ?? PO.text) : Colors.white)),
      ),
    );
  }
}

/// 画面下に固定するボタン帯
class PoFooter extends StatelessWidget {
  final List<Widget> children;
  const PoFooter({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: PO.line))),
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: children[i]),
            ],
          ],
        ),
      ),
    );
  }
}

/// 入力欄風のタップ領域（グレー地・枠）
class PoField extends StatelessWidget {
  final String text;
  final String hint;
  final VoidCallback? onTap;
  final IconData? trailing;
  final VoidCallback? onTrailingTap;
  final double fontSize;
  const PoField({super.key, required this.text, this.hint = '', this.onTap, this.trailing, this.onTrailingTap, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    final bool empty = text.isEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(color: PO.field, borderRadius: BorderRadius.circular(10), border: Border.all(color: PO.line)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                empty ? hint : text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PO.ts(fontSize, color: empty ? PO.hint : PO.text, w: FontWeight.w400),
              ),
            ),
            if (trailing != null)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTrailingTap ?? onTap,
                child: Padding(padding: const EdgeInsets.only(left: 6), child: Icon(trailing, size: 18, color: PO.sub)),
              ),
          ],
        ),
      ),
    );
  }
}

/// 地図の代わりの枠（地点が未確定のとき）
class PoMapPlaceholder extends StatelessWidget {
  final double height;
  const PoMapPlaceholder({super.key, required this.height});
  @override
  Widget build(BuildContext context) => Container(
        height: height,
        color: PO.mapBg,
        alignment: Alignment.center,
        child: Text('地図（Googleマップ）', style: PO.ts(13, color: PO.mapText)),
      );
}

/// 電話番号用の黒いダイヤル（0〜9・クリア・←）
class PoDialPad extends StatelessWidget {
  final ValueChanged<String> onInput;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  const PoDialPad({super.key, required this.onInput, required this.onClear, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    Widget key(Widget child, Color c, VoidCallback f) => Expanded(
          child: GestureDetector(
            onTap: f,
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(14)),
              child: child,
            ),
          ),
        );
    Widget num(String d) => key(Text(d, style: PO.ts(24, color: Colors.white)), PO.dark, () => onInput(d));
    Widget row(List<Widget> ks) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(children: [for (int i = 0; i < ks.length; i++) ...[if (i > 0) const SizedBox(width: 9), ks[i]]]),
        );
    return Container(
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: PO.line))),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(left: 2, bottom: 16), child: Text('入力ダイヤル', style: PO.ts(11.5, color: PO.sub))),
            row([num('1'), num('2'), num('3')]),
            row([num('4'), num('5'), num('6')]),
            row([num('7'), num('8'), num('9')]),
            row([
              key(Text('クリア', style: PO.ts(15, color: Colors.white)), PO.darkGray, onClear),
              num('0'),
              key(const Icon(Icons.backspace_rounded, size: 24, color: Colors.white), PO.darkGray, onBackspace),
            ]),
          ],
        ),
      ),
    );
  }
}

// ===================== ボトムシート共通 =====================

Future<T?> showPoSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: PO.overlay,
    builder: (ctx) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom), child: builder(ctx)),
  );
}

/// シートの枠：つまみ・タイトル・閉じる・本文（スクロール）・下ボタン
class PoSheetFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? footer;
  final VoidCallback? onClose;
  const PoSheetFrame({super.key, required this.title, required this.child, this.footer, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFFD4D7DC), borderRadius: BorderRadius.circular(2.5))),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 8, 20, 0),
            child: Row(
              children: [
                Expanded(child: Text(title, style: PO.ts(17))),
                GestureDetector(
                  onTap: onClose ?? () => Navigator.maybePop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: Color(0xFFF1F3F5), shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, size: 20, color: PO.text),
                  ),
                ),
              ],
            ),
          ),
          Flexible(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 12), child: child)),
          if (footer != null)
            Container(
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: PO.line))),
              padding: const EdgeInsets.fromLTRB(18, 11, 18, 11),
              child: SafeArea(top: false, child: footer!),
            ),
        ],
      ),
    );
  }
}

// ===================== 数量・番号・時刻の入力シート =====================

/// 数字入力シート（数量・担当者番号・来店時間など）。「確定」で文字列を返す。
/// [timeFormat] のときは HHMM（4桁）を「HH:MM」で表示し、確定値は4桁。
Future<String?> showPhoneNumericSheet(
  BuildContext context, {
  required String title,
  String initial = '',
  String hint = '番号を入力してください',
  String unit = '',
  int maxLength = 20,
  bool timeFormat = false,
}) {
  return showPoSheet<String>(
    context,
    (_) => _NumericSheet(title: title, initial: initial, hint: hint, unit: unit, maxLength: maxLength, timeFormat: timeFormat),
  );
}

class _NumericSheet extends StatefulWidget {
  final String title, initial, hint, unit;
  final int maxLength;
  final bool timeFormat;
  const _NumericSheet({required this.title, required this.initial, required this.hint, required this.unit, required this.maxLength, required this.timeFormat});
  @override
  State<_NumericSheet> createState() => _NumericSheetState();
}

class _NumericSheetState extends State<_NumericSheet> {
  late String _v;
  @override
  void initState() {
    super.initState();
    _v = widget.initial.replaceAll(RegExp(r'[^0-9]'), '');
    if (widget.timeFormat && _v.length > 4) _v = _v.substring(_v.length - 4);
  }

  void _in(String d) => setState(() {
        if (widget.timeFormat) {
          _v = (_v + d);
          if (_v.length > 4) _v = _v.substring(_v.length - 4);
        } else if (_v.length < widget.maxLength) {
          _v += d;
        }
      });

  String get _shown {
    if (widget.timeFormat) {
      final p = _v.padLeft(4, '0');
      return '${p.substring(0, 2)}:${p.substring(2)}';
    }
    return widget.unit.isEmpty ? _v : '${_v.isEmpty ? '0' : _v} ${widget.unit}';
  }

  @override
  Widget build(BuildContext context) {
    final bool empty = _v.isEmpty && !widget.timeFormat;
    final bool showHint = empty && widget.unit.isEmpty;
    Widget key(Widget child, Color bg, Color border, VoidCallback f) => Expanded(
          child: GestureDetector(
            onTap: f,
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
              child: child,
            ),
          ),
        );
    Widget num(String d) => key(Text(d, style: PO.ts(24)), Colors.white, PO.line, () => _in(d));
    Widget row(List<Widget> ks) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(children: [for (int i = 0; i < ks.length; i++) ...[if (i > 0) const SizedBox(width: 9), ks[i]]]),
        );
    return PoSheetFrame(
      title: widget.title,
      footer: PoButton(
        label: '確定',
        onTap: () {
          final out = widget.timeFormat ? _v.padLeft(4, '0') : _v;
          Navigator.pop(context, out);
        },
      ),
      child: Column(
        children: [
          Container(
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: PO.field, borderRadius: BorderRadius.circular(10), border: Border.all(color: PO.line)),
            child: Text(
              showHint ? widget.hint : _shown,
              style: showHint ? PO.ts(18, color: PO.hint) : PO.ts(26),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                row([num('1'), num('2'), num('3')]),
                row([num('4'), num('5'), num('6')]),
                row([num('7'), num('8'), num('9')]),
                row([
                  key(Text('クリア', style: PO.ts(15)), PO.segBg, PO.line, () => setState(() => _v = '')),
                  num('0'),
                  key(const Icon(Icons.backspace_rounded, size: 24, color: Colors.white), PO.orange, PO.orange, () => setState(() {
                        if (_v.isNotEmpty) _v = _v.substring(0, _v.length - 1);
                      })),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== 受注区分 =====================

/// 受注区分（受け渡し方法＋受注区分）。返り値は {orderSource, orderSourceOther, deliveryType}。キャンセルは null。
Future<Map<String, dynamic>?> showPhoneIntakeSheet(
  BuildContext context, {
  String initialOrderSource = '',
  String initialOrderSourceOther = '',
  String initialDeliveryType = '',
}) {
  return showPoSheet<Map<String, dynamic>>(
    context,
    (_) => _IntakeSheet(source: initialOrderSource, other: initialOrderSourceOther, type: initialDeliveryType),
  );
}

class _IntakeSheet extends StatefulWidget {
  final String source, other, type;
  const _IntakeSheet({required this.source, required this.other, required this.type});
  @override
  State<_IntakeSheet> createState() => _IntakeSheetState();
}

class _IntakeSheetState extends State<_IntakeSheet> {
  static const _sources = ['直取', 'デリカ', '結膳', 'その他'];
  late int _handover; // 0 配達 / 1 引取り
  late int _src;
  late String _other;
  @override
  void initState() {
    super.initState();
    _handover = widget.type == '引取' ? 1 : 0;
    final i = _sources.indexOf(widget.source);
    _src = i < 0 ? 0 : i;
    _other = widget.other;
  }

  @override
  Widget build(BuildContext context) {
    return PoSheetFrame(
      title: '受注区分',
      footer: Row(
        children: [
          Expanded(child: PoButton(label: 'キャンセル', outline: true, onTap: () => Navigator.pop(context))),
          const SizedBox(width: 10),
          Expanded(
            child: PoButton(
              label: '次へ',
              onTap: () => Navigator.pop(context, {
                'orderSource': _handover == 1 ? '' : _sources[_src],
                'orderSourceOther': (_handover == 1 || _src != 3) ? '' : _other,
                'deliveryType': _handover == 1 ? '引取' : '配送',
              }),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PoLabel('受け渡し方法'),
          PoSegment(options: const ['配達', '引取り'], index: _handover, onChanged: (i) => setState(() => _handover = i)),
          if (_handover == 0) ...[
            const SizedBox(height: 16),
            const PoLabel('受注区分'),
            PoSegment(options: _sources, index: _src, onChanged: (i) => setState(() => _src = i)),
            if (_src == 3) ...[
              const SizedBox(height: 10),
              PoField(
                text: _other,
                hint: 'その他の内容を入力',
                onTap: () async {
                  final t = await showPhoneTextSheet(context, title: 'その他の内容', initial: _other, hint: 'キーボードで入力してください');
                  if (t != null) setState(() => _other = t);
                },
              ),
            ],
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ===================== 配送元店舗 =====================

Future<String?> showPhoneBranchSheet(
  BuildContext context, {
  required List<String> branches,
  required String initial,
  String? nearest,
  String title = '配送元店舗',
}) {
  return showPoSheet<String>(context, (_) => _BranchSheet(branches: branches, initial: initial, nearest: nearest, title: title));
}

class _BranchSheet extends StatefulWidget {
  final List<String> branches;
  final String initial;
  final String? nearest;
  final String title;
  const _BranchSheet({required this.branches, required this.initial, this.nearest, required this.title});
  @override
  State<_BranchSheet> createState() => _BranchSheetState();
}

class _BranchSheetState extends State<_BranchSheet> {
  late String _sel;
  @override
  void initState() {
    super.initState();
    _sel = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return PoSheetFrame(
      title: widget.title,
      footer: PoButton(label: '決定', onTap: () => Navigator.pop(context, _sel)),
      child: PoPlainCard(
        child: Column(
          children: [
            for (int i = 0; i < widget.branches.length; i++) ...[
              if (i > 0) const Divider(height: 1, thickness: 1, color: PO.cardLine),
              InkWell(
                onTap: () => setState(() => _sel = widget.branches[i]),
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icon(widget.branches[i] == _sel ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                          size: 20, color: widget.branches[i] == _sel ? PO.purple : PO.hint),
                      const SizedBox(width: 10),
                      Expanded(child: Text(widget.branches[i], style: PO.ts(14))),
                      if (widget.branches[i] == widget.nearest)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(6)),
                          child: Text('最寄り', style: PO.ts(10.5, color: const Color(0xFFD32F2F))),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ===================== キーボード入力 =====================

/// 文字入力シート。確定した文字列を返す（キャンセルは null）。
Future<String?> showPhoneTextSheet(
  BuildContext context, {
  required String title,
  String initial = '',
  String hint = 'キーボードで入力してください',
}) {
  return showPoSheet<String>(context, (_) => _TextSheet(title: title, initial: initial, hint: hint));
}

class _TextSheet extends StatefulWidget {
  final String title, initial, hint;
  const _TextSheet({required this.title, required this.initial, required this.hint});
  @override
  State<_TextSheet> createState() => _TextSheetState();
}

class _TextSheetState extends State<_TextSheet> {
  static const _kana = <String, List<String>>{
    'あ': ['あ', 'い', 'う', 'え', 'お'],
    'か': ['か', 'き', 'く', 'け', 'こ'],
    'さ': ['さ', 'し', 'す', 'せ', 'そ'],
    'た': ['た', 'ち', 'つ', 'て', 'と'],
    'な': ['な', 'に', 'ぬ', 'ね', 'の'],
    'は': ['は', 'ひ', 'ふ', 'へ', 'ほ'],
    'ま': ['ま', 'み', 'む', 'め', 'も'],
    'や': ['や', 'ゆ', 'よ'],
    'ら': ['ら', 'り', 'る', 'れ', 'ろ'],
    'わ': ['わ', 'を', 'ん', 'ー'],
  };
  static const _direct = ['、', '。', '？', '！', 'ー'];
  late final TextEditingController _c;
  String? _open; // 開いている行（例: 'か'）

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _add(String s) {
    final sel = _c.selection;
    final t = _c.text;
    final start = sel.isValid ? sel.start : t.length;
    final end = sel.isValid ? sel.end : t.length;
    final nt = t.replaceRange(start, end, s);
    _c.value = TextEditingValue(text: nt, selection: TextSelection.collapsed(offset: start + s.length));
    setState(() => _open = null);
  }

  void _back() {
    final t = _c.text;
    if (t.isEmpty) return;
    _c.value = TextEditingValue(text: t.substring(0, t.length - 1), selection: TextSelection.collapsed(offset: t.length - 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool kb = MediaQuery.of(context).viewInsets.bottom > 0;
    final keys = _open == null ? [..._kana.keys, ..._direct] : _kana[_open]!;
    Widget keyBox(String k, VoidCallback f) => GestureDetector(
          onTap: f,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
            child: Text(k, style: PO.ts(16)),
          ),
        );
    return PoSheetFrame(
      title: widget.title,
      footer: Row(
        children: [
          Expanded(child: PoButton(label: 'キャンセル', color: PO.red, onTap: () => Navigator.pop(context))),
          const SizedBox(width: 10),
          Expanded(child: PoButton(label: '完了', onTap: () => Navigator.pop(context, _c.text))),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.only(left: 13, right: 6),
            decoration: BoxDecoration(color: PO.field, borderRadius: BorderRadius.circular(10), border: Border.all(color: PO.line)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _c,
                    style: PO.ts(14, w: FontWeight.w400),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: widget.hint,
                      hintStyle: PO.ts(14, color: PO.hint, w: FontWeight.w400),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: const Icon(Icons.backspace_outlined, size: 18, color: PO.sub),
                  onPressed: _back,
                ),
              ],
            ),
          ),
          if (!kb) ...[
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(12)),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 5,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 63 / 57,
                children: [
                  for (final k in keys)
                    keyBox(k, () {
                      if (_open == null && _kana.containsKey(k)) {
                        setState(() => _open = k);
                      } else {
                        _add(k);
                      }
                    }),
                  if (_open != null) keyBox('戻る', () => setState(() => _open = null)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ===================== 重複注意 =====================

/// 日程の重複・時間不足の注意。true=日時を調整する / false=このまま続ける / null=中止
Future<bool?> showPhoneDupDialog(BuildContext context, List<String> messages) {
  return showDialog<bool>(
    context: context,
    barrierColor: PO.overlay,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: Color(0xFFFFF3E0), shape: BoxShape.circle),
              child: const Icon(Icons.warning_amber_rounded, size: 28, color: PO.warnText),
            ),
            const SizedBox(height: 12),
            Text('重複注意', style: PO.ts(17)),
            const SizedBox(height: 12),
            for (final m in messages)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(m, textAlign: TextAlign.center, style: PO.ts(13, color: PO.sub, w: FontWeight.w400, h: 1.5)),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: PoButton(label: '中止', outline: true, height: 46, fontSize: 14, onTap: () => Navigator.pop(ctx, null))),
                const SizedBox(width: 10),
                Expanded(child: PoButton(label: 'このまま続ける', height: 46, fontSize: 14, onTap: () => Navigator.pop(ctx, false))),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('日時を調整する', style: PO.ts(13, color: PO.purple)),
            ),
          ],
        ),
      ),
    ),
  );
}

// ===================== 日付選択（配達・引取り・ゴミ回収） =====================

/// 日付を選ぶカレンダーのシート。選んだ日（0時）を返す。キャンセルは null。
Future<DateTime?> showPhoneDateSheet(
  BuildContext context, {
  required String title,
  required DateTime initial,
  required List<OrderModel> previewOrders,
  List<OrderModel> relatedOrders = const [],
  Map<String, String> relatedReasons = const {},
  bool pickup = false,
  bool trash = false,
  DateTime? highlightDate,
  required String confirmLabel,
  String? orderTypeFilter,
  Future<Set<DateTime>> Function(DateTime from, DateTime to)? travelWarnLoader,
  bool showOrders = true,
}) {
  return showPoSheet<DateTime>(
    context,
    (_) => _DateSheet(
      title: title,
      initial: initial,
      previewOrders: previewOrders,
      relatedOrders: relatedOrders,
      relatedReasons: relatedReasons,
      pickup: pickup,
      trash: trash,
      highlightDate: highlightDate,
      confirmLabel: confirmLabel,
      orderTypeFilter: orderTypeFilter,
      travelWarnLoader: travelWarnLoader,
      showOrders: showOrders,
    ),
  );
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

class _DateSheet extends StatefulWidget {
  final String title, confirmLabel;
  final DateTime initial;
  final List<OrderModel> previewOrders, relatedOrders;
  final Map<String, String> relatedReasons;
  final bool pickup, trash, showOrders;
  final DateTime? highlightDate;
  final String? orderTypeFilter;
  final Future<Set<DateTime>> Function(DateTime, DateTime)? travelWarnLoader;
  const _DateSheet({
    required this.title,
    required this.confirmLabel,
    required this.initial,
    required this.previewOrders,
    required this.relatedOrders,
    required this.relatedReasons,
    required this.pickup,
    required this.trash,
    required this.showOrders,
    this.highlightDate,
    this.orderTypeFilter,
    this.travelWarnLoader,
  });
  @override
  State<_DateSheet> createState() => _DateSheetState();
}

class _DateSheetState extends State<_DateSheet> {
  late DateTime _month;
  late DateTime _sel;
  final Set<DateTime> _travelWarn = {};
  final Set<String> _loaded = {};

  @override
  void initState() {
    super.initState();
    _sel = DateTime(widget.initial.year, widget.initial.month, widget.initial.day);
    _month = DateTime(_sel.year, _sel.month, 1);
    _loadWarn();
  }

  Future<void> _loadWarn() async {
    final l = widget.travelWarnLoader;
    if (l == null) return;
    final key = '${_month.year}-${_month.month}';
    if (!_loaded.add(key)) return;
    try {
      final days = await l(DateTime(_month.year, _month.month, 1), DateTime(_month.year, _month.month + 1, 0));
      if (!mounted) return;
      setState(() => _travelWarn.addAll(days.map((d) => DateTime(d.year, d.month, d.day))));
    } catch (_) {
      _loaded.remove(key);
    }
  }

  bool _hasOrder(DateTime d) {
    if (widget.trash) {
      return widget.previewOrders.any((o) => o.trashPickupRequested && o.trashPickupDateTime != null && _sameDay(o.trashPickupDateTime!, d));
    }
    if (widget.pickup) return widget.previewOrders.any((o) => o.deliveryType == '引取' && _sameDay(o.deliveryDate, d));
    return widget.previewOrders.any((o) => _sameDay(o.deliveryDate, d));
  }

  bool _hasWarn(DateTime d) {
    if (widget.pickup || widget.trash) return false;
    return widget.relatedOrders.any((o) => _sameDay(o.deliveryDate, d)) || _travelWarn.contains(d);
  }

  List<OrderModel> _ordersOnSel() {
    if (widget.trash) {
      final list = widget.previewOrders.where((o) => o.trashPickupRequested && o.trashPickupDateTime != null && _sameDay(o.trashPickupDateTime!, _sel)).toList();
      list.sort((a, b) => a.trashPickupDateTime!.compareTo(b.trashPickupDateTime!));
      return list;
    }
    final byId = <String, OrderModel>{};
    for (final o in [...widget.previewOrders, ...widget.relatedOrders]) {
      if (!_sameDay(o.deliveryDate, _sel)) continue;
      final f = widget.orderTypeFilter;
      if (f != null && (f == '引取') != (o.deliveryType == '引取')) continue;
      if (widget.pickup && o.deliveryType != '引取') continue;
      byId[o.id] = o;
    }
    final warnIds = widget.relatedOrders.map((o) => o.id).toSet();
    final list = byId.values.toList();
    list.sort((a, b) {
      final wa = warnIds.contains(a.id) ? 0 : 1;
      final wb = warnIds.contains(b.id) ? 0 : 1;
      if (wa != wb) return wa.compareTo(wb);
      return a.deliveryTime.compareTo(b.deliveryTime);
    });
    return list;
  }

  void _moveMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
    _loadWarn();
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(_month.year, _month.month, 1);
    final start = first.subtract(Duration(days: first.weekday % 7));
    final today = DateTime.now();
    final orders = _ordersOnSel();
    final String kind = widget.trash ? '回収' : (widget.pickup ? '引取り' : '受注');
    final warnIds = widget.relatedOrders.map((o) => o.id).toSet();

    Widget cell(DateTime d) {
      final bool inMonth = d.month == _month.month;
      final bool sel = _sameDay(d, _sel);
      final bool isToday = _sameDay(d, today);
      final bool order = _hasOrder(d);
      final bool warn = _hasWarn(d);
      final bool hl = widget.highlightDate != null && _sameDay(d, widget.highlightDate!);
      final int wd = d.weekday % 7;
      Color tc = !inMonth ? const Color(0xFFC4C8CD) : (wd == 0 ? const Color(0xFFE53935) : (wd == 6 ? PO.blue : PO.text));
      FontWeight fw = FontWeight.w400;
      if (isToday && inMonth) {
        tc = PO.red;
        fw = FontWeight.w900;
      }
      if (sel) {
        fw = FontWeight.w700;
        if (!(isToday)) tc = (wd == 6 && inMonth) ? PO.blue : PO.text;
      }
      Color? bg;
      Border? border;
      if (sel) {
        bg = PO.selBg;
      } else if (warn) {
        bg = PO.warnBg;
      }
      if (warn && !sel) {
        border = Border.all(color: PO.warnLine);
      } else if (order && !sel) {
        border = Border.all(color: PO.orderRing);
      }
      if (hl && !sel) border = Border.all(color: PO.purple, width: 2);
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _sel = DateTime(d.year, d.month, d.day);
              if (!inMonth) _month = DateTime(d.year, d.month, 1);
            });
            if (!inMonth) _loadWarn();
          },
          child: SizedBox(
            height: 42,
            child: Center(
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: border),
                child: Text('${d.day}', style: PO.ts(13, color: tc, w: fw)),
              ),
            ),
          ),
        ),
      );
    }

    Widget legend(Widget mark, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
          mark,
          const SizedBox(width: 4),
          Text(label, style: PO.ts(11, color: PO.sub, w: FontWeight.w400)),
        ]);
    Widget dot({Color? fill, Color? line}) => Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(5), border: line == null ? null : Border.all(color: line)),
        );

    return PoSheetFrame(
      title: widget.title,
      footer: PoButton(label: widget.confirmLabel, onTap: () => Navigator.pop(context, _sel)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: const Icon(Icons.chevron_left_rounded, size: 24, color: PO.text),
                onPressed: () => _moveMonth(-1),
              ),
              Text('${_month.year}年${_month.month}月', style: PO.ts(16)),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: const Icon(Icons.chevron_right_rounded, size: 24, color: PO.text),
                onPressed: () => _moveMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text('日月火水木金土'[i],
                        style: PO.ts(11, color: i == 0 ? const Color(0xFFE53935) : (i == 6 ? PO.blue : PO.sub), w: FontWeight.w400)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (int r = 0; r < 6; r++) Row(children: [for (int c = 0; c < 7; c++) cell(start.add(Duration(days: r * 7 + c)))]),
          const SizedBox(height: 6),
          Center(
            child: Wrap(
              spacing: 16,
              children: [
                legend(dot(line: PO.orderRing), widget.trash ? '回収あり' : (widget.pickup ? '引取りあり' : '予約あり')),
                legend(dot(fill: PO.selBg), '選択中'),
                if (!widget.pickup && !widget.trash) Text('⚠ 警告あり', style: PO.ts(11, color: PO.sub, w: FontWeight.w400)),
              ],
            ),
          ),
          if (widget.showOrders) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text('${DateFormat('M/d(E)', 'ja_JP').format(_sel)} の$kind ${orders.length}件', style: PO.ts(12, color: PO.sub)),
            ),
            const SizedBox(height: 8),
            if (orders.isNotEmpty)
              PoPlainCard(
                child: Column(
                  children: [
                    for (int i = 0; i < orders.length; i++) ...[
                      if (i > 0) const Divider(height: 1, thickness: 1, color: PO.cardLine),
                      _orderRow(orders[i], widget.trash),
                      if (warnIds.contains(orders[i].id))
                        Container(
                          height: 41,
                          color: PO.warnBg,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 16, color: PO.warnText),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('重複の可能性：${widget.relatedReasons[orders[i].id] ?? '同じ配達先'}',
                                    maxLines: 1, overflow: TextOverflow.ellipsis, style: PO.ts(12, color: PO.warnText)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _orderRow(OrderModel o, bool trash) {
    final String time = trash && o.trashPickupDateTime != null
        ? DateFormat('HH:mm').format(o.trashPickupDateTime!)
        : o.deliveryTime;
    final String sub = o.facilityName.isNotEmpty ? o.facilityName : o.address;
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(time, style: PO.ts(12, color: PO.purple))),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(withHonorific(o.customerName), maxLines: 1, overflow: TextOverflow.ellipsis, style: PO.ts(13)),
                const SizedBox(height: 2),
                Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: PO.ts(11.5, color: PO.sub, w: FontWeight.w400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
