// Figma node 89:4425 (10_配送予定（カレンダー）) を実データに接続したスマホ版。
import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import 'mobile_delivery_common.dart';

class MobileDeliveryScheduleData {
  final bool isLoading;
  final bool isOpening;
  final List<String> branches;
  final String selectedBranch;
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final Set<DateTime> orderDays; // 日付のみ(時刻なし)
  final Set<DateTime> warnDays;
  final List<OrderModel> dayOrders;
  final Map<String, String> displayNames;
  final void Function(String) onSelectBranch;
  final void Function(DateTime) onSelectDay;
  final void Function(int) onChangeMonth;
  final VoidCallback onRouteConfirm;
  final VoidCallback? onOpenMenu;
  final void Function(int)? onNavigate;

  const MobileDeliveryScheduleData({
    required this.isLoading,
    required this.isOpening,
    required this.branches,
    required this.selectedBranch,
    required this.focusedMonth,
    required this.selectedDay,
    required this.orderDays,
    required this.warnDays,
    required this.dayOrders,
    required this.displayNames,
    required this.onSelectBranch,
    required this.onSelectDay,
    required this.onChangeMonth,
    required this.onRouteConfirm,
    this.onOpenMenu,
    this.onNavigate,
  });
}

class MobileDeliveryScheduleCalendar894425 extends StatelessWidget {
  const MobileDeliveryScheduleCalendar894425(this.d, {super.key});

  final MobileDeliveryScheduleData d;

  static const _orange = Color(0xFFFF8A65);
  static const _red = Color(0xFFE53935);
  static const _blue = Color(0xFF1E88E5);
  static const _week = ['日', '月', '火', '水', '木', '金', '土'];

  static DateTime _dayOnly(DateTime t) => DateTime(t.year, t.month, t.day);

  String _area(OrderModel o) {
    final m = RegExp(r'([^\d\s]+?[市区町村])').firstMatch(o.address);
    return m?.group(1) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mdBg,
      bottomNavigationBar: MdBottomNav(2, onNavigate: d.onNavigate),
      body: Stack(
        children: [
          Column(
            children: [
              const MdStatusBar(),
              MdTopBar(title: '配送予定', onIconTap: d.onOpenMenu),
              Expanded(
                child: d.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final b in d.branches) ...[
                                  MdChip(b, selected: b == d.selectedBranch, onTap: () => d.onSelectBranch(b)),
                                  const SizedBox(width: 6),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          _calendar(),
                          const SizedBox(height: 14),
                          _ordersHeader(),
                          const SizedBox(height: 8),
                          _orderList(),
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: d.onRouteConfirm,
                              child: Container(
                                width: 132,
                                height: 52,
                                decoration: BoxDecoration(color: mdPurple, borderRadius: BorderRadius.circular(16)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.route, size: 20, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text('ルート確認', style: mdTs(14, c: Colors.white)),
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
          if (d.isOpening)
            const Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(color: Color(0x80000000), child: Center(child: CircularProgressIndicator())),
              ),
            ),
        ],
      ),
    );
  }

  Widget _calendar() {
    final first = DateTime(d.focusedMonth.year, d.focusedMonth.month, 1);
    final start = first.subtract(Duration(days: first.weekday % 7));
    final today = _dayOnly(DateTime.now());
    final sel = _dayOnly(d.selectedDay);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: mdCardLine),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => d.onChangeMonth(-1),
                child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.chevron_left, size: 20, color: mdInk)),
              ),
              Expanded(
                child: Center(child: Text('${first.year}年${first.month}月', style: mdTs(16))),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => d.onChangeMonth(1),
                child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.chevron_right, size: 20, color: mdInk)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(_week[i],
                        style: mdTs(11, w: FontWeight.w400, c: i == 0 ? _red : (i == 6 ? _blue : mdSub))),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (int r = 0; r < 6; r++)
            Row(
              children: [
                for (int c = 0; c < 7; c++)
                  Expanded(child: _cell(DateTime(start.year, start.month, start.day + r * 7 + c), c, today, sel)),
              ],
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              _legend('配送予定あり', border: _orange),
              _legend('今日', border: _red, fill: Colors.white),
              _legend('選択中', fill: mdLime),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cell(DateTime day, int col, DateTime today, DateTime sel) {
    final inMonth = day.month == d.focusedMonth.month;
    final isSel = day == sel;
    final isToday = day == today;
    final has = inMonth && d.orderDays.contains(day);
    final warn = inMonth && d.warnDays.contains(day);
    Color fg = col == 0 ? _red : (col == 6 ? _blue : mdInk);
    if (!inMonth) fg = const Color(0xFFC4C8CD);
    if (isToday) fg = const Color(0xFFF44336);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => d.onSelectDay(day),
      child: SizedBox(
        height: 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSel ? mdLime : null,
                border: has && !isSel ? Border.all(color: _orange) : (isToday && !isSel ? Border.all(color: _red) : null),
              ),
              child: Text('${day.day}',
                  style: mdTs(13, w: isToday ? FontWeight.w700 : FontWeight.w400, c: fg)),
            ),
            if (warn)
              const Positioned(top: 0, right: 2, child: Icon(Icons.warning_rounded, size: 12, color: Color(0xFFE65100))),
          ],
        ),
      ),
    );
  }

  Widget _legend(String label, {Color? border, Color? fill}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fill,
              border: border != null ? Border.all(color: border) : null,
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: mdTs(11, w: FontWeight.w400, c: mdSub)),
        ],
      );

  static const _wd = ['月', '火', '水', '木', '金', '土', '日'];

  Widget _ordersHeader() {
    final s = d.selectedDay;
    return Row(
      children: [
        const SizedBox(width: 2),
        const Icon(Icons.event_note, size: 16, color: mdPurple),
        const SizedBox(width: 5),
        Text('${s.month}/${s.day}(${_wd[s.weekday - 1]}) の受注 ${d.dayOrders.length}件',
            style: mdTs(12, c: mdSub)),
      ],
    );
  }

  Widget _orderList() {
    if (d.dayOrders.isEmpty) {
      return Container(
        height: 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: mdCardLine),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text('受注なし', style: mdTs(12, w: FontWeight.w400, c: mdSub)),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: mdCardLine),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < d.dayOrders.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: mdCardLine),
            _orderRow(d.dayOrders[i]),
          ],
        ],
      ),
    );
  }

  Widget _orderRow(OrderModel o) {
    final area = _area(o);
    final place = o.facilityName.isNotEmpty ? o.facilityName : o.address;
    final name = d.displayNames[o.id] ?? o.customerName;
    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text(o.deliveryTime, style: mdTs(13, w: FontWeight.w900, c: mdPurple))),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: mdTs(14)),
                Text(area.isEmpty ? place : '$area · $place',
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: mdTs(11.5, w: FontWeight.w400, c: mdSub)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
