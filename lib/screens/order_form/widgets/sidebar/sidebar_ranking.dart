import 'package:flutter/material.dart';
import '../../../../models/order_model.dart';
import '../../../../models/menu_model.dart';
import '../../../../widgets/k_responsive.dart';

class SidebarRanking extends StatelessWidget {
  final List<OrderModel> history;
  final List<MenuModel> allMenus;

  const SidebarRanking({super.key, required this.history, required this.allMenus});

  @override
  Widget build(BuildContext context) {
    // 商品ごとの注文頻度（注文回数）を集計
    final Map<String, int> rankingMap = {};
    for (var order in history) {
      // 1回の注文で同じ商品を複数個頼んでも、その商品についてはカウント1とする
      final uniqueItemsInOrder = order.items.map((i) => i['name'] as String? ?? '不明な商品').toSet();
      for (var name in uniqueItemsInOrder) {
        rankingMap[name] = (rankingMap[name] ?? 0) + 1;
      }
    }

    // 頻度順にソートして上位3件を抽出
    final sortedRanking = rankingMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sortedRanking.take(3).toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rs(context, 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, size: rs(context, 16), color: Colors.amber.shade700),
              SizedBox(width: rs(context, 8)),
              Text(
                'よく頼むメニュー (ベスト3)',
                style: TextStyle(
                  fontSize: rf(context, 14),
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          SizedBox(height: rs(context, 12)),
          if (top3.isEmpty)
            Expanded(
              child: Center(
                child: Text('データがありません', style: TextStyle(color: Colors.grey, fontSize: rf(context, 13))),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: top3.length,
                itemBuilder: (context, index) {
                  final item = top3[index];
                  final menu = _findMenu(item.key);
                  return _RankingItem(
                    rank: index + 1,
                    name: item.key,
                    imageUrl: menu?.imageUrl ?? '',
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  MenuModel? _findMenu(String name) {
    try {
      return allMenus.firstWhere((m) => m.name == name);
    } catch (_) {
      return null;
    }
  }
}

class _RankingItem extends StatelessWidget {
  final int rank;
  final String name;
  final String imageUrl;

  const _RankingItem({required this.rank, required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    Color rankColor;
    switch (rank) {
      case 1: rankColor = Colors.amber.shade600; break;
      case 2: rankColor = Colors.grey.shade400; break;
      case 3: rankColor = Colors.brown.shade300; break;
      default: rankColor = Colors.blueGrey.shade100;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 10)),
      child: Row(
        children: [
          // 順位バッジ
          Container(
            width: rs(context, 16),
            height: rs(context, 16),
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                color: Colors.white,
                fontSize: rf(context, 12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: rs(context, 16)),
          // 商品画像
          Container(
            width: rs(context, 35),
            height: rs(context, 35),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(rs(context, 8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(rs(context, 8)),
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.restaurant, color: Colors.grey.shade400))
                  : Icon(Icons.restaurant, color: Colors.grey.shade400),
            ),
          ),
          SizedBox(width: rs(context, 12)),
          // メニュー名
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
