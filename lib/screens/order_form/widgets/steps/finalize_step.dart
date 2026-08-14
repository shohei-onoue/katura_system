import 'package:flutter/material.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_tile_selector.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_multimodal_text_field.dart';
import '../../../../widgets/k_shared_quantity_input.dart';
import '../../../../widgets/k_date_time_display.dart';
import '../../../../widgets/k_date_time_selection_dialog.dart';
import '../../../../widgets/k_time_selection_dialog.dart';
import '../../../../widgets/k_numeric_dial_pad.dart';
import '../order_form_parts.dart';

class FinalizeStep extends StatelessWidget {
  final String branchName;
  final String paymentMethod;
  final String packagingType;
  final int packagingSmallQty;
  final TextEditingController packagingOtherController;
  final String preConfirmationMethod; // 事前確認方法
  final String preConfirmationPhoneType;
  final String preConfirmationPhoneNumber;
  final TextEditingController preConfirmationPhoneController;
  final DateTime? preConfirmationDateTime;
  final String preConfirmationSmsTime;
  final String phoneDisplay; // 受電番号

  final Function(String) onPackagingTypeChanged;
  final Function(int) onPackagingSmallQtyChanged;
  final Function(String) onBranchChanged;
  final Function(String) onPaymentChanged;
  final Function(String) onPreConfirmationMethodChanged;
  final Function(String) onPreConfirmationPhoneTypeChanged;
  final Function(String) onPreConfirmationPhoneNumberChanged;
  final Function(DateTime) onPreConfirmationDateTimeChanged;
  final Function(String) onPreConfirmationSmsTimeChanged;
  final VoidCallback onSave;

  const FinalizeStep({
    super.key,
    required this.branchName,
    required this.paymentMethod,
    required this.packagingType,
    required this.packagingSmallQty,
    required this.packagingOtherController,
    required this.preConfirmationMethod,
    required this.preConfirmationPhoneType,
    required this.preConfirmationPhoneNumber,
    required this.preConfirmationPhoneController,
    this.preConfirmationDateTime,
    required this.preConfirmationSmsTime,
    required this.phoneDisplay,
    required this.onPackagingTypeChanged,
    required this.onPackagingSmallQtyChanged,
    required this.onBranchChanged,
    required this.onPaymentChanged,
    required this.onPreConfirmationMethodChanged,
    required this.onPreConfirmationPhoneTypeChanged,
    required this.onPreConfirmationPhoneNumberChanged,
    required this.onPreConfirmationDateTimeChanged,
    required this.onPreConfirmationSmsTimeChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return OrderFormCard(
      title: '梱包・支払・確認設定',
      icon: Icons.check_circle,
      trailing: Text('受電: $phoneDisplay', 
        style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
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
                _choiceChip(context, 'SMS', preConfirmationMethod == 'SMS', (v) => onPreConfirmationMethodChanged('SMS')),
                const SizedBox(width: 12),
                _choiceChip(context, '電話', preConfirmationMethod == '電話', (v) => onPreConfirmationMethodChanged('電話')),
                if (preConfirmationMethod == 'SMS') ...[
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.blueGrey),
                    onPressed: () => _showSmsTimeDialog(context),
                    tooltip: 'SMS送信スケジュール設定',
                  ),
                ],
              ],
            ),
            details: _buildPreConfirmationDetailArea(context),
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

          // 4. 支払
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
        // 下段コンテンツ (ボタン 50% : 詳細 50%)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ボタンエリア (50%)
            Expanded(
              flex: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: buttons,
              ),
            ),
            const SizedBox(width: 16),
            // 詳細エリア (50%)
            Expanded(
              flex: 50,
              child: details ?? const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPackagingDetailArea(BuildContext context) {
    if (packagingType == '小分け') {
      return Center(
        child: Row(
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
        ),
      );
    }
    if (packagingType == 'その他') {
      return SizedBox(
        width: double.infinity,
        child: KMultimodalTextField(
          label: '',
          hintText: '梱包方法（詳細）',
          showLabel: false,
          controller: packagingOtherController,
          height: rs(context, 40),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPreConfirmationDetailArea(BuildContext context) {
    if (preConfirmationMethod == 'SMS') {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 16, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text('前日 $preConfirmationSmsTime に自動送信されます', 
                style: TextStyle(fontSize: rf(context, 12), color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.settings, size: 18, color: Colors.blue),
              onPressed: () => _showSmsTimeDialog(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    }

    if (preConfirmationMethod == '電話') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAccordionHeader(context),
          if (preConfirmationPhoneType == '指定番号へ連絡') ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showPhoneDialDialog(context),
              child: Container(
                height: rs(context, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      preConfirmationPhoneNumber.isEmpty ? '連絡先電話番号を入力' : preConfirmationPhoneNumber,
                      style: TextStyle(
                        fontSize: rf(context, 14), 
                        color: preConfirmationPhoneNumber.isEmpty ? Colors.grey.shade400 : Colors.black87,
                        fontWeight: preConfirmationPhoneNumber.isEmpty ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.phone_android, size: 18, color: Colors.blueGrey),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text('連絡希望日時', style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 4),
          KDateTimeDisplay(
            label: '',
            dateTime: preConfirmationDateTime,
            onTap: () async {
              final result = await showDialog<DateTime>(
                context: context,
                builder: (context) => KDateTimeSelectionDialog(
                  initialDateTime: preConfirmationDateTime ?? DateTime.now().add(const Duration(days: 1)),
                  title: '電話連絡日時の設定',
                ),
              );
              if (result != null) onPreConfirmationDateTimeChanged(result);
            },
            isCompact: true,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAccordionHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: _choiceChip(
              context, 
              '受電番号', 
              preConfirmationPhoneType == 'この電話番号', 
              (v) => onPreConfirmationPhoneTypeChanged('この電話番号'),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _choiceChip(
              context, 
              '指定番号', 
              preConfirmationPhoneType == '指定番号へ連絡', 
              (v) => onPreConfirmationPhoneTypeChanged('指定番号へ連絡'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSmsTimeDialog(BuildContext context) async {
    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) => KTimeSelectionDialog(
        initialDateTime: DateTime(2024, 1, 1, 
          int.parse(preConfirmationSmsTime.split(':')[0]), 
          int.parse(preConfirmationSmsTime.split(':')[1])
        ),
        title: 'SMS送信時間の変更',
      ),
    );
    if (result != null) {
      onPreConfirmationSmsTimeChanged(
        "${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}"
      );
    }
  }

  void _showPhoneDialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: rs(context, 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('電話番号の入力', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: Text(
                  preConfirmationPhoneController.text.isEmpty ? "番号を入力してください" : preConfirmationPhoneController.text,
                  style: TextStyle(
                    fontSize: rf(context, 24), 
                    fontWeight: FontWeight.bold, 
                    color: preConfirmationPhoneController.text.isEmpty ? Colors.grey : Colors.black87
                  ),
                ),
              ),
              const SizedBox(height: 24),
              KNumericDialPad(
                onInput: (digit) {
                  onPreConfirmationPhoneNumberChanged(preConfirmationPhoneController.text + digit);
                },
                onClear: () => onPreConfirmationPhoneNumberChanged(""),
                onBackspace: () {
                  if (preConfirmationPhoneController.text.isNotEmpty) {
                    onPreConfirmationPhoneNumberChanged(
                      preConfirmationPhoneController.text.substring(0, preConfirmationPhoneController.text.length - 1)
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: KButton(
                  label: '確定', 
                  onPressed: () => Navigator.pop(context),
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle(BuildContext context) {
    return TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700);
  }

  Widget _choiceChip(BuildContext context, String label, bool isSelected, Function(bool) onSelected, {bool enabled = true}) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold)),
        selected: isSelected,
        onSelected: enabled ? onSelected : null,
        selectedColor: Colors.deepPurple,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        visualDensity: VisualDensity.compact,
        showCheckmark: false,
      ),
    );
  }
}
