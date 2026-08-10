import 'package:flutter/material.dart';
import 'k_responsive.dart';

class KButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final bool fullWidth;
  final bool isSecondary;

  const KButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.fullWidth = true,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).primaryColor;
    
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: rs(context, 50),
      child: isSecondary
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor, width: 2),
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rs(context, 8)),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rs(context, 8)),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
