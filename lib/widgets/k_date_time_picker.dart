import 'package:flutter/material.dart';
import 'k_responsive.dart';

// Date and Time picker without external dependencies
enum KPickerType { date, time }

class KDateTimePicker extends StatelessWidget {
  final String label;
  final DateTime value;
  final KPickerType type;
  final ValueChanged<DateTime> onSelected;
  final IconData icon;
  final bool showLabel;

  const KDateTimePicker({
    super.key,
    required this.label,
    required this.value,
    this.type = KPickerType.date,
    required this.onSelected,
    required this.icon,
    this.showLabel = true,
  });

  String _formatValue(DateTime dt) {
    if (type == KPickerType.date) {
      final y = dt.year.toString();
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return "$y/$m/$d";
    } else {
      final h = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return "$h:$min";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rs(context, 4)),
      child: InkWell(
        onTap: () async {
          if (type == KPickerType.date) {
            final picked = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) onSelected(picked);
          } else {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(value),
            );
            if (picked != null) {
              final now = DateTime.now();
              onSelected(DateTime(now.year, now.month, now.day, picked.hour, picked.minute));
            }
          }
        },
        child: Container(
          height: rs(context, 50),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.blueGrey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showLabel && label.isNotEmpty)
                      Text(label, style: TextStyle(fontSize: rf(context, 10), color: Colors.grey)),
                    Text(
                      _formatValue(value),
                      style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
