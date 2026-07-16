import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderListScreen extends StatefulWidget {
  final Function(OrderModel)? onEditOrder;

  const OrderListScreen({super.key, this.onEditOrder});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final _orderService = OrderService();
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = true;
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final list = await _orderService.getAllOrders();
    setState(() {
      // 配送済みおよびキャンセル済み以外のデータのみを表示
      _allOrders = list.where((order) => 
        order.status != '配送済み' && order.status != 'キャンセル済み'
      ).toList();
      _filterOrdersByDay(_selectedDay!);
      _isLoading = false;
    });
  }

  Future<void> _cancelOrder(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('受注のキャンセル'),
        content: Text('${order.customerName} 様の受注をキャンセルしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('いいえ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('はい、キャンセルします'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _orderService.updateOrderStatus(order.id, 'キャンセル済み');
      _loadOrders();
    }
  }

  void _filterOrdersByDay(DateTime day) {
    setState(() {
      _filteredOrders = _allOrders.where((order) {
        return isSameDay(order.deliveryDate, day);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('受注一覧・工程管理', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 350,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _filterOrdersByDay(selectedDay);
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      final ordersOnDay = _allOrders.where((order) => isSameDay(order.deliveryDate, day)).toList();
                      if (ordersOnDay.isNotEmpty) {
                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                const Divider(height: 32),
                _buildSummaryCard(),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildOrderList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final dayStr = "${_selectedDay?.month}/${_selectedDay?.day}";
    
    final branches = [
      {'name': '岡崎本店', 'color': Colors.blue},
      {'name': '名古屋店', 'color': Colors.green},
      {'name': '岐阜店', 'color': Colors.purple},
    ];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text('$dayStr の店舗別概要', 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(height: 8),
        ...branches.map((branch) {
          final branchName = branch['name'] as String;
          final color = branch['color'] as Color;
          final branchOrders = _filteredOrders.where((o) => o.branchName == branchName).toList();
          final totalCount = branchOrders.fold(0, (sum, o) => sum + o.totalCount);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(branchName, 
                      style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                    Text('${branchOrders.length} 件', 
                      style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                  ],
                ),
                Text('$totalCount 個', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOrderList() {
    if (_filteredOrders.isEmpty) {
      return const Center(child: Text('この日の受注はありません'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        
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
              _buildProcessBar(order),
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
                              onPressed: () {
                                if (widget.onEditOrder != null) {
                                  widget.onEditOrder!(order);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                              tooltip: 'この受注をキャンセル',
                              onPressed: () => _cancelOrder(order),
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
      },
    );
  }

  Widget _buildProcessBar(OrderModel order) {
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          _buildProcessStep("受注", orderColor, "${order.receptionDate.month}/${order.receptionDate.day}"),
          _buildProcessConnector(orderColor == Colors.green && cookColor != Colors.pink.shade100),
          _buildProcessStep("調理", cookColor, _getCookingTime(order)),
          _buildProcessConnector(cookColor == Colors.green && deliverColor != Colors.pink.shade100),
          _buildProcessStep("配送", deliverColor, order.deliveryTime),
        ],
      ),
    );
  }

  Widget _buildProcessStep(String label, Color color, String time) {
    bool isDone = color == Colors.green;
    bool isActive = color == Colors.orange;

    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: isDone 
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : isActive 
                    ? const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: isActive ? Colors.orange : isDone ? Colors.green : Colors.grey,
                fontSize: 14,
              )),
            ],
          ),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildProcessConnector(bool active) {
    return Container(
      width: 40,
      height: 2,
      color: active ? Colors.green : Colors.grey[300],
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
