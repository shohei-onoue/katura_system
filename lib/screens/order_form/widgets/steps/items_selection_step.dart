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
  final Function(List<Map<String, dynamic>>) onAddItem;
  final Function(String, int) onQuantityChanged;
  final VoidCallback onNext;
  final VoidCallback? onReloadMenus; // 再読み込み用

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
    this.onReloadMenus,
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

  @override
  void didUpdateWidget(ItemsSelectionStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // メニューリストが後から届いた場合の再初期化
    if (selectedCategory.isEmpty && widget.menus.isNotEmpty) {
      _initCategory();
    }
  }

  void _initCategory() {
    if (widget.menus.isEmpty) return;
    
    final List<String> presetCategories = ['厳選牛ステーキ弁当', '高級弁当', 'オードブル', '丼もの', 'ギフト', 'ドリンク・サイドメニュー'];
    final actualCategories = widget.menus.map((m) => m.category).toSet();
    
    for (var preset in presetCategories) {
      if (actualCategories.contains(preset)) {
        setState(() => selectedCategory = preset);
        return;
      }
    }
    
    setState(() => selectedCategory = widget.menus.first.category);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.menus.isEmpty) {
      return _buildEmptyState();
    }

    final List<String> presetCategories = ['厳選牛ステーキ弁当', '高級弁当', 'オードブル', '丼もの', 'ギフト', 'ドリンク・サイドメニュー'];
    final actualCategories = widget.menus.map((m) => m.category).toSet().toList();
    final List<String> categories = [];
    
    for (var preset in presetCategories) {
      if (actualCategories.contains(preset)) categories.add(preset);
    }
    for (var actual in actualCategories) {
      if (!presetCategories.contains(actual)) categories.add(actual);
    }

    // 現在のカテゴリがリストにない（または空）場合のフォールバック
    if (!categories.contains(selectedCategory) && categories.isNotEmpty) {
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
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // カテゴリタブ
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
                          fontSize: rf(context, 13),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: rs(context, 24)),
              
              // メニューリスト
              if (displayMenus.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Text('このカテゴリに商品はありません', style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: rs(context, 16),
                    mainAxisSpacing: rs(context, 16),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          const Text('メニューデータが見つかりません', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 12),
          const Text('メニューマスタで商品を登録するか、下のボタンを押してください。', 
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: widget.onReloadMenus,
            icon: const Icon(Icons.refresh),
            label: const Text('メニューを読み直す'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
        ],
      ),
    );
  }
}
