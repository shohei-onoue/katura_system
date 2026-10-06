import 'package:flutter/material.dart';
import 'k_responsive.dart';
import '../services/auth_service.dart';
import '../services/email_auth_service.dart';
import '../screens/login/login_screen.dart';
import 'package:katura_system/utils/app_colors.dart';

/// 標準の[NavigationRail]は項目間の余白が大きく調整できないため、
/// 間隔を詰めた独自レイアウト（スクロール禁止・全項目を必ず画面内に収める）で実装する。
class KSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final bool collapsed; // trueならアイコンのみ表示
  final VoidCallback? onClose;
  final VoidCallback? onOpen;

  const KSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.collapsed = false,
    this.onClose,
    this.onOpen,
  });

  @override
  State<KSidebar> createState() => _KSidebarState();
}

class _KSidebarState extends State<KSidebar> {
  String _staffName = '';

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final emailName = EmailAuthService().currentUserDisplayName;
    if (emailName != null) {
      setState(() => _staffName = emailName);
      return;
    }
    final staff = await AuthService().restoreSession();
    if (!mounted) return;
    setState(() => _staffName = staff?.name ?? '');
  }

  Future<void> _logout() async {
    await AuthService().logout();
    await EmailAuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.menuBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.collapsed) ...[
            Container(
              color: AppColors.whiteText,
              height: _openLogoAreaHeight(context),
              padding: EdgeInsets.all(rs(context, 8)),
              child: Image.asset(
                'assets/img/Icon.jpg',
                fit: BoxFit.contain,
              ),
            ),
            _buildMenuHeader(context),
          ] else
            // 開閉アイコンはロゴ(白)とメニュー(黒)の境目の中央・右詰め
            Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [_buildLogo(context), _buildMenuHeader(context)],
                ),
                Positioned(
                  right: 0,
                  bottom: rs(context, 48) - rs(context, 15),
                  child: _buildToggle(context),
                ),
              ],
            ),
          SizedBox(height: rs(context, 4)),
          _buildItem(
            context,
            index: 0,
            icon: Icons.edit_document,
            label: '受注入力',
          ),
          _buildItem(context, index: 1, icon: Icons.list_alt, label: '受注一覧'),
          _buildItem(
            context,
            index: 2,
            icon: Icons.inventory_2,
            label: '調理・仕入れ計画',
          ),
          _buildItem(
            context,
            index: 3,
            icon: Icons.local_shipping,
            label: '配送予定',
          ),
          _buildItem(context, index: 5, icon: Icons.analytics, label: 'データ分析'),
          _buildItem(context, index: 6, icon: Icons.people, label: '顧客管理'),
          _buildItem(
            context,
            index: 7,
            icon: Icons.restaurant,
            label: 'メニューマスタ',
          ),
          _buildItem(context, index: 8, icon: Icons.badge, label: 'スタッフ管理'),
          _buildItem(context, index: 9, icon: Icons.settings, label: '設定'),
          const Spacer(),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildToggle(BuildContext context) {
    return Material(
      color: AppColors.menuBackground,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.whiteText),
      ),
      child: InkWell(
                onTap: widget.collapsed ? widget.onOpen : widget.onClose,
        child: SizedBox(
          width: rs(context, 30),
          height: rs(context, 30),
          child: Icon(
            widget.collapsed
                ? Icons.chevron_right
                : Icons.chevron_left,
            color: AppColors.whiteText,
            size: rs(context, 22),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuHeader(BuildContext context) {
    final toggle = _buildToggle(context);
    return SizedBox(
      height: rs(context, 48),
      child: Center(
        child: widget.collapsed
            ? toggle
            : Text(
                '- MENU -',
                style: TextStyle(
                  color: AppColors.whiteText,
                  fontWeight: FontWeight.bold,
                  fontSize: rf(context, 16),
                ),
              ),
      ),
    );
  }

  double _openLogoAreaHeight(BuildContext context) =>
      kOpenLogoAreaHeight(context);

  Widget _buildLogo(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final logoWidth = constraints.maxWidth * 0.8;
        return Container(
          color: AppColors.whiteText,
          padding: EdgeInsets.only(
            top: rs(context, 12),
            bottom: rs(context, 8),
            left: rs(context, 16),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(rs(context, 8)),
                child: SizedBox(
                  width: logoWidth,
                  child: Image.asset(
                    'assets/img/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.restaurant_menu,
                      size: rs(context, 40),
                      color: AppColors.accentOrange,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = widget.selectedIndex == index;
    return _buildRow(
      context,
      isSelected: isSelected,
      onTap: () => widget.onDestinationSelected(index),
      icon: Icon(icon, color: AppColors.whiteText, size: rs(context, 20)),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: rf(context, 14),
          height: 1.2,
          color: AppColors.whiteText,
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required bool isSelected,
    required VoidCallback onTap,
    required Widget icon,
    required Widget label,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rs(context, 8),
        vertical: rs(context, 2),
      ),
      child: Material(
        color: isSelected
            ? AppColors.whiteText.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(rs(context, 8)),
        child: InkWell(
          borderRadius: BorderRadius.circular(rs(context, 8)),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 0 : rs(context, 12),
              vertical: rs(context, 8),
            ),
            child: widget.collapsed
                ? Center(child: icon)
                : Row(
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
      padding: EdgeInsets.symmetric(
        horizontal: widget.collapsed ? 0 : rs(context, 24.0),
      ),
      child: widget.collapsed
          ? Padding(
              padding: EdgeInsets.only(bottom: rs(context, 12)),
              child: Center(
                child: Tooltip(
                  message: 'ログアウト',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(rs(context, 8)),
                    onTap: _logout,
                    child: Padding(
                      padding: EdgeInsets.all(rs(context, 4)),
                      child: Icon(
                        Icons.logout,
                        size: rs(context, 18),
                        color: AppColors.whiteText,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Colors.white24),
                SizedBox(height: rs(context, 6)),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _staffName.isNotEmpty ? _staffName : '未ログイン',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: rf(context, 12),
                          color: AppColors.whiteText,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'ログアウト',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(rs(context, 8)),
                        onTap: _logout,
                        child: Padding(
                          padding: EdgeInsets.all(rs(context, 4)),
                          child: Icon(
                            Icons.logout,
                            size: rs(context, 18),
                            color: AppColors.whiteText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: rs(context, 6)),
                Text(
                  'Version 1.0.52',
                  style: TextStyle(
                    fontSize: rf(context, 10),
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: rs(context, 8)),
              ],
            ),
    );
  }
}
