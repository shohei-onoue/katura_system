import 'package:katura_system/utils/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../widgets/k_responsive.dart';

class OrderListCard extends StatefulWidget {
  final OrderModel order;
  final String? displayName; // 顧客管理の最新の名前（なければ受注に保存された名前）
  final Function(OrderModel, String) onEdit;
  final Function(OrderModel) onCancel;
  final bool expanded;
  final VoidCallback onToggle;
  final bool isWarning; // 重複・同一配達先の警告対象
  final String warningText; // 警告内容（カードの外上部に表示）

  const OrderListCard({
    super.key,
    required this.order,
    this.displayName,
    required this.onEdit,
    required this.onCancel,
    required this.expanded,
    required this.onToggle,
    this.isWarning = false,
    this.warningText = '',
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

  bool get _expanded => widget.expanded;

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

  /// 住所の先頭の郵便番号（〒123-4567 / 123-4567 / 1234567）を取り除く
  String _addressWithoutZip(String address) =>
      address.replaceFirst(RegExp(r'^\s*〒?\s*\d{3}\s*[-‐－ー−]?\s*\d{4}\s*'), '');

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
    final String deliveryDateTime = '${order.deliveryDate.month}/${order.deliveryDate.day} ${order.deliveryTime}';

    final card = Card(
      margin: EdgeInsets.only(bottom: rs(context, 12)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rs(context, 12)),
        side: BorderSide(color: widget.isWarning ? AppColors.cancelButton : _branchColor.withValues(alpha: 0.2), width: rs(context, 1)),
      ),
      elevation: 2,
      color: widget.isWarning ? AppColors.cancelButton : null,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: widget.onToggle,
            child: Container(
              width: double.infinity,
              color: widget.isWarning ? Colors.transparent : _branchColor.withValues(alpha: 0.18),
              padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 3)),
              child: Row(
                children: [
                  if (order.preConfirmationMethod.isNotEmpty) ...[
                    Icon(Icons.notifications_active, size: rs(context, 24), color: widget.isWarning ? AppColors.whiteText : const Color(0xFFFFB300)),
                    SizedBox(width: rs(context, 18)),
                  ],
                  Expanded(
                    child: Text(
                      order.facilityName.trim().isEmpty ? '個人宅' : order.facilityName.trim(),
                      style: TextStyle(fontSize: rf(context, 22), fontWeight: FontWeight.bold, color: widget.isWarning ? AppColors.whiteText : Colors.black),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: rs(context, 7)),
                  Text(
                    order.branchName,
                    style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: widget.isWarning ? AppColors.whiteText : _branchColor),
                    maxLines: 1,
                  ),
                  SizedBox(width: rs(context, 7)),
                  InkWell(
                    onTap: () => _showEditChoice(order),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: rs(context, 6), horizontal: rs(context, 8)),
                      child: Icon(Icons.edit, size: rs(context, 20), color: widget.isWarning ? AppColors.whiteText : const Color(0xFF607D8B)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // アコーディオン展開部：配達日時・住所 / 区切り線 / 注文内容 / 合計金額
          if (_expanded) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 5)),
              child: Row(
                children: [
                  Icon(Icons.event, size: rs(context, 18), color: widget.isWarning ? AppColors.whiteText : Colors.black),
                  SizedBox(width: rs(context, 4)),
                  Text(
                    deliveryDateTime,
                    style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: widget.isWarning ? AppColors.whiteText : Colors.black),
                  ),
                  SizedBox(width: rs(context, 20)),
                  Expanded(
                    child: Text(
                      _addressWithoutZip(order.address),
                      style: TextStyle(fontSize: rf(context, 13), color: widget.isWarning ? AppColors.whiteText : const Color(0xFF616161)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 5)),
              child: Divider(height: 1, thickness: 1, color: widget.isWarning ? AppColors.whiteText : Colors.grey.shade500),
            ),
            if (order.items.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 5)),
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
                                style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.w500, color: widget.isWarning ? AppColors.whiteText : null),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 5)),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                border: const Border(top: BorderSide(color: Color(0xFFEEEEEE))),
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
    if (!widget.isWarning || widget.warningText.isEmpty) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: rs(context, 4), bottom: rs(context, 4)),
          child: Text(
            widget.warningText,
            style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: AppColors.cancelButton),
          ),
        ),
        card,
      ],
    );
  }
}
