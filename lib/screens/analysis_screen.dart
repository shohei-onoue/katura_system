import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../widgets/k_responsive.dart';
import '../widgets/k_point_heatmap.dart';
import '../widgets/k_button.dart';

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
  double _revenueThreshold = 100000; // デフォルト10万円
  double _customerThreshold = 10;    // デフォルト10社

  List<HeatmapPoint> _heatmapPoints = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final orders = await _orderService.getAllOrders();
    _allOrders = orders;
    _calculateHeatmap();
  }

  void _calculateHeatmap() {
    final Map<String, List<OrderModel>> areaGroups = {};
    for (var o in _allOrders) {
      if (o.latitude == null || o.latitude == 0) continue;
      final key = "${o.latitude!.toStringAsFixed(3)},${o.longitude!.toStringAsFixed(3)}";
      if (!areaGroups.containsKey(key)) areaGroups[key] = [];
      areaGroups[key]!.add(o);
    }

    final List<HeatmapPoint> points = [];
    final now = DateTime.now();

    areaGroups.forEach((key, orders) {
      final lat = double.parse(key.split(',')[0]);
      final lng = double.parse(key.split(',')[1]);
      final center = LatLng(lat, lng);

      if (_selectedMode == HeatmapMode.revenue) {
        final double sum = orders.fold(0, (s, o) => s + o.totalPrice);
        points.add(HeatmapPoint(location: center, value: sum));
      } 
      else if (_selectedMode == HeatmapMode.customer) {
        final double count = orders.map((o) => o.facilityName).toSet().length.toDouble();
        points.add(HeatmapPoint(location: center, value: count));
      } 
      else if (_selectedMode == HeatmapMode.loyalty) {
        // 直近の注文と最初の注文を比較
        final dates = orders.map((o) => o.deliveryDate).toList()..sort();
        final lastDate = dates.last;
        final firstDate = dates.first;
        
        String status = 'active';
        if (now.difference(firstDate).inDays < 90) {
          status = 'new';
        } else if (now.difference(lastDate).inDays > 180) {
          status = 'churned';
        }

        points.add(HeatmapPoint(location: center, value: 1.0, status: status));
      }
    });

    setState(() {
      _heatmapPoints = points;
      _isLoading = false;
    });
  }

  void _showSettings() {
    final controller = TextEditingController(
      text: _selectedMode == HeatmapMode.revenue 
        ? _revenueThreshold.toInt().toString() 
        : _customerThreshold.toInt().toString()
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_selectedMode == HeatmapMode.revenue ? '売上熱源の基準設定' : '顧客密度の基準設定'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('最高レベル（最も濃い色）として表示する数値を入力してください。'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: _selectedMode == HeatmapMode.revenue ? '円' : '社',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          KButton(
            label: '適用', 
            fullWidth: false,
            onPressed: () {
              setState(() {
                final val = double.tryParse(controller.text) ?? 0;
                if (_selectedMode == HeatmapMode.revenue) {
                  _revenueThreshold = val;
                } else {
                  _customerThreshold = val;
                }
                _calculateHeatmap();
              });
              Navigator.pop(context);
            }
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            flex: 75,
            child: Stack(
              children: [
                KPointHeatmap(
                  points: _heatmapPoints,
                  mode: _selectedMode,
                  threshold: _selectedMode == HeatmapMode.revenue ? _revenueThreshold : _customerThreshold,
                  initialPosition: const CameraPosition(target: LatLng(35.0, 137.0), zoom: 10),
                ),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
                _buildMapOverlay(),
              ],
            ),
          ),
          Expanded(
            flex: 25,
            child: _buildControlPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade200))),
      padding: EdgeInsets.all(rav(context, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('経営ダッシュボード', style: TextStyle(fontSize: rf(context, 22), fontWeight: FontWeight.w900)),
          const SizedBox(height: 32),
          _buildModeSelector(),
          const Spacer(),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Column(
      children: [
        _modeCard('売上熱源分析', 'エリア毎の合計売上', HeatmapMode.revenue, Colors.blue),
        const SizedBox(height: 12),
        _modeCard('顧客密度分析', '所属企業数ベース', HeatmapMode.customer, Colors.green),
        const SizedBox(height: 12),
        _modeCard('注文頻度・離脱分析', '新規〜離脱の可視化', HeatmapMode.loyalty, Colors.redAccent),
      ],
    );
  }

  Widget _modeCard(String title, String sub, HeatmapMode mode, Color color) {
    final isSelected = _selectedMode == mode;
    return InkWell(
      onTap: () => setState(() { _selectedMode = mode; _calculateHeatmap(); }),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? color : Colors.black87)),
                  Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected && mode != HeatmapMode.loyalty)
              IconButton(
                icon: const Icon(Icons.settings, size: 20),
                onPressed: _showSettings,
                color: color,
              ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    if (_selectedMode == HeatmapMode.loyalty) {
      return Column(
        children: [
          _legendItem('新規顧客 (3ヶ月以内)', Colors.red),
          _legendItem('安定顧客', Colors.orange),
          _legendItem('離脱・休眠 (>6ヶ月)', Colors.grey),
        ],
      );
    }
    final color = _selectedMode == HeatmapMode.revenue ? Colors.blue : Colors.green;
    final unit = _selectedMode == HeatmapMode.revenue ? '円' : '社';
    final threshold = _selectedMode == HeatmapMode.revenue ? _revenueThreshold : _customerThreshold;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('現在の基準値', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 8),
        Text('最高レベル: ${NumberFormat('#,###').format(threshold)}$unit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4),
        Text('※設定アイコンから変更可能', style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMapOverlay() {
    return Positioned(
      top: 24, left: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Text(_selectedMode == HeatmapMode.revenue ? '売上分布（青）' : (_selectedMode == HeatmapMode.customer ? '顧客分布（緑）' : '顧客状態（色分け）'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
