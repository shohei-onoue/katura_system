import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/customer_model.dart';
import '../../../../widgets/k_choice_group.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_date_time_selection_dialog.dart';
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
  final bool isDateSelected;
  final bool isTimeSelected;
  final bool isTypeSelected;
  final TextEditingController receiverController;
  final Customer? currentCustomer;
  final String facilityName;
  final String phoneDisplay;

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
    required this.facilityName,
    required this.phoneDisplay,
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
  });

  @override
  State<DeliveryTimeStep> createState() => _DeliveryTimeStepState();
}

class _DeliveryTimeStepState extends State<DeliveryTimeStep> {
  String _receiverMode = 'ご本人様'; 

  @override
  void initState() {
    super.initState();
    if (widget.currentCustomer != null && widget.receiverController.text == widget.currentCustomer!.name) {
      _receiverMode = 'ご本人様';
    } else if (widget.receiverController.text.isNotEmpty) {
      _receiverMode = '新規追加';
    } else {
      if (widget.currentCustomer != null) {
        widget.receiverController.text = widget.currentCustomer!.name;
        _receiverMode = 'ご本人様';
      }
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
      trailing: Text('受電: ${widget.phoneDisplay}', 
        style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 配達・引取り区分
            _buildSectionHeader('① 配達・引取り区分'),
            Row(
              children: [
                Expanded(
                  flex: 3,
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
                SizedBox(width: rs(context, 12)),
                Expanded(
                  flex: 7,
                  child: _buildDateTimeDisplayField(
                    context, 
                    widget.deliveryDate, 
                    widget.selectedTime, 
                    widget.isDateSelected,
                    widget.isTimeSelected,
                    Colors.deepPurple,
                    () => _showDateTimeDialog(context, isTrash: false),
                    () => _showSettingsCustomDialog(context, isTrash: false),
                  ),
                ),
              ],
            ),
            SizedBox(height: rs(context, 10)),

            // 2. ゴミ回収の日時
            _buildSectionHeader('② ゴミ回収の日時'),
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
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
                    flex: 7,
                    child: widget.trashPickupRequested ? _buildDateTimeDisplayField(
                      context, 
                      widget.trashPickupDateTime ?? widget.deliveryDate, 
                      widget.trashPickupDateTime ?? widget.deliveryDate, 
                      widget.trashPickupDateTime != null,
                      widget.trashPickupDateTime != null,
                      Colors.orange,
                      () => _showDateTimeDialog(context, isTrash: true),
                      () => _showSettingsCustomDialog(context, isTrash: true),
                    ) : Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
            Center(
              child: KButton(
                label: '注文商品の選択へ', 
                onPressed: _isAllValid ? widget.onNext : () {},
                color: _isAllValid ? Colors.deepPurple : Colors.grey,
              ),
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
    Color color,
    VoidCallback onTap,
    VoidCallback onSettingsPressed,
  ) {
    final String dateText = isDateSelected ? DateFormat('yyyy年M月d日').format(date) : "未設定";
    final String timeText = isTimeSelected ? "${time.hour}:${time.minute.toString().padLeft(2, '0')}" : "未設定";

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    SizedBox(width: 24),
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
          VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade200, indent: 8, endIndent: 8),
          IconButton(
            icon: Icon(Icons.settings, color: color, size: 20),
            onPressed: onSettingsPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40),
            splashRadius: 20,
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
        themeColor: isTrash ? Colors.orange : Colors.deepPurple,
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
              flex: 3,
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
            SizedBox(width: rs(context, 12)),
            Expanded(
              flex: 7,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: (widget.trashPickupLocation == '指定場所' && enabled)
                        ? KMultimodalTextField(
                            label: '詳細',
                            controller: widget.trashPickupLocationController,
                            maxLines: 1,
                            height: 44,
                            showLabel: false,
                            prefixText: '詳細：',
                          )
                        : const SizedBox(height: 44), // No label, so just field height
                  ),
                  SizedBox(width: rs(context, 8)),
                  SizedBox(width: rs(context, 12)),
                ],
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

  TextStyle _sectionTitleStyle(BuildContext context) {
    return TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade600);
  }

  Widget _buildReceiverModeToggle(BuildContext context) {
    return Container(
      height: rs(context, 44),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: ['ご本人様', '履歴から選択', '新規追加'].map((mode) {
          final isSelected = _receiverMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _receiverMode = mode);
                if (mode == 'ご本人様' && widget.currentCustomer != null) {
                  widget.receiverController.text = widget.currentCustomer!.name;
                } else if (mode == '新規追加') {
                  widget.receiverController.clear();
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
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Text('履歴なし', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
        );
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filteredReceivers.map((name) => ActionChip(
          label: Text(name, style: TextStyle(fontSize: KR.fontTiny(context), fontWeight: FontWeight.bold)),
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
        icon: Icons.person_add_alt_1_outlined,
        maxLines: 1,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.blue, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text('受取人：${widget.receiverController.text}', 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: rf(context, 14))),
          ),
        ],
      ),
    );
  }

  void _showSettingsCustomDialog(BuildContext context, {required bool isTrash}) {
    showDialog(
      context: context,
      builder: (context) => _TimeSettingsCustomDialog(
        initialMin: isTrash ? widget.trashTimeMin : widget.timeMin,
        initialMax: isTrash ? widget.trashTimeMax : widget.timeMax,
        initialInterval: isTrash ? widget.trashTimeInterval : widget.timeInterval,
        themeColor: isTrash ? Colors.orange : Colors.deepPurple,
        onSave: isTrash ? widget.onTrashTimeSettingsChanged : widget.onTimeSettingsChanged,
      ),
    );
  }
}

class _TimeSettingsCustomDialog extends StatefulWidget {
  final TimeOfDay initialMin;
  final TimeOfDay initialMax;
  final int initialInterval;
  final Color themeColor;
  final Function(TimeOfDay, TimeOfDay, int) onSave;

  const _TimeSettingsCustomDialog({
    required this.initialMin,
    required this.initialMax,
    required this.initialInterval,
    required this.themeColor,
    required this.onSave,
  });

  @override
  State<_TimeSettingsCustomDialog> createState() => _TimeSettingsCustomDialogState();
}

class _TimeSettingsCustomDialogState extends State<_TimeSettingsCustomDialog> {
  late String minStr;
  late String maxStr;
  late String intervalStr;
  int activeField = 0; 
  bool _shouldOverwrite = true; 

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
        if (activeField == 0) {
          minStr = "";
        } else if (activeField == 1) {
          maxStr = "";
        } else {
          intervalStr = "";
        }
        _shouldOverwrite = false;
        return;
      }

      String current = activeField == 0 ? minStr : (activeField == 1 ? maxStr : intervalStr);
      
      if (key == '⌫') {
        if (current.isNotEmpty) current = current.substring(0, current.length - 1);
        _shouldOverwrite = false;
      } else {
        if (_shouldOverwrite) {
          current = key;
          _shouldOverwrite = false;
        } else {
          final int limit = activeField == 2 ? 2 : 4;
          if (current.length < limit) {
            String next = current + key;
            if (activeField == 2) {
              if ((int.tryParse(next) ?? 0) > 60) next = "60";
            }
            current = next;
          }
        }
      }

      if (activeField == 0) minStr = current;
      else if (activeField == 1) maxStr = current;
      else intervalStr = current;
    });
  }

  void _setActiveField(int field) {
    setState(() {
      activeField = field;
      _shouldOverwrite = true;
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
      );
    }).toList();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: rs(context, 620),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('時間選択のカスタマイズ', style: TextStyle(fontSize: KR.fontLarge(context), fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInputRow('開始時間', _formatTimeDisplay(minStr), activeField == 0, () => _setActiveField(0)),
                      const SizedBox(height: 8),
                      _buildInputRow('終了時間', _formatTimeDisplay(maxStr), activeField == 1, () => _setActiveField(1)),
                      const SizedBox(height: 8),
                      _buildInputRow('表示間隔', intervalStr.isEmpty ? "0分" : "$intervalStr分", activeField == 2, () => _setActiveField(2)),
                      const SizedBox(height: 16),
                      Text('※各項目をタップしてテンキーで入力してください', 
                        style: TextStyle(fontSize: KR.fontTiny(context), color: Colors.grey), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Container(width: 1, height: rs(context, 300), color: Colors.grey.shade200),
                const SizedBox(width: 32),
                SizedBox(
                  width: rs(context, 260),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KDialPad(keys: dialKeys),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: KButton(
                              label: '戻る', 
                              onPressed: () => Navigator.pop(context),
                              isSecondary: true,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: KButton(
                              label: '反映', 
                              onPressed: () {
                                final minTime = _parse4Digit(minStr);
                                final maxTime = _parse4Digit(maxStr);
                                final int? intervalVal = int.tryParse(intervalStr);
                    
                                if (minTime == null || maxTime == null || intervalVal == null || intervalVal <= 0 || intervalVal > 60) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('入力内容が正しくありません（間隔は1〜60分以内）')));
                                  return;
                                }
                                widget.onSave(minTime, maxTime, intervalVal);
                                Navigator.pop(context);
                              },
                              color: widget.themeColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, String value, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? widget.themeColor.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(color: isActive ? widget.themeColor : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(
              fontSize: KR.fontSmall(context), 
              fontWeight: FontWeight.bold, 
              color: isActive ? widget.themeColor : Colors.blueGrey
            )),
            Text(value, style: TextStyle(
              fontSize: KR.fontXLarge(context), 
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.black87 : Colors.blueGrey.shade300
            )),
          ],
        ),
      ),
    );
  }
}
