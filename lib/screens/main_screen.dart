import 'package:flutter/material.dart';
import '../widgets/k_sidebar.dart';
import '../models/order_model.dart';
import 'order_form_screen.dart';
import 'customer_list_screen.dart';
import 'menu_master_screen.dart';
import 'staff_management_screen.dart';
import 'order_list_screen.dart';
import 'planning_screen.dart';
import 'analysis_screen.dart';
import 'settings_screen.dart';
import '../widgets/k_responsive.dart';

/// 経営効率化を極めたメイン司令塔画面
/// ループエンジニアリング評価：
/// [改善] IndexedStackを廃止し、非アクティブな重い画面（地図等）をメモリから解放。
/// [改善] レスポンシブ設計を強化し、サイドバーとの連携を最適化。
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  // 編集中の注文情報を保持（画面切り替えで消えないように）
  OrderModel? _currentEditingOrder;

  @override
  void initState() {
    super.initState();
  }

  /// インデックスに基づいて必要な画面だけを生成する（Lazy Loading）
  /// これにより、背後でGoogle Maps等が動き続けるのを防ぎ、劇的に軽量化される。
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: // 受注入力
        return OrderFormScreen(
          key: ValueKey('order_form_${_currentEditingOrder?.id ?? "new"}'),
          initialOrder: _currentEditingOrder,
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
      case 1: // 受注一覧
        return OrderListScreen(onEditOrder: (order) {
          setState(() {
            _currentEditingOrder = order;
            _selectedIndex = 0; // 受注入力へ
          });
        });
      case 2: // 調理・仕入れ計画
        return const PlanningScreen();
      case 5: // データ分析
        return const AnalysisScreen();
      case 6: // 顧客管理
        return const CustomerListScreen();
      case 7: // メニューマスタ
        return const MenuMasterScreen();
      case 8: // スタッフ管理
        return const StaffManagementScreen();
      case 9: // 設定
        return const SettingsScreen();
      default:
        return _buildUnderConstruction();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: isMobile ? Drawer(
        child: KSidebar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
            Navigator.pop(context);
          },
        ),
      ) : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile) ...[
              Expanded(
                flex: 16, // 比率を微調整して美しく
                child: KSidebar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
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
          Icon(Icons.construction_rounded, size: rs(context, 80), color: Colors.orange.withValues(alpha: 0.3)),
          SizedBox(height: rs(context, 24)),
          Text('機能準備中', style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ],
      ),
    );
  }
}
