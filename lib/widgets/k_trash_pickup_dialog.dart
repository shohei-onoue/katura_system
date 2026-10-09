import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'k_responsive.dart';
import 'k_button.dart';
import 'k_choice_group.dart';
import 'k_dialog_title.dart';
import 'k_multimodal_text_field.dart';
import 'package:katura_system/utils/app_colors.dart';

/// 注文内容ステップの「次へ」で開く、ゴミ回収の要否・日時・場所を決めるダイヤログ。
///
/// 返り値（`Navigator.pop`）: `{requested, dateTime, location, locationDetail}`
class KTrashPickupDialog extends StatefulWidget {
  final bool initialRequested;
  final DateTime? initialDateTime;
  final String initialLocation; // '引渡し場所' | '指定場所'
  final String initialLocationDetail;
  final DateTime deliveryDate;
  final TimeOfDay trashTimeMin;
  final TimeOfDay trashTimeMax;
  final int trashTimeInterval;
  /// 配達と同じカレンダーで日時を選ぶ処理（呼び出し側から渡す）
  final Future<DateTime?> Function(DateTime initial) dateTimePicker;

  const KTrashPickupDialog({
    super.key,
    required this.initialRequested,
    required this.initialDateTime,
    required this.initialLocation,
    required this.initialLocationDetail,
    required this.deliveryDate,
    this.trashTimeMin = const TimeOfDay(hour: 9, minute: 0),
    this.trashTimeMax = const TimeOfDay(hour: 18, minute: 0),
    this.trashTimeInterval = 15,
    required this.dateTimePicker,
  });

  @override
  State<KTrashPickupDialog> createState() => _KTrashPickupDialogState();
}

class _KTrashPickupDialogState extends State<KTrashPickupDialog> {
  late bool _requested;
  late DateTime? _dateTime;
  late String _location;
  late final TextEditingController _detailController;
  bool _detailStage = false; // false=あり/なし選択、true=「あり」の詳細（日時・場所）

  @override
  void initState() {
    super.initState();
    _requested = widget.initialRequested;
    _dateTime = widget.initialDateTime;
    _location = widget.initialLocation.isEmpty ? '引渡し場所' : widget.initialLocation;
    _detailController = TextEditingController(text: widget.initialLocationDetail);
  }

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _showDateTimeDialog() async {
    final result = await widget.dateTimePicker(_dateTime ?? widget.deliveryDate);
    if (result != null) setState(() => _dateTime = result);
  }

  void _onNext() {
    if (!_requested) {
      _submit();
      return;
    }
    _goDetail();
  }

  /// 「あり」→「次へ」：先に配達日時と同じデザインの日時ダイアログを開き、決まったら場所の設定へ進む
  Future<void> _goDetail() async {
    final result = await widget.dateTimePicker(_dateTime ?? widget.deliveryDate);
    if (!mounted || result == null) return; // 閉じたら「あり/なし」選択に戻る
    setState(() {
      _dateTime = result;
      _detailStage = true;
    });
  }

  void _submit() {
    Navigator.pop(context, {
      'requested': _requested,
      'dateTime': _requested ? _dateTime : null,
      'location': _location,
      'locationDetail': _detailController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth < 900 ? screenWidth * 0.92 : 560;

    return Dialog(
      backgroundColor: AppColors.popupBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rav(context, 16))),
      child: Container(
        width: dialogWidth,
        padding: EdgeInsets.all(rav(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Flexible(child: KDialogTitle('ゴミ回収の設定')),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: rs(context, 16)),

            if (!_detailStage)
              KChoiceGroup<bool>(
                label: '',
                showLabel: false,
                selectedValue: _requested,
                selectedColor: AppColors.selectButton,
                selectedTextColor: AppColors.primaryText,
                items: [
                  KChoiceItem(label: 'なし', value: false),
                  KChoiceItem(label: 'あり', value: true),
                ],
                onSelected: (v) => setState(() => _requested = v),
              ),

            if (_detailStage) ...[
              _header(context, '回収日時'),
              SizedBox(height: rs(context, 8)),
              InkWell(
                onTap: _showDateTimeDialog,
                borderRadius: BorderRadius.circular(rs(context, 8)),
                child: Container(
                  height: rs(context, 50),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
                  decoration: BoxDecoration(
                    color: AppColors.mainBackground,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(rs(context, 8)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, size: rs(context, 18), color: AppColors.accentOrange),
                      SizedBox(width: rs(context, 8)),
                      Text(
                        _dateTime != null
                            ? DateFormat('yyyy年M月d日 HH:mm', 'ja_JP').format(_dateTime!)
                            : '未設定',
                        style: TextStyle(
                          fontSize: rf(context, 14),
                          fontWeight: FontWeight.bold,
                          color: _dateTime != null ? Colors.black87 : Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
              SizedBox(height: rs(context, 20)),
              _header(context, '回収場所'),
              SizedBox(height: rs(context, 8)),
              KChoiceGroup<String>(
                label: '',
                showLabel: false,
                selectedValue: _location,
                selectedColor: AppColors.selectButton,
                selectedTextColor: AppColors.primaryText,
                items: [
                  KChoiceItem(label: '引渡し場所', value: '引渡し場所'),
                  KChoiceItem(label: '指定場所', value: '指定場所'),
                ],
                onSelected: (v) => setState(() => _location = v),
              ),
              if (_location == '指定場所') ...[
                SizedBox(height: rs(context, 10)),
                KMultimodalTextField(
                  label: '詳細',
                  showLabel: false,
                  controller: _detailController,
                  height: rs(context, 50),
                  maxLines: 1,
                ),
              ],
            ],

            SizedBox(height: rs(context, 28)),
            Row(
              children: [
                Expanded(
                  child: KButton(
                    label: 'キャンセル',
                    color: AppColors.cancelButton,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: rs(context, 16)),
                Expanded(
                  child: KButton(
                    label: _detailStage ? '確定' : '次へ',
                    color: AppColors.acceptButton,
                    onPressed: _detailStage ? _submit : _onNext,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String title) {
    return Text(title,
        style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800));
  }
}
