import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart' show isSameDay;
import 'package:katura_system/utils/app_colors.dart';
import 'phone_order_list_style.dart';

/// スマホ受注一覧の上部：月切替・今日・更新、1週間の日付、店舗チップ（Figma: 受注一覧）
class PhoneOrderListHeader extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<int> onChangeMonth;
  final VoidCallback onToday;
  final VoidCallback onRefresh;
  final List<String> branches;
  final String selectedBranch;
  final ValueChanged<String> onSelectBranch;
  final Set<DateTime> orderDays; // 受注のある日（日付だけ）
  final Set<DateTime> warnDays; // 警告のある日

  const PhoneOrderListHeader({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onSelectDay,
    required this.onChangeMonth,
    required this.onToday,
    required this.onRefresh,
    required this.branches,
    required this.selectedBranch,
    required this.onSelectBranch,
    this.orderDays = const {},
    this.warnDays = const {},
  });

  static const _weeks = ['日', '月', '火', '水', '木', '金', '土'];

  Widget _iconBtn(IconData icon, VoidCallback onTap, {Color color = PL.ink}) => InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 20, color: color)),
      );

  @override
  Widget build(BuildContext context) {
    final d = selectedDay;
    final sunday = DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday % 7));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    _iconBtn(Icons.chevron_left_rounded, () => onChangeMonth(-1)),
                    Text('${focusedDay.year}年${focusedDay.month}月', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PL.ink)),
                    _iconBtn(Icons.chevron_right_rounded, () => onChangeMonth(1)),
                    const Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onToday,
                      child: Container(
                        width: 52,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.selectButton, borderRadius: BorderRadius.circular(10)),
                        child: const Text('今日', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PL.ink)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _iconBtn(Icons.refresh_rounded, onRefresh, color: PL.grey),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: (e) {
                  final v = e.primaryVelocity ?? 0;
                  if (v.abs() < 200) return;
                  onSelectDay(selectedDay.add(Duration(days: v < 0 ? 7 : -7)));
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Row(
                    children: [
                      for (int i = 0; i < 7; i++) _dayCell(sunday.add(Duration(days: i)), i),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final b in branches)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onSelectBranch(b),
                      child: Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selectedBranch == b ? PL.purple : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: selectedBranch == b ? PL.purple : PL.border),
                        ),
                        child: Text(b, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: selectedBranch == b ? Colors.white : PL.ink)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dayCell(DateTime day, int i) {
    final selected = isSameDay(day, selectedDay);
    final color = i == 0 ? PL.redText : (i == 6 ? PL.sat : PL.ink);
    final hasOrder = orderDays.contains(day);
    final hasWarn = warnDays.contains(day);
    return Expanded(
      child: Center(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelectDay(day),
          child: Container(
            width: 44,
            height: 50,
            decoration: BoxDecoration(color: selected ? AppColors.selectButton : Colors.transparent, borderRadius: BorderRadius.circular(12)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${day.day}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: selected ? PL.ink : color)),
                    const SizedBox(height: 2),
                    Text(_weeks[i], style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? PL.ink : color)),
                  ],
                ),
                if (hasOrder && !selected) Positioned(bottom: 3, child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.accentOrange, shape: BoxShape.circle))),
                if (hasWarn) const Positioned(top: 1, right: 1, child: Icon(Icons.warning_rounded, size: 11, color: AppColors.warningText)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 「配達 3件」「引取り 2件」の見出し
class PhoneOrderSectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const PhoneOrderSectionTitle({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Row(children: [
          Icon(icon, size: 16, color: PL.purple),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PL.grey)),
        ]),
      );
}
