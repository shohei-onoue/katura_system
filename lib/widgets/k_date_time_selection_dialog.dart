import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'k_responsive.dart';
import 'k_button.dart';
import 'k_drum_time_picker.dart';

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
  late DateTime _tempTime;

  @override
  void initState() {
    super.initState();
    _tempDate = DateTime(
      widget.initialDateTime.year,
      widget.initialDateTime.month,
      widget.initialDateTime.day,
    );
    _tempTime = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 16))),
      child: Container(
        width: rs(context, 450),
        padding: EdgeInsets.all(rs(context, 20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold)),
            SizedBox(height: rs(context, 16)),
            
            // カレンダー
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(rs(context, 12)),
              ),
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 30)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _tempDate,
                currentDay: DateTime.now(),
                locale: 'ja_JP',
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 14)),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: widget.themeColor, shape: BoxShape.circle),
                  todayTextStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  outsideDaysVisible: false,
                ),
                selectedDayPredicate: (day) => isSameDay(_tempDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _tempDate = selectedDay;
                  });
                },
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontSize: rf(context, 10)),
                  weekendStyle: TextStyle(fontSize: rf(context, 10), color: Colors.red),
                ),
                rowHeight: rs(context, 40),
              ),
            ),
            
            SizedBox(height: rs(context, 16)),
            
            // 時間ドラム
            KDrumTimePicker(
              minTime: widget.minTime,
              maxTime: widget.maxTime,
              interval: widget.interval,
              selectedDateTime: _tempTime,
              onTimeSelected: (dt) {
                setState(() {
                  _tempTime = dt;
                });
              },
              themeColor: widget.themeColor,
            ),
            
            SizedBox(height: rs(context, 24)),
            
            Row(
              children: [
                Expanded(
                  child: KButton(
                    label: 'キャンセル', 
                    onPressed: () => Navigator.pop(context),
                    isSecondary: true,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: rs(context, 12)),
                Expanded(
                  child: KButton(
                    label: '反映', 
                    onPressed: () {
                      final result = DateTime(
                        _tempDate.year,
                        _tempDate.month,
                        _tempDate.day,
                        _tempTime.hour,
                        _tempTime.minute,
                      );
                      Navigator.pop(context, result);
                    },
                    color: widget.themeColor,
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
