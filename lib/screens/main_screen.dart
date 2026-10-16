import 'package:flutter/material.dart';
import '../widgets/k_sidebar.dart';
import 'contact_progress_screen.dart';
import '../models/order_model.dart';
import 'order_form_screen.dart';
import 'customer_list_screen.dart';
import 'menu_master_screen.dart';
import 'ingredient_master_screen.dart';
import 'staff_management_screen.dart';
import 'order_list_screen.dart';
import 'planning_screen.dart';
import 'analysis_screen.dart';
import 'route_optimization_screen.dart';
import 'settings_screen.dart';
import '../widgets/k_responsive.dart';
import 'package:katura_system/utils/app_colors.dart';
import '../services/auth_service.dart';
import '../services/email_auth_service.dart';
import 'login/login_screen.dart';
import 'phone/phone_common.dart';
import '../services/pre_contact_settings_service.dart';
import 'phone/phone_greeting_screen.dart';
import '../services/order_service.dart';

/// 経営効率化を極めたメイン司令塔画面
/// ループエンジニアリング評価：
/// [改善] 受注入力・データ分析（地図を含む）以外の一覧・設定系画面はIndexedStackで
///        マウントしたままにし、再訪時のFirestore再取得・読み込み待ちを解消。
/// [改善] レスポンシブ設計を強化し、サイドバーとの連携を最適化。
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final OrderFormHandle _orderFormHandle = OrderFormHandle();
  bool _sidebarOpen = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 編集中の注文情報を保持（画面切り替えで消えないように）
  OrderModel? _currentEditingOrder;
  String _editSection = ''; // 編集で選んだ項目（配達先/日程/注文内容）

  // 常駐キャッシュ対象の画面インデックス（受注入力=0とデータ分析=5は対象外）
  static const List<int> _cachedIndices = [1, 2, 3, 6, 7, 10, 8, 9, 11];

  String? _staffName; // ログイン者名（スマホ挨拶用）
  bool _staffNameLoaded = false;
  String? _contactSummary; // スマホ挨拶の下に出す「N件中n件連絡済み」
  int _pendingCount = 0; // 上部バーの事前連絡バッジ（未連絡件数）

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h <= 10) return 'おはよう';
    if (h >= 11 && h <= 17) return 'こんにちは';
    return 'こんばんは';
  }

  Future<void> _loadContactSummary() async {
    try {
      final all = await OrderService().getAllOrders();
      final targets = OrderService.preContactTargets(all, DateTime.now());
      final pending = targets.where(OrderService.isPreContactPending).length;
      if (targets.isEmpty) {
        if (mounted) setState(() => _pendingCount = 0);
        return;
      }
      final done = targets.length - pending;
      if (mounted) {
        setState(() {
          _pendingCount = pending;
          _contactSummary = '${targets.length}件中$done件連絡済み';
        });
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    AuthService().restoreSession().then((staff) {
      if (mounted) setState(() { _staffName = staff?.name; _staffNameLoaded = true; });
    }).catchError((_) {
      if (mounted) setState(() => _staffNameLoaded = true);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && isPhoneWidth(context)) {
        PreContactSettingsService.load();
        _loadContactSummary();
      }
    });
  }

  /// 受注カードの編集中に別の機能（受注入力の新規も含む）へ移動しようとしたとき、
  /// 編集を中止してよいか確認する。中止しない場合は画面を移動しない。
  Future<void> _goTo(int index) async {
    if (_selectedIndex == 0 && index != 0 && _currentEditingOrder == null && (_orderFormHandle.hasProgress?.call() ?? false)) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.mainBackground,
          title: const Text('注文をキャンセルしますか？'),
          content: const Text('入力中の内容は破棄され、予約枠も消えます。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('入力に戻る')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: AppColors.mainBackground),
              child: const Text('注文キャンセル'),
            ),
          ],
        ),
      );
      if (ok != true) return; // 入力に戻る：画面は移動しない
      await _orderFormHandle.discard?.call(); // 予約枠を消し終わってから移動
      if (!mounted) return;
    }
    if (_currentEditingOrder != null) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.mainBackground,
          title: const Text('編集をキャンセルしますか？'),
          content: const Text('受注の編集内容は保存されません。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('編集に戻る')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: AppColors.mainBackground),
              child: const Text('編集をキャンセル'),
            ),
          ],
        ),
      );
      if (ok != true) return; // 編集に戻る：画面は移動しない
      if (!mounted) return;
      setState(() => _currentEditingOrder = null);
    }
    if (!mounted) return;
    setState(() => _selectedIndex = index);
  }

  static const Map<int, String> _titles = {
    0: '受注入力', 1: '受注一覧', 2: '調理・仕入れ計画', 3: '配達予定', 4: '配送ルート', 5: 'データ分析', 6: '顧客管理',
    7: 'メニューマスタ', 8: 'スタッフ管理', 9: '設定', 10: '材料マスタ', 11: '事前連絡進捗',
  };
  // スマホ下部バー：画面インデックス（受注一覧・配達予定・設定）
  static const List<int> _bottomIndices = [1, 3, 9];

  Future<void> _logout() async {
    await AuthService().logout();
    await EmailAuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  PreferredSizeWidget _buildPhoneAppBar() {
    return AppBar(
      backgroundColor: AppColors.acceptButton,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      automaticallyImplyLeading: false,
      leading: IconButton(icon: const Icon(Icons.logout), tooltip: 'ログアウト', onPressed: _logout),
      centerTitle: true,
      title: Text(_titles[_selectedIndex] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      actions: [
        IconButton(
          icon: Badge(
            isLabelVisible: _pendingCount > 0,
            label: Text('$_pendingCount'),
            backgroundColor: Colors.red,
            textColor: Colors.white,
            child: const Icon(Icons.notifications_active),
          ),
          tooltip: '事前連絡',
          onPressed: _showContactDialog,
        ),
      ],
    );
  }

  Future<void> _showContactDialog() async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '閉じる',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, _, _) => SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
                child: const ContactProgressScreen(asPage: true),
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved), child: child),
        );
      },
    );
    if (mounted) _loadContactSummary();
  }

  Widget _buildPhoneBottomBar() {
    final pos = _bottomIndices.indexOf(_selectedIndex);
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: AppColors.acceptButton,
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((st) =>
            IconThemeData(color: pos >= 0 && st.contains(WidgetState.selected) ? Colors.orange : Colors.white)),
        labelTextStyle: WidgetStateProperty.resolveWith((st) =>
            TextStyle(fontSize: 12, color: pos >= 0 && st.contains(WidgetState.selected) ? Colors.orange : Colors.white)),
      ),
      child: NavigationBar(
        // バーに無い画面のときは選択なし扱い（全項目を白で表示）
        selectedIndex: pos >= 0 ? pos : 0,
        onDestinationSelected: (i) => _goTo(_bottomIndices[i]),
        destinations: [
          for (final d in const [
            (Icons.list_alt, '受注一覧'),
            (Icons.local_shipping, '配達予定'),
            (Icons.settings, '設定'),
          ])
            NavigationDestination(icon: Icon(d.$1), label: d.$2),
        ],
      ),
    );
  }

  Widget _buildOrderFormScreen() {
    return OrderFormScreen(
      handle: _orderFormHandle,
      onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
      onNavigate: _goTo,
      key: ValueKey('order_form_${_currentEditingOrder?.id ?? "new"}'),
      initialOrder: _currentEditingOrder,
      initialSection: _editSection,
      onSaveSuccess: () {
        setState(() {
          _currentEditingOrder = null;
          _selectedIndex = 1; // 受注一覧へ
        });
      },
      onCancel: () {
        setState(() {
          _currentEditingOrder = null;
        });
      },
    );
  }

  Widget _buildCachedScreen(int index) {
    switch (index) {
      case 1: // 受注一覧
        return OrderListScreen(
          onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
          onNavigate: _goTo,
          onEditOrder: (order, section) {
          setState(() {
            _currentEditingOrder = order;
            _editSection = section;
            _selectedIndex = 0; // 受注入力へ
          });
        });
      case 2: // 調理・仕入れ計画
        return const PlanningScreen();
      case 3: // 配送ルート最適化
        return RouteOptimizationScreen(onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(), onNavigate: _goTo);
      case 6: // 顧客管理
        return CustomerListScreen(onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(), onNavigate: _goTo);
      case 7: // メニューマスタ
        return MenuMasterScreen(onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(), onNavigate: _goTo);
      case 11: // 事前連絡進捗
        return const ContactProgressScreen();
      case 10: // 材料マスタ
        return const IngredientMasterScreen();
      case 8: // スタッフ管理
        return const StaffManagementScreen();
      case 9: // 設定
        return SettingsScreen(onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(), onNavigate: _goTo);
      default:
        return _buildUnderConstruction();
    }
  }

  /// 受注入力・データ分析以外はIndexedStackで常時マウントし、
  /// タブ切り替え時の再読み込みラグをなくす（Google Mapsを含むデータ分析は除外）。
  Widget _buildBody() {
    return Stack(
      children: [
        Offstage(
          offstage: !_cachedIndices.contains(_selectedIndex),
          child: IndexedStack(
            index: _cachedIndices.indexOf(_selectedIndex).clamp(0, _cachedIndices.length - 1),
            children: _cachedIndices.map(_buildCachedScreen).toList(),
          ),
        ),
        if (_selectedIndex == 0 && isPhoneWidth(context) && _currentEditingOrder == null)
          (_staffNameLoaded
              ? PhoneGreetingScreen(
                  key: ValueKey('greeting_${_staffName ?? ""}'),
                  text: (_staffName == null || _staffName!.isEmpty) ? _greeting() : '${_greeting()}、$_staffNameさん',
                  subText: _contactSummary,
                )
              : Container(color: Colors.white))
        else if (_selectedIndex == 0)
          _buildOrderFormScreen()
        else if (_selectedIndex == 5) // データ分析
          AnalysisScreen(onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(), onNavigate: _goTo)
        else if (!_cachedIndices.contains(_selectedIndex))
          _buildUnderConstruction(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;
    final bool isPhone = isPhoneWidth(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.mainBackground,
      appBar: isPhone ? _buildPhoneAppBar() : null,
      bottomNavigationBar: isPhone ? _buildPhoneBottomBar() : null,
      drawer: isMobile ? Drawer(
        child: KSidebar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) async {
            Navigator.pop(context); // 先にDrawerを閉じる（確認ダイヤログはその上に出す）
            await _goTo(index);
          },
        ),
      ) : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile) ...[
              if (_sidebarOpen)
                Expanded(
                  flex: 16, // 比率を微調整して美しく
                  child: KSidebar(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _goTo,
                    onClose: () => setState(() => _sidebarOpen = false),
                  ),
                )
              else
                SizedBox(
                  width: rs(context, 56),
                  child: KSidebar(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _goTo,
                    collapsed: true,
                    onOpen: () => setState(() => _sidebarOpen = true),
                  ),
                ),
              VerticalDivider(thickness: 1, width: rs(context, 1), color: Color(0xFFEEEEEE)),
            ],
            Expanded(
              flex: isMobile ? 100 : 84,
              child: _buildBody(), // 必要な画面だけを描画
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnderConstruction() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: rs(context, 80), color: AppColors.accentOrange.withValues(alpha: 0.3)),
          SizedBox(height: rs(context, 24)),
          Text('機能準備中', style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ],
      ),
    );
  }
}
