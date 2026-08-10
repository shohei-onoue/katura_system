import 'package:flutter/material.dart';
import '../../../../models/staff_model.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_tile_selector.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_multimodal_text_field.dart';
import '../order_form_parts.dart';

class FinalizeStep extends StatelessWidget {
  final String branchName;
  final String paymentMethod;
  final bool collectContainer;
  final String? selectedReceiverId;
  final List<Staff> staffList;
  final String orderSource;
  final TextEditingController orderSourceOtherController;
  final String packagingType;
  final int packagingSmallQty;
  final TextEditingController packagingOtherController;
  final String phoneDisplay; // 受電番号
  final String preConfirmationMethod; // 事前確認方法
  final Function(String) onOrderSourceChanged;
  final Function(String) onPackagingTypeChanged;
  final Function(int) onPackagingSmallQtyChanged;
  final Function(String) onBranchChanged;
  final Function(String) onPaymentChanged;
  final Function(bool) onCollectChanged;
  final Function(String) onReceiverChanged;
  final Function(String) onPreConfirmationMethodChanged;
  final VoidCallback onSave;

  const FinalizeStep({
    super.key,
    required this.branchName,
    required this.paymentMethod,
    required this.collectContainer,
    required this.selectedReceiverId,
    required this.staffList,
    required this.orderSource,
    required this.orderSourceOtherController,
    required this.packagingType,
    required this.packagingSmallQty,
    required this.packagingOtherController,
    required this.phoneDisplay,
    required this.preConfirmationMethod,
    required this.onOrderSourceChanged,
    required this.onPackagingTypeChanged,
    required this.onPackagingSmallQtyChanged,
    required this.onBranchChanged,
    required this.onPaymentChanged,
    required this.onCollectChanged,
    required this.onReceiverChanged,
    required this.onPreConfirmationMethodChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return OrderFormCard(
      title: '受注区分・梱包・支払',
      icon: Icons.check_circle,
      trailing: Text('受電: $phoneDisplay', 
        style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 受注区分
          Text('受注区分', style: _labelStyle(context)),
          SizedBox(height: rs(context, 8)),
          Row(
            children: [
              _choiceChip(context, '直取', orderSource == '直取', (v) => onOrderSourceChanged('直取')),
              SizedBox(width: rs(context, 8)),
              _choiceChip(context, '結膳', orderSource == '結膳', (v) => onOrderSourceChanged('結膳')),
              SizedBox(width: rs(context, 8)),
              _choiceChip(context, 'デリカ', orderSource == 'デリカ', (v) => onOrderSourceChanged('デリカ')),
              SizedBox(width: rs(context, 8)),
              _choiceChip(context, 'その他', orderSource == 'その他', (v) => onOrderSourceChanged('その他')),
            ],
          ),
          if (orderSource == 'その他') ...[
            SizedBox(height: rs(context, 12)),
            KMultimodalTextField(
              label: '受注区分（詳細）', 
              controller: orderSourceOtherController,
              icon: Icons.edit_note,
            ),
          ],
          
          SizedBox(height: rs(context, 32)),
          const Divider(),
          SizedBox(height: rs(context, 32)),

          // 2. 梱包
          Text('梱包方法', style: _labelStyle(context)),
          SizedBox(height: rs(context, 8)),
          Row(
            children: [
              _choiceChip(context, '紙袋', packagingType == '紙袋', (v) => onPackagingTypeChanged('紙袋')),
              SizedBox(width: rs(context, 8)),
              _choiceChip(context, '段ボール', packagingType == '段ボール', (v) => onPackagingTypeChanged('段ボール')),
              SizedBox(width: rs(context, 8)),
              _choiceChip(context, '小分け', packagingType == '小分け', (v) => onPackagingTypeChanged('小分け')),
              SizedBox(width: rs(context, 8)),
              _choiceChip(context, 'その他', packagingType == 'その他', (v) => onPackagingTypeChanged('その他')),
            ],
          ),
          if (packagingType == '小分け') ...[
            SizedBox(height: rs(context, 12)),
            Row(
              children: [
                Text('小分け数量：', style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () { if(packagingSmallQty > 0) onPackagingSmallQtyChanged(packagingSmallQty - 1); }),
                Text('$packagingSmallQty', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => onPackagingSmallQtyChanged(packagingSmallQty + 1)),
                const Text(' 個ずつ'),
              ],
            ),
          ],
          if (packagingType == 'その他') ...[
            SizedBox(height: rs(context, 12)),
            KMultimodalTextField(
              label: '梱包方法（詳細）', 
              controller: packagingOtherController,
              icon: Icons.inventory_2_outlined,
            ),
          ],

          SizedBox(height: rs(context, 32)),
          const Divider(),
          SizedBox(height: rs(context, 32)),

          // 3. 事前確認
          Text('事前確認（前日連絡）', style: _labelStyle(context)),
          SizedBox(height: rs(context, 8)),
          Row(
            children: [
              _choiceChip(context, 'SNS', preConfirmationMethod == 'SNS', (v) => onPreConfirmationMethodChanged('SNS')),
              SizedBox(width: rs(context, 12)),
              _choiceChip(context, '電話', preConfirmationMethod == '電話', (v) => onPreConfirmationMethodChanged('電話')),
            ],
          ),

          SizedBox(height: rs(context, 32)),
          const Divider(),
          SizedBox(height: rs(context, 32)),

          // 4. 店舗・支払
          KTileSelector(label: '担当店舗', selectedValue: branchName, items: [KTileItem(label: '岡崎本店', value: '岡崎本店'), KTileItem(label: '名古屋店', value: '名古屋店'), KTileItem(label: '岐阜店', value: '岐阜店')], onSelected: onBranchChanged),
          SizedBox(height: rs(context, 24)),
          Row(
            children: [
              Expanded(child: KTileSelector(label: '支払方法', selectedValue: paymentMethod, items: [KTileItem(label: '現金', value: '現金'), KTileItem(label: 'カード', value: 'カード'), KTileItem(label: '請求書', value: '請求')], onSelected: onPaymentChanged)),
              SizedBox(width: rs(context, 24)),
              Container(width: rs(context, 200), padding: EdgeInsets.all(rs(context, 16)), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(rs(context, 8))), child: Column(children: [Text('容器回収', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 14))), Switch(value: collectContainer, onChanged: onCollectChanged)])),
            ],
          ),
          SizedBox(height: rs(context, 24)),
          KTileSelector(label: '受電担当者', selectedValue: selectedReceiverId, items: staffList.map((s) => KTileItem(label: s.name, value: s.id)).toList(), onSelected: onReceiverChanged),
          SizedBox(height: rs(context, 40)),
          KButton(label: '受注を確定して保存する', color: Colors.deepOrange, onPressed: onSave),
        ],
      ),
    );
  }

  TextStyle _labelStyle(BuildContext context) {
    return TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700);
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
}
