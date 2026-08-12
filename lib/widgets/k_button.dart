import 'package:flutter/material.dart';
import 'k_responsive.dart';

class KButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool fullWidth;
  final bool isSecondary;
  final double? height;
  final double? fontSize;

  const KButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.fullWidth = true,
    this.isSecondary = false,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).primaryColor;
    
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height ?? rav(context, 48),
      child: isSecondary
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor, width: 2),
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rav(context, 8)),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(fontSize: fontSize ?? rf(context, 16), fontWeight: FontWeight.bold),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rav(context, 8)),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(fontSize: fontSize ?? rf(context, 16), fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
