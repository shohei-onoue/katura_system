import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/order_model.dart';
import '../models/menu_model.dart';
import '../models/planning_models.dart';
import '../services/order_service.dart';
import '../services/menu_service.dart';
import '../services/planning_service.dart';

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
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderService.getAllOrders();
      final menus = await _menuService.getAllMenus();
      if (mounted) {
        setState(() {
          _allOrders = orders;
          _allMenus = menus;
          _isLoading = false;
          _updatePlanningData(_selectedDay!);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('データの取得に失敗しました: $e')),
        );
      }
    }
  }

  void _updatePlanningData(DateTime day) {
    // 指定された日の受注を抽出（キャンセル済み以外）
    final dayOrders = _allOrders.where((o) => 
      isSameDay(o.deliveryDate, day) && o.status != 'キャンセル済み'
    ).toList();
    
    setState(() {
      _dayOrders = dayOrders;
      _ingredientTotals = _planningService.calculateTotalIngredients(
        dayOrders, _allMenus, _selectedBranch);
      _cookingTasks = _planningService.generateCookingSchedule(
        dayOrders, _selectedBranch);
    });
  }

  void _showTaskDetail(CookingTask task) {
    final menu = _allMenus.firstWhere((m) => m.name == task.menuName, 
        orElse: () => MenuModel(id: '', name: task.menuName, category: '', price: 0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.restaurant, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(child: Text(task.menuName)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem(Icons.person, '顧客', task.customerName),
              _buildDetailItem(Icons.numbers, '数量', '${task.quantity} 個'),
              _buildDetailItem(Icons.schedule, '調理開始予定', 
                  "${task.estimatedStartTime.hour}:${task.estimatedStartTime.minute.toString().padLeft(2, '0')}"),
              _buildDetailItem(Icons.local_shipping, '配達予定', task.deliveryTime),
              if (menu.ingredients.isNotEmpty) ...[
                const Divider(height: 32),
                const Text('主要食材 (1個あたり)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                ...menu.ingredients.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(fontSize: 13)),
                      Text(e.value, style: const TextStyle(color: Colors.blueGrey, fontSize: 13)),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initData,
            tooltip: '再読み込み',
          ),
        ],
      ),
      body: Row(
        children: [
          // 左側：カレンダーと概要
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey[200]!)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _updatePlanningData(selectedDay);
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
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
          // 右側：計画詳細
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: const TabBar(
                          labelColor: Colors.orange,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.orange,
                          indicatorWeight: 3,
                          tabs: [
                            Tab(
                              icon: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory),
                                  SizedBox(width: 8),
                                  Text('仕入れ・食材集計'),
                                ],
                              ),
                            ),
                            Tab(
                              icon: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.schedule),
                                  SizedBox(width: 8),
                                  Text('調理スケジュール'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildIngredientView(),
                            _buildCookingView(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedBranch,
          isExpanded: true,
          items: ['すべて', '岡崎本店', '名古屋店', '岐阜店'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedBranch = newValue);
              _updatePlanningData(_selectedDay!);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDaySummary() {
    final dayStr = "${_selectedDay?.month}/${_selectedDay?.day}";
    
    final branches = [
      {'name': '岡崎本店', 'color': Colors.blue},
      {'name': '名古屋店', 'color': Colors.green},
      {'name': '岐阜店', 'color': Colors.purple},
    ];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text('$dayStr の店舗別集計', 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        const SizedBox(height: 8),
        ...branches.map((branch) {
          final branchName = branch['name'] as String;
          final color = branch['color'] as Color;
          final branchOrders = _dayOrders.where((o) => o.branchName == branchName).toList();
          final totalCount = branchOrders.fold(0, (sum, o) => sum + o.totalCount);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(branchName, 
                      style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
                    Text('${branchOrders.length} 件', 
                      style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                  ],
                ),
                Text('$totalCount 個', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildIngredientView() {
    if (_ingredientTotals.isEmpty) {
      return _buildEmptyState('集計対象のデータがありません');
    }

    final ingredients = _ingredientTotals.values.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final item = ingredients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_basket_outlined, color: Colors.orange, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    item.name, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('必要量', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      "${item.amount.toStringAsFixed(1)} ${item.unit}",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCookingView() {
    if (_cookingTasks.isEmpty) {
      return _buildEmptyState('調理タスクはありません');
    }

    // 顧客ごとにグループ化
    final Map<String, List<CookingTask>> groupedTasks = {};
    for (var task in _cookingTasks) {
      groupedTasks.putIfAbsent(task.customerName, () => []).add(task);
    }

    const double hourWidth = 120.0; // 少し広げて視認性向上
    const int startHour = 5;  // 営業時間開始: 5:00
    const int endHour = 20;   // 営業時間終了: 20:00
    const double labelWidth = 160.0;

    return Column(
      children: [
        // ヘッダー（固定）: 時間軸
        Container(
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(), // 下のスクロールと同期させるための仕組み（簡易版）
            child: Row(
              children: [
                const SizedBox(width: labelWidth),
                ...List.generate(endHour - startHour + 1, (index) {
                  return Container(
                    width: hourWidth,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${startHour + index}:00",
                      style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: groupedTasks.entries.map((entry) {
                    final customerName = entry.key;
                    final tasks = entry.value;

                    // 重なりを防ぐためのレーン割り当てロジック
                    final List<List<CookingTask>> lanes = [];
                    for (var task in tasks) {
                      bool placed = false;
                      for (var lane in lanes) {
                        final lastTask = lane.last;
                        if (task.estimatedStartTime.isAfter(lastTask.deliveryDateTime) ||
                            task.estimatedStartTime.isAtSameMomentAs(lastTask.deliveryDateTime)) {
                          lane.add(task);
                          placed = true;
                          break;
                        }
                      }
                      if (!placed) lanes.add([task]);
                    }

                    final double rowHeight = (lanes.length * 40.0) + 20.0;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 固定列風の顧客名（実際は横スクロール内だが左端に配置）
                        Container(
                          width: labelWidth,
                          height: rowHeight,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!),
                              right: BorderSide(color: Colors.grey[300]!, width: 2),
                            ),
                          ),
                          child: Text(
                            customerName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // ガンチャートエリア
                        Stack(
                          children: [
                            // 背景グリッド
                            Row(
                              children: List.generate(endHour - startHour + 1, (index) {
                                return Container(
                                  width: hourWidth,
                                  height: rowHeight,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(color: Colors.grey[100]!),
                                      bottom: BorderSide(color: Colors.grey[200]!),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            // タスクバー
                            ...lanes.asMap().entries.expand((laneEntry) {
                              final laneIndex = laneEntry.key;
                              final laneTasks = laneEntry.value;
                              
                              return laneTasks.map((task) {
                                final startOffset = (task.estimatedStartTime.hour - startHour) * hourWidth +
                                    (task.estimatedStartTime.minute / 60.0) * hourWidth;
                                final durationMinutes = task.deliveryDateTime.difference(task.estimatedStartTime).inMinutes;
                                final barWidth = (durationMinutes / 60.0) * hourWidth;

                                return Positioned(
                                  left: startOffset,
                                  top: 10 + (laneIndex * 40.0),
                                  child: GestureDetector(
                                    onTap: () => _showTaskDetail(task),
                                    child: Container(
                                      width: barWidth,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          "${task.menuName} (x${task.quantity})",
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                            }),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('仕入れリストを出力しました（シミュレーション）')),
          );
        },
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('計画をエクスポート'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
