import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/menu_model.dart';
import '../models/order_model.dart';
import '../services/menu_service.dart';
import '../services/order_service.dart';
import '../widgets/k_responsive.dart';
import '../widgets/k_point_heatmap.dart';
import 'package:katura_system/utils/app_colors.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _orderService = OrderService();
  final _menuService = MenuService();
  List<OrderModel> _allOrders = [];
  List<MenuModel> _allMenus = [];
  bool _isLoading = true;

  int _view = 0; // 0: ヒートマップ, 1: グラフ
  List<HeatmapPoint> _heatmapPoints = [];

  // ヒートマップのモード切替タブ
  static const String _heatLoyalty = '顧客継続状況';
  static const String _heatDelivery = '配達実績';
  String _heatMode = _heatLoyalty;

  // 店舗の並び順・色
  static const List<String> _branchOrder = ['岡崎本店', '名古屋店', '岐阜店'];

  // グラフビューの店舗切替タブ
  String _graphBranch = '全店舗';
  List<String> get _graphBranchTabs => ['全店舗', ..._branchOrder];
  List<OrderModel> get _graphOrders =>
      _graphBranch == '全店舗' ? _allOrders : _allOrders.where((o) => o.branchName == _graphBranch).toList();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _orderService.getAllOrders(),
      _menuService.getAllMenus(),
    ]);
    _allOrders = results[0] as List<OrderModel>;
    _allMenus = results[1] as List<MenuModel>;
    _calculateMetrics();
  }

  Color _branchColor(String branch) {
    switch (branch) {
      case '名古屋店':
        return Colors.green;
      case '岐阜店':
        return Colors.purple;
      case '岡崎本店':
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }

  void _calculateMetrics() {
    final List<HeatmapPoint> points = [];

    if (_heatMode == _heatDelivery) {
      // 配達実績：各配達地点を店舗カラーで表示（店舗別カバーエリアの顕在化）
      for (final o in _allOrders) {
        if (o.latitude == null || o.latitude == 0) continue;
        final branch = o.branchName.isEmpty ? 'その他' : o.branchName;
        points.add(HeatmapPoint(
          location: LatLng(o.latitude!, o.longitude!),
          value: 1.0,
          status: branch, // クラスタ集約時の多数決グループ用
          color: _branchColor(branch).withValues(alpha: 0.45),
        ));
      }
    } else {
      // 顧客継続状況（ロイヤリティ）
      final Map<String, List<OrderModel>> customerOrders = {};
      for (var o in _allOrders) {
        if (o.phoneNumber.isEmpty) continue;
        customerOrders.putIfAbsent(o.phoneNumber, () => []).add(o);
      }

      final now = DateTime.now();
      customerOrders.forEach((phone, orders) {
        final latestOrder = orders.reduce((a, b) => a.deliveryDate.isAfter(b.deliveryDate) ? a : b);
        if (latestOrder.latitude == null || latestOrder.latitude == 0) return;

        String status = 'new';
        if (orders.length > 1) {
          final daysSinceLastOrder = now.difference(latestOrder.deliveryDate).inDays;
          status = daysSinceLastOrder <= 90 ? 'active' : 'churned';
        }

        points.add(HeatmapPoint(
          location: LatLng(latestOrder.latitude!, latestOrder.longitude!),
          value: orders.length.toDouble(),
          status: status,
        ));
      });
    }

    setState(() {
      _heatmapPoints = points;
      _isLoading = false;
    });
  }

  // ---- グラフ用集計 ----

  /// メニュー名 → 店舗名 → 注文食数
  Map<String, Map<String, int>> _menuByBranch() {
    final m = <String, Map<String, int>>{};
    for (final o in _graphOrders) {
      final branch = o.branchName.isEmpty ? 'その他' : o.branchName;
      for (final it in o.items) {
        final name = (it['name'] ?? '').toString();
        if (name.isEmpty || _isDrink(name)) continue;
        final qty = (it['quantity'] is int) ? it['quantity'] as int : int.tryParse('${it['quantity']}') ?? 0;
        final row = m.putIfAbsent(name, () => {});
        row[branch] = (row[branch] ?? 0) + qty;
      }
    }
    return m;
  }

  /// 月(yyyy-MM) → 食数上位3メニュー [(名前, 食数), ...]
  List<MapEntry<String, List<MapEntry<String, int>>>> _monthlyTopMenus() {
    final byMonth = <String, Map<String, int>>{};
    for (final o in _graphOrders) {
      final key = '${o.deliveryDate.year}-${o.deliveryDate.month.toString().padLeft(2, '0')}';
      final row = byMonth.putIfAbsent(key, () => {});
      for (final it in o.items) {
        final name = (it['name'] ?? '').toString();
        if (name.isEmpty || _isDrink(name)) continue;
        final qty = (it['quantity'] is int) ? it['quantity'] as int : int.tryParse('${it['quantity']}') ?? 0;
        row[name] = (row[name] ?? 0) + qty;
      }
    }
    final keys = byMonth.keys.toList()..sort((a, b) => b.compareTo(a)); // 新しい月が上
    return keys.map((k) {
      final sorted = byMonth[k]!.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      return MapEntry(k, sorted.take(3).toList());
    }).toList();
  }

  String? _menuImage(String name) {
    for (final m in _allMenus) {
      if (m.name == name) return m.imageUrl.isEmpty ? null : m.imageUrl;
    }
    return null;
  }

  /// ドリンク類はグラフ集計から除外する
  bool _isDrink(String name) {
    for (final m in _allMenus) {
      if (m.name == name) return m.category.contains('ドリンク');
    }
    return false;
  }

  List<String> _branchesInData(Map<String, Map<String, int>> data) {
    final set = <String>{};
    for (final row in data.values) {
      set.addAll(row.keys);
    }
    final ordered = <String>[];
    for (final b in _branchOrder) {
      if (set.remove(b)) ordered.add(b);
    }
    ordered.addAll(set); // その他
    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: EdgeInsets.all(rs(context, 24)),
        child: Column(
          children: [
            _buildViewTabs(),
            SizedBox(height: rs(context, 16)),
            Expanded(child: _view == 0 ? _buildHeatmapView() : _buildGraphView()),
          ],
        ),
      ),
    );
  }

  Widget _buildViewTabs() {
    return Container(
      padding: EdgeInsets.all(rs(context, 6)),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _viewTab('ヒートマップ', 0),
          _viewTab('グラフ', 1),
        ],
      ),
    );
  }

  Widget _viewTab(String label, int index) {
    final selected = _view == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _view = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: rs(context, 10)),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF000038) : Colors.transparent,
            borderRadius: BorderRadius.circular(rs(context, 8)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.background : Colors.blueGrey,
              fontWeight: FontWeight.bold,
              fontSize: rf(context, 13),
            ),
          ),
        ),
      ),
    );
  }

  // =============== グラフビュー ===============

  Widget _buildGraphView() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: _graphBranchTabs.map(_graphBranchTab).toList()),
        SizedBox(height: rs(context, 12)),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _card(
                  title: '店舗別 メニュー注文数（多い順）',
                  child: _buildMenuByBranchChart(),
                ),
              ),
              SizedBox(width: rs(context, 16)),
              Expanded(
                child: _card(
                  title: '月別 人気メニュー',
                  child: _buildMonthlyPopularList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _graphBranchTab(String label) {
    final selected = _graphBranch == label;
    return InkWell(
      onTap: () => setState(() => _graphBranch = label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 8)),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? const Color(0xFF000038) : Colors.transparent,
              width: rs(context, 2),
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: rf(context, 13),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? const Color(0xFF000038) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: EdgeInsets.all(rs(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 15))),
          SizedBox(height: rs(context, 12)),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildMenuByBranchChart() {
    final data = _menuByBranch();
    if (data.isEmpty) {
      return Center(child: Text('データがありません', style: TextStyle(color: Colors.grey, fontSize: rf(context, 12))));
    }
    final branches = _branchesInData(data);
    final totals = <String, int>{};
    data.forEach((menu, row) => totals[menu] = row.values.fold(0, (a, b) => a + b));
    final menus = totals.keys.toList()..sort((a, b) => totals[b]!.compareTo(totals[a]!));
    final maxTotal = totals.values.fold<int>(1, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 凡例
        Wrap(
          spacing: rs(context, 12),
          runSpacing: rs(context, 4),
          children: branches
              .map((b) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: rs(context, 10), height: rs(context, 10), color: _branchColor(b)),
                      SizedBox(width: rs(context, 4)),
                      Text(b, style: TextStyle(fontSize: rf(context, 10))),
                    ],
                  ))
              .toList(),
        ),
        SizedBox(height: rs(context, 10)),
        Expanded(
          child: ListView.separated(
            itemCount: menus.length,
            separatorBuilder: (context, index) => SizedBox(height: rs(context, 12)),
            itemBuilder: (context, i) {
              final menu = menus[i];
              final row = data[menu]!;
              final total = totals[menu]!;
              return InkWell(
                onTap: () => _showMenuBranchBreakdown(menu, row, branches),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: rs(context, 130),
                      child: Text(menu,
                          style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: rs(context, 8)),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final barW = c.maxWidth * (total / maxTotal);
                          return SizedBox(
                            height: rs(context, 26),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: barW <= 0 ? 1 : barW,
                                child: Row(
                                  children: branches
                                      .where((b) => (row[b] ?? 0) > 0)
                                      .map((b) => Expanded(
                                            flex: row[b]!,
                                            child: Container(color: _branchColor(b)),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showMenuBranchBreakdown(String menu, Map<String, int> row, List<String> branches) {
    final total = row.values.fold<int>(0, (a, b) => a + b);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.popupBackground,
        title: Text(menu, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 16))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final b in branches)
              if ((row[b] ?? 0) > 0)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: rs(context, 4)),
                  child: Row(
                    children: [
                      Container(width: rs(context, 12), height: rs(context, 12), color: _branchColor(b)),
                      SizedBox(width: rs(context, 8)),
                      Text(b, style: TextStyle(fontSize: rf(context, 14))),
                      const Spacer(),
                      Text('${row[b]}食', style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            Divider(height: rs(context, 16)),
            Row(
              children: [
                Text('合計', style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('$total食',
                    style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
        ],
      ),
    );
  }

  // 月別ランキング1行の統一高さ（メニュー名2行を想定）
  double get _monthRowHeight => rs(context, 108);

  Widget _buildMonthlyPopularList() {
    final months = _monthlyTopMenus();
    if (months.isEmpty) {
      return Center(child: Text('データがありません', style: TextStyle(color: Colors.grey, fontSize: rf(context, 12))));
    }
    return ListView.separated(
      itemCount: months.length,
      separatorBuilder: (context, index) => Divider(height: rs(context, 20)),
      itemBuilder: (context, i) {
        final monthKey = months[i].key;
        final top = months[i].value;
        final label = '${int.parse(monthKey.split('-')[1])}月';
        return InkWell(
          onTap: () => _showMonthlyTrendDialog(monthKey, top),
          child: SizedBox(
            height: _monthRowHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: rs(context, 34),
                  child: Text(label,
                      style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                ),
                SizedBox(width: rs(context, 8)),
                if (top.isNotEmpty)
                  Expanded(flex: 5, child: _rankMenu(top[0], rank: 1)),
                SizedBox(width: rs(context, 8)),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (top.length > 1) Expanded(child: _rankMenu(top[1], rank: 2)),
                      if (top.length > 2) Expanded(child: _rankMenu(top[2], rank: 3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _rankMenu(MapEntry<String, int> e, {required int rank}) {
    final bool big = rank == 1;
    final double imgSize = big ? rs(context, 64) : rs(context, 32);
    final double nameSize = big ? rf(context, 15) : rf(context, 11);
    final img = _menuImage(e.key);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(rs(context, 8)),
          child: SizedBox(
            width: imgSize,
            height: imgSize,
            child: img == null
                ? Container(
                    color: Colors.grey.shade200,
                    child: Icon(Icons.restaurant, size: imgSize * 0.45, color: Colors.grey.shade400),
                  )
                : Image.network(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: Colors.grey.shade200,
                      child: Icon(Icons.restaurant, size: imgSize * 0.45, color: Colors.grey.shade400),
                    ),
                  ),
          ),
        ),
        SizedBox(width: rs(context, 8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$rank位',
                  style: TextStyle(
                      fontSize: big ? rf(context, 11) : rf(context, 9),
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey)),
              Text(e.key,
                  style: TextStyle(fontSize: nameSize, height: 1.1, fontWeight: big ? FontWeight.bold : FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  /// 指定年の月別(1〜12)食数推移をメニュー別に算出
  Map<String, List<int>> _annualMenuTrend(int year, List<String> menuNames) {
    final result = {for (final n in menuNames) n: List<int>.filled(12, 0)};
    for (final o in _graphOrders) {
      if (o.deliveryDate.year != year) continue;
      final mi = o.deliveryDate.month - 1;
      for (final it in o.items) {
        final name = (it['name'] ?? '').toString();
        if (!result.containsKey(name)) continue;
        final qty = (it['quantity'] is int) ? it['quantity'] as int : int.tryParse('${it['quantity']}') ?? 0;
        result[name]![mi] += qty;
      }
    }
    return result;
  }

  void _showMonthlyTrendDialog(String monthKey, List<MapEntry<String, int>> top) {
    final year = int.parse(monthKey.split('-')[0]);
    final names = top.map((e) => e.key).toList();
    final trend = _annualMenuTrend(year, names);
    const palette = [Colors.deepOrange, Colors.blue, Colors.green];

    double maxY = 0;
    for (final series in trend.values) {
      for (final q in series) {
        if (q > maxY) maxY = q.toDouble();
      }
    }
    if (maxY <= 0) maxY = 1;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.popupBackground,
          insetPadding: EdgeInsets.symmetric(horizontal: rs(context, 24), vertical: rs(context, 24)),
          title: Text('$year年 月別食数推移',
              style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.9,
            height: rs(context, 340),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: rs(context, 14),
                  runSpacing: rs(context, 6),
                  children: [
                    for (int k = 0; k < names.length; k++)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: rs(context, 14), height: rs(context, 3), color: palette[k % palette.length]),
                          SizedBox(width: rs(context, 4)),
                          Text(names[k], style: TextStyle(fontSize: rf(context, 11))),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: rs(context, 16)),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      minX: 1,
                      maxX: 12,
                      minY: -(maxY * 0.12),
                      maxY: maxY * 1.2,
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: rs(context, 32),
                            getTitlesWidget: (value, meta) => SideTitleWidget(
                              meta: meta,
                              space: rs(context, 8),
                              child: Text('${value.toInt()}',
                                  style: TextStyle(
                                      fontSize: rf(context, 14),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey)),
                            ),
                          ),
                        ),
                      ),
                      lineBarsData: [
                        for (int k = 0; k < names.length; k++)
                          LineChartBarData(
                            spots: [
                              for (int mi = 0; mi < 12; mi++)
                                FlSpot((mi + 1).toDouble(), trend[names[k]]![mi].toDouble()),
                            ],
                            isCurved: false,
                            color: palette[k % palette.length],
                            barWidth: rs(context, 2),
                            dotData: const FlDotData(show: true),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('閉じる')),
          ],
        );
      },
    );
  }

  // =============== ヒートマップビュー ===============

  Widget _buildHeatmapView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [_heatModeTab(_heatLoyalty), _heatModeTab(_heatDelivery)]),
        SizedBox(height: rs(context, 12)),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(rs(context, 20)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                KPointHeatmap(
                  points: _heatmapPoints,
                  mode: HeatmapMode.loyalty,
                  isLoading: _isLoading,
                  threshold: 10,
                  initialPosition: const CameraPosition(target: LatLng(35.0, 137.0), zoom: 10),
                ),
                _buildMapOverlay(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _heatModeTab(String label) {
    final selected = _heatMode == label;
    return InkWell(
      onTap: () {
        if (_heatMode == label) return;
        setState(() => _heatMode = label);
        _calculateMetrics();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 8)),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? const Color(0xFF000038) : Colors.transparent,
              width: rs(context, 2),
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: rf(context, 13),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? const Color(0xFF000038) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildMapOverlay() {
    final bool delivery = _heatMode == _heatDelivery;
    return Positioned(
      top: rs(context, 16),
      left: rs(context, 16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 8)),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(rs(context, 8)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(delivery ? '配達実績（店舗別カバーエリア）' : '顧客継続状況',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 12))),
            SizedBox(height: rs(context, 8)),
            Row(
              children: delivery
                  ? [
                      _legendItem('岡崎', _branchColor('岡崎本店')),
                      SizedBox(width: rs(context, 8)),
                      _legendItem('名古屋', _branchColor('名古屋店')),
                      SizedBox(width: rs(context, 8)),
                      _legendItem('岐阜', _branchColor('岐阜店')),
                    ]
                  : [
                      _legendItem('新規', Colors.green),
                      SizedBox(width: rs(context, 8)),
                      _legendItem('継続', Colors.blue),
                      SizedBox(width: rs(context, 8)),
                      _legendItem('離脱', Colors.black),
                    ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: rs(context, 8),
          height: rs(context, 8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.7), shape: BoxShape.circle),
        ),
        SizedBox(width: rs(context, 4)),
        Text(label, style: TextStyle(fontSize: rf(context, 10), color: Colors.black87)),
      ],
    );
  }
}
