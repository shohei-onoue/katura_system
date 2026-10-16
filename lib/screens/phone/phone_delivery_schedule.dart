import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:katura_system/utils/name_format.dart';
import '../../models/order_model.dart';
import '../../services/customer_service.dart';
import '../../services/order_service.dart';
import '../../services/delivery_schedule_service.dart';
import '../../services/reservation_service.dart';
import '../../widgets/k_route_map_dialog.dart';
import 'phone_order_list_dialogs.dart';
import 'phone_delivery_common.dart';

const Color _orange = Color(0xFFFF8A65);
const Color _sunRed = Color(0xFFE53935);
const Color _satBlue = Color(0xFF1E88E5);

// =====================================================================
// 配達予定カレンダー（Figma 89:4425）
// =====================================================================

class PhoneDeliveryCalendarView extends StatelessWidget {
  final List<String> branchNames;
  final String branch;
  final ValueChanged<String> onBranch;
  final DateTime month;
  final DateTime? selected;
  final bool Function(DateTime) hasOrders;
  final bool Function(DateTime) hasWarning;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<int> onMonthMove;
  final List<OrderModel> dayOrders;
  final Map<String, String> names;
  final ValueChanged<OrderModel> onOrderTap;
  final VoidCallback? onRoute;

  const PhoneDeliveryCalendarView({
    super.key,
    required this.branchNames,
    required this.branch,
    required this.onBranch,
    required this.month,
    required this.selected,
    required this.hasOrders,
    required this.hasWarning,
    required this.onSelect,
    required this.onMonthMove,
    required this.dayOrders,
    required this.names,
    required this.onOrderTap,
    required this.onRoute,
  });

  @override
  Widget build(BuildContext context) {
    final sel = selected;
    return Container(
      color: PhoneUi.bg,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              PhoneChipRow(labels: branchNames, selected: branch, onTap: onBranch),
              const SizedBox(height: 6),
              _calendarCard(),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    const Icon(Icons.event_note_rounded, size: 16, color: PhoneUi.purple),
                    const SizedBox(width: 5),
                    Text(
                      '${sel == null ? '' : '${DateFormat('M/d(E)', 'ja_JP').format(sel)} の'}受注 ${dayOrders.length}件',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PhoneUi.sub),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 96),
                  child: _ordersCard(),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Opacity(
              opacity: onRoute == null ? 0.5 : 1,
              child: GestureDetector(
                onTap: onRoute,
                child: Container(
                  width: 132,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: PhoneUi.purple, borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.route_rounded, size: 20, color: Colors.white),
                      SizedBox(width: 6),
                      Text('ルート確認', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarCard() {
    final first = DateTime(month.year, month.month, 1);
    final offset = first.weekday % 7; // 日曜=0
    final today = DateTime.now();
    const dow = ['日', '月', '火', '水', '木', '金', '土'];

    Color dayColor(DateTime d, bool inMonth) {
      if (d.weekday == DateTime.sunday) return _sunRed;
      if (d.weekday == DateTime.saturday) return _satBlue;
      return inMonth ? PhoneUi.ink : const Color(0xFFC4C8CD);
    }

    Widget cell(DateTime d) {
      final inMonth = d.month == month.month;
      final isSel = sel(d);
      final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
      final orders = hasOrders(d);
      Color? border;
      if (isToday) {
        border = _sunRed;
      } else if (orders) {
        border = _orange;
      }
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onSelect(DateTime(d.year, d.month, d.day)),
          child: SizedBox(
            height: 32,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSel ? PhoneUi.chipFill : null,
                      border: border == null ? null : Border.all(color: border),
                    ),
                    child: Text(
                      '${d.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: (isSel || isToday) ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? PhoneUi.red : dayColor(d, inMonth),
                      ),
                    ),
                  ),
                  if (hasWarning(d))
                    const Positioned(top: -2, right: -2, child: Icon(Icons.warning_rounded, size: 12, color: Colors.red)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget legend(String label, {Color? border, Color? fill}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: fill ?? (border != null && border == _sunRed ? Colors.white : null),
                borderRadius: BorderRadius.circular(5),
                border: border == null ? null : Border.all(color: border),
              ),
            ),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: PhoneUi.sub)),
          ],
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PhoneUi.cardLine),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 32,
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onMonthMove(-1),
                  child: const SizedBox(width: 44, height: 32, child: Align(alignment: Alignment.centerLeft, child: Icon(Icons.chevron_left_rounded, size: 20, color: PhoneUi.ink))),
                ),
                Expanded(
                  child: Center(
                    child: Text('${month.year}年${month.month}月', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PhoneUi.ink)),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onMonthMove(1),
                  child: const SizedBox(width: 44, height: 32, child: Align(alignment: Alignment.centerRight, child: Icon(Icons.chevron_right_rounded, size: 20, color: PhoneUi.ink))),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 18,
            child: Row(
              children: [
                for (int i = 0; i < 7; i++)
                  Expanded(
                    child: Center(
                      child: Text(dow[i], style: TextStyle(fontSize: 11, color: i == 0 ? _sunRed : (i == 6 ? _satBlue : PhoneUi.sub))),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          for (int r = 0; r < 6; r++)
            Row(
              children: [
                for (int c = 0; c < 7; c++) cell(DateTime(first.year, first.month, 1 - offset + r * 7 + c)),
              ],
            ),
          const SizedBox(height: 3),
          SizedBox(
            height: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                legend('配送予定あり', border: _orange),
                const SizedBox(width: 22),
                legend('今日', border: _sunRed),
                const SizedBox(width: 22),
                legend('選択中', fill: PhoneUi.chipFill),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool sel(DateTime d) => selected != null && selected!.year == d.year && selected!.month == d.month && selected!.day == d.day;

  Widget _ordersCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PhoneUi.cardLine),
      ),
      child: dayOrders.isEmpty
          ? const SizedBox(height: 62, child: Center(child: Text('受注なし', style: TextStyle(fontSize: 12, color: PhoneUi.sub))))
          : Column(
              children: [
                for (final o in dayOrders)
                  InkWell(
                    onTap: () => onOrderTap(o),
                    child: SizedBox(
                      height: 62,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: Text(o.deliveryTime, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: PhoneUi.purple)),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(withHonorific(names[o.id] ?? o.customerName),
                                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PhoneUi.ink)),
                                const SizedBox(height: 3),
                                Text(
                                  o.facilityName.isNotEmpty ? '${phoneCityOf(o)} · ${o.facilityName}' : phoneCityOf(o),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11.5, color: PhoneUi.sub),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFB0B5BB)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

// =====================================================================
// 車両タイムライン（Figma 89:5445 / 89:5508 / 配達詳細 89:5658）
// =====================================================================

class PhoneDeliveryTimelinePage extends StatefulWidget {
  final DateTime date;
  final List<OrderModel> orders; // 全店舗の配送受注
  final List<String> branchNames;
  final String initialBranch;
  final Map<String, LatLng> branchPositions;
  final Map<String, int> branchVehicleCounts;
  final DeliveryScheduleService service;
  final List<ReservationSlot> initialReservations;
  final Future<List<ReservationSlot>> Function(String branch) reservationLoader;

  const PhoneDeliveryTimelinePage({
    super.key,
    required this.date,
    required this.orders,
    required this.branchNames,
    required this.initialBranch,
    required this.branchPositions,
    required this.branchVehicleCounts,
    required this.service,
    required this.initialReservations,
    required this.reservationLoader,
  });

  @override
  State<PhoneDeliveryTimelinePage> createState() => _PhoneDeliveryTimelinePageState();
}

class _PhoneDeliveryTimelinePageState extends State<PhoneDeliveryTimelinePage> {
  static const int _startHour = 9;
  static const int _endHour = 20;
  static const double _hourH = 72;
  static const double _top = 6; // 9:00の線の位置（本体上端から）
  static const double _gap = 6.5;
  static const Color _blue = Color(0xFF2196F3);

  late String _branch = widget.initialBranch;
  List<OrderModel> _dayOrders = [];
  List<ReservationSlot> _reservations = [];
  final Map<String, int> _lanes = {};
  int _laneCount = 1;
  Map<String, DeliveryStop> _stops = {};
  Map<String, String> _names = {};
  final Set<String> _late = {};
  final OrderService _orderService = OrderService();
  // ドラッグで号車を変えた予定（親の注文データは古いままなので、こちらを優先する）
  final Map<String, int> _vehicleOverride = {};
  final GlobalKey _vScrollKey = GlobalKey();
  final GlobalKey _timelineKey = GlobalKey();
  final ScrollController _vScroll = ScrollController();
  final ScrollController _hScroll = ScrollController();
  Timer? _autoScrollTimer;
  Offset? _dragPos;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _vScroll.dispose();
    _hScroll.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _reservations = widget.initialReservations;
    _buildDay();
    _loadStops();
    _loadNames();
  }

  LatLng? get _branchPos => widget.branchPositions[_branch];

  bool _isDay(OrderModel o) =>
      o.deliveryDate.year == widget.date.year &&
      o.deliveryDate.month == widget.date.month &&
      o.deliveryDate.day == widget.date.day &&
      DeliveryScheduleService.minutesOf(o.deliveryTime) != null;

  int _countOf(String b) => widget.orders.where((o) => o.branchName == b && _isDay(o)).length;

  void _buildDay() {
    _lanes.clear();
    _late.clear();
    _stops = {};
    _dayOrders = widget.orders.where((o) => o.branchName == _branch && _isDay(o)).toList()
      ..sort((a, b) => DeliveryScheduleService.minutesOf(a.deliveryTime)!.compareTo(DeliveryScheduleService.minutesOf(b.deliveryTime)!));
    final laneEnds = <int>[];
    int maxAssigned = 0;
    for (final o in _dayOrders) {
      final vn = _vehicleOverride[o.id] ?? o.vehicleNumber;
      if (vn > 0) {
        _lanes[o.id] = vn - 1;
        maxAssigned = math.max(maxAssigned, vn);
        continue;
      }
      final m = DeliveryScheduleService.minutesOf(o.deliveryTime)!;
      int lane = laneEnds.indexWhere((end) => end <= m - 30);
      if (lane == -1) {
        laneEnds.add(m);
        lane = laneEnds.length - 1;
      } else {
        laneEnds[lane] = m;
      }
      _lanes[o.id] = lane;
    }
    for (final r in _reservations) {
      maxAssigned = math.max(maxAssigned, r.vehicleNumber);
    }
    _laneCount = math.max(math.max(math.max(laneEnds.length, maxAssigned), widget.branchVehicleCounts[_branch] ?? 1), 1);
  }

  Future<void> _loadNames() async {
    try {
      final names = await CustomerService().resolveOrderNames(_dayOrders);
      if (mounted) setState(() => _names = names);
    } catch (e) {
      debugPrint('phone timeline names error: $e');
    }
  }

  Future<void> _loadStops() async {
    final branchAtStart = _branch;
    try {
      final result = <String, DeliveryStop>{};
      for (int lane = 0; lane < _laneCount; lane++) {
        final group = _dayOrders.where((o) => _lanes[o.id] == lane).toList();
        if (group.isEmpty) continue;
        final stops = await widget.service.buildStops(group, _branchPos);
        for (final s in stops) {
          result[s.order.id] = s;
        }
      }
      if (!mounted || branchAtStart != _branch) return;
      final late = <String>{};
      for (int lane = 0; lane < _laneCount; lane++) {
        final group = _dayOrders.where((o) => _lanes[o.id] == lane).toList();
        for (int i = 1; i < group.length; i++) {
          final sec = result[group[i].id]?.travelSeconds;
          if (sec == null) continue;
          final pm = DeliveryScheduleService.minutesOf(group[i - 1].deliveryTime)!;
          final nm = DeliveryScheduleService.minutesOf(group[i].deliveryTime)!;
          if (nm - pm - (sec / 60).ceil() < 0) late.add(group[i].id);
        }
      }
      setState(() {
        _stops = result;
        _late
          ..clear()
          ..addAll(late);
      });
    } catch (e) {
      debugPrint('phone timeline stops error: $e');
    }
  }

  Future<void> _selectBranch(String b) async {
    if (b == _branch) return;
    List<ReservationSlot> res = const [];
    try {
      res = b == widget.initialBranch ? widget.initialReservations : await widget.reservationLoader(b);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _branch = b;
      _reservations = res;
      _buildDay();
    });
    _loadStops();
    _loadNames();
  }

  /// 号車の見出しタップ → 確認 → ルート地図を表示（出発は店舗、最後の配達先が目的地）
  Future<void> _confirmRoute(int lane) async {
    final group = _dayOrders.where((o) => _lanes[o.id] == lane).toList();
    final origin = _branchPos;
    if (group.isEmpty || origin == null) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(group.isEmpty ? 'この号車には配達予定がありません' : '店舗の位置が取得できないため、ルートを表示できません'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('閉じる'))],
        ),
      );
      return;
    }
    final ok = await showPhoneRouteConfirm(context, lane + 1);
    if (ok != true || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => KRouteMapDialog(
          title: '- ${lane + 1}号車 -　配送ルート',
          origin: origin,
          vertical: true,
          stops: [
            for (final o in group)
              KRouteStop(
                location: (o.latitude != null && o.longitude != null) ? LatLng(o.latitude!, o.longitude!) : phoneCleanAddress(o),
                time: o.deliveryTime,
                place: phoneCityOf(o),
                color: _blue,
              ),
          ],
      ),
    );
  }

  static const int _cardMinutes = 30;

  /// [o] を [lane] の列へ移せるか（同じ列の他の予定・予約枠と30分以内で重ならない）。
  bool _canDrop(OrderModel o, int lane) {
    if (_lanes[o.id] == lane) return false;
    final m = DeliveryScheduleService.minutesOf(o.deliveryTime)!;
    bool clash(int other) => (other - m).abs() < _cardMinutes;
    for (final x in _dayOrders) {
      if (x.id != o.id && _lanes[x.id] == lane && clash(DeliveryScheduleService.minutesOf(x.deliveryTime)!)) return false;
    }
    for (final r in _reservations) {
      final rm = DeliveryScheduleService.minutesOf(r.time);
      if (r.vehicleNumber - 1 == lane && rm != null && clash(rm)) return false;
    }
    return true;
  }

  /// カードを別の号車の列へ移す（保存に失敗したら元に戻す）。
  Future<void> _moveToLane(OrderModel o, int lane) async {
    final before = _lanes[o.id]!;
    final beforeOverride = _vehicleOverride[o.id];
    setState(() {
      _lanes[o.id] = lane;
      _vehicleOverride[o.id] = lane + 1;
      _late.remove(o.id);
    });
    try {
      await _orderService.updateVehicleNumber(o.id, lane + 1);
      await _loadStops();
      if (!mounted) return;
      final shortage = _shortageAfterMove(o, lane);
      if (shortage > 0) _showNotice('移動時間が足りません（$shortage分不足）');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lanes[o.id] = before;
        if (beforeOverride == null) {
          _vehicleOverride.remove(o.id);
        } else {
          _vehicleOverride[o.id] = beforeOverride;
        }
      });
      _showNotice('号車の変更を保存できませんでした');
    }
  }

  /// 移した [o] の前後の区間で、移動時間が間隔を超える最大の不足分（分）。間に合うなら0。
  int _shortageAfterMove(OrderModel o, int lane) {
    final group = _dayOrders.where((x) => _lanes[x.id] == lane).toList();
    final i = group.indexWhere((x) => x.id == o.id);
    int shortage = 0;
    int gap(OrderModel from, OrderModel to) {
      final sec = _stops[to.id]?.travelSeconds;
      if (sec == null) return 0;
      final spare = DeliveryScheduleService.minutesOf(to.deliveryTime)! - DeliveryScheduleService.minutesOf(from.deliveryTime)! - (sec / 60).ceil();
      return spare < 0 ? -spare : 0;
    }

    if (i > 0) shortage = math.max(shortage, gap(group[i - 1], o));
    if (i >= 0 && i + 1 < group.length) shortage = math.max(shortage, gap(o, group[i + 1]));
    return shortage;
  }

  void _showNotice(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 4)));
  }

  // ---- ドラッグ中の画面端オートスクロール ----
  void _onDragStart() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => _autoScrollTick());
  }

  void _onDragEnd() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _dragPos = null;
  }

  void _autoScrollTick() {
    final pos = _dragPos;
    if (pos == null) return;
    const edge = 60.0;
    const step = 8.0;
    void scroll(ScrollController c, double v, double lo, double hi) {
      if (!c.hasClients) return;
      double d = 0;
      if (v < lo + edge) {
        d = -step;
      } else if (v > hi - edge) {
        d = step;
      }
      if (d == 0) return;
      final target = (c.offset + d).clamp(c.position.minScrollExtent, c.position.maxScrollExtent);
      if (target != c.offset) c.jumpTo(target);
    }

    final vBox = _vScrollKey.currentContext?.findRenderObject() as RenderBox?;
    if (vBox != null && vBox.attached) {
      final top = vBox.localToGlobal(Offset.zero).dy;
      scroll(_vScroll, pos.dy, top, top + vBox.size.height);
    }
    final tBox = _timelineKey.currentContext?.findRenderObject() as RenderBox?;
    if (tBox != null && tBox.attached) {
      final left = tBox.localToGlobal(Offset.zero).dx;
      scroll(_hScroll, pos.dx, left, left + tBox.size.width);
    }
  }

  double _yOf(int minutes) => _top + (minutes - _startHour * 60) * _hourH / 60;

  String get _title => '配達予定 ${DateFormat('M/d(E)', 'ja_JP').format(widget.date)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PhoneUi.bg,
      appBar: AppBar(
        toolbarHeight: 52,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 52,
        titleSpacing: 0,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 16), child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: PhoneUi.ink))),
        ),
        title: Text(_title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PhoneUi.ink)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 8, bottom: 9),
            width: double.infinity,
            child: PhoneChipRow(
              labels: [for (final b in widget.branchNames) '$b(${_countOf(b)})'],
              selected: '$_branch(${_countOf(_branch)})',
              onTap: (l) => _selectBranch(l.substring(0, l.lastIndexOf('('))),
            ),
          ),
          Expanded(child: _timeline()),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: PhoneUi.line))),
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
        child: SafeArea(
          top: false,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: PhoneUi.line)),
              child: const Text('戻る', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PhoneUi.ink)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeline() {
    return LayoutBuilder(builder: (context, c) {
      final n = _laneCount;
      final w = c.maxWidth;
      final colW = n <= 3 ? (w - 52 - 10 - (n - 1) * _gap) / n : 105.0;
      final contentW = n <= 3 ? w : 52 + n * colW + (n - 1) * _gap + 10;
      double colX(int i) => 52 + i * (colW + _gap);
      final totalH = _top + (_endHour - _startHour) * _hourH + 40;

      final header = SizedBox(
        height: 35,
        child: Stack(
          children: [
            for (int i = 0; i < n; i++)
              Positioned(
                left: colX(i),
                top: 8,
                width: colW,
                height: 27,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _confirmRoute(i),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(8)),
                    child: Text('${i + 1}号車', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
          ],
        ),
      );

      final children = <Widget>[];
      // 時間の線とラベル
      for (int h = _startHour; h <= _endHour; h++) {
        final y = _top + (h - _startHour) * _hourH;
        children.add(Positioned(left: 0, top: y, width: contentW - 10, height: 1, child: const ColoredBox(color: Color(0xFFE3E6EA))));
        children.add(Positioned(
          left: 10,
          top: y - 7,
          height: 15,
          child: Container(
            color: PhoneUi.bg,
            alignment: Alignment.centerLeft,
            child: Text('$h:00', style: const TextStyle(fontSize: 10.5, height: 1.2, color: PhoneUi.sub)),
          ),
        ));
      }
      // 偶数番目(2号車など)の列の背景
      for (int i = 1; i < n; i += 2) {
        children.add(Positioned(
          left: colX(i),
          top: _top,
          width: colW,
          height: totalH - _top,
          child: Container(decoration: BoxDecoration(color: const Color(0xFFECEFF1), borderRadius: BorderRadius.circular(10))),
        ));
      }

      // 号車の列ごとのドロップ先（見た目は無し）
      for (int lane = 0; lane < n; lane++) {
        children.add(Positioned(
          left: colX(lane),
          top: 0,
          width: colW,
          height: totalH,
          child: DragTarget<OrderModel>(
            onWillAcceptWithDetails: (d) => _canDrop(d.data, lane),
            onAcceptWithDetails: (d) => _moveToLane(d.data, lane),
            builder: (context, candidate, _) => const SizedBox.expand(),
          ),
        ));
      }

      for (int lane = 0; lane < n; lane++) {
        final group = _dayOrders.where((o) => _lanes[o.id] == lane).toList();
        final x = colX(lane);
        final pillW = colW - 8;
        // つなぎ線（最初のカードの中心→最後のカードの上端）
        if (group.length >= 2) {
          final y1 = _yOf(DeliveryScheduleService.minutesOf(group.first.deliveryTime)!) + 6 + 12;
          final y2 = _yOf(DeliveryScheduleService.minutesOf(group.last.deliveryTime)!) + 6;
          if (y2 > y1) {
            children.add(Positioned(left: x + colW / 2 - 1, top: y1, width: 2, height: y2 - y1, child: const ColoredBox(color: Color(0xFF333333))));
          }
        }
        // 移動時間・余裕
        for (int i = 1; i < group.length; i++) {
          final sec = _stops[group[i].id]?.travelSeconds;
          if (sec == null) continue;
          final pm = DeliveryScheduleService.minutesOf(group[i - 1].deliveryTime)!;
          final nm = DeliveryScheduleService.minutesOf(group[i].deliveryTime)!;
          final travel = (sec / 60).ceil();
          final prevBottom = _yOf(pm) + 6 + 26;
          final nextTop = _yOf(nm) + 6;
          if (nextTop - prevBottom < 16) continue;
          final mid = (prevBottom + nextTop) / 2;
          children.add(Positioned(
            left: x + 6,
            top: mid - 25,
            child: IgnorePointer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_car_rounded, size: 12, color: PhoneUi.purple),
                  const SizedBox(width: 0),
                  Text('移動$travel分 余裕${nm - pm - travel}分', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: PhoneUi.purple)),
                ],
              ),
            ),
          ));
        }
        // 予定カード
        for (final o in group) {
          final m = DeliveryScheduleService.minutesOf(o.deliveryTime)!;
          children.add(Positioned(
            left: x + 4,
            top: _yOf(m) + 6,
            width: pillW,
            height: 26,
            child: _draggablePill(o, pillW),
          ));
        }
        // 予約枠
        for (final r in _reservations.where((r) => r.vehicleNumber == lane + 1)) {
          final m = DeliveryScheduleService.minutesOf(r.time);
          if (m == null) continue;
          children.add(Positioned(left: x + 4, top: _yOf(m) + 6, width: pillW, height: 26, child: _pill('${r.time} 予約枠')));
        }
      }

      final body = Expanded(
        child: SingleChildScrollView(
          key: _vScrollKey,
          controller: _vScroll,
          child: SizedBox(width: contentW, height: totalH, child: Stack(children: children)),
        ),
      );
      final content = SizedBox(width: contentW, child: Column(children: [header, body]));
      if (n <= 3) return content;
      return SingleChildScrollView(key: _timelineKey, controller: _hScroll, scrollDirection: Axis.horizontal, child: content);
    });
  }

  /// 長押ししてドラッグすると、別の号車の列へ移せる予定カード（タップは詳細表示のまま）。
  Widget _draggablePill(OrderModel o, double pillW) {
    final pill = _pill('${o.deliveryTime} ${phoneCityOf(o)}',
        late: _late.contains(o.id), onTap: () => showPhoneDeliveryDetail(context, order: o, name: withHonorific(_names[o.id] ?? o.customerName)));
    return LongPressDraggable<OrderModel>(
      data: o,
      onDragStarted: _onDragStart,
      onDragUpdate: (d) => _dragPos = d.globalPosition,
      onDragEnd: (_) => _onDragEnd(),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: pillW, height: 26, child: Opacity(opacity: 0.85, child: pill)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: pill),
      child: pill,
    );
  }

  Widget _pill(String label, {bool late = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 7),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(color: late ? _sunRed : _blue, borderRadius: BorderRadius.circular(8)),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
