import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../widgets/k_responsive.dart';
import 'order_list/widgets/order_list_card.dart';
import 'package:katura_system/utils/app_colors.dart';

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
  String _selectedBranch = '全店舗';

  static const List<String> _branchTabs = ['全店舗', '岡崎店', '名古屋店', '岐阜店'];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });
    final list = await _orderService.getAllOrders();
    if (!mounted) return;
    setState(() {
      _allOrders = list.where((order) {
        return order.status != '配送済み' && order.status != 'キャンセル済み';
      }).toList();
      _filterOrdersByDay(_selectedDay!);
      _isLoading = false;
    });
  }

  Future<void> _cancelOrder(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.popupBackground,
          title: const Text('受注のキャンセル'),
          content: Text('${order.customerName} 様の受注をキャンセルしますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('いいえ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('はい、キャンセルします'),
            ),
          ],
        );
      },
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
        title: Text('受注一覧・工程管理', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 18))),
        backgroundColor: AppColors.mainBackground,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadOrders();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: rs(context, 350),
            color: AppColors.background,
            padding: EdgeInsets.all(rav(context, 16)),
            child: Column(
              children: [
                TableCalendar(
                  locale: 'ja_JP',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _filterOrdersByDay(selectedDay);
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.3), shape: BoxShape.circle),
                    selectedDecoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    defaultTextStyle: TextStyle(fontSize: rf(context, 14)),
                    weekendTextStyle: TextStyle(fontSize: rf(context, 14), color: Colors.red),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false, 
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (_allOrders.any((order) {
                        return isSameDay(order.deliveryDate, day);
                      })) {
                        return Container(
                          margin: EdgeInsets.all(rav(context, 4.0)),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.orange.withValues(alpha: 0.5), width: rs(context, 2)),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBranchTabs(),
                      const Divider(height: 1),
                      Expanded(child: _buildOrderList()),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Color _branchTabColor(String tab) {
    switch (tab) {
      case '岡崎店':
        return Colors.blue;
      case '名古屋店':
        return Colors.green;
      case '岐阜店':
        return Colors.purple;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildBranchTabs() {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: rav(context, 12), vertical: rs(context, 6)),
      child: Row(
        children: _branchTabs.map((tab) {
          final bool selected = _selectedBranch == tab;
          final Color color = _branchTabColor(tab);
          return Padding(
            padding: EdgeInsets.only(right: rs(context, 6)),
            child: InkWell(
              onTap: () => setState(() => _selectedBranch = tab),
              borderRadius: BorderRadius.circular(rs(context, 8)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 14), vertical: rs(context, 8)),
                decoration: BoxDecoration(
                  color: selected ? color : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(rs(context, 8)),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    fontSize: rf(context, 13),
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? AppColors.background : color,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<OrderModel> get _visibleOrders {
    if (_selectedBranch == '全店舗') return _filteredOrders;
    final key = _selectedBranch.replaceAll('店', '');
    return _filteredOrders.where((o) => o.branchName.contains(key)).toList();
  }

  Widget _buildOrderList() {
    final orders = _visibleOrders;
    if (orders.isEmpty) {
      return Center(child: Text('この日の受注はありません', style: TextStyle(fontSize: rf(context, 16))));
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(rav(context, 24), rav(context, 24), 0, rav(context, 24)),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return OrderListCard(
          order: orders[index],
          onEdit: (order) {
            widget.onEditOrder?.call(order);
          },
          onCancel: (order) {
            _cancelOrder(order);
          },
        );
      },
    );
  }
}
