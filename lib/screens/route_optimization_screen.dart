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
import '../services/date_warning_service.dart';
import '../services/delivery_schedule_service.dart';
import '../services/google_maps_service.dart';
import '../services/order_service.dart';
import '../services/reservation_service.dart';
import '../widgets/delivery_schedule_dialog.dart';
import '../widgets/k_button.dart';
import '../widgets/k_responsive.dart';
import 'mobile/mobile_delivery_schedule_calendar_89_4425.dart';

/// 配送ルート最適化機能。これまでダイヤログの中に隠れていた「日時選択（カレンダー）」を、
/// この画面ではポップアップではなく常時表示の画面として置く。
/// 日付をタップすると、選んだ店舗・その日の配達予定ダイヤログ（号車ごとの時間軸）を開く。
/// 実際のルート最適化（順序の自動並べ替えなど）は、今後この画面に追加していく。
class RouteOptimizationScreen extends StatefulWidget {
  final VoidCallback? onOpenMenu;
  final void Function(int)? onNavigate;

  const RouteOptimizationScreen({super.key, this.onOpenMenu, this.onNavigate});

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

  @override
  void initState() {
    super.initState();
    _load();
    // 受注が変わったら自動で反映する
    _ordersSub = _orderService.watchOrders().listen((orders) {
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _travelWarn.clear();
        _travelLoading.clear();
      });
      _loadTravelWarn(_focusedDay);
    });
  }

  StreamSubscription<List<OrderModel>>? _ordersSub;

  final Map<String, Set<DateTime>> _travelWarn = {}; // 店舗+月 → 移動時間不足の日
  final Set<String> _travelLoading = {};

  String _travelKey(DateTime m) => '$_branchName|${m.year}-${m.month}';

  /// 表示月の移動時間不足を非同期で取得する（同じ店舗・月はキャッシュ）。
  Future<void> _loadTravelWarn(DateTime month) async {
    if (_branchName.isEmpty) return;
    final key = _travelKey(month);
    if (_travelWarn.containsKey(key) || !_travelLoading.add(key)) return;
    try {
      final today = DateWarningService.dayOf(DateTime.now());
      final from = DateTime(month.year, month.month, 1);
      final to = DateTime(month.year, month.month + 1, 0);
      final res = await DateWarningService.travelShortagesByDate(
        orders: _orders.where((o) => OrderService.isActive(o) && o.deliveryType == '配送' && o.branchName == _branchName).toList(),
        service: _scheduleService,
        branchPositions: {for (final b in _branches) b.name: LatLng(b.latitude, b.longitude)},
        from: from.isBefore(today) ? today : from,
        to: to,
      );
      if (!mounted) return;
      setState(() => _travelWarn[key] = res.keys.toSet());
    } catch (e) {
      debugPrint('travel warn error: $e');
    } finally {
      _travelLoading.remove(key);
    }
  }

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
      _loadTravelWarn(_focusedDay);
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

  bool _opening = false; // 「ルート確認」の読み込み中（連打防止＋クルクル表示）

  Future<void> _openSchedule(DateTime day) async {
    if (_opening) return;
    setState(() => _opening = true);
    final branch = _selectedBranch;
    List<ReservationSlot> reservations = const [];
    try {
      reservations = await _reservationService.listByDate(_branchName, day);
    } catch (e) {
      debugPrint('reservation load error: $e'); // 取得できなくても画面は開く
    }
    if (!mounted) return;
    // ダイアログではなく画面として表示する（配達日時ダイアログと同じ内容）
    final pushed = Navigator.of(context).push<DeliverySlot>(
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
    setState(() => _opening = false); // 画面が開いたらクルクルを消す
    await pushed;
    // ここでは閲覧のみ（この画面から受注を作らないため、決定結果は使わない）。
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 600) return _buildMobile();
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Stack(
      children: [
        _buildMain(context),
        // 読み込み中は画面をグレーアウトし、中央にクルクルを出して操作を受け付けない
        if (_opening)
          const Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: Color(0x80000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobile() {
    final day = _selectedDay ?? DateTime.now();
    final warn = _travelWarn[_travelKey(_focusedDay)] ?? <DateTime>{};
    return MobileDeliveryScheduleCalendar894425(MobileDeliveryScheduleData(
      isLoading: _loading,
      isOpening: _opening,
      branches: [for (final b in _branches) b.name],
      selectedBranch: _branchName,
      focusedMonth: _focusedDay,
      selectedDay: day,
      orderDays: {for (final o in _branchOrders) DateWarningService.dayOf(o.deliveryDate)},
      warnDays: warn.map(DateWarningService.dayOf).toSet(),
      dayOrders: _dayOrders,
      displayNames: {for (final o in _dayOrders) o.id: withHonorific(_names[o.id] ?? o.customerName)},
      onSelectBranch: (name) {
        setState(() => _branchName = name);
        _loadTravelWarn(_focusedDay);
        _ensureNames(_dayOrders);
      },
      onSelectDay: (d) {
        setState(() {
          _selectedDay = d;
          if (d.month != _focusedDay.month) _focusedDay = d;
        });
        _loadTravelWarn(_focusedDay);
        _ensureNames(_dayOrders);
      },
      onChangeMonth: (delta) {
        setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + delta, 1));
        _loadTravelWarn(_focusedDay);
      },
      onRouteConfirm: () => _openSchedule(day),
      onOpenMenu: widget.onOpenMenu,
      onNavigate: widget.onNavigate,
    ));
  }

  Widget _buildMain(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: Padding(
        padding: EdgeInsets.all(rs(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('配達予定', style: TextStyle(fontSize: rf(context, 22), fontWeight: FontWeight.bold, color: AppColors.primary)),
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
                  return GestureDetector(
                    onTap: () {
                      setState(() => _branchName = b.name);
                      _loadTravelWarn(_focusedDay);
                      _ensureNames(_dayOrders);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.selectButton : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(rs(context, 20)),
                      ),
                      child: Text(b.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: rf(context, 14))),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: rs(context, 16)),
            // 左：カレンダー／右：選択日の受注カード＋「ルート確認」ボタン（受注機能の配達日時ダイアログと同じ配置）
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 7, child: _buildCalendar(context)),
                  SizedBox(width: rs(context, 12)),
                  Expanded(flex: 3, child: _buildDayOrdersArea(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(rs(context, 12)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Expanded(child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 30)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        currentDay: DateTime.now(),
        locale: 'ja_JP',
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        daysOfWeekHeight: rs(context, 32),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(color: AppColors.selectButton, shape: BoxShape.circle),
          selectedTextStyle: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
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
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          _loadTravelWarn(focusedDay);
        },
        eventLoader: (day) => (_travelWarn[_travelKey(day)]?.contains(DateWarningService.dayOf(day)) ?? false) ? const <Object>[1] : const <Object>[],
        shouldFillViewport: true,
        sixWeekMonthsEnforced: true,
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) => events.isEmpty
              ? null
              : Positioned(
                  top: rs(context, 2),
                  right: rs(context, 2),
                  child: Icon(Icons.warning_rounded, color: AppColors.warningText, size: rs(context, 14)),
                ),
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
      )),
          SizedBox(height: rs(context, 8)),
          // カレンダーのマークの意味
          Wrap(
            spacing: rs(context, 16),
            runSpacing: rs(context, 4),
            children: [
              _legendItem(context, '配送予定あり', border: AppColors.accentOrange),
              _legendItem(context, '今日', border: AppColors.primary),
              _legendItem(context, '選択中', fill: AppColors.selectButton),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(BuildContext context, String label, {Color? border, Color? fill}) {
    final size = rs(context, 14);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: border != null ? Border.all(color: border, width: rs(context, 1.5)) : null,
          ),
        ),
        SizedBox(width: rs(context, 6)),
        Text(label, style: TextStyle(fontSize: rf(context, 12))),
      ],
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
