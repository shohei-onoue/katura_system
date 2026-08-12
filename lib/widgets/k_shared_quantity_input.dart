import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'k_numeric_dial_pad.dart';

class KSharedQuantityInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String? title;
  final double? width;
  final double? height;
  final Color themeColor;

  const KSharedQuantityInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.width,
    this.height,
    this.themeColor = Colors.deepPurple,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(Icons.remove, () {
          if (value > 0) onChanged(value - 1);
        }),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => _showDialDialog(context),
          child: Container(
            width: width ?? rs(context, 80),
            height: height ?? rs(context, 44),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: value > 0 ? themeColor.withValues(alpha: 0.05) : Colors.white,
              border: Border.all(color: value > 0 ? themeColor : Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(8),
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
        const SizedBox(width: 4),
        _buildButton(Icons.add, () => onChanged(value + 1)),
      ],
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: height ?? 44,
          height: height ?? 44,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.blueGrey),
        ),
      ),
    );
  }

  void _showDialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _QuantityDialDialog(
        initialValue: value,
        title: title ?? '数量入力',
        themeColor: themeColor,
        onConfirmed: onChanged,
      ),
    );
  }
}

class _QuantityDialDialog extends StatefulWidget {
  final int initialValue;
  final String title;
  final Color themeColor;
  final ValueChanged<int> onConfirmed;

  const _QuantityDialDialog({
    required this.initialValue,
    required this.title,
    required this.themeColor,
    required this.onConfirmed,
  });

  @override
  State<_QuantityDialDialog> createState() => _QuantityDialDialogState();
}

class _QuantityDialDialogState extends State<_QuantityDialDialog> {
  late String _currentText;

  @override
  void initState() {
    super.initState();
    _currentText = widget.initialValue == 0 ? "" : widget.initialValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: rs(context, 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Text(
                _currentText.isEmpty ? "0" : _currentText,
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: widget.themeColor),
              ),
            ),
            const SizedBox(height: 24),
            KNumericDialPad(
              buttonColor: Colors.blueGrey.shade800,
              onInput: (digit) {
                if (_currentText.length < 4) {
                  setState(() => _currentText += digit);
                }
              },
              onClear: () => setState(() => _currentText = ""),
              onBackspace: () {
                if (_currentText.isNotEmpty) {
                  setState(() => _currentText = _currentText.substring(0, _currentText.length - 1));
                }
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final val = int.tryParse(_currentText) ?? 0;
                      widget.onConfirmed(val);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('確定', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
