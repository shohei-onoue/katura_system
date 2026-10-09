import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:katura_system/utils/app_colors.dart';
import 'package:katura_system/utils/name_format.dart';
import '../models/branch_model.dart';
import '../models/order_model.dart';
import '../services/branch_service.dart';
import '../services/customer_service.dart';
import '../services/delivery_schedule_service.dart';
import '../services/google_maps_service.dart';
import '../services/order_service.dart';
import '../services/reservation_service.dart';
import '../widgets/delivery_schedule_dialog.dart';
import '../widgets/k_button.dart';
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
  DateTime? _selectedDay = DateTime.now();
  bool _loading = true;
  Map<String, String> _names = {}; // 受注ID → 顧客管理の最新の名前
  final GlobalKey _calendarKey = GlobalKey(); // カレンダー枠の高さを測る（右側の高さを合わせる）
  double? _calendarHeight;

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
      _ensureNames(_dayOrders);
    } catch (e) {
      debugPrint('RouteOptimizationScreen load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  List<OrderModel> get _branchOrders =>
      _orders.where((o) => OrderService.isActive(o) && o.branchName == _branchName && o.deliveryType == '配送').toList();

  /// 選択日・選択店舗の配送受注（時間順）。
  List<OrderModel> get _dayOrders {
    final day = _selectedDay;
    if (day == null) return const [];
    return _branchOrders.where((o) => isSameDay(o.deliveryDate, day)).toList()
      ..sort((a, b) => a.deliveryTime.compareTo(b.deliveryTime));
  }

  /// まだ顧客名を取得していない注文だけ、顧客管理の最新の顧客名を取得して追加する。
  Future<void> _ensureNames(List<OrderModel> orders) async {
    final missing = orders.where((o) => !_names.containsKey(o.id)).toList();
    if (missing.isEmpty) return;
    try {
      final names = await CustomerService().resolveOrderNames(missing);
      if (!mounted) return;
      setState(() => _names = {..._names, ...names});
    } catch (_) {}
  }

  String _areaLabel(OrderModel o) {
    final m = RegExp(r'([^\d\s]+?[市区町村])').firstMatch(o.address);
    if (m != null) return m.group(1)!;
    return o.facilityName.isNotEmpty ? o.facilityName : o.address;
  }

  BranchModel? get _selectedBranch => _branches.where((b) => b.name == _branchName).isEmpty
      ? null
      : _branches.firstWhere((b) => b.name == _branchName);

  Future<void> _openSchedule(DateTime day) async {
    final branch = _selectedBranch;
    final reservations = await _reservationService.listByDate(_branchName, day);
    if (!mounted) return;
    // ダイアログではなく画面として表示する（配達日時ダイアログと同じ内容）
    await Navigator.of(context).push<DeliverySlot>(
      MaterialPageRoute(
        builder: (_) => DeliveryScheduleDialog(
          asPage: true,
          date: day,
          orders: _orders.where((o) => OrderService.isActive(o) && o.deliveryType == '配送').toList(),
          reservations: reservations,
          branchPos: branch == null ? null : LatLng(branch.latitude, branch.longitude),
          vehicleCount: branch?.deliveryVehicleCount ?? 1,
          service: _scheduleService,
          allowTimePick: false,
          branchNames: [for (final b in _branches) b.name],
          initialBranch: _branchName,
          branchPositions: {for (final b in _branches) b.name: LatLng(b.latitude, b.longitude)},
          branchVehicleCounts: {for (final b in _branches) b.name: b.deliveryVehicleCount},
          reservationLoader: (name) => _reservationService.listByDate(name, day),
        ),
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
            Text('日付を選ぶと、その日の受注が右に表示されます。「ルート確認」で配達予定を確認できます',
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
                    onSelected: (_) {
                      setState(() => _branchName = b.name);
                      _ensureNames(_dayOrders);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: rs(context, 16)),
            // 左：カレンダー／右：選択日の受注カード＋「ルート確認」ボタン（受注機能の配達日時ダイアログと同じ配置）
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: _buildCalendar(context)),
                    SizedBox(width: rs(context, 12)),
                    Expanded(
                      flex: 3,
                      child: SizedBox(height: _calendarHeight ?? rs(context, 420), child: _buildDayOrdersArea(context)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    // カレンダー枠の高さを測り、右側（カード＋ボタン）の下端をカレンダーの下端に合わせる
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final h = _calendarKey.currentContext?.size?.height;
      if (mounted && h != null && (_calendarHeight == null || (h - _calendarHeight!).abs() > 0.5)) {
        setState(() => _calendarHeight = h);
      }
    });
    return Container(
      key: _calendarKey,
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
          _ensureNames(_dayOrders);
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
    );
  }

  /// 選択日の受注カード一覧。
  Widget _buildDayOrdersPanel(BuildContext context) {
    final list = _dayOrders;
    final day = _selectedDay;
    return Container(
      padding: EdgeInsets.all(rs(context, 8)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${day == null ? '' : '${DateFormat('M/d(E)', 'ja_JP').format(day)} の'}受注 ${list.length}件',
              style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
          SizedBox(height: rs(context, 6)),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text('受注なし', style: TextStyle(fontSize: rf(context, 12), color: Colors.grey)))
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (context, index) => SizedBox(height: rs(context, 6)),
                    itemBuilder: (context, i) {
                      final o = list[i];
                      final place = o.facilityName.isNotEmpty ? o.facilityName : _areaLabel(o);
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 6)),
                        decoration: BoxDecoration(
                          color: AppColors.mainBackground,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(rs(context, 8)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${o.deliveryTime}  ${_areaLabel(o)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: rf(context, 11), fontWeight: FontWeight.bold, color: AppColors.primary)),
                            Text(withHonorific(_names[o.id] ?? o.customerName),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                            Text(place,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: rf(context, 11), color: AppColors.secondaryText)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 受注カード枠の外（下）に「ルート確認」ボタンを置いた右側エリア。
  Widget _buildDayOrdersArea(BuildContext context) {
    final day = _selectedDay;
    return Column(
      children: [
        Expanded(child: _buildDayOrdersPanel(context)),
        SizedBox(height: rs(context, 8)),
        KButton(
          label: 'ルート確認',
          color: AppColors.acceptButton,
          onPressed: day == null ? null : () => _openSchedule(day),
        ),
      ],
    );
  }
}
