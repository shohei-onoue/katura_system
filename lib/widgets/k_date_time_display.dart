import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'k_responsive.dart';

class KDateTimeDisplay extends StatelessWidget {
  final String label;
  final DateTime? dateTime;
  final VoidCallback onTap;
  final Color themeColor;
  final bool isActive;
  final bool isCompact; // コンパクトモード

  const KDateTimeDisplay({
    super.key,
    required this.label,
    required this.dateTime,
    required this.onTap,
    this.themeColor = Colors.deepPurple,
    this.isActive = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = dateTime != null;
    final double baseFontSize = isCompact ? 18 : 32;
    final double subFontSize = isCompact ? 12 : 18;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rs(context, 12)),
      child: Container(
        constraints: BoxConstraints(minHeight: rs(context, isCompact ? 50 : 80)),
        padding: EdgeInsets.all(rs(context, isCompact ? 8 : 16)),
        decoration: BoxDecoration(
          color: isActive 
              ? themeColor.withValues(alpha: 0.08) 
              : (isSelected ? themeColor.withValues(alpha: 0.03) : Colors.grey.shade50),
          border: Border.all(
            color: isActive 
                ? themeColor 
                : (isSelected ? themeColor.withValues(alpha: 0.2) : Colors.grey.shade300),
            width: isActive ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(rs(context, 12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (label.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    isSelected ? Icons.calendar_today : Icons.calendar_today_outlined, 
                    size: rs(context, isCompact ? 10 : 14), 
                    color: isSelected ? themeColor : Colors.grey
                  ),
                  SizedBox(width: rs(context, 8)),
                  Text(
                    label, 
                    style: TextStyle(
                      fontSize: rf(context, isCompact ? 10 : 11), 
                      fontWeight: FontWeight.bold, 
                      color: isSelected ? themeColor : Colors.grey.shade600
                    )
                  ),
                ],
              ),
              SizedBox(height: rs(context, 4)),
            ],
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (isSelected) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('MM/dd').format(dateTime!),
                        style: TextStyle(
                          fontSize: rf(context, baseFontSize), 
                          fontWeight: FontWeight.bold, 
                          color: themeColor.withValues(alpha: 0.9)
                        ),
                      ),
                      SizedBox(width: rs(context, 4)),
                      Text(
                        '(${DateFormat('E', 'ja_JP').format(dateTime!)})',
                        style: TextStyle(
                          fontSize: rf(context, subFontSize), 
                          fontWeight: FontWeight.bold, 
                          color: themeColor.withValues(alpha: 0.7)
                        ),
                      ),
                    ],
                  ),
                  // コンパクトモードで非常に幅が狭い場合は改行を許容
                  if (!isCompact) const Spacer(),
                  if (isCompact) SizedBox(width: rs(context, 8)), 
                  Text(
                    DateFormat('HH:mm').format(dateTime!),
                    style: TextStyle(
                      fontSize: rf(context, baseFontSize), 
                      fontWeight: FontWeight.bold, 
                      color: themeColor
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '未設定',
                        style: TextStyle(
                          fontSize: rf(context, isCompact ? 18 : 24), 
                          fontWeight: FontWeight.bold, 
                          color: Colors.grey.shade400
                        ),
                      ),
                      Icon(Icons.touch_app, color: Colors.grey.shade300, size: rs(context, isCompact ? 18 : 24)),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
