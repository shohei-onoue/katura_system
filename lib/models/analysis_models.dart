/// 経営分析用データモデル
class BusinessMetrics {
  final int todayOrders;
  final double wasteRate;       // 廃棄率 (0.0 - 1.0)
  final Duration avgDeliveryTime;
  final double grossMargin;     // 粗利益率 (0.0 - 1.0)
  final List<TimeSeriesData> demandTrend;
  final List<SkuPerformance> skuPerformance;

  BusinessMetrics({
    required this.todayOrders,
    required this.wasteRate,
    required this.avgDeliveryTime,
    required this.grossMargin,
    required this.demandTrend,
    required this.skuPerformance,
  });
}

class TimeSeriesData {
  final DateTime timestamp;
  final double value;
  final double? target;

  TimeSeriesData(this.timestamp, this.value, {this.target});
}

class SkuPerformance {
  final String name;
  final double profitMargin; // 利益率
  final double wasteRisk;   // 廃棄リスク
  final int salesCount;

  SkuPerformance({
    required this.name,
    required this.profitMargin,
    required this.wasteRisk,
    required this.salesCount,
  });
}
