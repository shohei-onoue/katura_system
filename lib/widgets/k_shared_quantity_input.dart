import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'k_numeric_input_dialog.dart';

class KSharedQuantityInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String? title;
  final double? width;
  final double? height;
  final Color themeColor;
  /// true の場合、直接入力ダイヤログは現在値をプリセットせず 0（空）から開始する
  final bool clearOnDirectInput;

  const KSharedQuantityInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.width,
    this.height,
    this.themeColor = Colors.deepPurple,
    this.clearOnDirectInput = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(context, Icons.remove, () {
          if (value > 0) onChanged(value - 1);
        }),
        SizedBox(width: rs(context, 4)),
        GestureDetector(
          onTap: () => _showDialDialog(context),
          child: Container(
            width: width ?? rs(context, 80),
            height: height ?? rs(context, 44),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: value > 0 ? themeColor.withValues(alpha: 0.05) : Colors.white,
              border: Border.all(color: value > 0 ? themeColor : Colors.grey.shade300, width: rs(context, 2)),
              borderRadius: BorderRadius.circular(rs(context, 8)),
            ),
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: rf(context, 20),
                fontWeight: FontWeight.bold,
                color: value > 0 ? themeColor : Colors.black87,
              ),
            ),
          ),
        ),
        SizedBox(width: rs(context, 4)),
        _buildButton(context, Icons.add, () => onChanged(value + 1)),
      ],
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(rs(context, 8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(rs(context, 8)),
        child: Container(
          width: height ?? 44,
          height: height ?? 44,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(rs(context, 8)),
          ),
          child: Icon(icon, size: rs(context, 20), color: Colors.blueGrey),
        ),
      ),
    );
  }

  void _showDialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => KNumericInputDialog(
        title: title ?? '数量入力',
        initialValue: (clearOnDirectInput || value == 0) ? '' : value.toString(),
        maxLength: 4,
        emptyHint: '0',
        themeColor: themeColor,
        onConfirmed: (text) => onChanged(int.tryParse(text) ?? 0),
      ),
    );
  }
}

