import 'package:flutter/material.dart';
import 'package:katura_system/utils/app_colors.dart';

/// スマホ版(Figma 89-xxxx)の共通カラー
class PhoneColors {
  static const Color bg = Color(0xFFF4F1FA);
  static const Color text = Color(0xFF1D1B20);
  static const Color sub = Color(0xFF6B6F76);
  static const Color hint = Color(0xFF9AA0A6);
  static const Color border = Color(0xFFE4E7EB);
  static const Color cardBorder = Color(0xFFEDF0F2);
  static const Color purple = Color(0xFF673AB7);
  static const Color purpleLight = Color(0xFFEDE7F6);
  static const Color orange = Color(0xFFFF6D00);
  static const Color red = Color(0xFFF44336);
  static const Color fieldBg = Color(0xFFF6F7F9);
  static const Color segBg = Color(0xFFECEFF1);
  static const Color green = Color(0xFFDAFFAF);
  static const Color greenText = Color(0xFF1D3B00);
  static const Color scrim = Color(0x7A121218);
}

/// 上部バー(白・左にメニュー・タイトル・右に[actions])
PreferredSizeWidget buildPhoneTopBar({
  required String title,
  required VoidCallback onLogout,
  List<Widget> actions = const [],
}) {
  return AppBar(
    backgroundColor: AppColors.acceptButton,
    surfaceTintColor: Colors.transparent,
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    toolbarHeight: 52,
    centerTitle: false,
    automaticallyImplyLeading: false,
    leadingWidth: 52,
    titleSpacing: 0,
    leading: InkWell(
      onTap: onLogout,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.logout_rounded, size: 24, color: Colors.white),
      ),
    ),
    title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    actions: actions,
  );
}

/// 下部バー: 受注一覧(1)・配送予定(3)・顧客(6)・設定(9)
class PhoneBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavigate;
  const PhoneBottomBar({super.key, required this.selectedIndex, required this.onNavigate});

  static const List<(int, IconData, String)> _items = [
    (1, Icons.list_alt_rounded, '受注一覧'),
    (3, Icons.local_shipping_rounded, '配送予定'),
    (6, Icons.people_rounded, '顧客'),
    (9, Icons.tune_rounded, '設定'),
  ];

  Widget _item({required IconData icon, required String label, required bool selected, required VoidCallback onTap}) {
    final color = selected ? const Color(0xFFFFB74D) : const Color(0xFFCDB8FF);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.acceptButton,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 7, bottom: 8),
          child: Row(
            children: [
              for (final e in _items)
                _item(icon: e.$2, label: e.$3, selected: e.$1 == selectedIndex, onTap: () => onNavigate(e.$1)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 横向き用の左ナビ(Figma: スマホ全画面 横)。ログアウト・事前連絡ベル・4つの画面切替を縦に並べる
class PhoneLandscapeRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavigate;
  final VoidCallback onLogout;
  final VoidCallback onBell;
  final int pendingCount;
  const PhoneLandscapeRail({
    super.key,
    required this.selectedIndex,
    required this.onNavigate,
    required this.onLogout,
    required this.onBell,
    this.pendingCount = 0,
  });

  static const double width = 104;

  static const List<(int, IconData, String)> _items = [
    (1, Icons.list_alt_rounded, '受注一覧'),
    (3, Icons.local_shipping_rounded, '配送予定'),
    (6, Icons.people_rounded, '顧客'),
    (9, Icons.tune_rounded, '設定'),
  ];

  Widget _topButton(IconData icon, VoidCallback onTap, {int badge = 0}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        width: 56,
        height: 44,
        child: Badge(
          isLabelVisible: badge > 0,
          label: Text('$badge'),
          backgroundColor: Colors.red,
          textColor: Colors.white,
          child: Icon(icon, size: 28, color: Colors.white),
        ),
      ),
    );
  }

  Widget _item((int, IconData, String) e) {
    final selected = e.$1 == selectedIndex;
    final color = selected ? const Color(0xFFFFD180) : Colors.white;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onNavigate(e.$1),
      child: Container(
        width: 92,
        height: 62,
        decoration: BoxDecoration(
          color: selected ? const Color(0x38FFFFFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(e.$2, size: 28, color: color),
            const SizedBox(height: 2),
            Text(e.$3, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ノッチ(切り欠き)側の余白ぶんだけ幅を広げ、紫の帯は画面端まで伸ばす
    final left = MediaQuery.of(context).padding.left;
    return Container(
      width: width + left,
      color: AppColors.acceptButton,
      padding: EdgeInsets.only(left: left),
      child: SafeArea(
        left: false,
        right: false,
        child: Column(
          children: [
            const SizedBox(height: 6),
            _topButton(Icons.logout_rounded, onLogout),
            _topButton(Icons.notifications_active_rounded, onBell, badge: pendingCount),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [for (final e in _items) Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: _item(e))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// メニュー(ドロワー): 黒背景・選択中は#3A3A3Aの角丸ハイライト
class PhoneDrawer extends StatelessWidget {
  final int selectedIndex;
  final String staffName;
  final String loginId;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final VoidCallback onClose;
  const PhoneDrawer({
    super.key,
    required this.selectedIndex,
    required this.staffName,
    this.loginId = '',
    required this.onSelect,
    required this.onLogout,
    required this.onClose,
  });

  static const List<(int, IconData, String)> _items = [
    (0, Icons.post_add_rounded, '受注入力'),
    (1, Icons.list_alt_rounded, '受注一覧'),
    (2, Icons.inventory_2_rounded, '調理・仕入れ計画'),
    (3, Icons.local_shipping_rounded, '配送予定'),
    (5, Icons.analytics_rounded, 'データ分析'),
    (6, Icons.people_rounded, '顧客管理'),
    (7, Icons.restaurant_rounded, 'メニューマスタ'),
    (9, Icons.settings_rounded, '設定'),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 296,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Row(
                children: [
                  const Spacer(),
                  InkWell(
                    onTap: onClose,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.close_rounded, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('- MENU -',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final e in _items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onSelect(e.$1),
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: e.$1 == selectedIndex ? const Color(0xFF3A3A3A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(e.$2, size: 22, color: Colors.white),
                              const SizedBox(width: 14),
                              Text(e.$3,
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: InkWell(
                onTap: onLogout,
                child: Container(
                  height: 57,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFF444444))),
                  child: Row(
                    children: [
                      const SizedBox(width: 0),
                      const Icon(Icons.account_circle_rounded, size: 22, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(loginId.isNotEmpty ? loginId : '未ログイン',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const Icon(Icons.logout_rounded, size: 20, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Version 1.0.52', style: TextStyle(color: Color(0xFF999999), fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2択/3択の切替(灰色の土台＋選択中だけ色付き)
class PhoneSegmented<T> extends StatelessWidget {
  final List<(T, String)> items;
  final T value;
  final ValueChanged<T> onChanged;
  final Color selectedBg;
  final Color selectedFg;
  const PhoneSegmented({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.selectedBg = PhoneColors.purple,
    this.selectedFg = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: PhoneColors.segBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          for (final it in items)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onChanged(it.$1),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: it.$1 == value ? selectedBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(it.$2,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: it.$1 == value ? selectedFg : PhoneColors.sub)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ボトムシート共通の見出し(つまみ＋タイトル＋閉じるボタン)
class PhoneSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  const PhoneSheetHeader({super.key, required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFFD4D7DC), borderRadius: BorderRadius.circular(2.5))),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 7, 10, 10),
          child: Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: PhoneColors.text))),
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.close_rounded, size: 20, color: PhoneColors.text),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ボトムシート共通の下部ボタン帯(上に細い線)
class PhoneSheetFooter extends StatelessWidget {
  final List<Widget> children;
  const PhoneSheetFooter({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: PhoneColors.border))),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: children[i]),
            ],
          ],
        ),
      ),
    );
  }
}

/// 下部ボタン(高さ48・角丸12)
class PhoneSheetButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  const PhoneSheetButton({super.key, required this.label, required this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// 時刻入力のテンキー(ボトムシート)。[initial]は4桁(HHMM)。確定で4桁文字列を返す。
Future<String?> showPhoneTimePadSheet(BuildContext context, {required String title, required String initial}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: PhoneColors.scrim,
    builder: (_) => _TimePadSheet(title: title, initial: initial),
  );
}

class _TimePadSheet extends StatefulWidget {
  final String title;
  final String initial;
  const _TimePadSheet({required this.title, required this.initial});

  @override
  State<_TimePadSheet> createState() => _TimePadSheetState();
}

class _TimePadSheetState extends State<_TimePadSheet> {
  late String _t;

  @override
  void initState() {
    super.initState();
    final d = widget.initial.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0');
    _t = d.substring(d.length - 4);
  }

  void _digit(String d) => setState(() => _t = _t.substring(1) + d);
  void _back() => setState(() => _t = '0${_t.substring(0, 3)}');
  void _clear() => setState(() => _t = '0000');

  void _confirm() {
    var h = int.parse(_t.substring(0, 2));
    var m = int.parse(_t.substring(2, 4));
    if (h > 23) h = 23;
    if (m > 59) m = 59;
    Navigator.pop(context, '${h.toString().padLeft(2, '0')}${m.toString().padLeft(2, '0')}');
  }

  Widget _key(Widget child, VoidCallback onTap, {Color bg = Colors.white, Color? border}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border ?? PhoneColors.border),
        ),
        child: child,
      ),
    );
  }

  Widget _num(String d) => _key(
        Text(d, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: PhoneColors.text)),
        () => _digit(d),
      );

  @override
  Widget build(BuildContext context) {
    final display = '${_t[0]} ${_t[1]} : ${_t[2]} ${_t[3]}';
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhoneSheetHeader(title: widget.title, onClose: () => Navigator.pop(context)),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: Column(
              children: [
                Container(
                  height: 58,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: PhoneColors.fieldBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: PhoneColors.border),
                  ),
                  child: Text(display, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: PhoneColors.text)),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      for (final r in rows)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Row(
                            children: [
                              for (var i = 0; i < r.length; i++) ...[
                                if (i > 0) const SizedBox(width: 9),
                                Expanded(child: _num(r[i])),
                              ],
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: _key(
                              const Text('クリア', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PhoneColors.text)),
                              _clear,
                              bg: PhoneColors.segBg,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(child: _num('0')),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _key(
                              const Icon(Icons.backspace_rounded, size: 24, color: Colors.white),
                              _back,
                              bg: PhoneColors.orange,
                              border: PhoneColors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
          PhoneSheetFooter(children: [PhoneSheetButton(label: '確定', color: PhoneColors.purple, onPressed: _confirm)]),
        ],
      ),
    );
  }
}

/// 店舗削除などの確認ダイアログ(Figma 33: 赤い丸アイコン・キャンセル/削除)
Future<bool?> showPhoneConfirmDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  String cancelLabel = 'キャンセル',
  String okLabel = '削除',
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: PhoneColors.scrim,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
              child: Icon(icon, size: 28, color: PhoneColors.red),
            ),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: PhoneColors.text)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: PhoneColors.sub)),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: PhoneColors.text,
                        side: const BorderSide(color: PhoneColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(cancelLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PhoneColors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(okLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
