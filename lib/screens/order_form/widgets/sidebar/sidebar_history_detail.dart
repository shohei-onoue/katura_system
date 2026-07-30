import 'package:flutter/material.dart';
import '../../../../models/order_model.dart';
import '../../../../widgets/k_responsive.dart';

class SidebarHistoryDetail extends StatelessWidget {
  final OrderModel order;

  const SidebarHistoryDetail({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final regExp = RegExp(r'\(([-+]?\d*\.?\d+),\s*([-+]?\d*\.?\d+)\)');
    final matches = regExp.allMatches(order.address);
    final coords = matches.isNotEmpty ? '${matches.last.group(1)}, ${matches.last.group(2)}' : '取得不可';
    
    return Container(
      padding: EdgeInsets.all(rs(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('前回注文の詳細', Icons.history),
          SizedBox(height: rs(context, 16)),
          _InfoRow('配達先', order.facilityName, isBold: true),
          _InfoRow('住所', order.address.split(' (').first),
          _InfoRow('位置情報', coords),
          _InfoRow('受取人', order.receiverName.isEmpty ? '-' : order.receiverName),
          const Divider(height: 32),
          _SectionTitle('前回注文の商品', Icons.restaurant),
          SizedBox(height: rs(context, 12)),
          ...order.items.map((i) => Padding(
            padding: EdgeInsets.only(bottom: rs(context, 4)), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                Expanded(child: Text(i['name'] ?? '', style: TextStyle(fontSize: rf(context, 14)))), 
                Text('x${i['quantity']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 14)))
              ]
            )
          )),
          const Divider(height: 32),
          _SectionTitle('決済情報', Icons.payment),
          _InfoRow('前回決済', order.paymentMethod),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Text('前回合計', style: TextStyle(color: Colors.grey, fontSize: rf(context, 14))), 
              Text('¥${_calculateTotal(order)}', style: TextStyle(fontSize: rf(context, 24), fontWeight: FontWeight.bold, color: Colors.deepOrange))
            ]
          ),
        ],
      ),
    );
  }

  int _calculateTotal(OrderModel order) {
    return order.items.fold(0, (sum, i) {
      final price = (i['price'] as num?)?.toInt() ?? 0;
      final quantity = (i['quantity'] as num?)?.toInt() ?? 0;
      return sum + price * quantity;
    });
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle(this.title, this.icon);
  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon, size: rs(context, 18), color: Colors.blueGrey), SizedBox(width: rs(context, 8)), Text(title, style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.bold, color: Colors.blueGrey))]);
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  const _InfoRow(this.label, this.value, {this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(vertical: rs(context, 4)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: rf(context, 11), color: Colors.grey)), Text(value, style: TextStyle(fontSize: rf(context, 14), fontWeight: isBold ? FontWeight.bold : FontWeight.normal))]));
  }
}
