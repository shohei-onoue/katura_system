import 'package:flutter/material.dart';
import 'k_responsive.dart';

class KPhoneInputPad extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onInput;
  final VoidCallback? onClear;
  final VoidCallback? onBackspace;

  const KPhoneInputPad({
    super.key,
    required this.controller,
    required this.onInput,
    this.onClear,
    this.onBackspace,
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
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 12)),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows.map((row) {
          return Padding(
            padding: EdgeInsets.only(bottom: rs(context, 12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((digit) {
                final isAction = digit == 'クリア' || digit == '⌫';
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: rs(context, 4)),
                    child: SizedBox(
                      height: rs(context, 80),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAction ? Colors.grey.shade600 : Colors.blueGrey.shade800,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
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
                              onBackspace?.call();
                            }
                          } else {
                            onInput(digit);
                          }
                        },
                        child: digit == '⌫'
                            ? Icon(Icons.backspace, size: rs(context, 32))
                            : Text(
                                digit,
                                style: TextStyle(
                                  fontSize: digit == 'クリア' ? rf(context, 18) : rf(context, 32),
                                  fontWeight: FontWeight.bold,
                                ),
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
