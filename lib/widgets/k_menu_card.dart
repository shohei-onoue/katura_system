import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'k_shared_quantity_input.dart';
import 'k_button.dart';
import '../models/menu_model.dart';
import 'package:katura_system/utils/app_colors.dart';

class KMenuCard extends StatefulWidget {
  final MenuModel menu;
  /// 数量入力の初期値（カード内でローカル管理し、右サイドバーとは連携しない）
  final int initialQuantity;
  /// 現在の数量をそのままカートへ入れる（詳細設定なし）
  final void Function(int quantity) onAddToCart;
  /// 詳細設定ダイヤログを開く（現在の数量を初期値として渡す）。
  /// カートへ追加されたら true を返す。
  final Future<bool> Function(int quantity) onOpenDetails;
  final Color themeColor;

  const KMenuCard({
    super.key,
    required this.menu,
    this.initialQuantity = 0,
    required this.onAddToCart,
    required this.onOpenDetails,
    this.themeColor = Colors.deepPurple,
  });

  @override
  State<KMenuCard> createState() => _KMenuCardState();
}

class _KMenuCardState extends State<KMenuCard> {
  late int _qty;

  @override
  void initState() {
    super.initState();
    _qty = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = _qty > 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(
          color: hasSelection ? widget.themeColor : Colors.grey.shade200,
          width: hasSelection ? 2 : 1,
        ),
        boxShadow: [
          if (hasSelection)
            BoxShadow(
              color: widget.themeColor.withValues(alpha: 0.1),
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(rs(context, 10))),
              child: _buildImage(widget.menu.imageUrl),
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
                    widget.menu.name,
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
                  '¥${widget.menu.price}',
                  style: TextStyle(
                    fontSize: rf(context, 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                SizedBox(height: rs(context, 12)),

                // 数量入力 (カード内ローカル。右サイドバーとは非連携)
                Center(
                  child: KSharedQuantityInput(
                    value: _qty,
                    onChanged: (v) => setState(() => _qty = v),
                    title: widget.menu.name,
                    width: rs(context, 60),
                    height: rs(context, 36),
                  ),
                ),
                SizedBox(height: rs(context, 8)),

                // カートへ入れる（オレンジ）＋ 詳細設定（＋）
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: rs(context, 36),
                        child: ElevatedButton(
                          onPressed: _qty > 0
                              ? () {
                                  widget.onAddToCart(_qty);
                                  setState(() => _qty = 0);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: AppColors.background,
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 8))),
                          ),
                          child: Icon(Icons.add_shopping_cart, size: rs(context, 18)),
                        ),
                      ),
                    ),
                    SizedBox(width: rs(context, 8)),
                    Expanded(
                      child: KButton(
                        label: '＋',
                        onPressed: () async {
                          final bool added = await widget.onOpenDetails(_qty);
                          if (added && mounted) setState(() => _qty = 0);
                        },
                        height: rs(context, 36),
                        fontSize: rf(context, 18),
                      ),
                    ),
                  ],
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
