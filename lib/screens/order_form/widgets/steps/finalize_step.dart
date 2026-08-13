import 'package:flutter/material.dart';
import '../../../../models/staff_model.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_tile_selector.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_multimodal_text_field.dart';
import '../../../../widgets/k_shared_quantity_input.dart';
import '../order_form_parts.dart';

class FinalizeStep extends StatelessWidget {
  final String branchName;
  final String paymentMethod;
  final bool collectContainer;
  final String? selectedReceiverId;
  final List<Staff> staffList;
  final String packagingType;
  final int packagingSmallQty;
  final TextEditingController packagingOtherController;
  final String preConfirmationMethod; // 事前確認方法
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
    required this.packagingType,
    required this.packagingSmallQty,
    required this.packagingOtherController,
    required this.preConfirmationMethod,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 梱包
          _buildFormRow(
            context: context,
            label: '梱包方法',
            buttons: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _choiceChip(context, '紙袋', packagingType == '紙袋', (v) => onPackagingTypeChanged('紙袋')),
                _choiceChip(context, '段ボール', packagingType == '段ボール', (v) => onPackagingTypeChanged('段ボール')),
                _choiceChip(context, '小分け', packagingType == '小分け', (v) => onPackagingTypeChanged('小分け')),
                _choiceChip(context, 'その他', packagingType == 'その他', (v) => onPackagingTypeChanged('その他')),
              ],
            ),
            details: _buildPackagingDetailArea(context),
          ),

          SizedBox(height: rs(context, 12)),
          const Divider(height: 1),
          SizedBox(height: rs(context, 12)),

          // 2. 事前確認
          _buildFormRow(
            context: context,
            label: '事前確認',
            buttons: Row(
              children: [
                _choiceChip(context, 'SNS', preConfirmationMethod == 'SNS', (v) => onPreConfirmationMethodChanged('SNS')),
                const SizedBox(width: 12),
                _choiceChip(context, '電話', preConfirmationMethod == '電話', (v) => onPreConfirmationMethodChanged('電話')),
              ],
            ),
          ),

          SizedBox(height: rs(context, 12)),
          const Divider(height: 1),
          SizedBox(height: rs(context, 12)),

          // 3. 店舗
          _buildFormRow(
            context: context, 
            label: '担当店舗', 
            buttons: KTileSelector(
              label: '', 
              selectedValue: branchName, 
              items: [
                KTileItem(label: '岡崎本店', value: '岡崎本店'), 
                KTileItem(label: '名古屋店', value: '名古屋店'), 
                KTileItem(label: '岐阜店', value: '岐阜店')
              ], 
              onSelected: onBranchChanged
            ),
          ),

          SizedBox(height: rs(context, 12)),
          const Divider(height: 1),
          SizedBox(height: rs(context, 12)),

          // 4. 支払・回収
          _buildFormRow(
            context: context, 
            label: '支払方法', 
            buttons: KTileSelector(
              label: '', 
              selectedValue: paymentMethod, 
              items: [
                KTileItem(label: '現金', value: '現金'), 
                KTileItem(label: 'カード', value: 'カード'), 
                KTileItem(label: '請求書', value: '請求')
              ], 
              onSelected: onPaymentChanged
            ),
            details: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('容器回収', style: _labelStyle(context).copyWith(fontSize: rf(context, 12))),
                const SizedBox(height: 4),
                Container(
                  height: rs(context, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('希望', style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold)),
                      Switch(value: collectContainer, onChanged: onCollectChanged),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: rs(context, 12)),
          const Divider(height: 1),
          SizedBox(height: rs(context, 12)),

          // 5. 担当者
          _buildFormRow(
            context: context, 
            label: '受電担当者', 
            buttons: KTileSelector(
              label: '', 
              selectedValue: selectedReceiverId, 
              items: staffList.map((s) => KTileItem(label: s.name, value: s.id)).toList(), 
              onSelected: onReceiverChanged
            ),
          ),
          
          SizedBox(height: rs(context, 24)),
          KButton(label: '受注を確定して保存する', color: Colors.deepOrange, onPressed: onSave),
        ],
      ),
    );
  }

  Widget _buildFormRow({
    required BuildContext context,
    required String label,
    required Widget buttons,
    Widget? details,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // タイトル
        Text(label, style: _labelStyle(context)),
        const SizedBox(height: 12),
        // 下段コンテンツ (ボタン 70% : 詳細 30%)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ボタンエリア (70%)
            Expanded(
              flex: 70,
              child: Align(
                alignment: Alignment.centerLeft,
                child: buttons,
              ),
            ),
            const SizedBox(width: 24),
            // 詳細エリア (30%)
            Expanded(
              flex: 30,
              child: details ?? const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPackagingDetailArea(BuildContext context) {
    if (packagingType == '小分け') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('数量:', style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(width: 4),
          KSharedQuantityInput(
            value: packagingSmallQty,
            onChanged: onPackagingSmallQtyChanged,
            title: '小分け数量',
            width: rs(context, 60),
            height: 36,
          ),
          const SizedBox(width: 4),
          Text('個ずつ', style: TextStyle(fontSize: rf(context, 12))),
        ],
      );
    }
    if (packagingType == 'その他') {
      return KMultimodalTextField(
        label: '',
        hintText: '梱包方法（詳細）',
        showLabel: false,
        controller: packagingOtherController,
        height: rs(context, 40),
      );
    }
    return const SizedBox.shrink();
  }

  TextStyle _labelStyle(BuildContext context) {
    return TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700);
  }

  Widget _choiceChip(BuildContext context, String label, bool isSelected, Function(bool) onSelected) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold)),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Colors.deepPurple,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
      showCheckmark: false,
    );
  }
}
