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
  OrderModel? _editingOrder;

  void _onEditOrder(OrderModel order) {
    setState(() {
      _editingOrder = order;
      _selectedIndex = 0; // 受注入力画面へ
    });
  }

  void _onSaveSuccess() {
    setState(() {
      _editingOrder = null;
      _selectedIndex = 1; // 一覧画面へ戻る
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_selectedIndex) {
      case 0:
        currentScreen = OrderFormScreen(
          key: ValueKey(_editingOrder?.id ?? 'new'),
          initialOrder: _editingOrder,
          onSaveSuccess: _onSaveSuccess,
        );
        break;
      case 1:
        currentScreen = OrderListScreen(onEditOrder: _onEditOrder);
        break;
      case 2:
        currentScreen = const PlanningScreen();
        break;
      case 7:
        currentScreen = const CustomerListScreen();
        break;
      case 8:
        currentScreen = const MenuMasterScreen();
        break;
      case 9:
        currentScreen = const StaffManagementScreen();
        break;
      default:
        currentScreen = const Center(child: Text('Coming Soon'));
    }

    return Scaffold(
      body: Row(
        children: [
          KSidebar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
                if (index != 0) {
                  _editingOrder = null; // 他の画面に切り替えたら編集状態を解除
                }
              });
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: currentScreen,
          ),
        ],
      ),
    );
  }
}
