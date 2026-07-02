import 'package:flutter/material.dart';

// Date and Time picker without external dependencies
enum KPickerType { date, time }

class KDateTimePicker extends StatelessWidget {
  final String label;
  final DateTime value;
  final KPickerType type;
  final ValueChanged<DateTime> onSelected;
  final IconData icon;

  const KDateTimePicker({
    super.key,
    required this.label,
    required this.value,
    this.type = KPickerType.date,
    required this.onSelected,
    required this.icon,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            _formatValue(value),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
