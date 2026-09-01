import 'package:flutter/material.dart';
import 'k_responsive.dart';
import '../models/branch_model.dart';
import '../services/branch_service.dart';

/// 標準の[NavigationRail]は項目間の余白が大きく調整できないため、
/// 間隔を詰めた独自レイアウト（スクロール禁止・全項目を必ず画面内に収める）で実装する。
class KSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const KSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  State<KSidebar> createState() => _KSidebarState();
}

class _KSidebarState extends State<KSidebar> {
  final GlobalKey _manageLabelKey = GlobalKey();
  final _branchService = BranchService();
  List<BranchModel> _branches = [];

  // 「管理」にまとめる画面の論理インデックス（MainScreenの_selectedIndexと対応）
  static const List<int> _manageIndices = [6, 7, 10, 8];
  static const List<String> _manageLabels = ['顧客管理', 'メニューマスタ', '材料マスタ', 'スタッフ管理'];
  static const List<IconData> _manageIcons = [Icons.people, Icons.restaurant, Icons.egg_alt, Icons.badge];

  bool get _isManageActive => _manageIndices.contains(widget.selectedIndex);

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    final branches = await _branchService.getAllBranches();
    if (!mounted) return;
    setState(() => _branches = branches);
  }

  void _showManageMenu() {
    final renderBox = _manageLabelKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayBox = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlayBox == null) return;

    final topRight = renderBox.localToGlobal(Offset(renderBox.size.width, 0), ancestor: overlayBox);
    final bottomRight = renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero), ancestor: overlayBox);
    final position = RelativeRect.fromRect(
      Rect.fromPoints(topRight, bottomRight),
      Offset.zero & overlayBox.size,
    );

    showMenu<int>(
      context: context,
      position: position,
      color: const Color(0xFF000038).withValues(alpha: 0.5),
      items: List.generate(_manageIndices.length, (i) {
        return PopupMenuItem<int>(
          value: _manageIndices[i],
          child: Row(
            children: [
              Icon(_manageIcons[i], size: rs(context, 18), color: Colors.white),
              SizedBox(width: rs(context, 10)),
              Text(_manageLabels[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }),
    ).then((selected) {
      if (selected != null) {
        widget.onDestinationSelected(selected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogo(context),
          SizedBox(height: rs(context, 4)),
          _buildItem(context, index: 0, icon: Icons.edit_document, label: '受注入力'),
          _buildItem(context, index: 1, icon: Icons.list_alt, label: '受注一覧'),
          _buildItem(context, index: 2, icon: Icons.inventory_2, label: '調理・仕入れ計画'),
          _buildItem(context, index: 3, icon: Icons.local_shipping, label: '配送ルート最適化'),
          _buildItem(context, index: 5, icon: Icons.analytics, label: 'データ分析'),
          _buildManageItem(context),
          _buildItem(context, index: 9, icon: Icons.settings, label: '設定'),
          const Spacer(),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final logoWidth = constraints.maxWidth * 0.8;
        return Padding(
          padding: EdgeInsets.only(
            top: rs(context, 12),
            bottom: rs(context, 8),
            left: rs(context, 16),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(rs(context, 8)),
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
    );
  }

  Widget _buildItem(BuildContext context, {required int index, required IconData icon, required String label}) {
    final isSelected = widget.selectedIndex == index;
    return _buildRow(
      context,
      isSelected: isSelected,
      onTap: () => widget.onDestinationSelected(index),
      icon: Icon(icon, color: isSelected ? Colors.deepPurple : Colors.black54, size: rs(context, 20)),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: rf(context, 14),
          height: 1.2,
          color: isSelected ? Colors.deepPurple : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildManageItem(BuildContext context) {
    return _buildRow(
      context,
      isSelected: _isManageActive,
      onTap: _showManageMenu,
      icon: Icon(
        _isManageActive ? Icons.admin_panel_settings : Icons.admin_panel_settings_outlined,
        color: _isManageActive ? Colors.deepPurple : Colors.black54,
        size: rs(context, 20),
      ),
      label: Container(
        key: _manageLabelKey,
        child: Row(
          children: [
            Text(
              '管理',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: rf(context, 14),
                height: 1.2,
                color: _isManageActive ? Colors.deepPurple : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(Icons.keyboard_arrow_down, size: rs(context, 16), color: _isManageActive ? Colors.deepPurple : Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, {required bool isSelected, required VoidCallback onTap, required Widget icon, required Widget label}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 2)),
      child: Material(
        color: isSelected ? Colors.deepPurple.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(rs(context, 8)),
        child: InkWell(
          borderRadius: BorderRadius.circular(rs(context, 8)),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 8)),
            child: Row(
              children: [
                icon,
                SizedBox(width: rs(context, 10)),
                Expanded(child: label),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 24.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          SizedBox(height: rs(context, 6)),
          for (final branch in _branches) ...[
            _buildStoreInfo(context, branch.name, branch.address, branch.phone),
            SizedBox(height: rs(context, 3)),
          ],
          Text(
            'Version 1.0.52',
            style: TextStyle(fontSize: rf(context, 10), color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: rs(context, 8)),
        ],
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
