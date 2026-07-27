import 'package:flutter/material.dart';
import '../../../../models/menu_model.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_quantity_counter.dart';
import '../order_form_parts.dart';

class ItemsSelectionStep extends StatelessWidget {
  final List<MenuModel> menus;
  final List<Map<String, dynamic>> confirmedItems;
  final Map<String, int> selectedQuantities;
  final double riceAmount;
  final String packaging;
  final int totalPrice;
  final Function(MenuModel) onAddItem;
  final Function(String, int) onQuantityChanged;
  final VoidCallback onNext;

  const ItemsSelectionStep({
    super.key,
    required this.menus,
    required this.confirmedItems,
    required this.selectedQuantities,
    required this.riceAmount,
    required this.packaging,
    required this.totalPrice,
    required this.onAddItem,
    required this.onQuantityChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final categories = menus.map((m) => m.category).toSet().toList();
    return Column(
      children: [
        OrderFormCard(
          title: '商品選択',
          icon: Icons.restaurant_menu,
          child: SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final cat = categories[i];
                final catMenus = menus.where((m) => m.category == cat).toList();
                return Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Container(padding: const EdgeInsets.all(8), width: double.infinity, color: Colors.grey.shade50, child: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: ListView.builder(itemCount: catMenus.length, itemBuilder: (context, j) => ListTile(dense: true, title: Text(catMenus[j].name), trailing: Text('¥${catMenus[j].price}'), onTap: () => onAddItem(catMenus[j])))),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        OrderFormCard(
          title: '注文内容・数量調整',
          icon: Icons.restaurant,
          trailing: confirmedItems.isEmpty ? null : Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('生米換算: ${riceAmount.toStringAsFixed(2)}kg', style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)), Text('資材目安: $packaging', style: const TextStyle(color: Colors.blueGrey, fontSize: 12))]),
          child: Column(
            children: [
              if (confirmedItems.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('メニューをタップして追加してください')))
              else ...confirmedItems.map((item) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), KQuantityCounter(value: selectedQuantities[item['id']] ?? 0, onChanged: (v) => onQuantityChanged(item['id'], v))]))),
              const Divider(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('合計: ¥$totalPrice', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepOrange)), if (confirmedItems.isNotEmpty) KButton(label: '内容確定', fullWidth: false, onPressed: onNext)]),
            ],
          ),
        ),
      ],
    );
  }
}
