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
              _DayStrip(
                selectedDay: selectedDay,
                focusedDay: focusedDay,
                cell: _dayCell,
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

  Widget _dayCell(DateTime day) {
    final i = day.weekday % 7;
    final selected = isSameDay(day, selectedDay);
    final color = i == 0 ? PL.redText : (i == 6 ? PL.sat : PL.ink);
    final hasOrder = orderDays.contains(day);
    final hasWarn = warnDays.contains(day);
    return SizedBox(
      width: 48,
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

/// 選択中の月の日付を横スクロールで並べる帯（選択日が見える位置へ自動で動く）
class _DayStrip extends StatefulWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Widget Function(DateTime day) cell;
  const _DayStrip({required this.selectedDay, required this.focusedDay, required this.cell});

  @override
  State<_DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<_DayStrip> {
  static const double _cellW = 48;
  final ScrollController _c = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToSelected();
  }

  @override
  void didUpdateWidget(covariant _DayStrip old) {
    super.didUpdateWidget(old);
    if (!isSameDay(old.selectedDay, widget.selectedDay)) _scrollToSelected();
  }

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_c.hasClients) return;
      final w = _c.position.viewportDimension;
      final target = (widget.selectedDay.day - 1) * _cellW - (w - _cellW) / 2;
      _c.animateTo(target.clamp(0.0, _c.position.maxScrollExtent), duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.selectedDay;
    final last = DateTime(m.year, m.month + 1, 0).day;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 50,
        child: SingleChildScrollView(
          controller: _c,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [for (int d = 1; d <= last; d++) widget.cell(DateTime(m.year, m.month, d))]),
        ),
      ),
    );
  }
}
