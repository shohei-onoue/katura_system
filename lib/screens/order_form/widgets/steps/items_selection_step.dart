import 'package:flutter/material.dart';
import '../../../../models/menu_model.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_item_details_dialog.dart';
import '../../../../widgets/k_menu_card.dart';
import '../order_form_parts.dart';

class ItemsSelectionStep extends StatefulWidget {
  final List<MenuModel> menus;
  final List<Map<String, dynamic>> confirmedItems;
  final Map<String, int> selectedQuantities;
  final double riceAmount;
  final String packaging;
  final int totalPrice;
  final String phoneDisplay; // 受電番号
  final Function(List<Map<String, dynamic>>) onAddItem;
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
    required this.phoneDisplay,
    required this.onAddItem,
    required this.onQuantityChanged,
    required this.onNext,
  });

  @override
  State<ItemsSelectionStep> createState() => _ItemsSelectionStepState();
}

class _ItemsSelectionStepState extends State<ItemsSelectionStep> {
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _initCategory();
  }

  void _initCategory() {
    final List<String> presetCategories = ['厳選牛ステーキ弁当', '高級弁当', 'オードブル', '丼もの', 'ギフト', 'ドリンク・サイドメニュー'];
    final actualCategories = widget.menus.map((m) => m.category).toSet();
    
    for (var preset in presetCategories) {
      if (actualCategories.contains(preset)) {
        selectedCategory = preset;
        return;
      }
    }
    
    if (actualCategories.isNotEmpty) {
      selectedCategory = actualCategories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> presetCategories = ['厳選牛ステーキ弁当', '高級弁当', 'オードブル', '丼もの', 'ギフト', 'ドリンク・サイドメニュー'];
    final actualCategories = widget.menus.map((m) => m.category).toSet().toList();
    final List<String> categories = [];
    
    for (var preset in presetCategories) {
      if (actualCategories.contains(preset)) categories.add(preset);
    }
    for (var actual in actualCategories) {
      if (!presetCategories.contains(actual)) categories.add(actual);
    }

    if (selectedCategory.isEmpty && categories.isNotEmpty) {
      selectedCategory = categories.first;
    }
    
    final displayMenus = widget.menus.where((m) => m.category == selectedCategory).toList();

    return Column(
      children: [
        OrderFormCard(
          title: '商品を選択してください',
          icon: Icons.restaurant_menu,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.confirmedItems.isNotEmpty) ...[
                Text('生米換算: ${widget.riceAmount.toStringAsFixed(2)}kg', 
                  style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: rf(context, 12))),
                const SizedBox(width: 24),
              ],
              Text('受電: ${widget.phoneDisplay}', 
                style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => selectedCategory = cat);
                        },
                        selectedColor: Colors.deepPurple,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: KR.fontSmall(context),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemCount: displayMenus.length,
                itemBuilder: (context, i) {
                  final menu = displayMenus[i];
                  final qty = widget.selectedQuantities[menu.id] ?? 0;
                  return KMenuCard(
                    menu: menu,
                    quantity: qty,
                    onQuantityChanged: (v) => widget.onQuantityChanged(menu.id, v),
                    onDetailsPressed: () async {
                      final result = await showDialog<List<Map<String, dynamic>>>(
                        context: context,
                        builder: (context) => KItemDetailsDialog(
                          menu: menu, 
                          initialQuantity: qty > 0 ? qty : 1,
                        ),
                      );
                      if (result != null) {
                        widget.onAddItem(result);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
