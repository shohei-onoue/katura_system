import 'package:flutter/material.dart';

class KTileSelector<T> extends StatelessWidget {
  final String label;
  final List<KTileItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T> onSelected;
  final int crossAxisCount;

  const KTileSelector({
    super.key,
    required this.label,
    required this.items,
    this.selectedValue,
    required this.onSelected,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.5,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = item.value == selectedValue;

            return InkWell(
              onTap: () => onSelected(item.value),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueGrey.shade700 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blueGrey.shade700 : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class KTileItem<T> {
  final String label;
  final T value;

  KTileItem({required this.label, required this.value});
}
