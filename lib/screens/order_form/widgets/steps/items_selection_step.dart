import 'package:flutter/material.dart';
import '../../../../models/menu_model.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_numeric_input_dialog.dart';
import '../order_form_parts.dart';

class ItemsSelectionStep extends StatefulWidget {
  final List<MenuModel> menus;
  final List<Map<String, dynamic>> confirmedItems;
  final Map<String, int> selectedQuantities;
  final double riceAmount;
  final String packaging;
  final int totalPrice;
  final String phoneDisplay; // 受電番号
  final Function(MenuModel) onAddItem;
  final Function(String, int) onQuantityChanged;
  final String teaOption;
  final int teaQuantity;
  final Function(String) onTeaOptionChanged;
  final Function(int) onTeaQuantityChanged;
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
    required this.teaOption,
    required this.teaQuantity,
    required this.onTeaOptionChanged,
    required this.onTeaQuantityChanged,
    required this.onNext,
  });

  @override
  State<ItemsSelectionStep> createState() => _ItemsSelectionStepState();
}

class _ItemsSelectionStepState extends State<ItemsSelectionStep> {
  String selectedCategory = 'すべて';

  @override
  void initState() {
    super.initState();
    selectedCategory = 'すべて';
  }

  @override
  Widget build(BuildContext context) {
    final List<String> presetCategories = ['すべて', '厳選牛ステーキ弁当', '高級弁当', 'オードブル', '丼もの', 'ギフト', 'ドリンク・サイドメニュー'];
    final actualCategories = widget.menus.map((m) => m.category).toSet().toList();
    final List<String> categories = ['すべて'];
    
    for (var preset in presetCategories) {
      if (preset != 'すべて' && actualCategories.contains(preset)) categories.add(preset);
    }
    for (var actual in actualCategories) {
      if (!presetCategories.contains(actual)) categories.add(actual);
    }
    
    final displayMenus = selectedCategory == 'すべて' 
        ? widget.menus 
        : widget.menus.where((m) => m.category == selectedCategory).toList();

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
                const SizedBox(width: 16),
                KButton(label: '内容を確定して次へ', fullWidth: false, onPressed: widget.onNext),
                const SizedBox(width: 24),
              ],
              Text('受電: ${widget.phoneDisplay}', 
                style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTeaOptionSection(context),
              const Divider(height: 48),
              
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemCount: displayMenus.length,
                itemBuilder: (context, i) {
                  final menu = displayMenus[i];
                  final qty = widget.selectedQuantities[menu.id] ?? 0;
                  return _buildMenuCard(menu, qty);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(MenuModel menu, int qty) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: qty > 0 ? Colors.deepPurple : Colors.grey.shade200, width: qty > 0 ? 2 : 1),
        boxShadow: [
          if (qty > 0) BoxShadow(color: Colors.deepPurple.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: _buildImage(menu.imageUrl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menu.name,
                  style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('¥${menu.price}',
                  style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left, size: 32, color: Colors.deepPurple),
                      onPressed: () {
                        if (qty > 0) widget.onQuantityChanged(menu.id, qty - 1);
                      },
                    ),
                    GestureDetector(
                      onTap: () async {
                        final result = await showDialog<int>(
                          context: context,
                          builder: (context) => KNumericInputDialog(initialValue: qty, title: menu.name),
                        );
                        if (result != null) {
                          widget.onQuantityChanged(menu.id, result);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('$qty',
                          style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right, size: 32, color: Colors.deepPurple),
                      onPressed: () {
                        widget.onQuantityChanged(menu.id, qty + 1);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                KButton(
                  label: 'カートに入れる', 
                  onPressed: () {
                    if (qty == 0) widget.onAddItem(menu);
                    else widget.onQuantityChanged(menu.id, qty + 1);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeaOptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_cafe, color: Colors.blueGrey, size: rs(context, 20)),
            SizedBox(width: rs(context, 8)),
            Text('お茶の設定', style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ],
        ),
        SizedBox(height: rs(context, 16)),
        Row(
          children: [
            _choiceChip(context, '込み', widget.teaOption == '込み', (v) => widget.onTeaOptionChanged('込み')),
            SizedBox(width: rs(context, 8)),
            _choiceChip(context, '別', widget.teaOption == '別', (v) => widget.onTeaOptionChanged('別')),
            SizedBox(width: rs(context, 8)),
            _choiceChip(context, 'なし', widget.teaOption == 'なし', (v) => widget.onTeaOptionChanged('なし')),
            SizedBox(width: rs(context, 8)),
            _choiceChip(context, '特典', widget.teaOption == '特典', (v) => widget.onTeaOptionChanged('特典')),
          ],
        ),
        if (widget.teaOption == '特典') ...[
          SizedBox(height: rs(context, 12)),
          Row(
            children: [
              Text('特典本数：', style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline), 
                onPressed: () { if(widget.teaQuantity > 0) widget.onTeaQuantityChanged(widget.teaQuantity - 1); }
              ),
              GestureDetector(
                onTap: () async {
                  final result = await showDialog<int>(
                    context: context,
                    builder: (context) => KNumericInputDialog(initialValue: widget.teaQuantity, title: '特典本数'),
                  );
                  if (result != null) widget.onTeaQuantityChanged(result);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                  child: Text('${widget.teaQuantity}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline), 
                onPressed: () => widget.onTeaQuantityChanged(widget.teaQuantity + 1)
              ),
              const Text(' 本', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _choiceChip(BuildContext context, String label, bool isSelected, Function(bool) onSelected) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Colors.deepPurple,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      showCheckmark: false,
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) return Container(color: Colors.grey.shade100, child: const Icon(Icons.restaurant, color: Colors.grey));
    if (url.startsWith('http')) return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    if (url.startsWith('assets/')) return Image.asset(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    return Container(color: Colors.grey.shade100);
  }
}
