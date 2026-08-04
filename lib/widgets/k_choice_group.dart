import 'package:flutter/material.dart';

class KChoiceGroup<T> extends StatelessWidget {
  final String label;
  final List<KChoiceItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final bool showLabel;

  const KChoiceGroup({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        // Expandedを削除し、親からの制約（SizedBox等）があればそれに合わせる
        // 制約がない場合はLayoutBuilder等で高さを決める必要があるが、ここでは柔軟にする
        Flexible(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: items.map((item) {
              final isSelected = item.value == selectedValue;
              final index = items.indexOf(item);
              final isFirst = index == 0;
              final isLast = index == items.length - 1;
        
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(item.value),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple : Colors.white,
                      border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey.shade300),
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
    );
  }
}

class KChoiceItem<T> {
  final String label;
  final T value;

  KChoiceItem({required this.label, required this.value});
}
