import 'package:flutter/material.dart';
import '../../../widgets/k_japanese_input_pad.dart';
import '../../../widgets/k_responsive.dart';

class RegistrationInputPad extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onRowTap;

  const RegistrationInputPad({
    super.key,
    required this.controller,
    required this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rs(context, 400),
      padding: EdgeInsets.symmetric(horizontal: rs(context, 10)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Center(
        child: KJapaneseInputPad(
          controller: controller,
          onRowTap: onRowTap,
          onCompleted: () {},
        ),
      ),
    );
  }
}
