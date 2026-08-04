import 'package:flutter/material.dart';
import 'k_responsive.dart';

class KDialKey {
  final String label;
  final String? subLabel;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isHighlight;

  const KDialKey({
    required this.label,
    this.subLabel,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.isHighlight = false,
  });
}

class KDialPad extends StatelessWidget {
  final List<KDialKey> keys;

  const KDialPad({super.key, required this.keys});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: rs(context, 12),
        crossAxisSpacing: rs(context, 12),
        childAspectRatio: 1.1,
      ),
      itemCount: keys.length,
      itemBuilder: (context, i) {
        final key = keys[i];
        final isSpecial = key.label == '⌫' || key.label == 'すべて' || key.label == '戻る';

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: key.backgroundColor ?? 
              (key.isHighlight ? Colors.deepPurple : (isSpecial ? Colors.orange.shade800 : Colors.grey.shade50)),
            foregroundColor: key.foregroundColor ?? (key.isHighlight || isSpecial ? Colors.white : Colors.black87),
            elevation: key.isHighlight ? 4 : 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
            padding: EdgeInsets.zero,
          ),
          onPressed: key.onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(key.label, 
                style: TextStyle(
                  fontSize: rf(context, key.label.length > 2 ? 16 : 24), 
                  fontWeight: FontWeight.bold
                )
              ),
              if (key.subLabel != null)
                Text(key.subLabel!, 
                  style: TextStyle(
                    fontSize: rf(context, 9), 
                    color: key.isHighlight ? Colors.white70 : Colors.grey
                  )
                ),
            ],
          ),
        );
      },
    );
  }
}
