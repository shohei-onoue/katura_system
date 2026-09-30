import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/order_model.dart';
import '../services/customer_service.dart';
import '../services/order_service.dart';
import '../widgets/k_responsive.dart';
import 'order_list/widgets/order_list_card.dart';
import 'package:katura_system/utils/app_colors.dart';

class OrderListScreen extends StatefulWidget {
  final Function(OrderModel, String)? onEditOrder;

  const OrderListScreen({super.key, this.onEditOrder});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final _orderService = OrderService();
  final _customerService = CustomerService();
  Map<String, String> _displayNames = {}; // 受注ID → 顧客管理の最新の名前
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = true;
  String? _expandedOrderId; // 展開中の受注（1枚だけ）
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedBranch = '全店舗';

  static const List<String> _branchTabs = ['全店舗', '岡崎店', '名古屋店', '岐阜店'];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadOrders();
    // 受注入力での確定など、受注が変わったら自動で更新する（最初の1回は上の読み込みと重複するため飛ばす）
    _ordersSub = _orderService.watchOrders().skip(1).listen((_) => _loadOrders(showLoading: false));
  }

  StreamSubscription<List<OrderModel>>? _ordersSub;

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }

  Future<void> _loadOrders({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }
    final list = await _orderService.getAllOrders(forceRefresh: true);
    final customers = await _customerService.getAllCustomers();
    if (!mounted) return;
    final byId = {for (final c in customers) c.id: c.name};
    // 旧データ（顧客IDなし）は電話番号（数字のみ）で1件だけ一致した顧客の名前を使う
    String digits(String v) => v.replaceAll(RegExp(r'[^0-9]'), '');
    final byPhone = <String, List<String>>{};
    for (final c in customers) {
      final d = digits(c.phoneNumber);
      if (d.isNotEmpty) byPhone.putIfAbsent(d, () => []).add(c.name);
    }
    final names = <String, String>{};
    for (final o in list) {
      final byIdName = byId[o.customerId];
      final phoneMatches = byPhone[digits(o.phoneNumber)];
      if (byIdName != null) {
        names[o.id] = byIdName;
      } else if (o.customerId.isEmpty && phoneMatches != null && phoneMatches.length == 1) {
        names[o.id] = phoneMatches.first;
      }
    }
    setState(() {
      _displayNames = names;
      _allOrders = list.where(OrderService.isActive).toList();
      _filterOrdersByDay(_selectedDay!);
      _isLoading = false;
    });
  }

  Future<void> _cancelOrder(OrderModel order) async {
    // 当日キャンセルはキャンセル料100%を確認し、削除せず履歴（status）として残す
    if (isSameDay(order.deliveryDate, DateTime.now())) {
      final agreed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.popupBackground,
          title: const Text('当日キャンセルの確認'),
          content: Text('${order.customerName} 様の予約は当日のため、キャンセル料は100％になります。よろしいですか？'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('戻る')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('了承'),
            ),
          ],
        ),
      );
      if (agreed == true) {
        await _orderService.updateOrderStatus(order.id, '当日キャンセル');
        _loadOrders();
      }
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.popupBackground,
          title: const Text('予約キャンセルの確認'),
          content: Text('${order.customerName} 様の予約をキャンセルし、登録内容を削除します。元に戻せません。よろしいですか？'),
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
      await _orderService.deleteOrder(order.id);
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
        foregroundColor: AppColors.primaryText,
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
            color: AppColors.mainBackground,
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
                    todayDecoration: BoxDecoration(color: AppColors.accentOrange.withValues(alpha: 0.3), shape: BoxShape.circle),
                    selectedDecoration: const BoxDecoration(color: AppColors.accentOrange, shape: BoxShape.circle),
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
                            border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.5), width: rs(context, 2)),
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
      color: AppColors.mainBackground,
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
                    color: selected ? AppColors.mainBackground : color,
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
          displayName: _displayNames[orders[index].id],
          expanded: _expandedOrderId == orders[index].id,
          onToggle: () => setState(() => _expandedOrderId = _expandedOrderId == orders[index].id ? null : orders[index].id),
          onEdit: (order, section) {
            widget.onEditOrder?.call(order, section);
          },
          onCancel: (order) {
            _cancelOrder(order);
          },
        );
      },
    );
  }
}
