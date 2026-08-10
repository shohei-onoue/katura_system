import 'package:flutter/material.dart';
import 'k_responsive.dart';

class KTimeSlotPicker extends StatelessWidget {
  final TimeOfDay minTime;
  final TimeOfDay maxTime;
  final int interval;
  final DateTime? selectedDateTime;
  final Function(DateTime) onTimeSelected;
  final Color themeColor;

  const KTimeSlotPicker({
    super.key,
    required this.minTime,
    required this.maxTime,
    required this.interval,
    this.selectedDateTime,
    required this.onTimeSelected,
    this.themeColor = Colors.deepPurple,
  });

  @override
  Widget build(BuildContext context) {
    final List<DateTime> slots = [];
    final now = selectedDateTime ?? DateTime.now();
    
    final startMinutes = minTime.hour * 60 + minTime.minute;
    final endMinutes = maxTime.hour * 60 + maxTime.minute;
    
    int currentM = startMinutes;
    while (currentM <= endMinutes) {
      slots.add(DateTime(now.year, now.month, now.day, currentM ~/ 60, currentM % 60));
      currentM += interval;
    }

    if (slots.isEmpty) {
      return Center(child: Text('設定可能な時間がありません', style: TextStyle(color: Colors.grey, fontSize: rf(context, 12))));
    }

    return Wrap(
      spacing: rs(context, 8),
      runSpacing: rs(context, 8),
      children: slots.map((dt) {
        final bool isSelected = selectedDateTime != null && 
            dt.hour == selectedDateTime!.hour && 
            dt.minute == selectedDateTime!.minute;

        return SizedBox(
          width: rs(context, 85),
          height: rs(context, 40),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? themeColor : Colors.white,
              foregroundColor: isSelected ? Colors.white : themeColor,
              elevation: isSelected ? 4 : 0,
              padding: EdgeInsets.zero,
              side: BorderSide(color: isSelected ? Colors.transparent : themeColor.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 8))),
            ),
            onPressed: () => onTimeSelected(dt),
            child: Text(
              "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }
}
