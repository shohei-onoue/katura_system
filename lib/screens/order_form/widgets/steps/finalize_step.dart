import 'package:flutter/material.dart';
import '../../../../models/staff_model.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_tile_selector.dart';
import '../order_form_parts.dart';

class FinalizeStep extends StatelessWidget {
  final String branchName;
  final String paymentMethod;
  final bool collectContainer;
  final String? selectedReceiverId;
  final List<Staff> staffList;
  final Function(String) onBranchChanged;
  final Function(String) onPaymentChanged;
  final Function(bool) onCollectChanged;
  final Function(String) onReceiverChanged;
  final VoidCallback onSave;

  const FinalizeStep({
    super.key,
    required this.branchName,
    required this.paymentMethod,
    required this.collectContainer,
    required this.selectedReceiverId,
    required this.staffList,
    required this.onBranchChanged,
    required this.onPaymentChanged,
    required this.onCollectChanged,
    required this.onReceiverChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return OrderFormCard(
      title: '支払・完了',
      icon: Icons.check_circle,
      child: Column(
        children: [
          KTileSelector(label: '担当店舗', selectedValue: branchName, items: [KTileItem(label: '岡崎本店', value: '岡崎本店'), KTileItem(label: '名古屋店', value: '名古屋店'), KTileItem(label: '岐阜店', value: '岐阜店')], onSelected: onBranchChanged),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: KTileSelector(label: '支払方法', selectedValue: paymentMethod, items: [KTileItem(label: '現金', value: '現金'), KTileItem(label: 'カード', value: 'カード'), KTileItem(label: '請求書', value: '請求')], onSelected: onPaymentChanged)),
              const SizedBox(width: 24),
              Container(width: 200, padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Column(children: [const Text('容器回収', style: TextStyle(fontWeight: FontWeight.bold)), Switch(value: collectContainer, onChanged: onCollectChanged)])),
            ],
          ),
          const SizedBox(height: 24),
          KTileSelector(label: '受電担当者', selectedValue: selectedReceiverId, items: staffList.map((s) => KTileItem(label: s.name, value: s.id)).toList(), onSelected: onReceiverChanged),
          const SizedBox(height: 40),
          KButton(label: '受注を確定して保存する', color: Colors.deepOrange, onPressed: onSave),
        ],
      ),
    );
  }
}
