import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'k_responsive.dart';
import 'k_button.dart';
import 'k_choice_group.dart';
import 'k_multimodal_text_field.dart';
import 'k_date_time_selection_dialog.dart';
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
  });

  @override
  State<KTrashPickupDialog> createState() => _KTrashPickupDialogState();
}

class _KTrashPickupDialogState extends State<KTrashPickupDialog> {
  late bool _requested;
  late DateTime? _dateTime;
  late String _location;
  late final TextEditingController _detailController;

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
    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) => KDateTimeSelectionDialog(
        initialDateTime: _dateTime ?? widget.deliveryDate,
        minTime: widget.trashTimeMin,
        maxTime: widget.trashTimeMax,
        interval: widget.trashTimeInterval,
        title: 'ゴミ回収日時の設定',
        themeColor: Colors.orange,
        highlightDate: widget.deliveryDate,
      ),
    );
    if (result != null) setState(() => _dateTime = result);
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
                Text('ゴミ回収の設定',
                    style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: rs(context, 16)),

            _header(context, 'ゴミ回収'),
            SizedBox(height: rs(context, 8)),
            KChoiceGroup<bool>(
              label: '',
              showLabel: false,
              selectedValue: _requested,
              items: [
                KChoiceItem(label: 'なし', value: false),
                KChoiceItem(label: 'あり', value: true),
              ],
              onSelected: (v) => setState(() => _requested = v),
            ),

            if (_requested) ...[
              SizedBox(height: rs(context, 20)),
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
                    color: AppColors.background,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(rs(context, 8)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, size: rs(context, 18), color: Colors.orange),
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
                    isSecondary: true,
                    color: Colors.blueGrey,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: rs(context, 16)),
                Expanded(
                  child: KButton(
                    label: '確定',
                    color: Colors.orange.shade800,
                    onPressed: _submit,
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
