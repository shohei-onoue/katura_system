import 'package:flutter/material.dart';
import '../../models/order_model.dart';

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
  const _Chip(
    this.label, {
    this.selected = false,
    this.purple = false,
    this.onTap,
  });

  final VoidCallback? onTap;
  final String label;
  final bool selected;
  final bool purple;

  @override
  Widget build(BuildContext context) {
    final Color bg = selected ? (purple ? _purple : _lime) : Colors.white;
    final Color border = selected ? (purple ? _purple : _limeLine) : _line;
    final Color fg = selected ? (purple ? Colors.white : _limeText) : _ink;
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
  const _OrderListScaffold(this.d);

  final MobileOrderListData d;

  static const _branches = ['全店舗', '岡崎店', '名古屋店', '岐阜店'];

  @override
  Widget build(BuildContext context) {
    final delivery = d.orders.where((o) => o.deliveryType != '引取').toList();
    final pickup = d.orders.where((o) => o.deliveryType == '引取').toList();
    Widget cards(List<OrderModel> list) => Column(
      children: [
        for (final o in list)
          _OrderCard(
            order: o,
            data: d,
          ),
      ],
    );
    return Scaffold(
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
            child: d.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _DateStrip(d),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final b in _branches) ...[
                                _Chip(
                                  b,
                                  selected: d.selectedBranch == b,
                                  purple: b == '全店舗',
                                  onTap: () => d.onSelectBranch(b),
                                ),
                                const SizedBox(width: 6),
                              ],
                            ],
                          ),
                        ),
                      ),
                      _SectionLabel(
                        Icons.directions_car,
                        '配達 ${delivery.length}件',
                      ),
                      cards(delivery),
                      _SectionLabel(
                        Icons.volunteer_activism,
                        '引取り ${pickup.length}件',
                      ),
                      cards(pickup),
                      if (d.orders.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'この日の受注はありません',
                              style: _ts(13, w: FontWeight.w400, c: _sub),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// 既存の受注一覧画面から渡すデータと操作（画面側のロジックをそのまま使う）
class MobileOrderListData {
  const MobileOrderListData({
    required this.isLoading,
    required this.orders,
    required this.displayNames,
    required this.warnTexts,
    required this.warnDays,
    required this.hasOrderDays,
    required this.selectedDay,
    required this.focusedDay,
    required this.selectedBranch,
    required this.expandedOrderId,
    required this.onSelectDay,
    required this.onChangeMonth,
    required this.onToday,
    required this.onRefresh,
    required this.onSelectBranch,
    required this.onToggle,
    required this.onEdit,
    required this.onCancel,
  });

  final bool isLoading;
  final List<OrderModel> orders; // 選択日・店舗で絞り込み済み
  final Map<String, String> displayNames;
  final Map<String, String> warnTexts; // 受注ID -> 警告文
  final Set<DateTime> warnDays;
  final Set<DateTime> hasOrderDays;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final String selectedBranch;
  final String? expandedOrderId;
  final void Function(DateTime) onSelectDay;
  final void Function(int) onChangeMonth;
  final VoidCallback onToday;
  final VoidCallback onRefresh;
  final void Function(String) onSelectBranch;
  final void Function(String) onToggle;
  final void Function(OrderModel, String) onEdit;
  final void Function(OrderModel) onCancel;
}

class _DateStrip extends StatelessWidget {
  const _DateStrip(this.d);

  final MobileOrderListData d;

  static const _wd = ['日', '月', '火', '水', '木', '金', '土'];

  Color _color(int i) => i == 0 ? _red : (i == 6 ? _blue : _ink);

  static bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final f = d.focusedDay;
    final start = DateTime(f.year, f.month, f.day - (f.weekday % 7));
    final days = [
      for (int i = 0; i < 7; i++) DateTime(start.year, start.month, start.day + i),
    ];
    return Container(
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
                  GestureDetector(
                    onTap: () => d.onChangeMonth(-1),
                    child: _ic(Icons.chevron_left, 20, _ink),
                  ),
                  const SizedBox(width: 8),
                  Text('${f.year}年${f.month}月', style: _ts(14)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => d.onChangeMonth(1),
                    child: _ic(Icons.chevron_right, 20, _ink),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: d.onToday,
                    child: Container(
                      width: 52,
                      decoration: BoxDecoration(
                        color: _lime,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text('今日', style: _ts(13))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: d.onRefresh,
                    child: _ic(Icons.refresh, 20, _sub),
                  ),
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
                    child: GestureDetector(
                      onTap: () => d.onSelectDay(days[i]),
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 50,
                          decoration: _same(days[i], d.selectedDay)
                              ? BoxDecoration(
                                  color: _lime,
                                  borderRadius: BorderRadius.circular(12),
                                )
                              : null,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${days[i].day}',
                                      style: _ts(16, c: _color(i)),
                                    ),
                                    Text(
                                      _wd[i],
                                      style: _ts(
                                        11,
                                        w: _same(days[i], d.selectedDay)
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        c: _color(i),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (d.hasOrderDays.contains(days[i]))
                                Positioned(
                                  bottom: 3,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Icon(Icons.circle, size: 4, color: _purple),
                                  ),
                                ),
                              if (d.warnDays.contains(days[i]))
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Icon(Icons.warning_rounded, size: 12, color: _red),
                                ),
                            ],
                          ),
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
  const _OrderCard({required this.order, required this.data});

  final OrderModel order;
  final MobileOrderListData data;

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

  int get _store {
    final b = order.branchName;
    if (b.contains('名古屋')) return 1;
    if (b.contains('岐阜')) return 2;
    return 0;
  }

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

  String _itemLabel(Map<String, dynamic> m) {
    final buf = StringBuffer("${m['name']} x${m['quantity']}");
    final special = m['specialOrder'];
    if (special != null && special.toString().isNotEmpty) buf.write(' ($special)');
    final tea = m['teaOption'];
    if (tea != null && tea.toString() != 'なし') {
      buf.write(' お茶:$tea');
      if ((int.tryParse('${m['teaQuantity']}') ?? 0) > 0) {
        buf.write('x${m['teaQuantity']}');
      }
    }
    return buf.toString();
  }

  Future<void> _showEditChoice(BuildContext context) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('変更内容を選択'),
        children: [
          for (final name in ['配達先', '日程', '注文内容'])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, name),
              child: Text(name),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, '予約キャンセル'),
            child: const Text('予約キャンセル', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (choice == null) return;
    if (choice == '予約キャンセル') {
      data.onCancel(order);
    } else {
      data.onEdit(order, choice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = _store;
    final name = order.facilityName.trim().isEmpty
        ? '個人宅'
        : order.facilityName.trim();
    final address = order.address.replaceFirst(
      RegExp(r'^\s*〒?\s*\d{3}\s*[-‐－ー−]?\s*\d{4}\s*'),
      '',
    );
    final expanded = data.expandedOrderId == order.id;
    final warn = data.warnTexts[order.id] ?? '';
    final card = GestureDetector(
      onTap: () => data.onToggle(order.id),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: warn.isNotEmpty ? _red : _cardLine),
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
                GestureDetector(
                  onTap: () => _showEditChoice(context),
                  child: _ic(Icons.edit, 18, _grey),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              address,
              style: _ts(11.5, w: FontWeight.w400, c: _sub),
            ),
            if (expanded) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  _ic(Icons.event, 15, _red),
                  const SizedBox(width: 0),
                  Text(
                    '${order.deliveryDate.month}/${order.deliveryDate.day} ${order.deliveryTime}',
                    style: _ts(11.5, c: _red),
                  ),
                  if (order.preConfirmationMethod.isNotEmpty) ...[
                    const SizedBox(width: 18),
                    _ic(Icons.notifications_active, 15, _sub),
                    Text(
                      order.preConfirmationMethod,
                      style: _ts(11.5, w: FontWeight.w400, c: _sub),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final m in order.items) _tag(_itemLabel(m))],
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
                    '${order.totalCount} 個 / ¥${order.totalPrice}',
                    style: _ts(16, c: const Color(0xFFF44336)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
    if (warn.isEmpty) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 14, 4),
          child: Text(warn, style: _ts(11.5, c: _red)),
        ),
        card,
      ],
    );
  }
}

class MobileOrderList894540 extends StatelessWidget {
  const MobileOrderList894540(this.data, {super.key});

  final MobileOrderListData data;

  @override
  Widget build(BuildContext context) => _OrderListScaffold(data);
}
