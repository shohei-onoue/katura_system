import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart' show isSameDay;
import '../models/order_model.dart';
import '../services/customer_service.dart';
import '../services/order_service.dart';
import '../widgets/k_responsive.dart';
import 'order_list/widgets/order_list_card.dart';
import 'package:katura_system/utils/app_colors.dart';
import 'package:katura_system/utils/name_format.dart';

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
  
  DateTime _focusedDay = _dateOnly(DateTime.now());
  DateTime? _selectedDay;
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  final DateTime _dateTabsStart = DateTime(2020, 1, 1);
  final int _dateTabsCount = 365 * 11;
  bool _dateTabsScrolled = false;
  ScrollController? _dateTabsController;
  String _selectedBranch = '全店舗';

  static const List<String> _branchTabs = ['全店舗', '岡崎店', '名古屋店', '岐阜店'];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadOrders();
    // 受注入力での確定など、受注が変わったら自動で更新する（最初の1回は上の読み込みと重複するため飛ばす）
    _ordersSub = _orderService.watchOrders().skip(1).listen((_) => _loadOrders(showLoading: false, refresh: false));
  }

  StreamSubscription<List<OrderModel>>? _ordersSub;

  @override
  void dispose() {
    _ordersSub?.cancel();
    _dateTabsController?.dispose();
    super.dispose();
  }

  Future<void> _loadOrders({bool showLoading = true, bool refresh = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }
    final list = await _orderService.getAllOrders(forceRefresh: refresh);
    final names = await _customerService.resolveOrderNames(list);
    if (!mounted) return;
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
          content: Text('${withHonorific(_displayNames[order.id] ?? order.customerName)}の予約は当日のため、キャンセル料は100％になります。よろしいですか？'),
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
          content: Text('${withHonorific(_displayNames[order.id] ?? order.customerName)}の予約をキャンセルし、登録内容を削除します。元に戻せません。よろしいですか？'),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateTabs(),
          const Divider(height: 1),
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

  // 日付の横並びタブ（横スクロール）。今日を最初に選択・中央表示する
  Widget _buildDateTabs() {
    final itemW = rs(context, 64);
    return Container(
      color: AppColors.mainBackground,
      height: rs(context, 78),
      child: LayoutBuilder(builder: (context, c) {
        final todayIndex = _dateTabsStart.difference(_dateOnly(DateTime.now())).inDays.abs();
        if (!_dateTabsScrolled) {
          _dateTabsScrolled = true;
          _dateTabsController = ScrollController(initialScrollOffset: (todayIndex * itemW - (c.maxWidth - itemW) / 2).clamp(0.0, double.infinity));
        }
        const weeks = ['月', '火', '水', '木', '金', '土', '日'];
        return ListView.builder(
          controller: _dateTabsController,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: rav(context, 8), vertical: rs(context, 8)),
          itemCount: _dateTabsCount,
          itemExtent: itemW,
          itemBuilder: (context, i) {
            final day = _dateTabsStart.add(Duration(days: i));
            final selected = isSameDay(_selectedDay, day);
            final isToday = isSameDay(day, DateTime.now());
            final hasOrder = _allOrders.any((o) => isSameDay(o.deliveryDate, day));
            final wd = day.weekday;
            final baseColor = wd == DateTime.sunday ? Colors.red : (wd == DateTime.saturday ? Colors.blue : AppColors.primaryText);
            final fg = selected ? AppColors.mainBackground : baseColor;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 3)),
              child: InkWell(
                borderRadius: BorderRadius.circular(rs(context, 8)),
                onTap: () {
                  setState(() {
                    _selectedDay = day;
                    _focusedDay = day;
                  });
                  _filterOrdersByDay(day);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accentOrange : (isToday ? AppColors.accentOrange.withValues(alpha: 0.3) : Colors.transparent),
                    borderRadius: BorderRadius.circular(rs(context, 8)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(day.day == 1 || i == 0 ? '${day.month}月' : '', style: TextStyle(fontSize: rf(context, 10), color: fg)),
                      Text('${day.day}', style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: fg)),
                      Text(weeks[wd - 1], style: TextStyle(fontSize: rf(context, 11), color: fg)),
                      SizedBox(
                        height: rs(context, 6),
                        child: hasOrder ? Icon(Icons.circle, size: rs(context, 5), color: selected ? AppColors.mainBackground : AppColors.accentOrange) : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
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
    final delivery = orders.where((o) => o.deliveryType != '引取').toList();
    final pickup = orders.where((o) => o.deliveryType == '引取').toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildOrderColumn('配達', Icons.directions_car, delivery)),
        VerticalDivider(width: 1, color: Colors.grey[300]),
        Expanded(child: _buildOrderColumn('引取り', Icons.volunteer_activism, pickup)),
      ],
    );
  }

  Widget _buildOrderColumn(String label, IconData icon, List<OrderModel> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(rav(context, 24), rav(context, 12), 0, 0),
          child: Row(
            children: [
              Icon(icon, size: rf(context, 20), color: AppColors.primaryText),
              SizedBox(width: rs(context, 6)),
              Text(label, style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: AppColors.primaryText)),
            ],
          ),
        ),
        Expanded(
          child: orders.isEmpty
              ? Center(child: Text('この日の受注はありません', style: TextStyle(fontSize: rf(context, 16))))
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(rav(context, 24), rav(context, 12), 0, rav(context, 24)),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return OrderListCard(
                      order: order,
                      displayName: _displayNames[order.id],
                      expanded: _expandedOrderId == order.id,
                      onToggle: () => setState(() => _expandedOrderId = _expandedOrderId == order.id ? null : order.id),
                      onEdit: (order, section) {
                        widget.onEditOrder?.call(order, section);
                      },
                      onCancel: (order) {
                        _cancelOrder(order);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
