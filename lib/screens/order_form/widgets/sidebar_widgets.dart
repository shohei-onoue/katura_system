import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../widgets/k_phone_input_pad.dart';

// --- Sidebar: Phone Pad ---
class SidebarPhonePad extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onInput;
  final VoidCallback onClear;
  final VoidCallback onBackspace;

  const SidebarPhonePad({
    super.key,
    required this.controller,
    required this.onInput,
    required this.onClear,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text('入力ダイヤル', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Spacer(),
        KPhoneInputPad(
          controller: controller,
          onInput: onInput,
          onClear: onClear,
          onBackspace: onBackspace,
        ),
        const Spacer(),
      ],
    );
  }
}

// --- Sidebar: Analysis ---
class SidebarAnalysis extends StatelessWidget {
  final List<OrderModel> history;
  final VoidCallback onRegenerate;

  const SidebarAnalysis({super.key, required this.history, required this.onRegenerate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('過去1年間の注文傾向', Icons.analytics),
          const SizedBox(height: 20),
          _TrendChart(history: history),
          const SizedBox(height: 40),
          _SectionTitle('注文メニュー TOP5', Icons.leaderboard),
          const SizedBox(height: 20),
          Expanded(child: _TopItemsRanking(history: history)),
          const Divider(height: 48),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('ダミーデータを最新座標で再生成'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.grey, side: BorderSide(color: Colors.grey.shade300)),
              onPressed: onRegenerate,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle(this.title, this.icon);
  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon, size: 18, color: Colors.blueGrey), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey))]);
  }
}

class _TrendChart extends StatelessWidget {
  final List<OrderModel> history;
  const _TrendChart({required this.history});
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthlyData = List.generate(12, (i) {
      final month = i + 1;
      final total = history.where((o) => o.deliveryDate.year == now.year && o.deliveryDate.month == month).fold(0, (sum, o) => sum + o.items.fold(0, (s, item) => s + (item['price'] as int) * (item['quantity'] as int)));
      return {'month': month, 'total': total};
    });
    final maxAmount = monthlyData.fold<int>(0, (max, d) => (d['total'] as int) > max ? d['total'] as int : max);
    final maxScale = ((maxAmount / 10000).ceil() * 10000).clamp(50000, 1000000);
    return Container(height: 220, padding: const EdgeInsets.only(top: 20), child: Stack(children: [Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(6, (i) => Expanded(child: Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))), alignment: Alignment.topLeft, child: i % 2 == 0 ? Text('${((5 - i) * maxScale / 50000).toInt()}万', style: const TextStyle(fontSize: 8, color: Colors.grey)) : null)))), Padding(padding: const EdgeInsets.only(left: 20, right: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: monthlyData.map((d) { final height = maxScale == 0 ? 0.0 : (d['total'] as int) / maxScale * 180; return Column(mainAxisAlignment: MainAxisAlignment.end, children: [Container(width: 14, height: height.clamp(0, 180), decoration: BoxDecoration(color: Colors.deepPurple.shade300, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))), const SizedBox(height: 8), Text('${d['month']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey))]); }).toList()))]));
  }
}

class _TopItemsRanking extends StatelessWidget {
  final List<OrderModel> history;
  const _TopItemsRanking({required this.history});
  @override
  Widget build(BuildContext context) {
    final Map<String, int> counts = {};
    for (var o in history) { for (var item in o.items) { counts[item['name']] = (counts[item['name']] ?? 0) + (item['quantity'] as int); } }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();
    if (top5.isEmpty) return const Center(child: Text('データなし', style: TextStyle(color: Colors.grey)));
    return ListView.builder(itemCount: top5.length, itemBuilder: (context, i) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)), child: Row(children: [Container(width: 24, height: 24, alignment: Alignment.center, decoration: BoxDecoration(color: i == 0 ? Colors.orange : Colors.grey.shade300, shape: BoxShape.circle), child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white))), const SizedBox(width: 12), Expanded(child: Text(top5[i].key, style: const TextStyle(fontWeight: FontWeight.bold))), Text('${top5[i].value}点', style: const TextStyle(color: Colors.blueGrey))])));
  }
}

// --- Sidebar: Search Results ---
class SidebarSearchResults extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSelect;
  final VoidCallback? onForceApiSearch; // 追加

  const SidebarSearchResults({
    super.key,
    required this.results,
    required this.onClose,
    required this.onSelect,
    this.onForceApiSearch, // 追加
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_SectionTitle('施設検索結果', Icons.business_center), IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onClose)]),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            itemBuilder: (context, i) => Card(margin: const EdgeInsets.only(bottom: 8), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)), child: ListTile(dense: true, title: Text(results[i]['name'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(results[i]['address'], style: const TextStyle(fontSize: 12)), trailing: const Icon(Icons.chevron_right, size: 16), onTap: () => onSelect(results[i]))),
          ),
          if (onForceApiSearch != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.travel_explore, size: 18),
                label: const Text('該当なし？Googleマップで再検索', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.deepPurple,
                  side: const BorderSide(color: Colors.deepPurple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onForceApiSearch,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// --- Sidebar: History Detail ---
class SidebarHistoryDetail extends StatelessWidget {
  final OrderModel order;

  const SidebarHistoryDetail({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final regExp = RegExp(r'\(([-+]?\d*\.?\d+),\s*([-+]?\d*\.?\d+)\)');
    final matches = regExp.allMatches(order.address);
    final coords = matches.isNotEmpty ? '${matches.last.group(1)}, ${matches.last.group(2)}' : '取得不可';
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('前回注文の詳細', Icons.history),
          const SizedBox(height: 16),
          _InfoRow('配達先', order.facilityName, isBold: true),
          _InfoRow('住所', order.address.split(' (').first),
          _InfoRow('位置情報', coords),
          _InfoRow('受取人', order.receiverName.isEmpty ? '-' : order.receiverName),
          const Divider(height: 32),
          _SectionTitle('前回注文の商品', Icons.restaurant),
          const SizedBox(height: 12),
          ...order.items.map((i) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(i['name'], style: const TextStyle(fontSize: 14))), Text('x${i['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold))]))),
          const Divider(height: 32),
          _SectionTitle('決済情報', Icons.payment),
          _InfoRow('前回決済', order.paymentMethod),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('前回合計', style: TextStyle(color: Colors.grey)), Text('¥${order.items.fold(0, (sum, i) => sum + (i['price'] as int) * (i['quantity'] as int))}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange))]),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  const _InfoRow(this.label, this.value, {this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)), Text(value, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal))]));
  }
}

// --- Sidebar: Summary ---
class SidebarSummary extends StatelessWidget {
  final DateTime date;
  final DateTime time;
  final String customerName;
  final String receiverName;
  final int totalPrice;
  final int totalCount;

  const SidebarSummary({
    super.key,
    required this.date,
    required this.time,
    required this.customerName,
    required this.receiverName,
    required this.totalPrice,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final weekDays = ['日', '月', '火', '水', '木', '金', '土'];
    final dateStr = "${date.year}年${date.month}月${date.day}日(${weekDays[date.weekday % 7]})";
    final timeStr = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('受注サマリー', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(),
          _SummaryRow('配達日', dateStr),
          _SummaryRow('時間', timeStr),
          _SummaryRow('注文者', customerName),
          if (receiverName.isNotEmpty) _SummaryRow('受取人', receiverName),
          _SummaryRow('合計', '¥$totalPrice ($totalCount点)'),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  const _SummaryRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Text('$label: ', style: const TextStyle(color: Colors.grey)), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)))]));
  }
}
