import 'package:flutter/material.dart';
import '../../../../models/menu_model.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_button.dart';
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
  final String phoneNumberText;

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
    this.phoneNumberText = '',
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

    return OrderFormCard(
      title: '商品を選択してください',
      icon: Icons.restaurant_menu,
      trailing: PhoneReceivedBadge(phoneNumber: widget.phoneNumberText),
      fill: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // カテゴリタブ（タブ以上は固定）
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: EdgeInsets.only(right: rs(context, 8)),
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

          // メニューリスト（タブより下のみスクロール可）
          Expanded(
            child: displayMenus.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(rs(context, 48.0)),
                      child: Text('このカテゴリに商品はありません', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: rs(context, 16),
                      mainAxisSpacing: rs(context, 16),
                      childAspectRatio: 0.65,
                    ),
                    itemCount: displayMenus.length,
                    itemBuilder: (context, i) {
                      final menu = displayMenus[i];
                      return KMenuCard(
                        key: ValueKey(menu.id),
                        menu: menu,
                        onAddToCart: (qty) {
                          if (qty <= 0) return;
                          widget.onAddItem([
                            {
                              'id': menu.id,
                              'name': menu.name,
                              'price': menu.price,
                              'quantity': qty,
                              'specialOrder': '',
                              'specialOrderQuantity': 0,
                              'topping': '',
                              'teaOption': 'なし',
                              'teaQuantity': 0,
                            }
                          ]);
                        },
                        onOpenDetails: (qty) async {
                          final result = await showDialog<List<Map<String, dynamic>>>(
                            context: context,
                            builder: (context) => KItemDetailsDialog(
                              menu: menu,
                              initialQuantity: qty > 0 ? qty : 1,
                            ),
                          );
                          if (result != null) {
                            widget.onAddItem(result);
                            return true;
                          }
                          return false;
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 48)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(context, 16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: rs(context, 64), color: Colors.grey.shade300),
          SizedBox(height: rs(context, 24)),
          Text('メニューデータが見つかりません', 
            style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          SizedBox(height: rs(context, 12)),
          const Text('メニューマスタで商品を登録するか、下のボタンを押してください。', 
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          SizedBox(height: rs(context, 32)),
          KButton(
            label: 'メニューを読み直す',
            icon: Icons.refresh,
            fullWidth: false,
            onPressed: widget.onReloadMenus,
          ),
        ],
      ),
    );
  }
}
