import 'package:flutter/material.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_pen_input_dialog.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_multimodal_text_field.dart';
import '../../../../widgets/k_shared_quantity_input.dart';
import '../../../../widgets/k_date_time_display.dart';
import '../../../../widgets/k_pre_contact_date_time_dialog.dart';
import '../../../../widgets/k_numeric_input_dialog.dart';
import '../order_form_parts.dart';
import 'package:katura_system/utils/app_colors.dart';

class FinalizeStep extends StatelessWidget {
  final String branchName;
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
  // 書類（複数選択）と支払い方法
  final Set<String> selectedDocuments;
  final String paymentMethod;
  final ValueChanged<String> onDocumentToggled;
  final ValueChanged<String> onPaymentMethodChanged;

  final Function(String) onPackagingTypeChanged;
  final Function(int) onPackagingSmallQtyChanged;
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
    required this.selectedDocuments,
    required this.paymentMethod,
    required this.onDocumentToggled,
    required this.onPaymentMethodChanged,
    required this.onPackagingTypeChanged,
    required this.onPackagingSmallQtyChanged,
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
      title: '梱包・確認設定',
      icon: Icons.check_circle,
      trailing: PhoneReceivedBadge(phoneNumber: phoneDisplay),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 梱包方法
          _buildPackagingArea(context),

          SizedBox(height: rs(context, 26)),
          Divider(height: rs(context, 1)),
          SizedBox(height: rs(context, 26)),

          // 2. 事前連絡
          _buildAdvanceNotificationSection(context),

          SizedBox(height: rs(context, 26)),
          Divider(height: rs(context, 1)),
          SizedBox(height: rs(context, 26)),

          // 3. 書類を選択（複数選択）／支払い方法
          _buildDocumentsArea(context),

          SizedBox(height: rs(context, 36)),
          Row(
            children: [
              Expanded(
                child: KButton(label: isEditingOrder ? '編集キャンセル' : '注文中止', color: AppColors.cancelButton, onPressed: onCancelOrder),
              ),
              SizedBox(width: rs(context, 12)),
              Expanded(
                child: KButton(label: '確定', color: AppColors.acceptButton, onPressed: onSave),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ラベルの横幅（全ラベル共通）。
  double _labelW(BuildContext context) => rs(context, 110);

  /// ラベルと、選択ボタンなどを同じ行に置く（ラベルのサイズは全画面で共通）。
  Widget _labeledRow(BuildContext context, String label, Widget child) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _labelW(context),
          height: rs(context, 44),
          child: Align(alignment: Alignment.centerLeft, child: Text(label, style: _labelStyle(context))),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildPackagingArea(BuildContext context) {
    // 表示名 → 保存する値
    const items = [
      ['個包装', '個包装'],
      ['紙袋', '紙袋'],
      ['ダンボール', '段ボール'],
      ['小分け', '小分け'],
      ['その他', 'その他'],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labeledRow(
          context,
          '梱包方法',
          Wrap(
            spacing: rs(context, 8),
            runSpacing: rs(context, 8),
            children: [
              for (int i = 0; i < items.length; i++)
                _choiceCard(context,
                    selected: packagingType == items[i][1], label: items[i][0], onTap: () => onPackagingTypeChanged(items[i][1])),
            ],
          ),
        ),
        if (packagingType == '小分け' || packagingType == 'その他') ...[
          SizedBox(height: rs(context, 8)),
          Padding(
            padding: EdgeInsets.only(left: _labelW(context)),
            child: SizedBox(height: kFieldHeight(context), child: _buildPackagingDetailArea(context)),
          ),
        ],
      ],
    );
  }

  Widget _buildPackagingDetailArea(BuildContext context) {
    if (packagingType == '小分け') {
      return Align(
        alignment: Alignment.centerLeft,
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
    final bool isNumberSelf = preConfirmationPhoneType == 'この電話番号';
    final bool isNumberOther = preConfirmationPhoneType == '指定番号へ連絡';
    // 事前連絡の「ご本人」は受取人ではなく顧客本人（注文者）を指す
    final String selfName = customerName.isNotEmpty ? customerName : receiverName;
    final linkStyle = TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 「受電番号」に「電話」で連絡する：ボタンを押すとメニューで選ぶ
        _labeledRow(
          context,
          '事前連絡',
          SizedBox(
            height: rs(context, 44),
            child: Row(
              children: [
                _menuButton(
                  context,
                  label: isNumberOther ? '指定番号' : '受電番号',
                  options: const ['受電番号', '指定番号'],
                  onSelected: (v) => onPreConfirmationPhoneTypeChanged(v == '指定番号' ? '指定番号へ連絡' : 'この電話番号'),
                ),
                SizedBox(width: rs(context, 10)),
                Text('に', style: linkStyle),
                SizedBox(width: rs(context, 10)),
                _menuButton(
                  context,
                  label: isSms ? 'SMS' : '電話',
                  options: const ['電話', 'SMS'],
                  onSelected: (v) => onPreConfirmationMethodChanged(v),
                ),
                SizedBox(width: rs(context, 10)),
                Text('で連絡する', style: linkStyle),
              ],
            ),
          ),
        ),
        SizedBox(height: rs(context, 14)),
        // 連絡先の番号／送信予約または連絡希望日時
        Padding(
          padding: EdgeInsets.only(left: _labelW(context)),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: rs(context, 44),
                  child: isNumberSelf
                      ? _numberField(context, phoneDisplay.isEmpty ? '受電番号なし' : phoneDisplay, phoneDisplay.isNotEmpty)
                      : InkWell(
                          onTap: () => _showPhoneDialDialog(context),
                          child: _numberField(context, preConfirmationPhoneNumber.isEmpty ? '電話番号を入力' : preConfirmationPhoneNumber, preConfirmationPhoneNumber.isNotEmpty),
                        ),
                ),
              ),
              SizedBox(width: rs(context, 8)),
              Expanded(child: SizedBox(height: rs(context, 44), child: isSms ? _smsScheduleRow(context) : _buildDateTimeRow(context))),
            ],
          ),
        ),

        SizedBox(height: rs(context, 22)),

        // 受取人の指定：ご本人（顧客名）／指定（ペン入力）
        _labeledRow(
          context,
          '受取人の指定',
          _RecipientSelector(
            controller: preConfirmationRecipientController,
            selfName: selfName,
          ),
        ),
      ],
    );
  }

  /// 書類（複数選択）と支払い方法。ラベルとボタンは同じ行に置く。
  Widget _buildDocumentsArea(BuildContext context) {
    const docs = ['領収書', '請求書', 'レシート', '納品書', '印字領収書'];
    const payments = ['現金', 'カード'];
    final double labelW = _labelW(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 書類を選択：ラベル／選択ボタン／プレビュー
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: labelW,
              height: rs(context, 44),
              child: Align(alignment: Alignment.centerLeft, child: Text('書類を選択', style: _labelStyle(context))),
            ),
            Expanded(
              child: Wrap(
                spacing: rs(context, 8),
                runSpacing: rs(context, 8),
                children: [
                  for (final d in docs)
                    _choiceCard(context, selected: selectedDocuments.contains(d), label: d, multi: true, onTap: () => onDocumentToggled(d)),
                ],
              ),
            ),
            SizedBox(width: rs(context, 8)),
            SizedBox(
              width: _btnW(context),
              height: rs(context, 44),
              child: TextButton(
                onPressed: onShowReceipt,
                style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: rs(context, 4))),
                child: FittedBox(fit: BoxFit.scaleDown, child: Text('領収書プレビュー', maxLines: 1, style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold))),
              ),
            ),
          ],
        ),
        SizedBox(height: rs(context, 26)),
        // 支払い方法：ラベル／選択ボタン
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: labelW,
              height: rs(context, 44),
              child: Align(alignment: Alignment.centerLeft, child: Text('支払い方法', style: _labelStyle(context))),
            ),
            Expanded(
              child: Wrap(
                spacing: rs(context, 8),
                runSpacing: rs(context, 8),
                children: [
                  for (final pm in payments)
                    _choiceCard(context, selected: paymentMethod == pm, label: pm, onTap: () => onPaymentMethodChanged(pm)),
                ],
              ),
            ),
          ],
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
        color: AppColors.mainBackground,
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

  /// 画面内のボタンの横幅：テキスト5文字分＋左右に4pxずつの隙間。
  double _btnW(BuildContext context) => rf(context, 14) * 5 + rs(context, 8);

  Widget _choiceCard(BuildContext context, {required bool selected, required String label, required VoidCallback onTap, bool multi = false}) {
    return SizedBox(
      width: _btnW(context),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(rs(context, 10)),
        child: Container(
          height: rs(context, 44),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: rs(context, 4)),
          decoration: BoxDecoration(
            color: selected ? AppColors.selectButton : AppColors.offButton,
            borderRadius: BorderRadius.circular(rs(context, 10)),
            border: selected ? null : Border.all(color: Colors.grey.shade300),
          ),
          // ボタンの中はテキストのみ（長い文字は縮小して収める）
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label,
                maxLines: 1,
                style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: selected ? AppColors.primaryText : AppColors.offButtonText)),
          ),
        ),
      ),
    );
  }

  /// タップでメニューを開いて選ぶボタン（テキストのみ）。
  Widget _menuButton(BuildContext context, {required String label, required List<String> options, required ValueChanged<String> onSelected}) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (_) => [for (final o in options) PopupMenuItem<String>(value: o, child: Text(o, style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.bold)))],
      child: Container(
        width: _btnW(context),
        height: rs(context, 44),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: rs(context, 4)),
        decoration: BoxDecoration(
          color: AppColors.offButton,
          borderRadius: BorderRadius.circular(rs(context, 10)),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, maxLines: 1, style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: AppColors.offButtonText)),
        ),
      ),
    );
  }

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
                builder: (context) => KPreContactDateTimeDialog(
                  initialDateTime: preConfirmationDateTime ??
                      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 15, 0),
                  title: '事前確認日',
                  deliveryDate: deliveryDate,
                ),
              );
              if (result != null) {
                onPreConfirmationDateTimeChanged(result);
              }
            },
            isCompact: true,
            height: rs(context, 40),
            fillColor: AppColors.mainBackground,
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
        themeColor: AppColors.accentPurple,
        onConfirmed: onPreConfirmationPhoneNumberChanged,
      ),
    );
  }

  TextStyle _labelStyle(BuildContext context) {
    return TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700);
  }
}

/// 受取人の指定。ご本人（顧客名）／指定（ペン入力で名前を書く）。
class _RecipientSelector extends StatefulWidget {
  final TextEditingController controller;
  final String selfName;

  const _RecipientSelector({
    required this.controller,
    required this.selfName,
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
    } else if (widget.controller.text.isNotEmpty) {
      _mode = '指定';
    } else {
      _mode = 'ご本人様';
    }
  }

  void _selectMode(String mode) {
    setState(() {
      _mode = mode;
      // ご本人＝顧客名／指定＝空欄にしてペン入力で書く
      widget.controller.text = mode == 'ご本人様' ? widget.selfName : '';
    });
  }

  Future<void> _inputByPen() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KPenInputDialog(
        initialText: widget.controller.text,
        onTextRecognized: (t) {
          if (mounted) setState(() => widget.controller.text = t.trim());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = rf(context, 14) * 5 + rs(context, 8);
    // ご本人 / 指定 / 名前の表示欄 をすべて同じROWに配置
    return Row(
      children: [
        SizedBox(width: w, child: _modeBtn(context, 'ご本人様', 'ご本人')),
        SizedBox(width: rs(context, 8)),
        SizedBox(width: w, child: _modeBtn(context, '指定', '指定')),
        SizedBox(width: rs(context, 8)),
        Expanded(child: _buildInput(context)),
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
          color: sel ? AppColors.selectButton : AppColors.mainBackground,
          borderRadius: BorderRadius.circular(rs(context, 10)),
          border: sel ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: sel ? AppColors.primaryText : Colors.black87)),
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    final bool isSpecified = _mode == '指定';
    final String shown = isSpecified ? widget.controller.text : (widget.selfName.isEmpty ? '未設定' : widget.selfName);
    final field = Container(
      width: double.infinity,
      height: rs(context, 44),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: rs(context, 12)),
      decoration: BoxDecoration(
        color: isSpecified ? AppColors.mainBackground : Colors.grey.shade50,
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
    // 指定のときだけ、タップでペン入力できる
    return isSpecified ? InkWell(onTap: _inputByPen, child: field) : field;
  }
}
