import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'k_dial_pad.dart';

class KNumericInputDialog extends StatefulWidget {
  final int initialValue;
  final String title;

  const KNumericInputDialog({
    super.key,
    required this.initialValue,
    this.title = '数量を入力',
  });

  @override
  State<KNumericInputDialog> createState() => _KNumericInputDialogState();
}

class _KNumericInputDialogState extends State<KNumericInputDialog> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue == 0 ? "" : widget.initialValue.toString();
  }

  void _handleKeyTap(String key) {
    setState(() {
      if (key == 'クリア') {
        _currentValue = "";
      } else if (key == '⌫') {
        if (_currentValue.isNotEmpty) {
          _currentValue = _currentValue.substring(0, _currentValue.length - 1);
        }
      } else {
        if (_currentValue.length < 4) { // 最大4桁(9999)
          _currentValue += key;
        }
      }
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _currentValue.isEmpty ? "0" : _currentValue,
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 24),
            KDialPad(keys: dialKeys),
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
                    child: const Text('キャンセル', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final val = int.tryParse(_currentValue) ?? 0;
                      Navigator.pop(context, val);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('決定', style: TextStyle(fontWeight: FontWeight.bold)),
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
