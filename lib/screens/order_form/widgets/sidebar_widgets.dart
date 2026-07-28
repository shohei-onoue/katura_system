import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../widgets/k_phone_input_pad.dart';
import '../../../../widgets/k_responsive.dart';

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
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: rs(context, 40)),
          Text('入力ダイヤル', style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold)),
          SizedBox(height: rs(context, 20)),
          KPhoneInputPad(
            controller: controller,
            onInput: onInput,
            onClear: onClear,
            onBackspace: onBackspace,
          ),
          SizedBox(height: rs(context, 40)),
        ],
      ),
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(rs(context, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('過去1年間の注文傾向', Icons.analytics),
          SizedBox(height: rs(context, 20)),
          _TrendChart(history: history),
          SizedBox(height: rs(context, 40)),
          _SectionTitle('注文メニュー TOP5', Icons.leaderboard),
          SizedBox(height: rs(context, 20)),
          _TopItemsRanking(history: history),
          const Divider(height: 48),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(Icons.refresh, size: rs(context, 16)),
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
    return Row(children: [Icon(icon, size: rs(context, 18), color: Colors.blueGrey), SizedBox(width: rs(context, 8)), Text(title, style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.bold, color: Colors.blueGrey))]);
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
    return Container(height: rs(context, 220), padding: EdgeInsets.only(top: rs(context, 20)), child: Stack(children: [Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(6, (i) => Expanded(child: Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))), alignment: Alignment.topLeft, child: i % 2 == 0 ? Text('${((5 - i) * maxScale / 50000).toInt()}万', style: TextStyle(fontSize: rf(context, 8), color: Colors.grey)) : null)))), Padding(padding: EdgeInsets.only(left: rs(context, 20), right: rs(context, 10)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: monthlyData.map((d) { final height = maxScale == 0 ? 0.0 : (d['total'] as int) / maxScale * rs(context, 180); return Column(mainAxisAlignment: MainAxisAlignment.end, children: [Container(width: rs(context, 14), height: height.clamp(0, rs(context, 180)), decoration: BoxDecoration(color: Colors.deepPurple.shade300, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))), SizedBox(height: rs(context, 8)), Text('${d['month']}', style: TextStyle(fontSize: rf(context, 10), fontWeight: FontWeight.bold, color: Colors.blueGrey))]); }).toList()))]));
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
    if (top5.isEmpty) return Center(child: Text('データなし', style: TextStyle(color: Colors.grey, fontSize: rf(context, 14))));
    
    return Column(
      children: top5.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: rs(context, 12)),
          padding: EdgeInsets.all(rs(context, 12)),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Container(
                width: rs(context, 24),
                height: rs(context, 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: i == 0 ? Colors.orange : Colors.grey.shade300, shape: BoxShape.circle),
                child: Text('${i + 1}', style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              SizedBox(width: rs(context, 12)),
              Expanded(child: Text(item.key, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 14)))),
              Text('${item.value}点', style: TextStyle(color: Colors.blueGrey, fontSize: rf(context, 13))),
            ],
          ),
        );
      }).toList(),
    );
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
      padding: EdgeInsets.all(rs(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_SectionTitle('施設検索結果', Icons.business_center), IconButton(icon: Icon(Icons.close, size: rs(context, 18)), onPressed: onClose)]),
          SizedBox(height: rs(context, 12)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            itemBuilder: (context, i) => Card(margin: EdgeInsets.only(bottom: rs(context, 8)), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 8)), side: BorderSide(color: Colors.grey.shade200)), child: ListTile(dense: true, title: Text(results[i]['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 14))), subtitle: Text(results[i]['address'], style: TextStyle(fontSize: rf(context, 12))), trailing: Icon(Icons.chevron_right, size: rs(context, 16)), onTap: () => onSelect(results[i]))),
          ),
          if (onForceApiSearch != null) ...[
            SizedBox(height: rs(context, 24)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(Icons.travel_explore, size: rs(context, 18)),
                label: Text('該当なし？Googleマップで再検索', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 14))),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: rs(context, 16)),
                  foregroundColor: Colors.deepPurple,
                  side: const BorderSide(color: Colors.deepPurple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
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
      padding: EdgeInsets.all(rs(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('前回注文の詳細', Icons.history),
          SizedBox(height: rs(context, 16)),
          _InfoRow('配達先', order.facilityName, isBold: true),
          _InfoRow('住所', order.address.split(' (').first),
          _InfoRow('位置情報', coords),
          _InfoRow('受取人', order.receiverName.isEmpty ? '-' : order.receiverName),
          const Divider(height: 32),
          _SectionTitle('前回注文の商品', Icons.restaurant),
          SizedBox(height: rs(context, 12)),
          ...order.items.map((i) => Padding(padding: EdgeInsets.only(bottom: rs(context, 4)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(i['name'], style: TextStyle(fontSize: rf(context, 14)))), Text('x${i['quantity']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 14)))]))),
          const Divider(height: 32),
          _SectionTitle('決済情報', Icons.payment),
          _InfoRow('前回決済', order.paymentMethod),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('前回合計', style: TextStyle(color: Colors.grey, fontSize: rf(context, 14))), Text('¥${order.items.fold(0, (sum, i) => sum + (i['price'] as int) * (i['quantity'] as int))}', style: TextStyle(fontSize: rf(context, 24), fontWeight: FontWeight.bold, color: Colors.deepOrange))]),
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
    return Padding(padding: EdgeInsets.symmetric(vertical: rs(context, 4)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: rf(context, 11), color: Colors.grey)), Text(value, style: TextStyle(fontSize: rf(context, 14), fontWeight: isBold ? FontWeight.bold : FontWeight.normal))]));
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
      margin: EdgeInsets.all(rs(context, 16)),
      padding: EdgeInsets.all(rs(context, 20)),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(rs(context, 12)), border: Border.all(color: Colors.orange.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('受注サマリー', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 18))),
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
    return Padding(padding: EdgeInsets.symmetric(vertical: rs(context, 4)), child: Row(children: [Text('$label: ', style: TextStyle(color: Colors.grey, fontSize: rf(context, 14))), Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 14))))]));
  }
}
