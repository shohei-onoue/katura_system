import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../widgets/k_responsive.dart';
import 'package:katura_system/utils/app_colors.dart';

class OrderProcessBar extends StatelessWidget {
  final OrderModel order;

  const OrderProcessBar({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    Color orderColor = Colors.green;
    Color cookColor = Colors.pink.shade100;
    Color deliverColor = Colors.pink.shade100;

    switch (order.status) {
      case '受注済み':
        cookColor = Colors.pink.shade100;
        deliverColor = Colors.pink.shade100;
        break;
      case '調理中':
        cookColor = Colors.orange;
        deliverColor = Colors.pink.shade100;
        break;
      case '調理完了':
        cookColor = Colors.green;
        deliverColor = Colors.pink.shade100;
        break;
      case '配送中':
        cookColor = Colors.green;
        deliverColor = Colors.orange;
        break;
      case '配送済み':
        cookColor = Colors.green;
        deliverColor = Colors.green;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: rs(context, 12), horizontal: rs(context, 20)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.vertical(top: Radius.circular(rs(context, 16))),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          _buildProcessStep(context, "受注", orderColor, "${order.receptionDate.month}/${order.receptionDate.day}"),
          _buildProcessConnector(context, orderColor == Colors.green && cookColor != Colors.pink.shade100),
          _buildProcessStep(context, "調理", cookColor, _getCookingTime(order)),
          _buildProcessConnector(context, cookColor == Colors.green && deliverColor != Colors.pink.shade100),
          _buildProcessStep(context, "配送", deliverColor, order.deliveryTime),
        ],
      ),
    );
  }

  Widget _buildProcessStep(BuildContext context, String label, Color color, String time) {
    bool isDone = color == Colors.green;
    bool isActive = color == Colors.orange;

    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: rs(context, 24),
                height: rs(context, 24),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: isDone 
                  ? Icon(Icons.check, size: rs(context, 16), color: AppColors.background)
                  : isActive 
                    ? Padding(
                        padding: EdgeInsets.all(rs(context, 4.0)),
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                      )
                    : null,
              ),
              SizedBox(width: rs(context, 8)),
              Text(label, style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: isActive ? Colors.orange : isDone ? Colors.green : Colors.grey,
                fontSize: rf(context, 14),
              )),
            ],
          ),
          SizedBox(height: rs(context, 4)),
          Text(time, style: TextStyle(fontSize: rf(context, 11), color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildProcessConnector(BuildContext context, bool active) {
    return Container(
      width: rs(context, 40),
      height: rs(context, 2),
      color: active ? Colors.green : Colors.grey[300],
    );
  }

  String _getCookingTime(OrderModel order) {
    try {
      final parts = order.deliveryTime.split(':');
      int hour = int.parse(parts[0]);
      int min = int.parse(parts[1]);
      
      DateTime dt = DateTime(2024, 1, 1, hour, min);
      DateTime cookDt = dt.subtract(const Duration(minutes: 30));
      
      return "${cookDt.hour}:${cookDt.minute.toString().padLeft(2, '0')} 頃";
    } catch (e) {
      return "--:--";
    }
  }
}
