import 'package:flutter/material.dart';
import 'k_numeric_dial_pad.dart';

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
    return KNumericDialPad(
      onInput: onInput,
      onClear: onClear ?? () => controller.clear(),
      onBackspace: onBackspace ?? () {
        final text = controller.text;
        if (text.isNotEmpty) {
          controller.text = text.substring(0, text.length - 1);
        }
      },
      buttonColor: Colors.blueGrey.shade800,
    );
  }
}
