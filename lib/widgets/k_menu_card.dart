import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'k_shared_quantity_input.dart';
import 'k_button.dart';
import '../models/menu_model.dart';

class KMenuCard extends StatelessWidget {
  final MenuModel menu;
  final int quantity;
  final Function(int) onQuantityChanged;
  final VoidCallback onDetailsPressed;
  final Color themeColor;

  const KMenuCard({
    super.key,
    required this.menu,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onDetailsPressed,
    this.themeColor = Colors.deepPurple,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = quantity > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(
          color: hasSelection ? themeColor : Colors.grey.shade200, 
          width: hasSelection ? 2 : 1,
        ),
        boxShadow: [
          if (hasSelection) 
            BoxShadow(
              color: themeColor.withValues(alpha: 0.1), 
              blurRadius: 8, 
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 画像エリア (アスペクト比固定)
          Expanded(
            flex: 10,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: _buildImage(menu.imageUrl),
            ),
          ),
          
          // テキスト・操作エリア (固定高さを持たせて揃える)
          Padding(
            padding: EdgeInsets.all(rs(context, 12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // メニュー名 (最大2行)
                SizedBox(
                  height: rf(context, 40), // 2行分を確保
                  child: Text(
                    menu.name,
                    style: TextStyle(
                      fontSize: rf(context, 14), 
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: rs(context, 4)),
                
                // 金額
                Text(
                  '¥${menu.price}',
                  style: TextStyle(
                    fontSize: rf(context, 16), 
                    fontWeight: FontWeight.bold, 
                    color: Colors.deepOrange,
                  ),
                ),
                SizedBox(height: rs(context, 12)),
                
                // 数量入力 (共通ウィジェット)
                Center(
                  child: KSharedQuantityInput(
                    value: quantity,
                    onChanged: onQuantityChanged,
                    title: menu.name,
                    width: rs(context, 60),
                    height: 36,
                  ),
                ),
                SizedBox(height: rs(context, 8)),
                
                // 詳細設定ボタン
                KButton(
                  label: '詳細設定',
                  onPressed: onDetailsPressed,
                  height: 36,
                  fontSize: 13,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: const Icon(Icons.restaurant, color: Colors.grey),
      );
    }
    
    final imageWidget = url.startsWith('http')
        ? Image.network(url, fit: BoxFit.cover)
        : Image.asset(url, fit: BoxFit.cover);

    return imageWidget;
  }
}
