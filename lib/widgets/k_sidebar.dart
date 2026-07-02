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
      minExtendedWidth: 200,
      backgroundColor: Colors.grey[50],
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/img/logo.jpeg',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.restaurant_menu, size: 40, color: Colors.deepOrange);
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'KATURA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.edit_document),
          label: Text('受注入力'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.list_alt),
          label: Text('受注一覧'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.inventory_2),
          label: Text('調理・仕入れ計画'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.local_shipping),
          label: Text('配送ルート最適化'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.map),
          label: Text('独自ジオコーディング'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.email),
          label: Text('事前確認メール'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.analytics),
          label: Text('データ分析'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people),
          label: Text('顧客管理'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.restaurant),
          label: Text('メニューマスタ'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.badge),
          label: Text('スタッフ管理'),
        ),
      ],
      trailing: Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 12),
              _buildStoreInfo('岡崎本店', '岡崎市井田南町3-5', '0564-23-8861'),
              const SizedBox(height: 12),
              _buildStoreInfo('名古屋店', '名古屋市緑区森の里1-93', '050-1748-2670'),
              const SizedBox(height: 12),
              _buildStoreInfo('岐阜店', '岐阜県内 (デリバリー専門)', '050-1748-2670'),
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
