import 'package:flutter/material.dart';
import 'k_responsive.dart';

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
    final railLabelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: rf(context, 11),
      height: 1.2,
    );

    return NavigationRail(
      extended: true,
      minExtendedWidth: rs(context, 150), 
      groupAlignment: -1.0, // 上寄せ（垂直方向）
      backgroundColor: Colors.grey[50],
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      leading: LayoutBuilder(
        builder: (context, constraints) {
          final railWidth = constraints.maxWidth;
          final logoWidth = railWidth * 0.8;

          return Padding(
            padding: EdgeInsets.only(
              top: rs(context, 24),
              bottom: rs(context, 24),
              left: rs(context, 16), // 左に少しパディング
            ),
            child: Align(
              alignment: Alignment.centerLeft, // 左寄せ
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: logoWidth,
                  child: Image.asset(
                    'assets/img/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.restaurant_menu,
                      size: rs(context, 40),
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),


      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.edit_document),
          label: Align(alignment: Alignment.centerLeft, child: Text('受注入力', style: railLabelStyle)),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.list_alt),
          label: Align(alignment: Alignment.centerLeft, child: Text('受注一覧', style: railLabelStyle)),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.inventory_2),
          label: Align(alignment: Alignment.centerLeft, child: Text('調理・仕入れ計画', style: railLabelStyle)),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.local_shipping),
          label: Align(alignment: Alignment.centerLeft, child: Text('配送ルート最適化', style: railLabelStyle)),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.email),
          label: Align(alignment: Alignment.centerLeft, child: Text('事前確認メール', style: railLabelStyle)),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.analytics),
          label: Align(alignment: Alignment.centerLeft, child: Text('データ分析', style: railLabelStyle)),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.people),
          label: Align(alignment: Alignment.centerLeft, child: Text('顧客管理', style: railLabelStyle)),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.restaurant),
          label: Align(alignment: Alignment.centerLeft, child: Text('メニューマスタ', style: railLabelStyle)),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.badge),
          label: Align(alignment: Alignment.centerLeft, child: Text('スタッフ管理', style: railLabelStyle)),
        ),
      ],
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomLeft,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 24.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  SizedBox(height: rs(context, 24)),
                  _buildStoreInfo(context, '岡崎本店', '岡崎市井田南町3-5', '0564-23-8861'),
                  SizedBox(height: rs(context, 10)),
                  _buildStoreInfo(context, '名古屋店', '名古屋市緑区森の里1-93', '050-1748-2670'),
                  SizedBox(height: rs(context, 10)),
                  _buildStoreInfo(context, '岐阜店', '岐阜県岐阜市加納矢場町1-42-1', '050-1748-2670'),
                  SizedBox(height: rs(context, 40)), 
                  Text(
                    'Version 1.0.52',
                    style: TextStyle(fontSize: rf(context, 10), color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: rs(context, 10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreInfo(BuildContext context, String name, String address, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 12), color: Colors.black87),
        ),
        Text(
          address,
          style: TextStyle(fontSize: rf(context, 10), color: Colors.grey),
        ),
        Text(
          phone,
          style: TextStyle(fontSize: rf(context, 10), color: Colors.blueGrey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
