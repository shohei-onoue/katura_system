import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import 'package:katura_system/utils/facility_icon.dart';
import 'phone_common.dart';
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

  static const _g = Color(0xFF9A9AA5);

  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: _g));

  Widget _line([Color c = const Color(0xFFECE8F5)]) => Container(height: 1, color: c);

  /// 開いた状態のカード（Figma: 展開カード04 ラベル上置き）
  Widget _expandedCard(String baseName, String honorific) {
    final method = order.preConfirmationMethod;
    final dateText = DateFormat('M/d(E) ', 'ja_JP').format(order.deliveryDate) + order.deliveryTime;
    final facility = order.facilityName.trim();
    final header = Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4527A0), Color(0xFF7E57C2)])),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(orderIcon(deliveryType: order.deliveryType, facilityName: order.facilityName), size: 18, color: PL.purple),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(children: [
            Flexible(child: Text(baseName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white))),
            const SizedBox(width: 5),
            Text(honorific, style: const TextStyle(fontSize: 11.5, color: Color(0xFFE1D6FF))),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
          child: Text(order.branchName, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: PL.branchFg(order.branchName))),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.keyboard_arrow_up_rounded, size: 20, color: Color(0xFFE1D6FF)),
      ]),
    );
    final address = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('お届け先'),
          const SizedBox(height: 3),
          Text(order.address, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PL.ink)),
          if (facility.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 2), child: Text(facility, style: const TextStyle(fontSize: 11.5, color: PL.grey))),
        ]),
      ),
      InkWell(
        onTap: () => openMap(lat: order.latitude, lng: order.longitude, address: order.address),
        child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.map_rounded, size: 20, color: PL.purple)),
      ),
    ]);
    final contact = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('連絡方法'),
      const SizedBox(height: 3),
      Text(method.isEmpty ? '—' : method, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PL.ink)),
      if (order.phoneNumber.isNotEmpty)
        InkWell(
          onTap: () => callPhone(order.phoneNumber),
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.phone_rounded, size: 14, color: PL.purple),
              const SizedBox(width: 4),
              Text(order.phoneNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PL.purple, decoration: TextDecoration.underline)),
            ]),
          ),
        ),
    ]);
    final itemsPanel = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: PL.purpleSoft, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        for (final it in order.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(
                child: Row(children: [
                  Flexible(child: Text('${it['name'] ?? ''}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: PL.ink))),
                  if ((it['specialOrder'] ?? '').toString().isNotEmpty)
                    Padding(padding: const EdgeInsets.only(left: 6), child: Text('${it['specialOrder']}', style: const TextStyle(fontSize: 10.5, color: PL.grey))),
                ]),
              ),
              Text('× ${it['quantity'] ?? ''}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PL.purple)),
            ]),
          ),
        _line(const Color(0xFFD4C8EE)),
        const SizedBox(height: 8),
        Row(children: [
          Text('合計 ${order.totalCount}個', style: const TextStyle(fontSize: 13, color: PL.grey)),
          const Spacer(),
          Text('¥${NumberFormat('#,###').format(order.totalPrice)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: PL.purple)),
        ]),
      ]),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isWarning ? Border.all(color: PL.red, width: 1.5) : null,
        boxShadow: const [BoxShadow(color: Color(0x1F1B1B2F), blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onToggle,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            header,
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('配達日時'),
                const SizedBox(height: 3),
                Text(dateText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PL.redText)),
                const SizedBox(height: 12),
                _line(),
                const SizedBox(height: 12),
                address,
                const SizedBox(height: 12),
                _line(),
                const SizedBox(height: 12),
                contact,
                const SizedBox(height: 12),
                itemsPanel,
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plainName = (displayName ?? order.customerName).trim();
    final baseName = plainName.replaceFirst(RegExp(r'\s*(様|さま|御中)$'), '');
    final honorific = RegExp(r'(様|さま|御中)$').firstMatch(plainName)?.group(0) ?? '様';
    final collapsedCard = Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isWarning ? PL.redSoft : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isWarning ? Border.all(color: PL.red, width: 1.5) : null,
        boxShadow: const [BoxShadow(color: Color(0x1F1B1B2F), blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 8, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(orderIcon(deliveryType: order.deliveryType, facilityName: order.facilityName), size: 20, color: PL.purple),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Row(children: [
                        Flexible(child: Text(baseName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PL.ink))),
                        const SizedBox(width: 6),
                        Text(honorific, style: const TextStyle(fontSize: 11.5, color: PL.grey)),
                      ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: PL.branchBg(order.branchName), borderRadius: BorderRadius.circular(6)),
                      child: Text(order.branchName, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: PL.branchFg(order.branchName))),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 2),
                Row(children: [
                  const Padding(padding: EdgeInsets.only(right: 5), child: Icon(Icons.place_outlined, size: 13, color: PL.grey)),
                  Expanded(child: Text(order.address, style: const TextStyle(fontSize: 12, color: PL.grey))),
                ]),
                Padding(
                    padding: const EdgeInsets.only(top: 8, right: 7),
                    child: Row(children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: PL.purple),
                      const SizedBox(width: 4),
                      Text(order.deliveryTime, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PL.ink)),
                      const Spacer(),
                      Text('¥${NumberFormat('#,###').format(order.totalPrice)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PL.purple)),
                    ]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    final Widget card = expanded ? _expandedCard(baseName, honorific) : collapsedCard;
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
