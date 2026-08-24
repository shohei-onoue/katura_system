import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'k_responsive.dart';
import 'k_button.dart';
import 'k_numeric_dial_pad.dart';

class KDateTimeSelectionDialog extends StatefulWidget {
  final DateTime initialDateTime;
  final TimeOfDay minTime;
  final TimeOfDay maxTime;
  final int interval;
  final String title;
  final Color themeColor;

  const KDateTimeSelectionDialog({
    super.key,
    required this.initialDateTime,
    this.minTime = const TimeOfDay(hour: 0, minute: 0),
    this.maxTime = const TimeOfDay(hour: 23, minute: 59),
    this.interval = 15,
    this.title = '配達日時の設定',
    this.themeColor = Colors.deepPurple,
  });

  @override
  State<KDateTimeSelectionDialog> createState() => _KDateTimeSelectionDialogState();
}

class _KDateTimeSelectionDialogState extends State<KDateTimeSelectionDialog> {
  late DateTime _tempDate;
  late String _timeBuffer; // 4桁の数字保持用 (例: "1430")

  @override
  void initState() {
    super.initState();
    _tempDate = DateTime(
      widget.initialDateTime.year,
      widget.initialDateTime.month,
      widget.initialDateTime.day,
    );
    // 初期時間を4桁の文字列に変換
    _timeBuffer = widget.initialDateTime.hour.toString().padLeft(2, '0') +
                  widget.initialDateTime.minute.toString().padLeft(2, '0');
  }

  void _onInput(String digit) {
    setState(() {
      _timeBuffer = (_timeBuffer + digit);
      if (_timeBuffer.length > 4) {
        _timeBuffer = _timeBuffer.substring(_timeBuffer.length - 4);
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_timeBuffer.isNotEmpty) {
        _timeBuffer = '0${_timeBuffer.substring(0, _timeBuffer.length - 1)}';
      }
    });
  }

  void _onClear() {
    setState(() {
      _timeBuffer = "0000";
    });
  }

  String get _displayTime {
    return "${_timeBuffer.substring(0, 2)}:${_timeBuffer.substring(2, 4)}";
  }

  bool _isValidTime() {
    final hour = int.parse(_timeBuffer.substring(0, 2));
    final minute = int.parse(_timeBuffer.substring(2, 4));
    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isValid = _isValidTime();
    final String formattedDate = DateFormat('yyyy/MM/dd (E)', 'ja_JP').format(_tempDate);
    
    // タブレットなどの広い画面を想定し、横長に調整
    final double dialogWidth = screenWidth < 900 ? screenWidth * 0.95 : 850;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rs(context, 16)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rav(context, 16))),
      child: Container(
        width: dialogWidth,
        padding: EdgeInsets.all(rav(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(widget.title, style: TextStyle(fontSize: rf(context, 22), fontWeight: FontWeight.bold, color: widget.themeColor)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isValid ? widget.themeColor.withValues(alpha: 0.08) : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isValid ? widget.themeColor.withValues(alpha: 0.2) : Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event, size: 18, color: isValid ? widget.themeColor : Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        "$formattedDate  ",
                        style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: isValid ? Colors.black87 : Colors.red),
                      ),
                      Icon(Icons.access_time, size: 18, color: isValid ? widget.themeColor : Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        _displayTime,
                        style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.w900, color: isValid ? Colors.black87 : Colors.red, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左側: カレンダーエリア
                  Expanded(
                    flex: 55,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(rs(context, 12)),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.now().subtract(const Duration(days: 30)),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _tempDate,
                        currentDay: DateTime.now(),
                        locale: 'ja_JP',
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarStyle: CalendarStyle(
                          selectedDecoration: BoxDecoration(color: widget.themeColor, shape: BoxShape.circle),
                          todayDecoration: BoxDecoration(color: widget.themeColor.withValues(alpha: 0.3), shape: BoxShape.circle),
                        ),
                        selectedDayPredicate: (day) => isSameDay(_tempDate, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() => _tempDate = selectedDay);
                        },
                        rowHeight: rs(context, 50),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: rs(context, 24)),
                  const VerticalDivider(width: 1),
                  SizedBox(width: rs(context, 24)),
                  
                  // 右側: 時間入力エリア (テンキーのみ)
                  Expanded(
                    flex: 45,
                    child: Center(
                      child: KNumericDialPad(
                        onInput: _onInput,
                        onBackspace: _onBackspace,
                        onClear: _onClear,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: rs(context, 54),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('キャンセル', 
                        style: TextStyle(fontSize: rf(context, 18), color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: SizedBox(
                    height: rs(context, 54),
                    child: KButton(
                      label: '設定を反映する', 
                      onPressed: isValid ? () {
                        final hour = int.parse(_timeBuffer.substring(0, 2));
                        final minute = int.parse(_timeBuffer.substring(2, 4));
                        final result = DateTime(
                          _tempDate.year,
                          _tempDate.month,
                          _tempDate.day,
                          hour,
                          minute,
                        );
                        Navigator.pop(context, result);
                      } : null,
                      color: widget.themeColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
