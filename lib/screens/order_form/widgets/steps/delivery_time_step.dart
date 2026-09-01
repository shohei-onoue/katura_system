import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/customer_model.dart';
import '../../../../widgets/k_choice_group.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_date_time_selection_dialog.dart';
import '../../../../widgets/k_multimodal_text_field.dart';
import '../order_form_parts.dart';

class DeliveryTimeStep extends StatefulWidget {
  final DateTime deliveryDate;
  final String deliveryType;
  final DateTime selectedTime;
  final TimeOfDay timeMin;
  final TimeOfDay timeMax;
  final int timeInterval;
  final bool isDateSelected;
  final bool isTimeSelected;
  final bool isTypeSelected;
  final TextEditingController receiverController;
  final Customer? currentCustomer;
  final String customerName;
  final String facilityName;

  final String orderSource;
  final TextEditingController orderSourceOtherController;
  final Function(String) onOrderSourceChanged;

  final bool trashPickupRequested;
  final DateTime? trashPickupDateTime;
  final String trashPickupLocation;
  final TextEditingController trashPickupLocationController;
  
  final TimeOfDay trashTimeMin;
  final TimeOfDay trashTimeMax;
  final int trashTimeInterval;

  final Function(bool) onTrashPickupRequestedChanged;
  final Function(DateTime) onTrashPickupDateTimeChanged;
  final Function(String) onTrashPickupLocationChanged;

  final Function(DateTime) onDateSelected;
  final Function(String) onTypeSelected;
  final Function(DateTime) onTimeSelected;
  final Function(TimeOfDay, TimeOfDay, int) onTimeSettingsChanged;
  final Function(TimeOfDay, TimeOfDay, int) onTrashTimeSettingsChanged;
  final VoidCallback onNext;
  final VoidCallback onCancelOrder;
  final String phoneNumberText;

  const DeliveryTimeStep({
    super.key,
    required this.deliveryDate,
    required this.deliveryType,
    required this.selectedTime,
    required this.timeMin,
    required this.timeMax,
    required this.timeInterval,
    required this.isDateSelected,
    required this.isTimeSelected,
    required this.isTypeSelected,
    required this.receiverController,
    required this.currentCustomer,
    required this.customerName,
    required this.facilityName,
    required this.orderSource,
    required this.orderSourceOtherController,
    required this.onOrderSourceChanged,
    required this.trashPickupRequested,
    required this.trashPickupDateTime,
    required this.trashPickupLocation,
    required this.trashPickupLocationController,
    required this.trashTimeMin,
    required this.trashTimeMax,
    required this.trashTimeInterval,
    required this.onTrashPickupRequestedChanged,
    required this.onTrashPickupDateTimeChanged,
    required this.onTrashPickupLocationChanged,
    required this.onDateSelected,
    required this.onTypeSelected,
    required this.onTimeSelected,
    required this.onTimeSettingsChanged,
    required this.onTrashTimeSettingsChanged,
    required this.onNext,
    required this.onCancelOrder,
    this.phoneNumberText = '',
  });

  @override
  State<DeliveryTimeStep> createState() => _DeliveryTimeStepState();
}

class _DeliveryTimeStepState extends State<DeliveryTimeStep> {
  String _receiverMode = 'ご本人様'; 

  @override
  void initState() {
    super.initState();
    final String effectiveName = widget.currentCustomer?.name ?? widget.customerName;

    // 受取人が現在の顧客名と一致している場合、あるいは空の場合に「ご本人様」モードにする
    if (effectiveName.isNotEmpty && (widget.receiverController.text == effectiveName || widget.receiverController.text.isEmpty)) {
      widget.receiverController.text = effectiveName;
      _receiverMode = 'ご本人様';
    } else if (widget.receiverController.text.isNotEmpty) {
      _receiverMode = '新規追加';
    } else {
      // フォールバック
      _receiverMode = 'ご本人様';
    }
  }

  bool get _isAllValid {
    return widget.isDateSelected && 
           widget.isTimeSelected && 
           widget.isTypeSelected && 
           widget.receiverController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return OrderFormCard(
      title: '配達日時・受取人の詳細設定',
      icon: Icons.timer,
      trailing: PhoneReceivedBadge(phoneNumber: widget.phoneNumberText),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 受注区分（デリカ・結膳・直取・その他）＋ 配達日時
            _buildSectionHeader('① 受注区分'),
            _buildOrderSourceRow(context),
            if (widget.orderSource == 'その他') ...[
              SizedBox(height: rs(context, 10)),
              KMultimodalTextField(
                label: '',
                hintText: '受注区分（詳細）を入力',
                showLabel: false,
                controller: widget.orderSourceOtherController,
                height: rs(context, 50),
                maxLines: 1,
              ),
            ],
            SizedBox(height: rs(context, 10)),

            // 2. ゴミ回収の日時
            _buildSectionHeader('② ゴミ回収の日時'),
            SizedBox(
              height: rs(context, 50),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: KChoiceGroup<bool>(
                      label: '',
                      selectedValue: widget.trashPickupRequested,
                      items: [
                        KChoiceItem(label: 'なし', value: false),
                        KChoiceItem(label: 'あり', value: true),
                      ],
                      onSelected: (val) {
                        widget.onTrashPickupRequestedChanged(val);
                      },
                      showLabel: false,
                      selectedColor: Colors.orange,
                    ),
                  ),
                  SizedBox(width: rs(context, 12)),
                  Expanded(
                    flex: 6,
                    child: widget.trashPickupRequested ? _buildDateTimeDisplayField(
                      context,
                      widget.trashPickupDateTime ?? widget.deliveryDate,
                      widget.trashPickupDateTime ?? widget.deliveryDate,
                      widget.trashPickupDateTime != null,
                      widget.trashPickupDateTime != null,
                      () => _showDateTimeDialog(context, isTrash: true),
                    ) : Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: rs(context, 50),
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.transparent), // Align with fields
                            ),
                            child: Text(
                              'ゴミ回収なし',
                              style: TextStyle(
                                fontSize: rf(context, 14), 
                                fontWeight: FontWeight.bold, 
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: rs(context, 8)), // Keep consistent spacing
                        SizedBox(width: rs(context, 32)), 
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: rs(context, 10)),
            _buildTrashLocationArea(context),
            SizedBox(height: rs(context, 10)),

            // 3. 受取人の選択
            _buildSectionHeader('③ 受取人の選択'),
            _buildReceiverArea(context),

            SizedBox(height: rs(context, 20)),
            Row(
              children: [
                Expanded(
                  child: KButton(label: '注文キャンセル', isSecondary: true, color: Colors.redAccent, onPressed: widget.onCancelOrder),
                ),
                SizedBox(width: rs(context, 12)),
                Expanded(
                  child: KButton(
                    label: '注文商品の選択へ',
                    onPressed: _isAllValid ? widget.onNext : () {},
                    color: _isAllValid ? Colors.deepPurple : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(
            fontSize: rf(context, 15), 
            fontWeight: FontWeight.bold, 
            color: Colors.blueGrey.shade800,
          )),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildDateTimeDisplayField(
    BuildContext context,
    DateTime date,
    DateTime time,
    bool isDateSelected,
    bool isTimeSelected,
    VoidCallback onTap,
  ) {
    final String dateText = isDateSelected ? DateFormat('yyyy年M月d日').format(date) : "未設定";
    final String timeText = isTimeSelected ? "${time.hour}:${time.minute.toString().padLeft(2, '0')}" : "未設定";

    return Container(
      height: rs(context, 50),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(rs(context, 8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(rs(context, 8))),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
                child: Row(
                  children: [
                    Text(
                      "日付：$dateText",
                      style: TextStyle(
                        fontSize: rf(context, 14), 
                        fontWeight: FontWeight.bold, 
                        color: isDateSelected ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    SizedBox(width: rs(context, 24)),
                    Text(
                      "時間：$timeText",
                      style: TextStyle(
                        fontSize: rf(context, 14), 
                        fontWeight: FontWeight.bold, 
                        color: isTimeSelected ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDateTimeDialog(BuildContext context, {required bool isTrash}) async {
    final DateTime initial = isTrash 
        ? (widget.trashPickupDateTime ?? widget.deliveryDate) 
        : widget.selectedTime;

    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) => KDateTimeSelectionDialog(
        initialDateTime: initial,
        minTime: isTrash ? widget.trashTimeMin : widget.timeMin,
        maxTime: isTrash ? widget.trashTimeMax : widget.timeMax,
        interval: isTrash ? widget.trashTimeInterval : widget.timeInterval,
        title: isTrash ? 'ゴミ回収日時の設定' : '配達日時の設定',
        themeColor: isTrash ? Colors.orange : const Color(0xFF000038),
        highlightDate: isTrash ? widget.deliveryDate : null,
      ),
    );

    if (result != null) {
      if (isTrash) {
        widget.onTrashPickupDateTimeChanged(result);
      } else {
        widget.onDateSelected(result);
        widget.onTimeSelected(result);
      }
    }
  }

  Widget _buildTrashLocationArea(BuildContext context) {
    final bool enabled = widget.trashPickupRequested;
    // 「指定場所」ボタン（KChoiceGroup）と入力フィールドの高さを揃えるための共通値。
    // ここを変更すると両者の高さが同時に調整される。
    final double locationFieldHeight = kFieldHeight(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: rs(context, 10)),
          child: Text(
            '■ 回収場所', 
            style: TextStyle(
              fontSize: rf(context, 15), 
              fontWeight: FontWeight.bold, 
              color: enabled ? Colors.blueGrey.shade800 : Colors.grey,
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: SizedBox(
                height: locationFieldHeight,
                child: KChoiceGroup<String>(
                  label: '',
                  selectedValue: widget.trashPickupLocation,
                  items: [
                    KChoiceItem(label: '引渡し場所', value: '引渡し場所'),
                    KChoiceItem(label: '指定場所', value: '指定場所'),
                  ],
                  onSelected: widget.onTrashPickupLocationChanged,
                  showLabel: false,
                  selectedColor: Colors.orange,
                  enabled: enabled,
                ),
              ),
            ),
            SizedBox(width: rs(context, 12)),
            Expanded(
              flex: 6,
              child: SizedBox(
                height: locationFieldHeight,
                child: (widget.trashPickupLocation == '指定場所' && enabled)
                    ? KMultimodalTextField(
                        label: '詳細',
                        controller: widget.trashPickupLocationController,
                        maxLines: 1,
                        height: locationFieldHeight,
                        showLabel: false,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReceiverArea(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReceiverModeToggle(context),
        SizedBox(height: rs(context, 12)),
        _buildReceiverInputArea(context),
      ],
    );
  }

  Widget _buildReceiverModeToggle(BuildContext context) {
    return Container(
      height: rs(context, 50),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(rs(context, 8)),
      ),
      child: Row(
        children: ['ご本人様', '履歴から選択', '新規追加'].map((mode) {
          final isSelected = _receiverMode == mode;
          return Expanded(
            child: GestureDetector(
            onTap: () {
                setState(() => _receiverMode = mode);
                if (mode == 'ご本人様') {
                  final String effectiveName = widget.currentCustomer?.name ?? widget.customerName;
                  if (effectiveName.isNotEmpty) {
                    widget.receiverController.text = effectiveName;
                  }
                } else if (mode == '新規追加') {
                  widget.receiverController.clear();
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(rs(context, 8)),
                ),
                child: Text(
                  mode,
                  style: TextStyle(
                    fontSize: KR.fontSmall(context),
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.blueGrey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReceiverInputArea(BuildContext context) {
    if (_receiverMode == '履歴から選択') {
      final allReceivers = widget.currentCustomer?.facilityReceivers[widget.facilityName] ?? [];
      final filteredReceivers = allReceivers.where((name) => 
        widget.currentCustomer == null || name != widget.currentCustomer!.name
      ).toList();

      if (filteredReceivers.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: rs(context, 12.0), horizontal: rs(context, 8.0)),
          child: Text('履歴なし', style: TextStyle(color: Colors.grey, fontSize: rf(context, 13), fontWeight: FontWeight.bold)),
        );
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filteredReceivers.map((name) => ActionChip(
          label: Text(name, style: TextStyle(fontSize: KR.fontLarge(context), fontWeight: FontWeight.bold)),
          labelPadding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 4)),
          onPressed: () {
            widget.receiverController.text = name;
          },
          backgroundColor: Colors.deepPurple.shade50,
          side: BorderSide(color: Colors.deepPurple.shade100),
        )).toList(),
      );
    }

    if (_receiverMode == '新規追加') {
      return KMultimodalTextField(
        label: '',
        controller: widget.receiverController,
        maxLines: 1,
        height: kFieldHeight(context),
        showLabel: false,
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 12)),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(rs(context, 8)),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.blue, size: rs(context, 18)),
          SizedBox(width: rs(context, 8)),
          Expanded(
            child: Text('受取人：${widget.receiverController.text}', 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: rf(context, 14))),
          ),
        ],
      ),
    );
  }

  /// 受注区分の選択に応じて配送・引取区分(deliveryType)を自動的に決定する。
  /// 「直取」＝引取、それ以外（デリカ・結膳・その他）＝配送。
  void _selectOrderSource(String source) {
    widget.onOrderSourceChanged(source);
    widget.onTypeSelected(source == '直取' ? '引取' : '配送');
  }

  /// 受注区分の選択ボタンと配達日時の入力フィールドを同じRowに配置する。
  /// ボタンサイズは②ゴミ回収の日時項目（KChoiceGroup）と同一にする。
  Widget _buildOrderSourceRow(BuildContext context) {
    return SizedBox(
      height: rs(context, 50),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: KChoiceGroup<String>(
              label: '',
              selectedValue: widget.orderSource,
              items: [
                KChoiceItem(label: 'デリカ', value: 'デリカ'),
                KChoiceItem(label: '結膳', value: '結膳'),
                KChoiceItem(label: '直取', value: '直取'),
                KChoiceItem(label: 'その他', value: 'その他'),
              ],
              onSelected: _selectOrderSource,
              showLabel: false,
              selectedColor: Colors.deepPurple,
            ),
          ),
          SizedBox(width: rs(context, 12)),
          Expanded(
            flex: 6,
            child: _buildDateTimeDisplayField(
              context,
              widget.deliveryDate,
              widget.selectedTime,
              widget.isDateSelected,
              widget.isTimeSelected,
              () => _showDateTimeDialog(context, isTrash: false),
            ),
          ),
        ],
      ),
    );
  }
}

