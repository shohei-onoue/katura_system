import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../widgets/k_responsive.dart';
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
      margin: EdgeInsets.only(bottom: rs(context, 12)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rs(context, 12)),
        side: BorderSide(color: branchColor.withValues(alpha: 0.2), width: 1),
      ),
      elevation: 2,
      child: Column(
        children: [
          OrderProcessBar(order: order),
          Padding(
            padding: EdgeInsets.all(rs(context, 12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  order.customerName, 
                                  style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: rs(context, 8)),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 2)),
                                decoration: BoxDecoration(
                                  color: branchColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: branchColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  order.branchName,
                                  style: TextStyle(color: branchColor, fontSize: rf(context, 10), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          if (order.facilityName.isNotEmpty)
                            Text(
                              order.facilityName, 
                              style: TextStyle(color: Colors.grey[600], fontSize: rf(context, 13)),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMainTimeDisplay(context, order),
                        SizedBox(width: rs(context, 12)),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.edit, color: Colors.blueGrey, size: rs(context, 20)),
                          onPressed: () => onEdit(order),
                        ),
                        SizedBox(width: rs(context, 8)),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.cancel_outlined, color: Colors.redAccent, size: rs(context, 20)),
                          onPressed: () => onCancel(order),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: rs(context, 8)),
                Row(
                  children: [
                    Icon(Icons.location_on, size: rs(context, 14), color: Colors.grey),
                    SizedBox(width: rs(context, 4)),
                    Expanded(
                      child: Text(
                        "${order.address}${order.deliveryLocation.isNotEmpty ? ' (${order.deliveryLocation})' : ''}", 
                        style: TextStyle(fontSize: rf(context, 12), color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Divider(height: rs(context, 16)),
                Wrap(
                  spacing: rs(context, 6),
                  runSpacing: rs(context, 6),
                  children: order.items.map((item) => Container(
                    padding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rs(context, 4)),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(rs(context, 6)),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
                    ),
                    child: Text("${item['name']} x${item['quantity']}", 
                      style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.w500)),
                  )).toList(),
                ),
                SizedBox(height: rs(context, 12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("支払: ${order.paymentMethod} / 梱包: ${order.packagingType}", 
                      style: TextStyle(color: Colors.blueGrey, fontSize: rf(context, 11))),
                    Text("${order.totalCount} 個 / ¥${order.totalPrice}", 
                      style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTimeDisplay(BuildContext context, OrderModel order) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 4)),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(rs(context, 8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('配送予定', style: TextStyle(fontSize: rf(context, 9), color: Colors.deepOrange)),
          Text(order.deliveryTime, 
            style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
        ],
      ),
    );
  }
}
