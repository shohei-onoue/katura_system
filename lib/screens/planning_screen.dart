import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/order_model.dart';
import '../models/menu_model.dart';
import '../models/planning_models.dart';
import '../services/order_service.dart';
import '../services/menu_service.dart';
import '../services/planning_service.dart';
import 'planning/widgets/ingredient_list.dart';
import 'planning/widgets/cooking_schedule_list.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  final _orderService = OrderService();
  final _menuService = MenuService();
  final _planningService = PlanningService();

  List<OrderModel> _allOrders = [];
  List<MenuModel> _allMenus = [];
  List<OrderModel> _dayOrders = [];
  Map<String, IngredientRequirement> _ingredientTotals = {};
  List<CookingTask> _cookingTasks = [];
  bool _isLoading = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedBranch = 'すべて';

  @override
  void initState() { super.initState(); _selectedDay = _focusedDay; _initData(); }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderService.getAllOrders();
      final menus = await _menuService.getAllMenus();
      if (mounted) setState(() { _allOrders = orders; _allMenus = menus; _isLoading = false; _updatePlanningData(_selectedDay!); });
    } catch (e) { if (mounted) setState(() => _isLoading = false); }
  }

  void _updatePlanningData(DateTime day) {
    final dayOrders = _allOrders.where((o) => isSameDay(o.deliveryDate, day) && (_selectedBranch == 'すべて' || o.branchName == _selectedBranch)).toList();
    setState(() { _dayOrders = dayOrders; _ingredientTotals = _planningService.calculateIngredientTotals(dayOrders, _allMenus); _cookingTasks = _planningService.generateCookingSchedule(dayOrders); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('調理・仕入れ計画', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [ IconButton(icon: const Icon(Icons.refresh), onPressed: _initData, tooltip: '再読み込み')],
      ),
      body: Row(
        children: [
          Container(
            width: 320,
            decoration: BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: Colors.grey[200]!))),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1), lastDay: DateTime.utc(2030, 12, 31), focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) { setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; }); _updatePlanningData(selectedDay); },
                  calendarStyle: CalendarStyle(todayDecoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.3), shape: BoxShape.circle), selectedDecoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                ),
                const Divider(height: 32),
                _buildBranchSelector(),
                const SizedBox(height: 16),
                _buildDaySummary(),
                const Spacer(),
                _buildExportButton(),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(color: Colors.white, child: const TabBar(labelColor: Colors.orange, unselectedLabelColor: Colors.grey, indicatorColor: Colors.orange, indicatorWeight: 3, tabs: [Tab(icon: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inventory), SizedBox(width: 8), Text('仕入れ・食材集計')])), Tab(icon: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.schedule), SizedBox(width: 8), Text('調理スケジュール')]))])),
                  Expanded(child: TabBarView(children: [IngredientList(isLoading: _isLoading, ingredientTotals: _ingredientTotals), CookingScheduleList(isLoading: _isLoading, cookingTasks: _cookingTasks)])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _selectedBranch, isExpanded: true, items: ['すべて', '岡崎本店', '名古屋店', '岐阜店'].map((String v) => DropdownMenuItem<String>(value: v, child: Text(v, style: const TextStyle(fontSize: 14)))).toList(), onChanged: (nv) { setState(() { _selectedBranch = nv!; _updatePlanningData(_selectedDay!); }); })));
  }

  Widget _buildDaySummary() {
    final totalBoxes = _dayOrders.fold(0, (sum, o) => sum + o.totalCount);
    return Card(elevation: 0, color: Colors.orange.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.shade100)), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [_summaryItem('受注総数', '${_dayOrders.length} 件'), const SizedBox(height: 8), _summaryItem('製造個数', '$totalBoxes 個')])));
  }

  Widget _summaryItem(String l, String v) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Colors.grey, fontSize: 14)), Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]);
  Widget _buildExportButton() => SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('指示書を出力 (PDF)'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))));
}
