import 'package:flutter/material.dart';
import '../widgets/k_sidebar.dart';
import '../models/order_model.dart';
import 'order_form_screen.dart';
import 'customer_list_screen.dart';
import 'menu_master_screen.dart';
import 'staff_management_screen.dart';
import 'order_list_screen.dart';
import 'planning_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 各画面の保持用インスタンス
  final List<Widget> _screens = [];
  final Map<int, int> _indexMap = {
    0: 0, // 受注入力
    1: 1, // 受注一覧
    2: 2, // 計画
    6: 3, // 顧客管理
    7: 4, // メニューマスタ
    8: 5, // スタッフ管理
  };

  @override
  void initState() {
    super.initState();
    _initScreens();
  }

  void _initScreens() {
    _screens.clear();
    _screens.add(OrderFormScreen(
      key: const ValueKey('order_form'),
      onSaveSuccess: _onSaveSuccess,
      onCancel: _onCancelOrder,
    ));
    _screens.add(OrderListScreen(onEditOrder: _onEditOrder));
    _screens.add(const PlanningScreen());
    _screens.add(const CustomerListScreen());
    _screens.add(const MenuMasterScreen());
    _screens.add(const StaffManagementScreen());
  }

  void _onEditOrder(OrderModel order) {
    setState(() {
      _screens[0] = OrderFormScreen(
        key: ValueKey('edit_${order.id}'),
        initialOrder: order,
        onSaveSuccess: _onSaveSuccess,
        onCancel: _onCancelOrder,
      );
      _selectedIndex = 0; // 受注入力画面へ
    });
  }

  void _onCancelOrder() {
    setState(() {
      // キャンセル後は空のフォームに戻す
      _screens[0] = OrderFormScreen(
        key: const ValueKey('order_form_reset'),
        onSaveSuccess: _onSaveSuccess,
        onCancel: _onCancelOrder,
      );
    });
  }

  void _onSaveSuccess() {
    setState(() {
      // 保存成功後は空のフォームに戻す
      _screens[0] = OrderFormScreen(
        key: const ValueKey('order_form_new'),
        onSaveSuccess: _onSaveSuccess,
        onCancel: _onCancelOrder,
      );
      _selectedIndex = 1; // 一覧画面へ戻る
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    final sidebar = KSidebar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        if (isMobile) {
          Navigator.pop(context); // モバイル時はDrawerを閉じる
        }
      },
    );

    // インデックスの安全な取得
    final stackIndex = _indexMap[_selectedIndex] ?? 0;

    return Scaffold(
      drawer: isMobile ? Drawer(child: sidebar) : null,
      appBar: isMobile ? AppBar(
        title: const Text('Katura System', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ) : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile) ...[
              Expanded(
                flex: 15,
                child: sidebar,
              ),
              const VerticalDivider(thickness: 1, width: 1),
            ],
            Expanded(
              flex: isMobile ? 100 : 85,
              child: IndexedStack(
                index: stackIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
