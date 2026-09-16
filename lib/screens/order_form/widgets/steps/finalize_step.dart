import 'package:flutter/material.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_choice_group.dart';
import '../../../../widgets/k_tile_selector.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_multimodal_text_field.dart';
import '../../../../widgets/k_shared_quantity_input.dart';
import '../../../../widgets/k_date_time_display.dart';
import '../../../../widgets/k_date_time_selection_dialog.dart';
import '../../../../widgets/k_numeric_input_dialog.dart';
import '../order_form_parts.dart';
import 'package:katura_system/utils/app_colors.dart';

class FinalizeStep extends StatelessWidget {
  final String branchName;
  final String paymentMethod;
  final String packagingType;
  final int packagingSmallQty;
  final TextEditingController packagingOtherController;
  final String preConfirmationMethod; // 事前連絡方法
  final String preConfirmationPhoneType;
  final String preConfirmationPhoneNumber;
  final TextEditingController preConfirmationPhoneController;
  final DateTime? preConfirmationDateTime;
  final String preConfirmationSmsTime;
  final DateTime? scheduledSmsDateTime; // 送信予定日時
  final String phoneDisplay; // 受電番号
  final String customerName;
  final String receiverName;
  final String deliveryType;
  final DateTime deliveryDate;
  final String deliveryTime;
  final String address;
  final List<Map<String, dynamic>> items;
  final int totalPrice;
  final DateTime? trashPickupDateTime;
  final String trashPickupLocationDetail;
  // 事前連絡の宛先（受取人と同じUIで選択、独立した値）
  final TextEditingController preConfirmationRecipientController;
  final List<String> recipientHistory;

  final Function(String) onPackagingTypeChanged;
  final Function(int) onPackagingSmallQtyChanged;
  final Function(String) onPaymentChanged;
  final Function(String) onPreConfirmationMethodChanged;
  final Function(String) onPreConfirmationPhoneTypeChanged;
  final Function(String) onPreConfirmationPhoneNumberChanged;
  final Function(DateTime) onPreConfirmationDateTimeChanged;
  final Function(DateTime) onScheduledSmsDateTimeChanged; // 追加
  final VoidCallback onSave;
  final VoidCallback onCancelOrder;
  final VoidCallback onShowReceipt; // 領収書確認
  final bool isEditingOrder; // 受注一覧の編集から遷移した場合 true

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
    this.scheduledSmsDateTime, // 追加
    required this.phoneDisplay,
    required this.customerName,
    required this.receiverName,
    required this.deliveryType,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.address,
    required this.items,
    required this.totalPrice,
    this.trashPickupDateTime,
    required this.trashPickupLocationDetail,
    required this.preConfirmationRecipientController,
    this.recipientHistory = const [],
    required this.onPackagingTypeChanged,
    required this.onPackagingSmallQtyChanged,
    required this.onPaymentChanged,
    required this.onPreConfirmationMethodChanged,
    required this.onPreConfirmationPhoneTypeChanged,
    required this.onPreConfirmationPhoneNumberChanged,
    required this.onPreConfirmationDateTimeChanged,
    required this.onScheduledSmsDateTimeChanged, // 追加
    required this.onSave,
    required this.onCancelOrder,
    required this.onShowReceipt,
    this.isEditingOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    return OrderFormCard(
      title: '梱包・支払・確認設定',
      icon: Icons.check_circle,
      trailing: PhoneReceivedBadge(phoneNumber: phoneDisplay),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 梱包
          _buildPackagingArea(context),

          SizedBox(height: rs(context, 12)),
          Divider(height: rs(context, 1)),
          SizedBox(height: rs(context, 12)),

          // 2. 事前連絡
          _buildAdvanceNotificationSection(context),

          SizedBox(height: rs(context, 12)),
          Divider(height: rs(context, 1)),
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
                KTileItem(label: 'カード', value: 'カード')
              ],
              onSelected: onPaymentChanged
            ),
            details: LayoutBuilder(
              builder: (context, c) {
                // 支払方法ボタン（KTileSelector: 3列・childAspectRatio 2.5）と同寸
                final tileW = (c.maxWidth - rs(context, 16)) / 3;
                final tileH = tileW / 2.5;
                return Row(
                  children: [
                    const Spacer(),
                    SizedBox(
                      width: tileW,
                      height: tileH,
                      child: KButton(
                        label: '領収書',
                        isSecondary: true,
                        color: Colors.blueGrey,
                        height: tileH,
                        fontSize: rf(context, 15),
                        onPressed: onShowReceipt,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          SizedBox(height: rs(context, 24)),
          Row(
            children: [
              Expanded(
                child: KButton(label: isEditingOrder ? '編集キャンセル' : '注文キャンセル', isSecondary: !isEditingOrder, color: isEditingOrder ? Colors.red : Colors.redAccent, onPressed: onCancelOrder),
              ),
              SizedBox(width: rs(context, 12)),
              Expanded(
                child: KButton(label: '受注を確定して保存する', color: Colors.deepOrange, onPressed: onSave),
              ),
            ],
          ),
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
        Text(label, style: _labelStyle(context)),
        SizedBox(height: rs(context, 6)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: buttons,
              ),
            ),
            SizedBox(width: rs(context, 16)),
            Expanded(
              flex: 50,
              child: details ?? const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPackagingArea(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('梱包方法', style: _labelStyle(context)),
        SizedBox(height: rs(context, 12)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: KChoiceGroup<String>(
                label: '',
                selectedValue: packagingType,
                items: [
                  KChoiceItem(label: '紙袋', value: '紙袋'),
                  KChoiceItem(label: '段ボール', value: '段ボール'),
                  KChoiceItem(label: '小分け', value: '小分け'),
                  KChoiceItem(label: 'その他', value: 'その他'),
                ],
                onSelected: onPackagingTypeChanged,
                showLabel: false,
              ),
            ),
            SizedBox(width: rs(context, 12)),
            Expanded(
              flex: 1,
              child: SizedBox(
                height: kFieldHeight(context),
                child: _buildPackagingDetailArea(context),
              ),
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
            SizedBox(width: rs(context, 4)),
            KSharedQuantityInput(
              value: packagingSmallQty,
              onChanged: onPackagingSmallQtyChanged,
              title: '小分け数量',
              width: rs(context, 60),
              height: kFieldHeight(context),
            ),
            SizedBox(width: rs(context, 4)),
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
          height: kFieldHeight(context),
          maxLines: 1,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildAdvanceNotificationSection(BuildContext context) {
    final bool isSms = preConfirmationMethod == 'SMS';
    final bool isPhone = preConfirmationMethod == '電話';
    final bool isNumberSelf = preConfirmationPhoneType == 'この電話番号';
    final bool isNumberOther = preConfirmationPhoneType == '指定番号へ連絡';
    // 事前連絡の「ご本人」は受取人ではなく顧客本人（注文者）を指す
    final String selfName = customerName.isNotEmpty ? customerName : receiverName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('事前連絡', style: _labelStyle(context)),
        SizedBox(height: rs(context, 10)),

        // ① 連絡先番号：受電番号 / 指定番号 / 番号フィールド を同じROWに
        Text('連絡先番号', style: _subLabelStyle(context)),
        SizedBox(height: rs(context, 6)),
        Row(
          children: [
            Expanded(flex: 3, child: _choiceCard(context, selected: isNumberSelf, label: '受電番号', onTap: () => onPreConfirmationPhoneTypeChanged('この電話番号'))),
            SizedBox(width: rs(context, 8)),
            Expanded(flex: 3, child: _choiceCard(context, selected: isNumberOther, label: '指定番号', onTap: () => onPreConfirmationPhoneTypeChanged('指定番号へ連絡'))),
            SizedBox(width: rs(context, 8)),
            Expanded(
              flex: 5,
              child: isNumberSelf
                  ? _numberField(context, phoneDisplay.isEmpty ? '受電番号なし' : phoneDisplay, phoneDisplay.isNotEmpty)
                  : InkWell(
                      onTap: () => _showPhoneDialDialog(context),
                      child: _numberField(context, preConfirmationPhoneNumber.isEmpty ? '電話番号を入力' : preConfirmationPhoneNumber, preConfirmationPhoneNumber.isNotEmpty),
                    ),
            ),
          ],
        ),

        SizedBox(height: rs(context, 12)),

        // ② 連絡方法：SMS / 電話連絡 / テキスト（送信予約 or 連絡希望日時）を同じROWに
        Text('連絡方法', style: _subLabelStyle(context)),
        SizedBox(height: rs(context, 6)),
        SizedBox(
          height: rs(context, 44),
          child: Row(
            children: [
              Expanded(flex: 3, child: _choiceCard(context, selected: isSms, label: 'SMS', onTap: () => onPreConfirmationMethodChanged('SMS'))),
              SizedBox(width: rs(context, 8)),
              Expanded(flex: 3, child: _choiceCard(context, selected: isPhone, label: '電話連絡', onTap: () => onPreConfirmationMethodChanged('電話'))),
              SizedBox(width: rs(context, 8)),
              Expanded(flex: 5, child: isSms ? _smsScheduleRow(context) : _buildDateTimeRow(context)),
            ],
          ),
        ),

        SizedBox(height: rs(context, 12)),

        // ③ 連絡の宛先：ご本人（顧客名）/ 履歴 / 受取人（受取人名）
        Text('連絡の宛先', style: _subLabelStyle(context)),
        SizedBox(height: rs(context, 6)),
        _RecipientSelector(
          controller: preConfirmationRecipientController,
          selfName: selfName,
          receiverName: receiverName,
          history: recipientHistory,
        ),
      ],
    );
  }

  Widget _smsScheduleRow(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.info_outline, size: rs(context, 14), color: Colors.blue),
        SizedBox(width: rs(context, 4)),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(fontSize: rf(context, 13), color: Colors.blue.shade800, fontWeight: FontWeight.bold),
              children: scheduledSmsDateTime != null
                  ? [
                      TextSpan(
                        text: '${scheduledSmsDateTime!.month}月${scheduledSmsDateTime!.day}日 ${scheduledSmsDateTime!.hour}:${scheduledSmsDateTime!.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' 送信予約'),
                    ]
                  : [
                      TextSpan(
                        text: '前日 $preConfirmationSmsTime',
                        style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' 自動送信'),
                    ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _numberField(BuildContext context, String text, bool filled) {
    return Container(
      height: rs(context, 44),
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: rs(context, 12)),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(rs(context, 8)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          style: TextStyle(
            fontSize: filled ? rf(context, 24) : rf(context, 13),
            color: filled ? Colors.black87 : Colors.grey.shade400,
            fontWeight: filled ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _choiceCard(BuildContext context, {required bool selected, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rs(context, 10)),
      child: Container(
        height: rs(context, 44),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.onButton : AppColors.offButton,
          borderRadius: BorderRadius.circular(rs(context, 10)),
          border: Border.all(color: selected ? AppColors.onButton : Colors.grey.shade300, width: selected ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: rs(context, 18), color: selected ? AppColors.onButtonText : Colors.grey),
            SizedBox(width: rs(context, 6)),
            Text(label,
                style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: selected ? AppColors.onButtonText : AppColors.offButtonText)),
          ],
        ),
      ),
    );
  }

  TextStyle _subLabelStyle(BuildContext context) =>
      TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade600);

  Widget _buildDateTimeRow(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.event, size: rs(context, 18), color: Colors.blueGrey),
        SizedBox(width: rs(context, 8)),
        Expanded(
          child: KDateTimeDisplay(
            label: '',
            dateTime: preConfirmationDateTime,
            emptyText: '連絡希望日時を設定',
            onTap: () async {
              final result = await showDialog<DateTime>(
                context: context,
                builder: (context) => KDateTimeSelectionDialog(
                  initialDateTime: preConfirmationDateTime ?? DateTime.now().add(const Duration(days: 1)),
                  title: '電話連絡日時の設定',
                ),
              );
              if (result != null) {
                onPreConfirmationDateTimeChanged(result);
              }
            },
            isCompact: true,
            height: rs(context, 40),
            fillColor: AppColors.background,
          ),
        ),
      ],
    );
  }

  void _showPhoneDialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => KNumericInputDialog(
        title: '電話番号の入力',
        initialValue: preConfirmationPhoneController.text,
        emptyHint: '番号を入力してください',
        themeColor: Colors.deepPurple,
        onConfirmed: onPreConfirmationPhoneNumberChanged,
      ),
    );
  }

  TextStyle _labelStyle(BuildContext context) {
    return TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700);
  }
}

/// 事前連絡の宛先セレクタ。受取人の選択UI（ご本人様／履歴から選択／新規追加）と同じ。
class _RecipientSelector extends StatefulWidget {
  final TextEditingController controller;
  final String selfName;
  final String receiverName;
  final List<String> history;

  const _RecipientSelector({
    required this.controller,
    required this.selfName,
    required this.receiverName,
    required this.history,
  });

  @override
  State<_RecipientSelector> createState() => _RecipientSelectorState();
}

class _RecipientSelectorState extends State<_RecipientSelector> {
  late String _mode;

  @override
  void initState() {
    super.initState();
    // デフォルトはご本人（顧客名）
    if (widget.controller.text.isEmpty && widget.selfName.isNotEmpty) {
      widget.controller.text = widget.selfName;
      _mode = 'ご本人様';
    } else if (widget.controller.text == widget.selfName) {
      _mode = 'ご本人様';
    } else if (widget.receiverName.isNotEmpty && widget.controller.text == widget.receiverName) {
      _mode = '受取人';
    } else if (widget.history.contains(widget.controller.text)) {
      _mode = '履歴から選択';
    } else {
      _mode = 'ご本人様';
    }
  }

  void _selectMode(String mode) {
    setState(() => _mode = mode);
    if (mode == 'ご本人様') {
      widget.controller.text = widget.selfName;
    } else if (mode == '受取人') {
      widget.controller.text = widget.receiverName;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ご本人 / 履歴 / 受取人 / 表示欄 をすべて同じROWに配置
    return Row(
      children: [
        Expanded(flex: 2, child: _modeBtn(context, 'ご本人様', 'ご本人')),
        SizedBox(width: rs(context, 6)),
        Expanded(flex: 2, child: _modeBtn(context, '履歴から選択', '履歴')),
        SizedBox(width: rs(context, 6)),
        Expanded(flex: 2, child: _modeBtn(context, '受取人', '受取人')),
        SizedBox(width: rs(context, 6)),
        Expanded(flex: 5, child: _buildInput(context)),
      ],
    );
  }

  Widget _modeBtn(BuildContext context, String mode, String label) {
    final sel = _mode == mode;
    return InkWell(
      onTap: () => _selectMode(mode),
      borderRadius: BorderRadius.circular(rs(context, 10)),
      child: Container(
        height: rs(context, 44),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sel ? Colors.deepPurple.shade50 : AppColors.background,
          borderRadius: BorderRadius.circular(rs(context, 10)),
          border: Border.all(color: sel ? Colors.deepPurple : Colors.grey.shade300, width: sel ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(sel ? Icons.check_circle : Icons.radio_button_unchecked,
                size: rs(context, 15), color: sel ? Colors.deepPurple : Colors.grey),
            SizedBox(width: rs(context, 3)),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: sel ? Colors.deepPurple.shade900 : Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    if (_mode == '履歴から選択') {
      final list = widget.history.where((n) => n.isNotEmpty && n != widget.selfName).toList();
      return SizedBox(
        height: rs(context, 44),
        child: list.isEmpty
            ? Align(
                alignment: Alignment.centerLeft,
                child: Text('履歴なし', style: TextStyle(color: Colors.grey, fontSize: rf(context, 13), fontWeight: FontWeight.bold)),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: list.map((name) {
                    final sel = widget.controller.text == name;
                    return Padding(
                      padding: EdgeInsets.only(right: rs(context, 6)),
                      child: ActionChip(
                        label: Text(name, style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold)),
                        labelPadding: EdgeInsets.symmetric(horizontal: rs(context, 6)),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() => widget.controller.text = name),
                        backgroundColor: sel ? Colors.deepPurple.shade100 : Colors.deepPurple.shade50,
                        side: BorderSide(color: sel ? Colors.deepPurple : Colors.deepPurple.shade100),
                      ),
                    );
                  }).toList(),
                ),
              ),
      );
    }

    // ご本人様（顧客名）／受取人（受取人名）はともに読み取り専用表示
    final String shown = _mode == '受取人'
        ? (widget.receiverName.isEmpty ? '未設定' : widget.receiverName)
        : (widget.selfName.isEmpty ? '未設定' : widget.selfName);
    return Container(
      width: double.infinity,
      height: rs(context, 44),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: rs(context, 12)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(rs(context, 8)),
      ),
      child: Text(
        shown,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}
