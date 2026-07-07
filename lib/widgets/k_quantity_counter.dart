import 'package:flutter/material.dart';

class KQuantityCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String? label;
  final int step;
  final int? min;
  final int? max;

  const KQuantityCounter({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.step = 1,
    this.min = 0,
    this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            _buildStepButton(
              icon: Icons.remove,
              onPressed: (min == null || value > min!) ? () => onChanged(value - step) : null,
              isLarge: true,
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 80),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
            ),
            _buildStepButton(
              icon: Icons.add,
              onPressed: (max == null || value < max!) ? () => onChanged(value + step) : null,
              isLarge: true,
            ),
            const SizedBox(width: 16),
            // クイック入力ボタン（現場でよく出る数）
            Wrap(
              spacing: 8,
              children: [5, 10, 20].map((v) {
                return _buildQuickButton(context, '+$v', () => onChanged(value + v));
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepButton({required IconData icon, VoidCallback? onPressed, bool isLarge = false}) {
    return Material(
      color: onPressed == null ? Colors.grey[200] : Colors.orange.shade50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: onPressed == null ? Colors.transparent : Colors.orange.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 30, color: onPressed == null ? Colors.grey : Colors.orange.shade800),
        ),
      ),
    );
  }

  Widget _buildQuickButton(BuildContext context, String text, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(60, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }
}
