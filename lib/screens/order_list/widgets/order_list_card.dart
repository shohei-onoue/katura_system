import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import 'order_process_bar.dart';

class OrderListCard extends StatelessWidget {
  final OrderModel order;
  final Function(OrderModel) onEdit;
  final Function(OrderModel) onCancel;

  const OrderListCard({
    super.key,
    required this.order,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    // 店舗ごとのテーマカラー
    Color branchColor;
    switch (order.branchName) {
      case '名古屋店':
        branchColor = Colors.green;
        break;
      case '岐阜店':
        branchColor = Colors.purple;
        break;
      default:
        branchColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: branchColor.withOpacity(0.3), width: 1),
      ),
      elevation: 3,
      child: Column(
        children: [
          OrderProcessBar(order: order),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(order.customerName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: branchColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: branchColor.withOpacity(0.5)),
                              ),
                              child: Text(
                                order.branchName,
                                style: TextStyle(color: branchColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        if (order.facilityName.isNotEmpty)
                          Text(order.facilityName, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                      ],
                    ),
                    Row(
                      children: [
                        _buildMainTimeDisplay(order),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          tooltip: 'この受注を編集',
                          onPressed: () => onEdit(order),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                          tooltip: 'この受注をキャンセル',
                          onPressed: () => onCancel(order),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${order.address}${order.deliveryLocation.isNotEmpty ? ' (${order.deliveryLocation})' : ''}", 
                        style: const TextStyle(fontSize: 14, color: Colors.grey)
                      ),
                    ),
                    if (order.receiverName.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.person_outline, size: 16, color: Colors.blueGrey),
                      const SizedBox(width: 4),
                      Text(order.receiverName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    ],
                  ],
                ),
                const Divider(height: 32),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: order.items.map((item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.1)),
                    ),
                    child: Text("${item['name']} x${item['quantity']}", 
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("支払: ${order.paymentMethod} / 梱包: ${order.packagingType}", 
                      style: const TextStyle(color: Colors.blueGrey, fontSize: 13)),
                    Text("合計 ${order.totalCount} 個", 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTimeDisplay(OrderModel order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('配送予定', style: TextStyle(fontSize: 10, color: Colors.deepOrange)),
          Text(order.deliveryTime, 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
        ],
      ),
    );
  }
}
