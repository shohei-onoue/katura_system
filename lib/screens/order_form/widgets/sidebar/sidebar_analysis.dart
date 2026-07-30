import 'package:flutter/material.dart';
import '../../../../models/order_model.dart';
import '../../../../widgets/k_responsive.dart';

class SidebarAnalysis extends StatelessWidget {
  final List<OrderModel> history;

  const SidebarAnalysis({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: rs(context, 12)),
            child: Row(
              children: [
                Icon(Icons.analytics_outlined, size: rs(context, 18), color: Colors.blueGrey),
                SizedBox(width: rs(context, 8)),
                Text(
                  '月別売上推移 (直近1年)',
                  style: TextStyle(
                    fontSize: rf(context, 15),
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: rs(context, 16)),
          Expanded(child: _TrendChart(history: history)),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<OrderModel> history;
  const _TrendChart({required this.history});
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // 直近12ヶ月分を逆算して集計
    final monthlyData = List.generate(12, (i) {
      final targetDate = DateTime(now.year, now.month - (11 - i), 1);
      final monthOrders = history.where((o) => o.deliveryDate.year == targetDate.year && o.deliveryDate.month == targetDate.month).toList();
      final total = monthOrders.fold(0, (sum, o) => sum + o.items.fold(0, (s, item) {
        final price = (item['price'] is num) ? (item['price'] as num).toInt() : int.tryParse(item['price']?.toString() ?? '0') ?? 0;
        final quantity = (item['quantity'] is num) ? (item['quantity'] as num).toInt() : int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
        return s + price * quantity;
      }));
      return {'month': targetDate.month, 'total': total, 'count': monthOrders.length, 'isCurrent': i == 11};
    });

    final maxAmount = monthlyData.fold<int>(0, (max, d) => (d['total'] as int) > max ? d['total'] as int : max);
    final maxScale = ((maxAmount / 10000).ceil() * 10000).clamp(50000, 1000000);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = constraints.maxHeight - rs(context, 30); // ラベル分
        final barMaxHeight = chartHeight * 0.8;

        return Container(
          padding: EdgeInsets.only(top: rs(context, 10)),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: List.generate(6, (i) => Expanded(
                  child: Container(
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))), 
                    alignment: Alignment.topLeft, 
                    child: i % 2 == 0 ? Text('${((5 - i) * maxScale / 50000).toInt()}万', style: TextStyle(fontSize: rf(context, 8), color: Colors.grey)) : null
                  )
                ))
              ), 
              Padding(
                padding: EdgeInsets.only(left: rs(context, 15), right: rs(context, 5)), 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  crossAxisAlignment: CrossAxisAlignment.end, 
                  children: monthlyData.map((d) { 
                    final height = maxScale == 0 ? 0.0 : (d['total'] as int) / maxScale * barMaxHeight; 
                    final count = d['count'] as int;
                    final isCurrent = d['isCurrent'] as bool;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end, 
                      children: [
                        if (count > 0)
                          Padding(
                            padding: EdgeInsets.only(bottom: rs(context, 2)),
                            child: Text('$count回', style: TextStyle(fontSize: rf(context, 8), fontWeight: FontWeight.bold, color: isCurrent ? Colors.deepOrange : Colors.deepPurple)),
                          ),
                        Container(
                          width: rs(context, 12), 
                          height: height.toDouble().clamp(0, barMaxHeight), 
                          decoration: BoxDecoration(
                            color: count > 0 ? (isCurrent ? Colors.deepOrange.shade300 : Colors.deepPurple.shade300) : Colors.grey.shade100, 
                            borderRadius: BorderRadius.vertical(top: Radius.circular(rs(context, 2)))
                          ),
                        ), 
                        SizedBox(height: rs(context, 6)), 
                        Text('${d['month']}', style: TextStyle(fontSize: rf(context, 9), fontWeight: FontWeight.bold, color: isCurrent ? Colors.deepOrange : Colors.blueGrey))
                      ]
                    ); 
                  }).toList()
                )
              )
            ]
          ),
        );
      }
    );
  }
}
