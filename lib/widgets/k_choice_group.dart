import 'package:flutter/material.dart';

class KChoiceGroup<T> extends StatelessWidget {
  final String label;
  final List<KChoiceItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final bool showLabel;
  final Color selectedColor;
  final bool enabled;

  const KChoiceGroup({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.showLabel = true,
    this.selectedColor = Colors.deepPurple,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel && label.isNotEmpty) ...[
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
            ),
            const SizedBox(height: 8),
          ],
          // 固定高さを確保して制約違反を防ぐ
          SizedBox(
            height: 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = item.value == selectedValue;
                final isFirst = index == 0;
                final isLast = index == items.length - 1;
          
                return Expanded(
                  child: GestureDetector(
                    onTap: enabled ? () => onSelected(item.value) : null,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? selectedColor : Colors.white,
                        border: Border.all(color: isSelected ? selectedColor : Colors.grey.shade300),
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(isFirst ? 8 : 0),
                          right: Radius.circular(isLast ? 8 : 0),
                        ),
                      ),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
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
