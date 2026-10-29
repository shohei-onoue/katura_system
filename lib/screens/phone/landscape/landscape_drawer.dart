import 'package:flutter/material.dart';

/// スマホ横向きのメニュー(Figma 169:210): 幅560・黒背景・項目2列。PhoneDrawer と同じ引数。
/// 使い方: Drawer の中身として PhoneDrawer の代わりに返す（Drawer幅は560で包まれる）。
class LandscapeDrawer extends StatelessWidget {
  final int selectedIndex;
  final String loginId;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final VoidCallback onClose;

  const LandscapeDrawer({
    super.key,
    required this.selectedIndex,
    this.loginId = '',
    required this.onSelect,
    required this.onLogout,
    required this.onClose,
  });

  static const _left = <(int, IconData, String)>[
    (0, Icons.post_add_rounded, '受注入力'),
    (1, Icons.list_alt_rounded, '受注一覧'),
    (2, Icons.inventory_2_rounded, '調理・仕入れ計画'),
    (3, Icons.local_shipping_rounded, '配送予定'),
  ];
  static const _right = <(int, IconData, String)>[
    (5, Icons.analytics_rounded, 'データ分析'),
    (6, Icons.people_rounded, '顧客管理'),
    (7, Icons.restaurant_rounded, 'メニューマスタ'),
    (9, Icons.settings_rounded, '設定'),
  ];

  Widget _item((int, IconData, String) e) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onSelect(e.$1),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: e.$1 == selectedIndex ? const Color(0xFF3A3A3A) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF444444)),
        ),
        child: Row(children: [
          Icon(e.$2, size: 28, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(e.$3, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
        ]),
      ),
    );
  }

  Widget _column(List<(int, IconData, String)> items) => Expanded(
        child: Column(children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            _item(items[i]),
          ],
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 560,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Row(children: [
                const Expanded(child: Text('- MENU -', maxLines: 1, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded, size: 32, color: Colors.white)),
              ]),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _column(_left),
                      const SizedBox(width: 8),
                      _column(_right),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onLogout,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF666666))),
                  child: Row(children: [
                    const Icon(Icons.account_circle_rounded, size: 28, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(child: Text(loginId.isNotEmpty ? loginId : '未ログイン', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                    const Icon(Icons.logout_rounded, size: 28, color: Colors.white),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
