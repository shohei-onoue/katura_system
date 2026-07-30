import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'order_list/widgets/order_list_card.dart';
import 'order_list/widgets/order_summary_panel.dart';

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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('いいえ')),
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
      _filteredOrders = _allOrders.where((order) => isSameDay(order.deliveryDate, day)).toList();
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
                    setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; });
                    _filterOrdersByDay(selectedDay);
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(color: Colors.orange.withOpacity(0.3), shape: BoxShape.circle),
                    selectedDecoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                  ),
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (_allOrders.any((order) => isSameDay(order.deliveryDate, day))) {
                        return Container(margin: const EdgeInsets.all(4.0), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2)));
                      }
                      return null;
                    },
                  ),
                ),
                const Divider(height: 32),
                if (_selectedDay != null) OrderSummaryPanel(selectedDay: _selectedDay!, orders: _filteredOrders),
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

  Widget _buildOrderList() {
    if (_filteredOrders.isEmpty) return const Center(child: Text('この日の受注はありません'));
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) => OrderListCard(
        order: _filteredOrders[index],
        onEdit: (order) => widget.onEditOrder?.call(order),
        onCancel: _cancelOrder,
      ),
    );
  }
}
