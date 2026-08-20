import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../widgets/k_responsive.dart';

class OrderSummaryPanel extends StatelessWidget {
  final DateTime selectedDay;
  final List<OrderModel> orders;

  const OrderSummaryPanel({
    super.key,
    required this.selectedDay,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    final dayStr = "${selectedDay.month}/${selectedDay.day}";
    
    final branches = [
      {'name': '岡崎本店', 'color': Colors.blue},
      {'name': '名古屋店', 'color': Colors.green},
      {'name': '岐阜店', 'color': Colors.purple},
    ];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(rav(context, 16)),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(rav(context, 12)),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text('$dayStr の店舗別概要', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 16))),
        ),
        SizedBox(height: rs(context, 8)),
        ...branches.map((branch) {
          final branchName = branch['name'] as String;
          final color = branch['color'] as Color;
          final branchOrders = orders.where((o) => o.branchName == branchName).toList();
          final totalCount = branchOrders.fold(0, (sum, o) => sum + o.totalCount);

          return Container(
            margin: EdgeInsets.only(bottom: rs(context, 8)),
            padding: EdgeInsets.all(rav(context, 12)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(rav(context, 12)),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(branchName, 
                      style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: rf(context, 14))),
                    Text('${branchOrders.length} 件', 
                      style: TextStyle(fontSize: rf(context, 12), color: Colors.blueGrey)),
                  ],
                ),
                Text('$totalCount 個', 
                  style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
