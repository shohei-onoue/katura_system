import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'k_responsive.dart';
import 'k_button.dart';

class KTimeSelectionDialog extends StatefulWidget {
  final DateTime initialDateTime;
  final TimeOfDay minTime;
  final TimeOfDay maxTime;
  final int interval;
  final String title;
  final Color themeColor;

  const KTimeSelectionDialog({
    super.key,
    required this.initialDateTime,
    this.minTime = const TimeOfDay(hour: 0, minute: 0),
    this.maxTime = const TimeOfDay(hour: 23, minute: 59),
    this.interval = 15,
    this.title = '時間を選択',
    this.themeColor = Colors.deepPurple,
  });

  @override
  State<KTimeSelectionDialog> createState() => _KTimeSelectionDialogState();
}

class _KTimeSelectionDialogState extends State<KTimeSelectionDialog> {
  late DateTime _tempDateTime;
  late List<DateTime> _slots;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _tempDateTime = widget.initialDateTime;
    _generateSlots();
    _currentIndex = _slots.indexWhere((dt) => 
      dt.hour == _tempDateTime.hour && dt.minute == _tempDateTime.minute);
    if (_currentIndex == -1) _currentIndex = 0;
  }

  void _generateSlots() {
    _slots = [];
    final startMinutes = widget.minTime.hour * 60 + widget.minTime.minute;
    final endMinutes = widget.maxTime.hour * 60 + widget.maxTime.minute;
    
    int currentM = startMinutes;
    while (currentM <= endMinutes) {
      _slots.add(DateTime(
        _tempDateTime.year, 
        _tempDateTime.month, 
        _tempDateTime.day, 
        currentM ~/ 60, 
        currentM % 60
      ));
      currentM += widget.interval;
    }
    if (_slots.isEmpty) {
      _slots.add(DateTime(_tempDateTime.year, _tempDateTime.month, _tempDateTime.day, 12, 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 16))),
      child: Container(
        width: rs(context, 400),
        padding: EdgeInsets.all(rs(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: widget.themeColor),
                SizedBox(width: rs(context, 12)),
                Text(widget.title, style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: rs(context, 24)),
            Container(
              height: rs(context, 200),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(rs(context, 12)),
                color: Colors.grey.shade50,
              ),
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: _currentIndex),
                itemExtent: rs(context, 44),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _tempDateTime = _slots[index];
                  });
                },
                children: _slots.map((dt) => Center(
                  child: Text(
                    "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      fontSize: rf(context, 24), 
                      fontWeight: FontWeight.bold,
                      color: widget.themeColor,
                    ),
                  ),
                )).toList(),
              ),
            ),
            SizedBox(height: rs(context, 32)),
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
                    label: '確定', 
                    onPressed: () => Navigator.pop(context, _slots[_currentIndex]),
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
