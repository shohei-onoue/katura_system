import 'package:flutter/material.dart';
import 'package:katura_system/utils/app_colors.dart';
import 'package:katura_system/utils/name_format.dart';
import '../../models/order_model.dart';
import 'phone_common.dart';

/// スマホ用の受注カード（タップでアコーディオン展開、マップアイコンで配達先の地図へ）
class PhoneOrderCard extends StatelessWidget {
  final OrderModel order;
  final String? displayName;
  final bool expanded;
  final bool isWarning;
  final VoidCallback onToggle;
  final void Function(OrderModel, String) onEdit;
  final void Function(OrderModel) onCancel;

  const PhoneOrderCard({
    super.key,
    required this.order,
    this.displayName,
    required this.expanded,
    required this.onToggle,
    required this.onEdit,
    required this.onCancel,
    this.isWarning = false,
  });

  Color get _branchColor {
    switch (order.branchName) {
      case '名古屋店':
        return Colors.green;
      case '岐阜店':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _itemLabel(dynamic item) {
    final m = item is Map ? item : const {};
    final buf = StringBuffer("${m['name']} x${m['quantity']}");
    final special = m['specialOrder'];
    if (special != null && special.toString().isNotEmpty) buf.write(' ($special)');
    return buf.toString();
  }

  Future<void> _editChoice(BuildContext context) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppColors.popupBackground,
        title: const Text('変更内容を選択'),
        children: [
          for (final n in ['配達先', '日程', '注文内容']) SimpleDialogOption(onPressed: () => Navigator.pop(ctx, n), child: Text(n)),
          SimpleDialogOption(onPressed: () => Navigator.pop(ctx, '予約キャンセル'), child: const Text('予約キャンセル', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (choice == null) return;
    choice == '予約キャンセル' ? onCancel(order) : onEdit(order, choice);
  }

  @override
  Widget build(BuildContext context) {
    final fg = isWarning ? AppColors.whiteText : AppColors.primaryText;
    final sub = isWarning ? AppColors.whiteText : AppColors.secondaryText;
    final name = withHonorific(displayName ?? order.customerName);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isWarning ? AppColors.cancelButton : null,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: _branchColor.withValues(alpha: 0.3))),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Container(
              color: isWarning ? Colors.transparent : _branchColor.withValues(alpha: 0.18),
              padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
              child: Row(
                children: [
                  if (order.preConfirmationMethod.isNotEmpty) ...[
                    Icon(order.preConfirmationMethod == '電話' ? Icons.phone : Icons.mail, size: 20, color: isWarning ? AppColors.whiteText : const Color(0xFFFFB300)),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      order.facilityName.trim().isEmpty ? '個人宅' : order.facilityName.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: fg),
                    ),
                  ),
                  Text(order.branchName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isWarning ? AppColors.whiteText : _branchColor)),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.edit, size: 20, color: isWarning ? AppColors.whiteText : const Color(0xFF607D8B)),
                    onPressed: () => _editChoice(context),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.event, size: 18, color: fg),
                    const SizedBox(width: 4),
                    Text('${order.deliveryDate.month}/${order.deliveryDate.day} ${order.deliveryTime}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: fg)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: fg))),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(child: Text(order.address, style: TextStyle(fontSize: 13, color: sub))),
                    IconButton(
                      icon: Icon(Icons.map, color: isWarning ? AppColors.whiteText : AppColors.accentPurple),
                      onPressed: () => openMap(lat: order.latitude, lng: order.longitude, address: order.address),
                    ),
                  ]),
                  if (order.phoneNumber.isNotEmpty)
                    InkWell(
                      onTap: () => callPhone(order.phoneNumber),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          Icon(Icons.phone, size: 16, color: fg),
                          const SizedBox(width: 4),
                          Text(order.phoneNumber, style: TextStyle(fontSize: 14, color: fg, decoration: TextDecoration.underline)),
                        ]),
                      ),
                    ),
                  Divider(color: isWarning ? AppColors.whiteText : Colors.grey),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final it in order.items)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.accentOrange.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.2))),
                          child: Text(_itemLabel(it), style: const TextStyle(fontSize: 12, color: AppColors.primaryText)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('${order.totalCount} 個 / ¥${order.totalPrice}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isWarning ? AppColors.whiteText : AppColors.accentOrange)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
