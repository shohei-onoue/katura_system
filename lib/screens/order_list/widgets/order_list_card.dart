import 'package:katura_system/utils/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../widgets/k_responsive.dart';

class OrderListCard extends StatefulWidget {
  final OrderModel order;
  final String? displayName; // 顧客管理の最新の名前（なければ受注に保存された名前）
  final Function(OrderModel, String) onEdit;
  final Function(OrderModel) onCancel;

  const OrderListCard({
    super.key,
    required this.order,
    this.displayName,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  State<OrderListCard> createState() => _OrderListCardState();
}

class _OrderListCardState extends State<OrderListCard> {
  Future<void> _showEditChoice(OrderModel order) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: AppColors.popupBackground,
        title: const Text('変更内容を選択'),
        children: [
          for (final name in ['配達先', '日程', '注文内容'])
            SimpleDialogOption(onPressed: () => Navigator.pop(context, name), child: Text(name)),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, '予約キャンセル'),
            child: const Text('予約キャンセル', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (choice == null) return;
    if (choice == '予約キャンセル') {
      widget.onCancel(order);
    } else {
      widget.onEdit(order, choice);
    }
  }

  bool _expanded = false;

  Color get _branchColor {
    switch (widget.order.branchName) {
      case '名古屋店':
        return Colors.green;
      case '岐阜店':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _itemLabel(dynamic item) {
    final order = widget.order;
    final m = item is Map ? item : const {};
    final buf = StringBuffer("${m['name']} x${m['quantity']}");
    final special = m['specialOrder'];
    if (special != null && special.toString().isNotEmpty) buf.write(' ($special)');
    final tea = m['teaOption'] ?? order.teaOption;
    final teaQty = m['teaQuantity'] ?? order.teaQuantity;
    if (m['teaOption'] != null && tea.toString() != 'なし') {
      buf.write(' お茶:$tea');
      if ((int.tryParse(teaQty.toString()) ?? 0) > 0) buf.write('x$teaQty');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final String preMethod = order.preConfirmationMethod.isEmpty ? '事前連絡なし' : order.preConfirmationMethod;
    final String deliveryDateTime = '${order.deliveryDate.month}/${order.deliveryDate.day} ${order.deliveryTime}';

    return Card(
      margin: EdgeInsets.only(bottom: rs(context, 12)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rs(context, 12)),
        side: BorderSide(color: _branchColor.withValues(alpha: 0.2), width: rs(context, 1)),
      ),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              width: double.infinity,
              color: _branchColor.withValues(alpha: 0.18),
              padding: EdgeInsets.fromLTRB(rs(context, 12), rs(context, 8), 0, rs(context, 8)),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.displayName ?? order.customerName,
                      style: TextStyle(fontSize: rf(context, 22), fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (order.address.isNotEmpty) ...[
                    SizedBox(width: rs(context, 8)),
                    Flexible(
                      child: Text(
                        order.address,
                        style: TextStyle(fontSize: rf(context, 13), color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(width: rs(context, 8)),
                  Text(
                    order.branchName,
                    style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: _branchColor),
                  ),
                  SizedBox(width: rs(context, 4)),
                  // カード右端に密着：右余白0 + アイコン字形の右側の透明部分(約2.7)をTransformでカード端へ押し出す
                  Transform.translate(
                    offset: Offset(rs(context, 2.7), 0),
                    child: InkWell(
                      onTap: () => _showEditChoice(order),
                      child: Padding(
                        padding: EdgeInsets.only(top: rs(context, 6), bottom: rs(context, 6), left: rs(context, 8)),
                        child: Icon(Icons.edit, size: rs(context, 20), color: Colors.blueGrey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // アコーディオン展開部：配達日時 / 事前連絡方法 / 注文内容 / 合計金額
          if (_expanded) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(rs(context, 12), rs(context, 8), rs(context, 12), rs(context, 10)),
              child: Row(
                children: [
                  Icon(Icons.event, size: rs(context, 18), color: AppColors.accentOrange),
                  SizedBox(width: rs(context, 4)),
                  Text(
                    deliveryDateTime,
                    style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: AppColors.accentOrange),
                  ),
                  SizedBox(width: rs(context, 16)),
                  Icon(Icons.notifications_active_outlined, size: rs(context, 18), color: Colors.blueGrey),
                  SizedBox(width: rs(context, 4)),
                  Text(preMethod, style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.w500, color: Colors.blueGrey)),
                ],
              ),
            ),
            if (order.items.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(rs(context, 12), 0, rs(context, 12), rs(context, 10)),
                child: SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: rs(context, 6),
                    runSpacing: rs(context, 6),
                    children: order.items
                        .map((item) => Container(
                              padding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rs(context, 4)),
                              decoration: BoxDecoration(
                                color: AppColors.accentOrange.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(rs(context, 6)),
                                border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.1)),
                              ),
                              child: Text(
                                _itemLabel(item),
                                style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.w500),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(rs(context, 12), rs(context, 10), rs(context, 12), rs(context, 12)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('合計金額', style: TextStyle(fontSize: rf(context, 12), color: Colors.grey.shade700)),
                  Text(
                    '${order.totalCount} 個 / ¥${order.totalPrice}',
                    style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: AppColors.accentOrange),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
