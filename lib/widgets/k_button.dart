import 'package:flutter/material.dart';
import 'k_responsive.dart';

class KButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final bool fullWidth;

  const KButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: rs(context, 50),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
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
