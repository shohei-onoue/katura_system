import 'package:flutter/material.dart';

class KPhoneInputPad extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onInput;
  final VoidCallback? onClear;

  const KPhoneInputPad({
    super.key,
    required this.controller,
    required this.onInput,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['クリア', '0', '⌫'],
    ];

    return Container(
      width: 380, // KJapaneseInputPadと統一
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((digit) {
                final isAction = digit == 'クリア' || digit == '⌫';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: SizedBox(
                    width: 105,
                    height: 90, // Japanese Padの縦横比に近づける
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAction ? Colors.grey.shade600 : Colors.blueGrey.shade800,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        if (digit == 'クリア') {
                          controller.clear();
                          onClear?.call();
                        } else if (digit == '⌫') {
                          final text = controller.text;
                          if (text.isNotEmpty) {
                            final lastChar = text.substring(text.length - 1);
                            final deleteCount = lastChar == '-' ? 2 : 1;
                            if (text.length >= deleteCount) {
                              controller.text = text.substring(0, text.length - deleteCount);
                            }
                          }
                        } else {
                          onInput(digit);
                        }
                      },
                      child: digit == '⌫'
                          ? const Icon(Icons.backspace, size: 32)
                          : Text(
                              digit,
                              style: TextStyle(
                                fontSize: digit == 'クリア' ? 18 : 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
