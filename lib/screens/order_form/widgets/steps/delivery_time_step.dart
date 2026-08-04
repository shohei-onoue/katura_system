import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../models/customer_model.dart';
import '../../../../widgets/k_choice_group.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_multimodal_text_field.dart';
import '../../../../widgets/k_dial_pad.dart';
import '../order_form_parts.dart';

class DeliveryTimeStep extends StatefulWidget {
  final DateTime deliveryDate;
  final String deliveryType;
  final DateTime selectedTime;
  final TimeOfDay timeMin;
  final TimeOfDay timeMax;
  final int timeInterval;
  final TextEditingController receiverController;
  final Customer? currentCustomer;
  final String facilityName;
  final Function(DateTime) onDateSelected;
  final Function(String) onTypeSelected;
  final Function(DateTime) onTimeSelected;
  final Function(TimeOfDay, TimeOfDay, int) onTimeSettingsChanged;
  final VoidCallback onNext;

  const DeliveryTimeStep({
    super.key,
    required this.deliveryDate,
    required this.deliveryType,
    required this.selectedTime,
    required this.timeMin,
    required this.timeMax,
    required this.timeInterval,
    required this.receiverController,
    required this.currentCustomer,
    required this.facilityName,
    required this.onDateSelected,
    required this.onTypeSelected,
    required this.onTimeSelected,
    required this.onTimeSettingsChanged,
    required this.onNext,
  });

  @override
  State<DeliveryTimeStep> createState() => _DeliveryTimeStepState();
}

class _DeliveryTimeStepState extends State<DeliveryTimeStep> {
  String _receiverMode = 'ご本人様'; // 'ご本人様', '履歴', 'その他'

  @override
  void initState() {
    super.initState();
    // 初期値の判定
    if (widget.currentCustomer != null && widget.receiverController.text == widget.currentCustomer!.name) {
      _receiverMode = 'ご本人様';
    } else if (widget.receiverController.text.isNotEmpty) {
      _receiverMode = 'その他';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> slots = [];
    final int interval = widget.timeInterval > 0 ? widget.timeInterval : 15;
    final startMinutes = widget.timeMin.hour * 60 + widget.timeMin.minute;
    final endMinutes = widget.timeMax.hour * 60 + widget.timeMax.minute;
    
    int currentM = startMinutes;
    while (currentM <= endMinutes) {
      slots.add(DateTime(widget.deliveryDate.year, widget.deliveryDate.month, widget.deliveryDate.day, currentM ~/ 60, currentM % 60));
      currentM += interval;
    }
    if (slots.isEmpty) slots.add(DateTime(widget.deliveryDate.year, widget.deliveryDate.month, widget.deliveryDate.day, 12, 0));

    int initialIndex = slots.indexWhere((dt) => dt.hour == widget.selectedTime.hour && dt.minute == widget.selectedTime.minute);
    if (initialIndex == -1) initialIndex = 0;

    return OrderFormCard(
      title: '配達日時・受取人の詳細設定',
      icon: Icons.timer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左側: 区分とカレンダー (40%)
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('配達・引取区分', style: _sectionTitleStyle(context)),
                SizedBox(height: rs(context, 8)),
                SizedBox(
                  height: rs(context, 44),
                  child: KChoiceGroup(
                    label: '', 
                    selectedValue: widget.deliveryType, 
                    items: [
                      KChoiceItem(label: '配送', value: '配送'), 
                      KChoiceItem(label: '引取', value: '引取')
                    ], 
                    onSelected: widget.onTypeSelected,
                    showLabel: false,
                  ),
                ),
                SizedBox(height: rs(context, 24)),
                Text('配達日を選択', style: _sectionTitleStyle(context)),
                SizedBox(height: rs(context, 8)),
                _buildCalendar(context),
              ],
            ),
          ),
          
          SizedBox(width: rs(context, 32)),
          VerticalDivider(width: 1, color: Colors.grey.shade200),
          SizedBox(width: rs(context, 32)),

          // 右側: 時間と受取人 (60%)
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 時間選択
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('希望時間（ドラム選択）', style: _sectionTitleStyle(context)),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.deepPurple),
                      onPressed: () => _showTimeSettingsDialog(context),
                    ),
                  ],
                ),
                Container(
                  height: rs(context, 140),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: initialIndex),
                    itemExtent: rs(context, 40),
                    onSelectedItemChanged: (index) {
                      if (index >= 0 && index < slots.length) widget.onTimeSelected(slots[index]);
                    },
                    children: slots.map((dt) => Center(
                      child: Text(
                        "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold),
                      ),
                    )).toList(),
                  ),
                ),
                
                SizedBox(height: rs(context, 32)),
                
                // 受取人選択
                Text('受取人の選択', style: _sectionTitleStyle(context)),
                SizedBox(height: rs(context, 12)),
                _buildReceiverModeToggle(context),
                
                SizedBox(height: rs(context, 20)),
                _buildReceiverInputArea(context),
                
                const SizedBox(height: 64),
                KButton(label: '注文商品の選択へ', onPressed: widget.onNext, color: Colors.deepPurple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _sectionTitleStyle(BuildContext context) {
    return TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700);
  }

  Widget _buildCalendar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 30)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: widget.deliveryDate,
        currentDay: DateTime.now(),
        locale: 'ja_JP',
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          selectedDecoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
          outsideDaysVisible: false,
        ),
        selectedDayPredicate: (day) => isSameDay(widget.deliveryDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          widget.onDateSelected(selectedDay);
        },
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekendStyle: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildReceiverModeToggle(BuildContext context) {
    return Container(
      height: rs(context, 44),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: ['ご本人様', '履歴から選択', 'その他'].map((mode) {
          final isSelected = _receiverMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _receiverMode = mode);
                if (mode == 'ご本人様' && widget.currentCustomer != null) {
                  widget.receiverController.text = widget.currentCustomer!.name;
                } else if (mode == '履歴から選択') {
                  // 履歴から選ぶまでは一旦空にするか現状維持
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mode,
                  style: TextStyle(
                    fontSize: rf(context, 12),
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
      final receivers = widget.currentCustomer?.facilityReceivers[widget.facilityName] ?? [];
      if (receivers.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('履歴がありません', style: TextStyle(color: Colors.grey, fontSize: 12)),
        );
      }
      return Wrap(
        spacing: 8,
        children: receivers.map((name) => ActionChip(
          label: Text(name, style: const TextStyle(fontSize: 12)),
          onPressed: () {
            widget.receiverController.text = name;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('「$name」を選択しました'), duration: const Duration(seconds: 1)));
          },
          backgroundColor: Colors.deepPurple.shade50,
        )).toList(),
      );
    }

    // 'ご本人様' または 'その他' の場合は入力フィールド（その他はペンタブ有効）
    return KMultimodalTextField(
      label: '',
      controller: widget.receiverController,
      icon: Icons.person_outline,
      maxLines: 1,
    );
  }

  void _showTimeSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _TimeSettingsCustomDialog(
        initialMin: widget.timeMin,
        initialMax: widget.timeMax,
        initialInterval: widget.timeInterval,
        onSave: widget.onTimeSettingsChanged,
      ),
    );
  }
}

class _TimeSettingsCustomDialog extends StatefulWidget {
  final TimeOfDay initialMin;
  final TimeOfDay initialMax;
  final int initialInterval;
  final Function(TimeOfDay, TimeOfDay, int) onSave;

  const _TimeSettingsCustomDialog({
    required this.initialMin,
    required this.initialMax,
    required this.initialInterval,
    required this.onSave,
  });

  @override
  State<_TimeSettingsCustomDialog> createState() => _TimeSettingsCustomDialogState();
}

class _TimeSettingsCustomDialogState extends State<_TimeSettingsCustomDialog> {
  late String minStr;
  late String maxStr;
  late String intervalStr;
  int activeField = 0; // 0: 開始時間, 1: 終了時間, 2: 間隔

  @override
  void initState() {
    super.initState();
    minStr = _timeTo4Digit(widget.initialMin);
    maxStr = _timeTo4Digit(widget.initialMax);
    intervalStr = widget.initialInterval.toString();
  }

  String _timeTo4Digit(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}";
  }

  TimeOfDay? _parse4Digit(String s) {
    if (s.isEmpty) return null;
    final String padded = s.padLeft(4, '0');
    final h = int.tryParse(padded.substring(0, 2));
    final m = int.tryParse(padded.substring(2, 4));
    if (h == null || m == null || h >= 24 || m >= 60) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTimeDisplay(String s) {
    if (s.isEmpty) return "00:00";
    final String padded = s.padLeft(4, '0');
    return "${padded.substring(0, 2)}:${padded.substring(2)}";
  }

  void _handleKeyTap(String key) {
    setState(() {
      if (key == 'クリア') {
        if (activeField == 0) minStr = "";
        else if (activeField == 1) maxStr = "";
        else intervalStr = "";
        return;
      }

      String current = activeField == 0 ? minStr : (activeField == 1 ? maxStr : intervalStr);
      if (key == '⌫') {
        if (current.isNotEmpty) current = current.substring(0, current.length - 1);
      } else {
        final int limit = activeField == 2 ? 3 : 4;
        if (current.length < limit) current += key;
      }

      if (activeField == 0) minStr = current;
      else if (activeField == 1) maxStr = current;
      else intervalStr = current;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<KDialKey> dialKeys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      'クリア', '0', '⌫'
    ].map((k) {
      return KDialKey(
        label: k,
        onTap: () => _handleKeyTap(k),
        backgroundColor: k == 'クリア' ? Colors.red.shade50 : (k == '⌫' ? Colors.orange.shade50 : null),
        foregroundColor: k == 'クリア' ? Colors.red : (k == '⌫' ? Colors.orange.shade900 : null),
      );
    }).toList();

    return AlertDialog(
      title: const Text('時間選択のカスタマイズ', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: rs(context, 750),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 左側：項目垂直リスト
            Expanded(
              flex: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInputRow('開始時間', _formatTimeDisplay(minStr), activeField == 0, () => setState(() => activeField = 0)),
                  const SizedBox(height: 12),
                  _buildInputRow('終了時間', _formatTimeDisplay(maxStr), activeField == 1, () => setState(() => activeField = 1)),
                  const SizedBox(height: 12),
                  _buildInputRow('表示間隔', intervalStr.isEmpty ? "0分" : "$intervalStr分", activeField == 2, () => setState(() => activeField = 2)),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('※各項目をタップしてテンキーで入力してください', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 48),
            // 右側：テンキー
            SizedBox(
              width: rs(context, 280),
              child: KDialPad(keys: dialKeys),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
        ElevatedButton(
          onPressed: () {
            final minTime = _parse4Digit(minStr);
            final maxTime = _parse4Digit(maxStr);
            final int? intervalVal = int.tryParse(intervalStr);

            if (minTime == null || maxTime == null || intervalVal == null || intervalVal <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('入力内容が正しくありません')));
              return;
            }
            widget.onSave(minTime, maxTime, intervalVal);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
          child: const Text('反映する'),
        ),
      ],
    );
  }

  Widget _buildInputRow(String label, String value, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.deepPurple.shade50 : Colors.white,
          border: Border.all(color: isActive ? Colors.deepPurple : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: isActive ? Colors.deepPurple : Colors.blueGrey
            )),
            Text(value, style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.black87 : Colors.blueGrey.shade300
            )),
          ],
        ),
      ),
    );
  }
}
