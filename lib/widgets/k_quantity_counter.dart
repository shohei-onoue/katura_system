import 'package:flutter/material.dart';
import 'k_responsive.dart';

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
            style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.w500, color: Colors.black54),
          ),
          SizedBox(height: rs(context, 8)),
        ],
        Row(
          children: [
            _buildStepButton(
              context,
              icon: Icons.remove,
              onPressed: (min == null || value > min!) ? () => onChanged(value - step) : null,
            ),
            Container(
              constraints: BoxConstraints(minWidth: rs(context, 80)),
              padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: TextStyle(fontSize: rf(context, 32), fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
            ),
            _buildStepButton(
              context,
              icon: Icons.add,
              onPressed: (max == null || value < max!) ? () => onChanged(value + step) : null,
            ),
            SizedBox(width: rs(context, 16)),
            // クイック入力ボタン（現場でよく出る数）
            Wrap(
              spacing: rs(context, 8),
              children: [5, 10, 20].map((v) {
                return _buildQuickButton(context, '+$v', () => onChanged(value + v));
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepButton(BuildContext context, {required IconData icon, VoidCallback? onPressed}) {
    return Material(
      color: onPressed == null ? Colors.grey[200] : Colors.orange.shade50,
      borderRadius: BorderRadius.circular(rs(context, 12)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(rs(context, 12)),
        child: Container(
          width: rs(context, 60),
          height: rs(context, 60),
          decoration: BoxDecoration(
            border: Border.all(color: onPressed == null ? Colors.transparent : Colors.orange.shade200),
            borderRadius: BorderRadius.circular(rs(context, 12)),
          ),
          child: Icon(icon, size: rs(context, 30), color: onPressed == null ? Colors.grey : Colors.orange.shade800),
        ),
      ),
    );
  }

  Widget _buildQuickButton(BuildContext context, String text, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(rs(context, 60), rs(context, 60)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
        side: BorderSide(color: Colors.grey.shade300),
        padding: EdgeInsets.zero,
      ),
      child: Text(text, style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }
}
