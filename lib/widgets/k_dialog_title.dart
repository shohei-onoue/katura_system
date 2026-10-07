import 'package:flutter/material.dart';
import 'package:katura_system/utils/app_colors.dart';
import 'k_responsive.dart';

/// ダイアログのタイトル。左に「｜」（dialogLabel）を置き、文字は primaryText。
class KDialogTitle extends StatelessWidget {
  final String text;
  final double? fontSize;
  const KDialogTitle(this.text, {super.key, this.fontSize});

  @override
  Widget build(BuildContext context) {
    final size = fontSize ?? rf(context, 20);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('｜', style: TextStyle(fontSize: size, fontWeight: FontWeight.bold, color: AppColors.dialogLabel)),
        SizedBox(width: rs(context, 4)),
        Flexible(child: Text(text, style: TextStyle(fontSize: size, fontWeight: FontWeight.bold, color: AppColors.primaryText), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
