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
import '../widgets/k_time_slot_selector.dart';
import '../widgets/k_quantity_counter.dart';
import '../widgets/k_tile_selector.dart';
import '../widgets/k_hierarchy_selector.dart';
import '../widgets/k_stepper.dart';

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

  // Form State
  int _currentStep = 0;
  DateTime _receptionDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 1));
  String _deliveryType = '配送';
  DateTime _selectedTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0);
  
  String _paymentMethod = '現金';
  String _branchName = '岡崎本店';
  String? _selectedReceiverId;

  Customer? _currentCustomer;
  List<MenuModel> _menus = [];
  Map<String, int> _selectedQuantities = {};
  List<Map<String, dynamic>> _confirmedItems = [];
  List<Staff> _staffList = [];
  
  bool _isLoading = false;
  String? _incomingNumber;
  String? _duplicateOrderAlert;

  final List<String> _stepLabels = ['番号確認', '顧客・施設', '配達日時', '注文内容', '支払・完了'];

  @override
  void initState() {
    super.initState();
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
    });
  }

  void _simulateIncomingCall() async {
    await Future.delayed(const Duration(seconds: 5));
    if (widget.initialOrder != null) return;
    final customers = await _customerService.getAllCustomers();
    if (customers.isNotEmpty && mounted) {
      final randomCustomer = customers[Random().nextInt(customers.length)];
      setState(() => _incomingNumber = randomCustomer.phoneNumber);
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
        
        // 番号確認ステップなら、ヒットした時点で次のステップへ自動遷移
        if (_currentStep == 0) {
          _nextStep();
        }
      } else {
        _currentCustomer = null;
        if (_currentStep == 0) {
           _nextStep(); // ヒットしなくても番号が確定したら次へ
        }
      }
    });
  }

  void _checkDuplicateOrder(String address) {
    if (address.contains('豊田') || address.contains('病院')) {
      setState(() => _duplicateOrderAlert = "⚠️ 警告: 近日中に重複注文があります。");
    } else {
      setState(() => _duplicateOrderAlert = null);
    }
  }

  void _nextStep() {
    if (_currentStep < _stepLabels.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
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

  int get _totalCount => _confirmedItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
  int get _totalPrice => _confirmedItems.fold(0, (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int));

  Future<void> _handleSave() async {
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
      packagingType: '紙袋',
      paymentMethod: _paymentMethod,
      branchName: _branchName,
    );
    await _orderService.saveOrder(order);
    if (mounted) widget.onSaveSuccess?.call();
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
                KStepper(
                  currentStep: _currentStep,
                  steps: _stepLabels,
                  onStepTapped: (step) => setState(() => _currentStep = step),
                ),
                if (_duplicateOrderAlert != null) _buildDuplicateAlert(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildStepContent(),
                  ),
                ),
                _buildBottomNav(),
              ],
            ),
          ),
          _buildRightSideMenu(),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildPhoneConfirmStep();
      case 1: return _buildCustomerStep();
      case 2: return _buildDeliveryStep();
      case 3: return _buildItemsStep();
      case 4: return _buildFinalStep();
      default: return Container();
    }
  }

  Widget _buildPhoneConfirmStep() {
    return Column(
      children: [
        _buildCard(
          title: '電話番号の確認 (CTI連携)',
          icon: Icons.phone_callback,
          child: Column(
            children: [
              const Text('受話器から聞き取った番号、または着信番号を確認してください。', style: TextStyle(color: Colors.blueGrey)),
              const SizedBox(height: 24),
              KTextField(
                label: '電話番号 (ハイフンなし)',
                controller: _phoneController,
                icon: Icons.phone_android,
                onChanged: _lookupCustomer,
                autofocus: true,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 40),
              if (_phoneController.text.length >= 10)
                KButton(label: 'この番号で進む', onPressed: _nextStep)
              else
                const Text('10桁以上の番号を入力してください', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerStep() {
    return Column(
      children: [
        _buildCard(
          title: '顧客・施設詳細情報',
          icon: Icons.person_pin_circle,
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text('確認済み番号: ${_phoneController.text}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              const SizedBox(height: 16),
              KHierarchySelector(
                label: 'エリア・施設階層選択 (右手タップ)',
                onSelected: (val) {
                  setState(() {
                    _facilityController.text = val;
                    if (val.contains('市民病院')) _addressController.text = "愛知県岡崎市若松町1-1";
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: KTextField(label: 'お名前', controller: _nameController, icon: Icons.badge)),
                  const SizedBox(width: 16),
                  Expanded(child: KTextField(label: '施設・会社名', controller: _facilityController, icon: Icons.business)),
                ],
              ),
              const SizedBox(height: 16),
              KTextField(label: '配達先住所', controller: _addressController, icon: Icons.map),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryStep() {
    return Column(
      children: [
        _buildCard(
          title: '配達日時・区分選択',
          icon: Icons.timer,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: KDateTimePicker(label: '配達日', value: _deliveryDate, icon: Icons.calendar_month, onSelected: (d) => setState(() => _deliveryDate = d))),
                  const SizedBox(width: 16),
                  Expanded(child: KChoiceGroup(label: '区分', selectedValue: _deliveryType, items: [KChoiceItem(label: '配送', value: '配送'), KChoiceItem(label: '引取', value: '引取')], onSelected: (v) => setState(() => _deliveryType = v))),
                ],
              ),
              const SizedBox(height: 24),
              KTimeSlotSelector(label: '希望時間枠', selectedTime: _selectedTime, onSelected: (t) {
                setState(() => _selectedTime = t);
                _nextStep();
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsStep() {
    return Column(
      children: [
        _buildCard(
          title: '注文内容の確認・数量調整',
          icon: Icons.restaurant,
          child: Column(
            children: [
              if (_confirmedItems.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('右側メニューから商品を選択してください')))
              else
                ..._confirmedItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      KQuantityCounter(value: _selectedQuantities[item['id']] ?? 0, onChanged: (v) {
                        setState(() {
                          _selectedQuantities[item['id']] = v;
                          _confirmSelection();
                        });
                      }),
                    ],
                  ),
                )),
              const Divider(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('合計: ¥${_totalPrice}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  if (_confirmedItems.isNotEmpty) KButton(label: '内容確定', fullWidth: false, onPressed: _nextStep),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinalStep() {
    return Column(
      children: [
        _buildCard(
          title: '支払・担当店舗・完了',
          icon: Icons.check_circle,
          child: Column(
            children: [
              KTileSelector(label: '担当店舗', selectedValue: _branchName, items: [KTileItem(label: '岡崎本店', value: '岡崎本店'), KTileItem(label: '名古屋店', value: '名古屋店'), KTileItem(label: '岐阜店', value: '岐阜店')], onSelected: (v) => setState(() => _branchName = v)),
              const SizedBox(height: 24),
              KTileSelector(label: '支払方法', selectedValue: _paymentMethod, items: [KTileItem(label: '現金', value: '現金'), KTileItem(label: 'カード', value: 'カード'), KTileItem(label: '請求書', value: '請求')], onSelected: (v) => setState(() => _paymentMethod = v)),
              const SizedBox(height: 24),
              KTileSelector(label: '受電担当者', selectedValue: _selectedReceiverId, items: _staffList.map((s) => KTileItem(label: s.name, value: s.id)).toList(), onSelected: (v) => setState(() => _selectedReceiverId = v)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0) KButton(label: '戻る', color: Colors.grey, fullWidth: false, onPressed: _prevStep) else const SizedBox(),
          if (_currentStep < _stepLabels.length - 1)
            KButton(label: '次へ', fullWidth: false, onPressed: _nextStep)
          else
            KButton(label: '受注を確定して保存する', color: Colors.deepOrange, fullWidth: false, onPressed: _handleSave),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(20), child: Row(children: [Icon(icon, color: Colors.deepOrange, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))])),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _buildRightSideMenu() {
    final categories = _menus.map((m) => m.category).toSet().toList();
    return Container(
      width: 400,
      decoration: BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: Colors.grey.shade200))),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(24), child: const Text('メニュー選択', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final category = categories[i];
                final categoryMenus = _menus.where((m) => m.category == category).toList();
                return Column(
                  children: [
                    ListTile(title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold))),
                    ...categoryMenus.map((menu) => ListTile(
                      title: Text(menu.name),
                      trailing: Text('¥${menu.price}'),
                      onTap: () {
                        setState(() {
                          _selectedQuantities[menu.id] = (_selectedQuantities[menu.id] ?? 0) + 1;
                          _confirmSelection();
                          // 注文ステップでなければ、自動的に注文ステップへ移動する等の配慮も可能だが、
                          // 基本はユーザーの自由なステップ行き来を優先。
                        });
                      },
                    )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuplicateAlert() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
      child: Row(children: [const Icon(Icons.warning, color: Colors.red), const SizedBox(width: 12), Text(_duplicateOrderAlert!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))]),
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
          KButton(label: '入力開始', color: Colors.white, fullWidth: false, onPressed: () {
            _phoneController.text = _incomingNumber!;
            _lookupCustomer(_incomingNumber!);
            setState(() => _incomingNumber = null);
          }),
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
    super.dispose();
  }
}
