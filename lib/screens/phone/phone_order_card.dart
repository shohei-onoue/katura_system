import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:katura_system/utils/name_format.dart';
import '../../models/order_model.dart';
import 'phone_common.dart';
import 'phone_order_list_dialogs.dart';
import 'phone_order_list_style.dart';

/// スマホ用の受注カード（Figma: 受注一覧）。タップで展開、鉛筆アイコンで「変更内容を選択」。
class PhoneOrderCard extends StatelessWidget {
  final OrderModel order;
  final String? displayName;
  final bool expanded;
  final bool isWarning;
  final String warningText;
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
    this.warningText = '',
  });

  String _itemLabel(dynamic item) {
    final m = item is Map ? item : const {};
    final buf = StringBuffer("${m['name']} x${m['quantity']}");
    final special = m['specialOrder'];
    if (special != null && special.toString().isNotEmpty) buf.write(' ($special)');
    return buf.toString();
  }

  Future<void> _editChoice(BuildContext context) async {
    final name = withHonorific(displayName ?? order.customerName);
    final choice = await showPhoneChangeSelectSheet(context, name);
    if (choice == null) return;
    choice == '予約キャンセル' ? onCancel(order) : onEdit(order, choice);
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: PL.purpleSoft, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: PL.purple)),
      );

  @override
  Widget build(BuildContext context) {
    final plainName = (displayName ?? order.customerName).trim();
    final baseName = plainName.replaceFirst(RegExp(r'\s*(様|さま|御中)$'), '');
    final honorific = RegExp(r'(様|さま|御中)$').firstMatch(plainName)?.group(0) ?? '様';
    final method = order.preConfirmationMethod;
    final dateText = '${order.deliveryDate.month}/${order.deliveryDate.day} ${order.deliveryTime}';
    final facility = order.facilityName.trim();
    final card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isWarning ? PL.redSoft : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isWarning ? PL.red : PL.cardBorder, width: isWarning ? 1.5 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 8, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(baseName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: PL.ink)),
                    ),
                    const SizedBox(width: 6),
                    Text(honorific, style: const TextStyle(fontSize: 11.5, color: PL.grey)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: PL.branchBg(order.branchName), borderRadius: BorderRadius.circular(6)),
                      child: Text(order.branchName, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: PL.branchFg(order.branchName))),
                    ),
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _editChoice(context),
                      child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.edit_rounded, size: 18, color: PL.iconGrey)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(children: [
                  Expanded(child: Text(order.address, style: const TextStyle(fontSize: 11.5, color: PL.grey))),
                  if (expanded)
                    InkWell(
                      onTap: () => openMap(lat: order.latitude, lng: order.longitude, address: order.address),
                      child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), child: Icon(Icons.map_rounded, size: 18, color: PL.purple)),
                    ),
                ]),
                if (expanded) ...[
                  if (facility.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 2), child: Text(facility, style: const TextStyle(fontSize: 11.5, color: PL.grey))),
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.event_rounded, size: 15, color: PL.redText),
                    const SizedBox(width: 3),
                    Text(dateText, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: PL.redText)),
                    if (method.isNotEmpty) ...[
                      const SizedBox(width: 18),
                      Icon(method == '電話' ? Icons.notifications_active_rounded : Icons.sms_rounded, size: 15, color: PL.grey),
                      const SizedBox(width: 3),
                      Text(method == '電話' ? '電話' : 'SMS', style: const TextStyle(fontSize: 11.5, color: PL.grey)),
                    ],
                    const Spacer(),
                    if (order.phoneNumber.isNotEmpty)
                      InkWell(
                        onTap: () => callPhone(order.phoneNumber),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.phone_rounded, size: 14, color: PL.purple),
                            const SizedBox(width: 3),
                            Text(order.phoneNumber, style: const TextStyle(fontSize: 11.5, color: PL.purple, decoration: TextDecoration.underline)),
                          ]),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 10),
                  Wrap(spacing: 6, runSpacing: 6, children: [for (final it in order.items) _chip(_itemLabel(it))]),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: Row(children: [
                      const Text('合計金額', style: TextStyle(fontSize: 11.5, color: PL.grey)),
                      const Spacer(),
                      Text('${order.totalCount} 個 / ¥${NumberFormat('#,###').format(order.totalPrice)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PL.red)),
                    ]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    if (!isWarning || warningText.isEmpty) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(Icons.warning_amber_rounded, size: 16, color: PL.red),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(warningText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PL.red)),
              ),
            ],
          ),
        ),
        card,
      ],
    );
  }
}
