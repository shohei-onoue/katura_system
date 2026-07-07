import 'dart:math';
import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../models/menu_model.dart';
import '../models/staff_model.dart';
import '../models/order_model.dart';
import '../services/customer_service.dart';
import '../services/menu_service.dart';
import '../services/staff_service.dart';
import '../services/print_service.dart';
import '../services/order_service.dart';
import '../widgets/k_text_field.dart';
import '../widgets/k_button.dart';
import '../widgets/k_choice_group.dart';
import '../widgets/k_date_time_picker.dart';
import '../widgets/k_labeled_checkbox.dart';
import '../widgets/k_time_slot_selector.dart';
import '../widgets/k_quantity_counter.dart';
import '../widgets/k_tile_selector.dart';
import '../widgets/k_hierarchy_selector.dart';

class OrderFormScreen extends StatefulWidget {
  final OrderModel? initialOrder;
  final VoidCallback? onSaveSuccess;

  const OrderFormScreen({
    super.key,
    this.initialOrder,
    this.onSaveSuccess,
  });

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _customerService = CustomerService();
  final _menuService = MenuService();
  final _staffService = StaffService();
  final _orderService = OrderService();
  
  // Controllers
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _facilityController = TextEditingController();
  final _addressController = TextEditingController();
  final _remarksController = TextEditingController();
  final _packagingCountController = TextEditingController();
  final _teaCountController = TextEditingController();

  // Form State
  DateTime _receptionDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 1));
  String _deliveryType = '配送';
  DateTime _selectedTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0);
  
  bool _isDirect = false;
  bool _isKetsuzen = false;
  bool _hasDeliveryNote = true;
  bool _isDelica = false;

  String _packagingType = '紙袋';
  String _teaType = 'なし';
  String _paymentMethod = '現金';
  String _receiptType = '不要';
  String _branchName = '岡崎本店';
  
  late DateTime _confirmationDate;
  String _confirmationMethod = '電話';

  // Staff State
  List<Staff> _staffList = [];
  String? _selectedReceiverId;
  String? _selectedConfirmerId;

  Customer? _currentCustomer;
  List<MenuModel> _menus = [];
  Map<String, int> _selectedQuantities = {};
  List<Map<String, dynamic>> _confirmedItems = [];
  
  bool _isLoading = false;
  String? _incomingNumber;
  String? _duplicateOrderAlert;

  @override
  void initState() {
    super.initState();
    _confirmationDate = _deliveryDate.subtract(const Duration(days: 1));
    _loadData().then((_) {
      if (widget.initialOrder != null) {
        _populateForm(widget.initialOrder!);
      }
    });
    _simulateIncomingCall();
  }

  Future<void> _loadData() async {
    final menus = await _menuService.getAllMenus();
    final staff = await _staffService.getAllStaff();
    if (mounted) {
      setState(() {
        _menus = menus;
        _staffList = staff;
      });
    }
  }

  void _populateForm(OrderModel order) {
    setState(() {
      _phoneController.text = order.phoneNumber;
      _nameController.text = order.customerName;
      _facilityController.text = order.facilityName;
      _addressController.text = order.address;
      _deliveryDate = order.deliveryDate;
      _receptionDate = order.receptionDate;
      _deliveryType = order.deliveryType;
      _packagingType = order.packagingType;
      _paymentMethod = order.paymentMethod;
      _branchName = order.branchName;
      
      final timeParts = order.deliveryTime.split(':');
      if (timeParts.length == 2) {
        _selectedTime = DateTime(2024, 1, 1, int.parse(timeParts[0]), int.parse(timeParts[1]));
      }

      _selectedQuantities.clear();
      for (var item in order.items) {
        _selectedQuantities[item['id']] = item['quantity'];
      }
      _confirmedItems = List.from(order.items);
      _confirmationDate = _deliveryDate.subtract(const Duration(days: 1));
    });
  }

  void _simulateIncomingCall() async {
    await Future.delayed(const Duration(seconds: 5));
    if (widget.initialOrder != null) return;

    final customers = await _customerService.getAllCustomers();
    if (customers.isNotEmpty && mounted) {
      final randomCustomer = customers[Random().nextInt(customers.length)];
      setState(() {
        _incomingNumber = randomCustomer.phoneNumber;
      });
    }
  }

  Future<void> _lookupCustomer(String phone) async {
    final cleanDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanDigits.length < 10) return;

    setState(() => _isLoading = true);
    final customer = await _customerService.findByPhoneNumber(phone);
    setState(() {
      _isLoading = false;
      if (customer != null) {
        _currentCustomer = customer;
        _nameController.text = customer.name;
        _facilityController.text = customer.companyName;
        _addressController.text = customer.address;
        _phoneController.text = customer.phoneNumber;
        _checkDuplicateOrder(customer.address);
      } else {
        _currentCustomer = null;
        _duplicateOrderAlert = null;
      }
    });
  }

  void _checkDuplicateOrder(String address) {
    // 現場要件: 同一住所または近隣の近日中の注文をチェック
    // モック実装: 特定のキーワードで警告を出す
    if (address.contains('豊田') || address.contains('病院')) {
      setState(() {
        _duplicateOrderAlert = "⚠️ 警告: 3日以内に近隣で注文があります。「前回とは違うお弁当」を提案してください。";
      });
    } else {
      setState(() => _duplicateOrderAlert = null);
    }
  }

  void _confirmSelection() {
    setState(() {
      _confirmedItems = _menus
          .where((m) => (_selectedQuantities[m.id] ?? 0) > 0)
          .map((m) => {
                'id': m.id,
                'name': m.name,
                'price': m.price,
                'quantity': _selectedQuantities[m.id],
              })
          .toList();
    });
  }

  double _calculateRiceAmount(int totalCount) {
    // 夏季（5-10月）は吸水率が高いため補正係数 1.1、冬季（11-4月）は 1.05
    final month = _deliveryDate.month;
    final isSummer = month >= 5 && month <= 10;
    final coefficient = isSummer ? 1.1 : 1.05;
    const baseRicePerBento = 0.15; // 150g
    return totalCount * baseRicePerBento * coefficient;
  }

  int get _totalCount {
    return _confirmedItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  int get _totalPrice {
    return _confirmedItems.fold(0, (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int));
  }

  Future<void> _handleSave() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _confirmedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('必須項目（氏名、電話番号、注文内容）を入力してください')),
      );
      return;
    }

    final orderId = widget.initialOrder?.id ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    
    final order = OrderModel(
      id: orderId,
      customerName: _nameController.text,
      facilityName: _facilityController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      receptionDate: _receptionDate,
      deliveryDate: _deliveryDate,
      deliveryTime: "${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}",
      deliveryType: _deliveryType,
      items: _confirmedItems,
      totalCount: _totalCount,
      packagingType: _packagingType,
      paymentMethod: _paymentMethod,
      status: widget.initialOrder?.status ?? '受注済み',
      branchName: _branchName,
    );

    try {
      await _orderService.saveOrder(order);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.initialOrder == null ? '受注を保存しました' : '受注内容を更新しました')),
        );
        if (widget.onSaveSuccess != null) {
          widget.onSaveSuccess!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                if (_incomingNumber != null) _buildIncomingCallBar(),
                _buildHeader(),
                if (_duplicateOrderAlert != null) _buildDuplicateAlert(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    children: [
                      _buildCustomerSection(),
                      const SizedBox(height: 24),
                      _buildDeliveryDateTimeSection(),
                      const SizedBox(height: 24),
                      _buildItemsAndRiceSection(),
                      const SizedBox(height: 24),
                      _buildOptionsAndPaymentSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildRightSideMenu(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 520), // 右側メニューを避ける
        child: FloatingActionButton.extended(
          onPressed: _handleSave,
          label: Text(widget.initialOrder == null ? '受注確定・保存 (F10)' : '内容更新', 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.check_circle),
          backgroundColor: Colors.deepOrange,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.phone_callback, color: Colors.deepOrange, size: 28),
          const SizedBox(width: 12),
          Text(
            widget.initialOrder == null ? '受注入力（右手片手操作特化）' : '受注編集',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const Spacer(),
          if (_isLoading) const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildDuplicateAlert() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(_duplicateOrderAlert!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    return _buildCard(
      title: '顧客・施設情報（カーナビ風選択）',
      icon: Icons.person_pin_circle,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: KTextField(
                  label: '電話番号',
                  controller: _phoneController,
                  icon: Icons.phone_android,
                  onChanged: _lookupCustomer,
                  autofocus: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KTextField(label: 'お名前', controller: _nameController, icon: Icons.badge),
              ),
            ],
          ),
          const SizedBox(height: 20),
          KHierarchySelector(
            label: '施設名・エリア階層選択',
            onSelected: (val) {
              setState(() {
                _facilityController.text = val;
                // 住所自動補正ロジック（モック）
                if (val.contains('市民病院')) _addressController.text = "愛知県岡崎市若松町1-1";
              });
            },
          ),
          const SizedBox(height: 12),
          KTextField(
            label: '詳細施設名・会社名',
            controller: _facilityController,
            icon: Icons.business,
          ),
          const SizedBox(height: 12),
          KTextField(
            label: '配達先住所',
            controller: _addressController,
            icon: Icons.map,
            suffix: _currentCustomer != null ? _buildAddressHistoryPopup() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDateTimeSection() {
    return _buildCard(
      title: '配達・日時（15分刻み）',
      icon: Icons.timer,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: KDateTimePicker(
                  label: '配達日',
                  value: _deliveryDate,
                  onSelected: (date) => setState(() => _deliveryDate = date),
                  icon: Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KChoiceGroup<String>(
                  label: '区分',
                  selectedValue: _deliveryType,
                  items: [KChoiceItem(label: '配送', value: '配送'), KChoiceItem(label: '引取', value: '引取')],
                  onSelected: (val) => setState(() => _deliveryType = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          KTimeSlotSelector(
            label: '希望時間枠',
            selectedTime: _selectedTime,
            onSelected: (time) => setState(() => _selectedTime = time),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsAndRiceSection() {
    return _buildCard(
      title: '注文内容・生米換算',
      icon: Icons.restaurant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_confirmedItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('右側メニューからお弁当を選択してください', style: TextStyle(color: Colors.grey))),
            )
          else
            ..._confirmedItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  KQuantityCounter(
                    value: _selectedQuantities[item['id']] ?? 0,
                    onChanged: (val) {
                      setState(() {
                        _selectedQuantities[item['id']] = val;
                        _confirmSelection();
                      });
                    },
                  ),
                ],
              ),
            )),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('合計金額', style: TextStyle(color: Colors.grey)),
                  Text('¥${_totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]},")}',
                       style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.deepOrange)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const Text('必要生米量', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('${_calculateRiceAmount(_totalCount).toStringAsFixed(2)} kg',
                         style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    Text('(${_deliveryDate.month >= 5 && _deliveryDate.month <= 10 ? "夏季" : "冬季"}補正適用)',
                         style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsAndPaymentSection() {
    return _buildCard(
      title: '支払・店舗・担当',
      icon: Icons.settings,
      child: Column(
        children: [
          KTileSelector<String>(
            label: '担当店舗',
            selectedValue: _branchName,
            items: [
              KTileItem(label: '岡崎本店', value: '岡崎本店'),
              KTileItem(label: '名古屋店', value: '名古屋店'),
              KTileItem(label: '岐阜店', value: '岐阜店'),
            ],
            onSelected: (val) => setState(() => _branchName = val),
          ),
          const SizedBox(height: 20),
          KTileSelector<String?>(
            label: '受電担当者（右手タイル選択）',
            selectedValue: _selectedReceiverId,
            items: _staffList.map((s) => KTileItem(label: s.name, value: s.id)).toList(),
            onSelected: (val) => setState(() => _selectedReceiverId = val),
          ),
          const SizedBox(height: 20),
          KTileSelector<String>(
            label: '支払方法',
            selectedValue: _paymentMethod,
            items: [
              KTileItem(label: '現金', value: '現金'),
              KTileItem(label: 'カード', value: 'カード'),
              KTileItem(label: '請求書', value: '請求'),
              KTileItem(label: '売掛', value: '売掛'),
            ],
            onSelected: (val) => setState(() => _paymentMethod = val),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Icon(icon, color: Colors.deepOrange, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ],
            ),
          ),
          const Divider(),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _buildRightSideMenu() {
    final categories = _menus.map((m) => m.category).toSet().toList();
    return Container(
      width: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey.shade50, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
            child: const Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.blueGrey),
                SizedBox(width: 12),
                Text('メニュー選択（ダイレクト追加）', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryMenus = _menus.where((m) => m.category == category).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Text(category, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.orange.shade800)),
                    ),
                    ...categoryMenus.map((menu) {
                      final qty = _selectedQuantities[menu.id] ?? 0;
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade100)),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedQuantities[menu.id] = qty + 1;
                              _confirmSelection();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(menu.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('¥${menu.price}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                if (qty > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                                    child: Text('$qty', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressHistoryPopup() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.history, color: Colors.deepOrange),
      onSelected: (String value) => _addressController.text = value,
      itemBuilder: (context) => _currentCustomer!.deliveryAddresses.map((addr) => PopupMenuItem(value: addr, child: Text(addr))).toList(),
    );
  }

  Widget _buildIncomingCallBar() {
    return Container(
      color: Colors.green.shade600,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.phone_in_talk, color: Colors.white),
          const SizedBox(width: 16),
          Text('着信中: $_incomingNumber', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              _phoneController.text = _incomingNumber!;
              _lookupCustomer(_incomingNumber!);
              setState(() => _incomingNumber = null);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green.shade800),
            child: const Text('入力開始'),
          ),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _incomingNumber = null)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _facilityController.dispose();
    _addressController.dispose();
    _remarksController.dispose();
    _packagingCountController.dispose();
    _teaCountController.dispose();
    super.dispose();
  }
}
