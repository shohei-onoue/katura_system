import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'package:katura_system/utils/app_colors.dart';

class KButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool fullWidth;
  final bool isSecondary;
  final double? height;
  final double? fontSize;
  final IconData? icon;

  const KButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.fullWidth = true,
    this.isSecondary = false,
    this.height,
    this.fontSize,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? KR.primaryColor;
    final textStyle = TextStyle(fontSize: fontSize ?? rf(context, 16), fontWeight: FontWeight.bold);
    final labelWidget = Text(label, style: textStyle);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height ?? kFieldHeight(context),
      child: isSecondary
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor, width: rs(context, 2)),
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rav(context, 8)),
                ),
              ),
              child: icon == null
                  ? labelWidget
                  : Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: rs(context, 18)), SizedBox(width: rs(context, 8)), labelWidget]),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rav(context, 8)),
                ),
              ),
              child: icon == null
                  ? labelWidget
                  : Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: rs(context, 18)), SizedBox(width: rs(context, 8)), labelWidget]),
            ),
    );
  }
}
