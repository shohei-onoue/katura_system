import 'package:flutter/material.dart';
import '../../../../widgets/k_phone_input_pad.dart';
import '../../../../widgets/k_responsive.dart';
import '../order_form_parts.dart';

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
        const SidebarSectionTitle(title: '入力ダイヤル', icon: Icons.phone_callback),
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
