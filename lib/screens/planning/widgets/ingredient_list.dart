import 'package:flutter/material.dart';
import '../../../models/planning_models.dart';

class IngredientList extends StatelessWidget {
  final bool isLoading;
  final Map<String, IngredientRequirement> ingredientTotals;

  const IngredientList({
    super.key,
    required this.isLoading,
    required this.ingredientTotals,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (ingredientTotals.isEmpty) return const Center(child: Text('対象の受注データがありません'));

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: ingredientTotals.length,
      itemBuilder: (context, index) {
        final entry = ingredientTotals.entries.elementAt(index);
        final req = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('使用メニュー: ${req.usedInMenus.join(", ")}', 
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('必要量', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('${req.totalQuantity.toStringAsFixed(1)}${req.unit}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
