import 'package:flutter/material.dart';
import '../widgets/k_sidebar.dart';
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
  bool _sidebarOpen = true;

  // 編集中の注文情報を保持（画面切り替えで消えないように）
  OrderModel? _currentEditingOrder;
  String _editSection = ''; // 編集で選んだ項目（配達先/日程/注文内容）

  // 常駐キャッシュ対象の画面インデックス（受注入力=0とデータ分析=5は対象外）
  static const List<int> _cachedIndices = [1, 2, 3, 6, 7, 10, 8, 9];

  @override
  void initState() {
    super.initState();
  }

  /// 受注カードの編集中に別の機能（受注入力の新規も含む）へ移動しようとしたとき、
  /// 編集を中止してよいか確認する。中止しない場合は画面を移動しない。
  Future<void> _goTo(int index) async {
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

  Widget _buildOrderFormScreen() {
    return OrderFormScreen(
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
        return OrderListScreen(onEditOrder: (order, section) {
          setState(() {
            _currentEditingOrder = order;
            _editSection = section;
            _selectedIndex = 0; // 受注入力へ
          });
        });
      case 2: // 調理・仕入れ計画
        return const PlanningScreen();
      case 3: // 配送ルート最適化
        return const RouteOptimizationScreen();
      case 6: // 顧客管理
        return const CustomerListScreen();
      case 7: // メニューマスタ
        return const MenuMasterScreen();
      case 10: // 材料マスタ
        return const IngredientMasterScreen();
      case 8: // スタッフ管理
        return const StaffManagementScreen();
      case 9: // 設定
        return const SettingsScreen();
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
        if (_selectedIndex == 0)
          _buildOrderFormScreen()
        else if (_selectedIndex == 5) // データ分析
          const AnalysisScreen()
        else if (!_cachedIndices.contains(_selectedIndex))
          _buildUnderConstruction(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
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
