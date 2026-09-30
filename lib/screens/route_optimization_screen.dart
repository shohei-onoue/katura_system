import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:katura_system/utils/app_colors.dart';
import '../models/branch_model.dart';
import '../models/order_model.dart';
import '../services/branch_service.dart';
import '../services/delivery_schedule_service.dart';
import '../services/google_maps_service.dart';
import '../services/order_service.dart';
import '../services/reservation_service.dart';
import '../widgets/delivery_schedule_dialog.dart';
import '../widgets/k_responsive.dart';

/// 配送ルート最適化機能。これまでダイヤログの中に隠れていた「日時選択（カレンダー）」を、
/// この画面ではポップアップではなく常時表示の画面として置く。
/// 日付をタップすると、選んだ店舗・その日の配達予定ダイヤログ（号車ごとの時間軸）を開く。
/// 実際のルート最適化（順序の自動並べ替えなど）は、今後この画面に追加していく。
class RouteOptimizationScreen extends StatefulWidget {
  const RouteOptimizationScreen({super.key});

  @override
  State<RouteOptimizationScreen> createState() => _RouteOptimizationScreenState();
}

class _RouteOptimizationScreenState extends State<RouteOptimizationScreen> {
  final BranchService _branchService = BranchService();
  final OrderService _orderService = OrderService();
  final ReservationService _reservationService = ReservationService();
  late final DeliveryScheduleService _scheduleService = DeliveryScheduleService(GoogleMapsService());

  List<BranchModel> _branches = [];
  List<OrderModel> _orders = [];
  String _branchName = '';
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    // 受注が変わったら自動で反映する
    _ordersSub = _orderService.watchOrders().listen((orders) {
      if (mounted) setState(() => _orders = orders);
    });
  }

  StreamSubscription<List<OrderModel>>? _ordersSub;

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final branches = await _branchService.getAllBranches();
      final orders = await _orderService.getAllOrders(forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _branches = branches;
        _orders = orders;
        if (_branchName.isEmpty && branches.isNotEmpty) _branchName = branches.first.name;
        _loading = false;
      });
    } catch (e) {
      debugPrint('RouteOptimizationScreen load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  List<OrderModel> get _branchOrders =>
      _orders.where((o) => OrderService.isActive(o) && o.branchName == _branchName && o.deliveryType == '配送').toList();

  BranchModel? get _selectedBranch => _branches.where((b) => b.name == _branchName).isEmpty
      ? null
      : _branches.firstWhere((b) => b.name == _branchName);

  Future<void> _openSchedule(DateTime day) async {
    final branch = _selectedBranch;
    final reservations = await _reservationService.listByDate(_branchName, day);
    if (!mounted) return;
    await showDialog<DeliverySlot>(
      context: context,
      builder: (_) => DeliveryScheduleDialog(
        date: day,
        orders: _branchOrders,
        reservations: reservations,
        branchPos: branch == null ? null : LatLng(branch.latitude, branch.longitude),
        vehicleCount: branch?.deliveryVehicleCount ?? 1,
        service: _scheduleService,
        allowTimePick: false,
      ),
    );
    // ここでは閲覧のみ（この画面から受注を作らないため、決定結果は使わない）。
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: Padding(
        padding: EdgeInsets.all(rs(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('配送ルート最適化', style: TextStyle(fontSize: rf(context, 22), fontWeight: FontWeight.bold, color: AppColors.primary)),
            SizedBox(height: rs(context, 6)),
            Text('日付をタップすると、その日・その店舗の配達予定を確認できます',
                style: TextStyle(fontSize: rf(context, 13), color: AppColors.secondaryText)),
            SizedBox(height: rs(context, 16)),
            // 店舗選択
            SizedBox(
              height: rs(context, 40),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _branches.length,
                separatorBuilder: (_, __) => SizedBox(width: rs(context, 8)),
                itemBuilder: (context, i) {
                  final b = _branches[i];
                  final selected = b.name == _branchName;
                  return ChoiceChip(
                    label: Text(b.name),
                    selected: selected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.primaryText, fontWeight: FontWeight.bold),
                    onSelected: (_) => setState(() => _branchName = b.name),
                  );
                },
              ),
            ),
            SizedBox(height: rs(context, 16)),
            // 日時選択（カレンダー）：これまでダイヤログだった部分を画面としてそのまま表示
            Container(
              padding: EdgeInsets.all(rs(context, 12)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(rs(context, 12)),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 30)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                currentDay: DateTime.now(),
                locale: 'ja_JP',
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  selectedTextStyle: const TextStyle(color: AppColors.whiteText, fontWeight: FontWeight.bold),
                  todayDecoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: rs(context, 1.5)),
                  ),
                  todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                selectedDayPredicate: (day) => _selectedDay != null && isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _openSchedule(selectedDay);
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                rowHeight: rs(context, 50),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    if (!_branchOrders.any((o) => isSameDay(o.deliveryDate, day))) return null;
                    return Center(
                      child: Container(
                        width: rs(context, 36),
                        height: rs(context, 36),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accentOrange, width: rs(context, 1.5)),
                        ),
                        child: Text('${day.day}'),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: rs(context, 12)),
            if (_selectedDay != null)
              Text(
                '${DateFormat('M/d(E)', 'ja_JP').format(_selectedDay!)} の配送: ${_branchOrders.where((o) => isSameDay(o.deliveryDate, _selectedDay!)).length}件',
                style: TextStyle(fontSize: rf(context, 13), color: AppColors.secondaryText),
              ),
          ],
        ),
      ),
    );
  }
}
