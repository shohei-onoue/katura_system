import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:katura_system/utils/app_colors.dart';
import 'k_numeric_dial_pad.dart';
import 'k_responsive.dart';

/// 事前連絡日時の設定ダイアログ。
/// 左：カレンダー（日付）／右：時間（HHMM・ダイヤル）／下：キャンセル・確定。
/// 画面の高さ90%以内に収まるよう、固定サイズの中身を縮小して表示する（スクロールなし）。
/// 確定すると日付＋時間の DateTime を返す。キャンセルは null。
class KPreContactDateTimeDialog extends StatefulWidget {
  final DateTime initialDateTime;
  final String title;
  final DateTime? deliveryDate; // お渡し日（紫の丸で表示）

  const KPreContactDateTimeDialog({
    super.key,
    required this.initialDateTime,
    this.deliveryDate,
    this.title = '事前確認日',
  });

  @override
  State<KPreContactDateTimeDialog> createState() => _KPreContactDateTimeDialogState();
}

class _KPreContactDateTimeDialogState extends State<KPreContactDateTimeDialog> {
  static const double _bodyW = 800;
  static const double _bodyH = 560;

  late DateTime _date;
  late List<String> _t; // HHMM の4桁
  int _cursor = 0;

  @override
  void initState() {
    super.initState();
    final i = widget.initialDateTime;
    _date = DateTime(i.year, i.month, i.day);
    _t = (i.hour.toString().padLeft(2, '0') + i.minute.toString().padLeft(2, '0')).split('');
  }

  int get _hour => int.parse(_t[0] + _t[1]);
  int get _minute => int.parse(_t[2] + _t[3]);
  bool get _isValid => _hour <= 23 && _minute <= 59;

  Widget _digit(int i, bool valid) {
    final selected = i == _cursor;
    return GestureDetector(
      onTap: () => setState(() => _cursor = i),
      child: Container(
        width: 44,
        padding: const EdgeInsets.symmetric(vertical: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: selected ? AppColors.selectButton : Colors.transparent, width: 3)),
        ),
        child: Text(_t[i],
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: valid ? AppColors.primaryText : Colors.red)),
      ),
    );
  }

  Widget _timeDisplay() {
    final valid = _isValid;
    final colon = TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: valid ? AppColors.primaryText : Colors.red);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: valid ? Colors.grey.shade300 : Colors.red, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_digit(0, valid), _digit(1, valid), Text(':', style: colon), _digit(2, valid), _digit(3, valid)],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.primaryText)),
      ],
    );
  }

  Widget _calendarWithLegend() {
    return Column(
      children: [
        Expanded(child: _calendar()),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(AppColors.selectButton, '選択中'),
            if (widget.deliveryDate != null) ...[
              const SizedBox(width: 20),
              _legendItem(AppColors.accentPurple, 'お渡し日'),
            ],
          ],
        ),
      ],
    );
  }

  Widget _calendar() {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
    final last = DateTime(now.year, now.month, now.day).add(const Duration(days: 365));
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TableCalendar(
        firstDay: _date.isBefore(first) ? _date : first,
        lastDay: _date.isAfter(last) ? _date : last,
        focusedDay: _date,
        currentDay: now,
        locale: 'ja_JP',
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(color: AppColors.selectButton, shape: BoxShape.circle),
          selectedTextStyle: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        calendarBuilders: CalendarBuilders(
          prioritizedBuilder: (context, day, focusedDay) {
            final dd = widget.deliveryDate;
            if (dd == null || !isSameDay(dd, day)) return null;
            final both = isSameDay(_date, day); // お渡し日＝選択日：外側にselectButtonの輪
            return Center(
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentPurple,
                  border: both ? Border.all(color: AppColors.selectButton, width: 4) : null,
                ),
                child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            );
          },
        ),
        selectedDayPredicate: (d) => isSameDay(_date, d),
        onDaySelected: (selected, _) => setState(() => _date = DateTime(selected.year, selected.month, selected.day)),
        rowHeight: 46,
        daysOfWeekHeight: 32,
        sixWeekMonthsEnforced: true,
      ),
    );
  }

  Widget _button(String label, Color color, VoidCallback? onPressed) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final dateText = DateFormat('yyyy/MM/dd (E)', 'ja_JP').format(_date);
    return Dialog(
      backgroundColor: AppColors.popupBackground,
      insetPadding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: screen.height * 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screen.height * 0.9 - 32, maxWidth: screen.width - 64),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: _bodyW,
              height: _bodyH,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(width: 16),
                      Text(dateText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _calendarWithLegend()),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _timeDisplay(),
                              const SizedBox(height: 12),
                              KNumericDialPad(
                                height: 52,
                                onInput: (d) => setState(() {
                                  _t[_cursor] = d;
                                  if (_cursor < 3) _cursor++;
                                }),
                                onClear: () => setState(() {
                                  _t = ['0', '0', '0', '0'];
                                  _cursor = 0;
                                }),
                                onBackspace: () => setState(() {
                                  _t[_cursor] = '0';
                                  if (_cursor > 0) _cursor--;
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _button('キャンセル', AppColors.cancelButton, () => Navigator.pop(context))),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _button(
                          '確定',
                          AppColors.acceptButton,
                          _isValid ? () => Navigator.pop(context, DateTime(_date.year, _date.month, _date.day, _hour, _minute)) : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
