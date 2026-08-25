import 'package:flutter/material.dart';
import '../../../models/planning_models.dart';
import '../../../widgets/k_responsive.dart';

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
      padding: EdgeInsets.all(rs(context, 24)),
      itemCount: ingredientTotals.length,
      itemBuilder: (context, index) {
        final entry = ingredientTotals.entries.elementAt(index);
        final req = entry.value;

        return Card(
          margin: EdgeInsets.only(bottom: rs(context, 12)),
          child: Padding(
            padding: EdgeInsets.all(rs(context, 16)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 18))),
                      SizedBox(height: rs(context, 4)),
                      Text('使用メニュー: ${req.usedInMenus.join(", ")}', 
                        style: TextStyle(color: Colors.grey, fontSize: rf(context, 12))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('必要量', style: TextStyle(fontSize: rf(context, 12), color: Colors.grey)),
                    Text('${req.totalQuantity.toStringAsFixed(1)}${req.unit}',
                      style: TextStyle(fontSize: rf(context, 22), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
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
