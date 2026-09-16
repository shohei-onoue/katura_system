import 'package:flutter/material.dart';
import '../../../../models/customer_model.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_multimodal_text_field.dart';
import 'package:katura_system/utils/app_colors.dart';

/// 受取人の選択（ご本人様 / 履歴から選択 / 新規追加）。
/// もとは配達日時ステップに含まれていた UI を配達先の確定ステップへ移設したもの。
class ReceiverSelector extends StatefulWidget {
  final TextEditingController receiverController;
  final Customer? currentCustomer;
  final String customerName;
  final String facilityName;
  final ValueChanged<String>? onChanged;

  const ReceiverSelector({
    super.key,
    required this.receiverController,
    required this.currentCustomer,
    required this.customerName,
    required this.facilityName,
    this.onChanged,
  });

  @override
  State<ReceiverSelector> createState() => _ReceiverSelectorState();
}

class _ReceiverSelectorState extends State<ReceiverSelector> {
  String _receiverMode = 'ご本人様';

  @override
  void initState() {
    super.initState();
    final String effectiveName = widget.currentCustomer?.name ?? widget.customerName;

    // 受取人が現在の顧客名と一致している場合、あるいは空の場合に「ご本人様」モードにする
    if (effectiveName.isNotEmpty &&
        (widget.receiverController.text == effectiveName || widget.receiverController.text.isEmpty)) {
      widget.receiverController.text = effectiveName;
      _receiverMode = 'ご本人様';
    } else if (widget.receiverController.text.isNotEmpty) {
      _receiverMode = '新規追加';
    } else {
      _receiverMode = 'ご本人様';
    }
  }

  void _notify() => widget.onChanged?.call(widget.receiverController.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: rs(context, 10)),
          child: Text(
            '受取人の選択',
            style: TextStyle(
              fontSize: rf(context, 15),
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
        ),
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
                _notify();
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
                    color: isSelected ? AppColors.background : Colors.blueGrey,
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
      final filteredReceivers = allReceivers
          .where((name) => widget.currentCustomer == null || name != widget.currentCustomer!.name)
          .toList();

      if (filteredReceivers.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: rs(context, 12.0), horizontal: rs(context, 8.0)),
          child: Text('履歴なし',
              style: TextStyle(color: Colors.grey, fontSize: rf(context, 13), fontWeight: FontWeight.bold)),
        );
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filteredReceivers
            .map((name) => ActionChip(
                  label: Text(name,
                      style: TextStyle(fontSize: KR.fontLarge(context), fontWeight: FontWeight.bold)),
                  labelPadding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 4)),
                  onPressed: () {
                    widget.receiverController.text = name;
                    _notify();
                  },
                  backgroundColor: Colors.deepPurple.shade50,
                  side: BorderSide(color: Colors.deepPurple.shade100),
                ))
            .toList(),
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
}
