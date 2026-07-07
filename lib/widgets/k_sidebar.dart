import 'package:flutter/material.dart';

class KSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const KSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: true,
      minExtendedWidth: 220, // 左揃えを安定させるために幅を確保
      backgroundColor: Colors.grey[50],
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      leading: Padding(
        padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
        child: Center(
          child: SizedBox(
            width: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/img/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.restaurant_menu, size: 40, color: Colors.deepOrange);
                },
              ),
            ),
          ),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.edit_document),
          label: Text('受注入力', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.list_alt),
          label: Text('受注一覧', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.inventory_2),
          label: Text('調理・仕入れ計画', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.local_shipping),
          label: Text('配送ルート最適化', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.map),
          label: Text('独自ジオコーディング', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.email),
          label: Text('事前確認メール', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.analytics),
          label: Text('データ分析', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people),
          label: Text('顧客管理', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.restaurant),
          label: Text('メニューマスタ', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.badge),
          label: Text('スタッフ管理', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
      trailing: Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 24),
              _buildStoreInfo('岡崎本店', '岡崎市井田南町3-5', '0564-23-8861'),
              const SizedBox(height: 12),
              _buildStoreInfo('名古屋店', '名古屋市緑区森の里1-93', '050-1748-2670'),
              const SizedBox(height: 12),
              _buildStoreInfo('岐阜店', '岐阜県内 (デリバリー専門)', '050-1748-2670'),
              const SizedBox(height: 40), // 店舗情報を少し上に移動
              const Text(
                'Version 1.0.52',
                style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreInfo(String name, String address, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
        ),
        Text(
          address,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        Text(
          phone,
          style: const TextStyle(fontSize: 10, color: Colors.blueGrey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
