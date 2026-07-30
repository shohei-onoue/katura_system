import 'package:flutter/material.dart';
import '../../../../widgets/k_responsive.dart';

class SidebarSummary extends StatelessWidget {
  final DateTime date;
  final DateTime time;
  final String customerName;
  final String receiverName;
  final int totalPrice;
  final int totalCount;

  const SidebarSummary({
    super.key,
    required this.date,
    required this.time,
    required this.customerName,
    required this.receiverName,
    required this.totalPrice,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final weekDays = ['日', '月', '火', '水', '木', '金', '土'];
    final dateStr = "${date.year}年${date.month}月${date.day}日(${weekDays[date.weekday % 7]})";
    final timeStr = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: EdgeInsets.all(rs(context, 16)),
      padding: EdgeInsets.all(rs(context, 20)),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(rs(context, 12)), border: Border.all(color: Colors.orange.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('受注サマリー', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 18))),
          const Divider(),
          _SummaryRow('配達日', dateStr),
          _SummaryRow('時間', timeStr),
          _SummaryRow('注文者', customerName),
          if (receiverName.isNotEmpty) _SummaryRow('受取人', receiverName),
          _SummaryRow('合計', '¥${_formatCurrency(totalPrice)} ($totalCount点)'),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  const _SummaryRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(vertical: rs(context, 4)), child: Row(children: [Text('$label: ', style: TextStyle(color: Colors.grey, fontSize: rf(context, 14))), Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 14))))]));
  }
}
