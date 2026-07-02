import 'package:flutter/material.dart';

class KChoiceGroup<T> extends StatelessWidget {
  final String label;
  final List<KChoiceItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  const KChoiceGroup({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final isSelected = item.value == selectedValue;
              return ChoiceChip(
                label: Text(item.label),
                selected: isSelected,
                onSelected: (_) => onSelected(item.value),
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                checkmarkColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class KChoiceItem<T> {
  final String label;
  final T value;

  KChoiceItem({required this.label, required this.value});
}
