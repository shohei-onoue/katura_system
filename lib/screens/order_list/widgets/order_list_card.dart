import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../widgets/k_responsive.dart';

class OrderListCard extends StatefulWidget {
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
  State<OrderListCard> createState() => _OrderListCardState();
}

class _OrderListCardState extends State<OrderListCard> {
  bool _expanded = false;

  Color get _branchColor {
    switch (widget.order.branchName) {
      case '名古屋店':
        return Colors.green;
      case '岐阜店':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  /// 今日時点での進捗ステータスカード（配達日と本日の差で判定）
  Widget _buildStatusBadge(BuildContext context, OrderModel order) {
    final today = DateUtils.dateOnly(DateTime.now());
    final delivery = DateUtils.dateOnly(order.deliveryDate);
    final diff = delivery.difference(today).inDays;

    final String label;
    final Color color;
    if (diff < 0) {
      label = '完了';
      color = Colors.green;
    } else if (diff == 0) {
      label = '本日';
      color = Colors.deepOrange;
    } else if (diff == 1) {
      label = '前日';
      color = Colors.orange;
    } else {
      label = '予定';
      color = Colors.blueGrey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 3)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(rs(context, 6)),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: rf(context, 11), fontWeight: FontWeight.bold, color: color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final String preMethod = order.preConfirmationMethod.isEmpty ? '事前連絡なし' : order.preConfirmationMethod;
    final String deliveryDateTime = '${order.deliveryDate.month}/${order.deliveryDate.day} ${order.deliveryTime}';

    return Card(
      margin: EdgeInsets.only(bottom: rs(context, 12)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rs(context, 12)),
        side: BorderSide(color: _branchColor.withValues(alpha: 0.2), width: rs(context, 1)),
      ),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダーROW（ステータス / 顧客名 / 所属企業 / 担当店舗 / ︙）
                Container(
                  width: double.infinity,
                  color: _branchColor.withValues(alpha: 0.18),
                  padding: EdgeInsets.fromLTRB(rs(context, 12), rs(context, 8), 0, rs(context, 8)),
                  child: Row(
                    children: [
                      _buildStatusBadge(context, order),
                      SizedBox(width: rs(context, 8)),
                      Flexible(
                        child: Text(
                          order.customerName,
                          style: TextStyle(fontSize: rf(context, 22), fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (order.facilityName.isNotEmpty) ...[
                        SizedBox(width: rs(context, 8)),
                        Flexible(
                          child: Text(
                            order.facilityName,
                            style: TextStyle(fontSize: rf(context, 13), color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                      const Spacer(),
                      SizedBox(width: rs(context, 8)),
                      Text(
                        order.branchName,
                        style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: _branchColor),
                      ),
                      SizedBox(width: rs(context, 4)),
                      // 右端に密着させるため：icon: ではなく child:（余分なタップ領域が付かない）
                      // ＋ コンテナ右パディング0 ＋ Transform で more_vert 字形の右サイドベアリング分を
                      // カード端へ押し出し、Card の clipBehavior で透明部分をクリップする。
                      Transform.translate(
                        offset: Offset(rs(context, 6), 0),
                        child: PopupMenuButton<String>(
                          tooltip: '',
                          padding: EdgeInsets.zero,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: rs(context, 8), top: rs(context, 6), bottom: rs(context, 6)),
                            child: Icon(Icons.more_vert, size: rs(context, 20), color: Colors.blueGrey),
                          ),
                          onSelected: (v) {
                            if (v == 'edit') {
                              widget.onEdit(order);
                            } else if (v == 'cancel') {
                              widget.onCancel(order);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(children: [
                                Icon(Icons.edit, size: rs(context, 18), color: Colors.blue),
                                SizedBox(width: rs(context, 8)),
                                const Text('編集'),
                              ]),
                            ),
                            PopupMenuItem(
                              value: 'cancel',
                              child: Row(children: [
                                Icon(Icons.cancel_outlined, size: rs(context, 18), color: Colors.red),
                                SizedBox(width: rs(context, 8)),
                                const Text('キャンセル', style: TextStyle(color: Colors.red)),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 配達日時 / 事前連絡方法
                Padding(
                  padding: EdgeInsets.fromLTRB(rs(context, 12), rs(context, 8), rs(context, 12), rs(context, 10)),
                  child: Row(
                    children: [
                      Icon(Icons.event, size: rs(context, 18), color: Colors.deepOrange),
                      SizedBox(width: rs(context, 4)),
                      Text(
                        deliveryDateTime,
                        style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: Colors.deepOrange),
                      ),
                      SizedBox(width: rs(context, 16)),
                      Icon(Icons.notifications_active_outlined, size: rs(context, 18), color: Colors.blueGrey),
                      SizedBox(width: rs(context, 4)),
                      Text(preMethod, style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.w500, color: Colors.blueGrey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // アコーディオン展開部：注文内容 + 合計金額
          if (_expanded)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(rs(context, 12), rs(context, 10), rs(context, 12), rs(context, 12)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: rs(context, 6),
                    runSpacing: rs(context, 6),
                    children: order.items
                        .map((item) => Container(
                              padding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rs(context, 4)),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(rs(context, 6)),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
                              ),
                              child: Text(
                                "${item['name']} x${item['quantity']}",
                                style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.w500),
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: rs(context, 10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('合計金額', style: TextStyle(fontSize: rf(context, 12), color: Colors.grey.shade700)),
                      Text(
                        '${order.totalCount} 個 / ¥${order.totalPrice}',
                        style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: Colors.deepOrange),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
