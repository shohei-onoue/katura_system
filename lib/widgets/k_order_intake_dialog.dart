import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'k_button.dart';
import 'k_choice_group.dart';
import 'k_multimodal_text_field.dart';
import 'package:katura_system/utils/app_colors.dart';

/// 番号確認の「次へ」で開く、受注区分＋受け渡し方法（配達／引取り）の確認ダイヤログ。
///
/// 返り値（`Navigator.pop`）: `{orderSource, orderSourceOther, deliveryType}`
/// - `deliveryType` は `配達` → `'配送'` / `引取り` → `'引取'`
class KOrderIntakeDialog extends StatefulWidget {
  final String initialOrderSource;
  final String initialOrderSourceOther;
  final String initialDeliveryType;

  const KOrderIntakeDialog({
    super.key,
    this.initialOrderSource = '',
    this.initialOrderSourceOther = '',
    this.initialDeliveryType = '',
  });

  @override
  State<KOrderIntakeDialog> createState() => _KOrderIntakeDialogState();
}

class _KOrderIntakeDialogState extends State<KOrderIntakeDialog> {
  static const _orderSources = ['デリカ', '結膳', '直取', 'その他'];

  late String _orderSource;
  late String _handover; // '配達' | '引取り'
  late final TextEditingController _otherController;

  @override
  void initState() {
    super.initState();
    _orderSource = _orderSources.contains(widget.initialOrderSource)
        ? widget.initialOrderSource
        : '';
    _handover = widget.initialDeliveryType == '引取'
        ? '引取り'
        : (widget.initialDeliveryType == '配送' ? '配達' : '');
    _otherController = TextEditingController(text: widget.initialOrderSourceOther);
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _orderSource.isNotEmpty && _handover.isNotEmpty;

  void _submit() {
    if (!_canSubmit) return;
    Navigator.pop(context, {
      'orderSource': _orderSource,
      'orderSourceOther': _otherController.text,
      'deliveryType': _handover == '引取り' ? '引取' : '配送',
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth < 900 ? screenWidth * 0.92 : 560;
    const themeColor = Color(0xFF000038);

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
                Text('受注区分・受け渡し方法',
                    style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: themeColor)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: rs(context, 16)),

            _sectionHeader(context, '受注区分'),
            SizedBox(height: rs(context, 8)),
            KChoiceGroup<String>(
              label: '',
              selectedValue: _orderSource,
              showLabel: false,
              items: _orderSources.map((s) => KChoiceItem(label: s, value: s)).toList(),
              onSelected: (v) => setState(() => _orderSource = v),
            ),
            if (_orderSource == 'その他') ...[
              SizedBox(height: rs(context, 10)),
              KMultimodalTextField(
                label: '',
                hintText: '受注区分（詳細）を入力',
                showLabel: false,
                controller: _otherController,
                height: rs(context, 50),
                maxLines: 1,
              ),
            ],
            SizedBox(height: rs(context, 20)),

            _sectionHeader(context, '受け渡し方法'),
            SizedBox(height: rs(context, 8)),
            KChoiceGroup<String>(
              label: '',
              selectedValue: _handover,
              showLabel: false,
              items: [
                KChoiceItem(label: '配達', value: '配達'),
                KChoiceItem(label: '引取り', value: '引取り'),
              ],
              onSelected: (v) => setState(() => _handover = v),
            ),
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
                    label: '次へ',
                    color: themeColor,
                    onPressed: _canSubmit ? _submit : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(title,
        style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800));
  }
}
