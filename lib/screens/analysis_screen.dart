import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../widgets/k_responsive.dart';
import '../widgets/k_point_heatmap.dart';
import '../widgets/k_metrics_card.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _orderService = OrderService();
  List<OrderModel> _allOrders = [];
  bool _isLoading = true;
  
  HeatmapMode _selectedMode = HeatmapMode.revenue;
  List<HeatmapPoint> _heatmapPoints = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final orders = await _orderService.getAllOrders();
    _allOrders = orders;
    _calculateMetrics();
  }

  void _calculateMetrics() {
    final List<HeatmapPoint> points = [];
    
    if (_selectedMode == HeatmapMode.loyalty) {
      // 顧客継続分析（ロイヤリティ）
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
    } else {
      // 売上・顧客数
      for (var o in _allOrders) {
        if (o.latitude == null || o.latitude == 0) continue;
        final pos = LatLng(o.latitude!, o.longitude!);
        
        if (_selectedMode == HeatmapMode.revenue) {
          points.add(HeatmapPoint(location: pos, value: o.totalPrice.toDouble()));
        } else if (_selectedMode == HeatmapMode.customer) {
          points.add(HeatmapPoint(location: pos, value: 1.0));
        }
      }
    }

    setState(() {
      _heatmapPoints = points;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: EdgeInsets.all(rs(context, 24)),
        child: Column(
          children: [
            _buildSummaryRow(),
            SizedBox(height: rs(context, 24)),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 65,
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
                            mode: _selectedMode,
                            isLoading: _isLoading,
                            threshold: _selectedMode == HeatmapMode.revenue ? 100000 : 10,
                            initialPosition: const CameraPosition(target: LatLng(35.0, 137.0), zoom: 10),
                          ),
                          _buildMapOverlay(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: rs(context, 24)),
                  Expanded(
                    flex: 35,
                    child: _buildRightPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(child: KMetricsCard(label: '本日の受注', value: '${_allOrders.length}件', subValue: '+12%', icon: Icons.shopping_cart, color: Colors.blue)),
        SizedBox(width: rs(context, 16)),
        Expanded(child: KMetricsCard(label: '廃棄ロス率', value: '4.2%', subValue: '-2.1%', icon: Icons.delete_outline, color: Colors.orange)),
        SizedBox(width: rs(context, 16)),
        Expanded(child: KMetricsCard(label: '平均配達時間', value: '28分', subValue: '+3分', icon: Icons.timer, color: Colors.purple, isAlert: true)),
        SizedBox(width: rs(context, 16)),
        Expanded(child: KMetricsCard(label: '粗利益率', value: '32.5%', subValue: '+0.5%', icon: Icons.trending_up, color: Colors.green)),
      ],
    );
  }

  Widget _buildRightPanel() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(rs(context, 6)),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(rs(context, 12)), border: Border.all(color: Colors.grey.shade200)),
          child: Row(
            children: [
              _modeTab('売上規模', HeatmapMode.revenue),
              _modeTab('顧客数', HeatmapMode.customer),
              _modeTab('顧客継続', HeatmapMode.loyalty),
            ],
          ),
        ),
        SizedBox(height: rs(context, 20)),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(rs(context, 20)),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(rs(context, 16)), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SKU別 利益・廃棄分析', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 16))),
                SizedBox(height: rs(context, 16)),
                Expanded(
                  child: ListView(
                    children: [
                      _buildSkuItem('特製ステーキ弁当', 0.35, 0.02, 120),
                      _buildSkuItem('霜降りハンバーグ', 0.28, 0.08, 85),
                      _buildSkuItem('幻の蓬莱牛重', 0.42, 0.01, 30),
                      _buildSkuItem('大人のステーキ丼', 0.25, 0.12, 150),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _modeTab(String label, HeatmapMode mode) {
    final isSelected = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () { setState(() => _selectedMode = mode); _calculateMetrics(); },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: rs(context, 8)),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(rs(context, 8)),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: rf(context, 11))),
        ),
      ),
    );
  }

  Widget _buildSkuItem(String name, double margin, double waste, int sales) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rs(context, 8)),
      child: Container(
        padding: EdgeInsets.all(rs(context, 12)),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(rs(context, 8)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 13))),
                  SizedBox(height: rs(context, 2)),
                  Text('累計売上: $sales個', style: TextStyle(fontSize: rf(context, 10), color: Colors.grey.shade600)),
                ],
              ),
            ),
            _metricBadge('${(margin * 100).toInt()}%', Colors.blue.shade700, '利益率'),
            SizedBox(width: rs(context, 12)),
            _metricBadge('${(waste * 100).toInt()}%', Colors.red.shade700, '廃棄率', isWarning: waste > 0.05),
          ],
        ),
      ),
    );
  }

  Widget _metricBadge(String text, Color color, String label, {bool isWarning = false}) {
    final activeColor = isWarning ? Colors.red : color;
    return SizedBox(
      width: rs(context, 45),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: rf(context, 8), color: Colors.grey)),
          SizedBox(height: rs(context, 2)),
          Container(
            padding: EdgeInsets.symmetric(vertical: rs(context, 2)),
            width: double.infinity,
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(rs(context, 4)),
              border: Border.all(color: activeColor.withValues(alpha: 0.2)),
            ),
            alignment: Alignment.center,
            child: Text(text, style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: rf(context, 11))),
          ),
        ],
      ),
    );
  }

  Widget _buildMapOverlay() {
    String title = '需要熱源 (売上高)';
    if (_selectedMode == HeatmapMode.customer) title = '密集度 (顧客数)';
    if (_selectedMode == HeatmapMode.loyalty) title = '顧客継続状況 (リピート判定)';

    return Positioned(
      top: rs(context, 16), left: rs(context, 16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 8)),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(rs(context, 8)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 12))),
            if (_selectedMode == HeatmapMode.loyalty) ...[
              SizedBox(height: rs(context, 8)),
              Row(
                children: [
                  _legendItem('新規', Colors.red),
                  SizedBox(width: rs(context, 8)),
                  _legendItem('継続', Colors.orange),
                  SizedBox(width: rs(context, 8)),
                  _legendItem('離反', Colors.grey),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: rs(context, 8), height: rs(context, 8), decoration: BoxDecoration(color: color.withValues(alpha: 0.7), shape: BoxShape.circle)),
        SizedBox(width: rs(context, 4)),
        Text(label, style: TextStyle(fontSize: rf(context, 10), color: Colors.black87)),
      ],
    );
  }
}
