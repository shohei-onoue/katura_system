import 'package:flutter/material.dart';
import 'k_responsive.dart';

class KNumericDialPad extends StatelessWidget {
  final Function(String) onInput;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final Color? buttonColor;
  final double? height;

  const KNumericDialPad({
    super.key,
    required this.onInput,
    required this.onClear,
    required this.onBackspace,
    this.buttonColor,
    this.height,
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
                      height: height ?? rs(context, 70),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAction 
                              ? Colors.grey.shade600 
                              : (buttonColor ?? Colors.blueGrey.shade800),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          if (digit == 'クリア') {
                            onClear();
                          } else if (digit == '⌫') {
                            onBackspace();
                          } else {
                            onInput(digit);
                          }
                        },
                        child: digit == '⌫'
                            ? Icon(Icons.backspace, size: rs(context, 28))
                            : Text(
                                digit,
                                style: TextStyle(
                                  fontSize: digit == 'クリア' ? rf(context, 16) : rf(context, 28),
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
