import 'package:flutter/material.dart';
import '../../../../widgets/k_phone_input_pad.dart';
import '../../../../widgets/k_responsive.dart';

class SidebarPhonePad extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onInput;
  final VoidCallback onClear;
  final VoidCallback onBackspace;

  const SidebarPhonePad({
    super.key,
    required this.controller,
    required this.onInput,
    required this.onClear,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: rs(context, 40)),
        Text('入力ダイヤル', style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold)),
        SizedBox(height: rs(context, 20)),
        KPhoneInputPad(
          controller: controller,
          onInput: onInput,
          onClear: onClear,
          onBackspace: onBackspace,
        ),
        SizedBox(height: rs(context, 40)),
      ],
    );
  }
}
