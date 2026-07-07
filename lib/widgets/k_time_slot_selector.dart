import 'package:flutter/material.dart';

class KTimeSlotSelector extends StatelessWidget {
  final String label;
  final DateTime selectedTime;
  final ValueChanged<DateTime> onSelected;

  const KTimeSlotSelector({
    super.key,
    required this.label,
    required this.selectedTime,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 9:00から18:00まで15分刻み
    final List<DateTime> slots = [];
    final now = DateTime.now();
    for (int h = 9; h <= 18; h++) {
      for (int m = 0; m < 60; m += 15) {
        slots.add(DateTime(now.year, now.month, now.day, h, m));
        if (h == 18 && m == 0) break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.5,
            ),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              final isSelected = slot.hour == selectedTime.hour && slot.minute == selectedTime.minute;
              final timeStr = "${slot.hour}:${slot.minute.toString().padLeft(2, '0')}";

              return InkWell(
                onTap: () => onSelected(slot),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.deepOrange : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade300),
                  ),
                  child: Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
