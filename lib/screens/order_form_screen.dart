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
import '../widgets/k_time_field.dart';

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
  final _otherWorkController = TextEditingController();
  final _totalCountController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _remarksController = TextEditingController();
  final _packagingCountController = TextEditingController();
  final _teaCountController = TextEditingController();

  // Form State
  DateTime _receptionDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 1));
  String _deliveryType = '配送';
  DateTime _pickupTime = DateTime.now();
  DateTime _deliveryTime = DateTime.now();
  
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
      _totalCountController.text = order.totalCount.toString();
      _deliveryDate = order.deliveryDate;
      _receptionDate = order.receptionDate;
      _deliveryType = order.deliveryType;
      _packagingType = order.packagingType;
      _paymentMethod = order.paymentMethod;
      _branchName = order.branchName; // 追加: 既存の店舗情報を反映
      
      // Parse time
      final timeParts = order.deliveryTime.split(':');
      if (timeParts.length == 2) {
        final time = DateTime(2024, 1, 1, int.parse(timeParts[0]), int.parse(timeParts[1]));
        if (_deliveryType == '配送') {
          _deliveryTime = time;
        } else {
          _pickupTime = time;
        }
      }

      // Populate items
      _selectedQuantities.clear();
      for (var item in order.items) {
        _selectedQuantities[item['id']] = item['quantity'];
      }
      _confirmedItems = List.from(order.items);
      
      // Re-calculate price
      int totalPrice = 0;
      for (var item in _confirmedItems) {
        totalPrice += (item['price'] as int) * (item['quantity'] as int);
      }
      _totalPriceController.text = totalPrice.toString();
      
      _confirmationDate = _deliveryDate.subtract(const Duration(days: 1));
    });
  }

  void _simulateIncomingCall() async {
    await Future.delayed(const Duration(seconds: 5));
    if (widget.initialOrder != null) return; // 編集時は着信シミュレーション停止

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
      } else {
        _currentCustomer = null;
      }
    });
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
      
      int totalCount = 0;
      int totalPrice = 0;
      for (var item in _confirmedItems) {
        totalCount += (item['quantity'] as int);
        totalPrice += (item['price'] as int) * (item['quantity'] as int);
      }
      _totalCountController.text = totalCount.toString();
      _totalPriceController.text = totalPrice.toString();
    });
  }

  void _resetForm() {
    setState(() {
      _phoneController.clear();
      _nameController.clear();
      _facilityController.clear();
      _addressController.clear();
      _otherWorkController.clear();
      _totalCountController.clear();
      _totalPriceController.clear();
      _remarksController.clear();
      _packagingCountController.clear();
      _teaCountController.clear();
      
      _selectedQuantities.clear();
      _confirmedItems.clear();
      _currentCustomer = null;
      
      _receptionDate = DateTime.now();
      _deliveryDate = DateTime.now().add(const Duration(days: 1));
      _confirmationDate = _deliveryDate.subtract(const Duration(days: 1));
      
      _selectedReceiverId = null;
      _selectedConfirmerId = null;
    });
  }

  String _getBranchFromAddress(String address) {
    if (address.contains('名古屋')) return '名古屋店';
    if (address.contains('岐阜')) return '岐阜店';
    return '岡崎本店'; // デフォルト
  }

  Future<void> _handleSave() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _confirmedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('必須項目（氏名、電話番号、注文内容）を入力してください')),
      );
      return;
    }

    final orderId = widget.initialOrder?.id ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    
    // 新規登録時は住所から自動判定、編集時は選択されている値を優先
    final determinedBranch = widget.initialOrder == null 
        ? _getBranchFromAddress(_addressController.text)
        : _branchName;

    final order = OrderModel(
      id: orderId,
      customerName: _nameController.text,
      facilityName: _facilityController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      receptionDate: _receptionDate,
      deliveryDate: _deliveryDate,
      deliveryTime: _deliveryType == '配送' 
          ? "${_deliveryTime.hour}:${_deliveryTime.minute.toString().padLeft(2, '0')}"
          : "${_pickupTime.hour}:${_pickupTime.minute.toString().padLeft(2, '0')}",
      deliveryType: _deliveryType,
      items: _confirmedItems,
      totalCount: int.tryParse(_totalCountController.text) ?? 0,
      packagingType: _packagingType,
      paymentMethod: _paymentMethod,
      status: widget.initialOrder?.status ?? '受注済み',
      branchName: determinedBranch,
    );

    try {
      await _orderService.saveOrder(order);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.initialOrder == null ? '受注を保存しました' : '受注内容を更新しました')),
        );
        if (widget.onSaveSuccess != null) {
          widget.onSaveSuccess!();
        } else {
          _resetForm();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _handlePrint() async {
    final timeStr = _deliveryType == '配送' 
        ? "${_deliveryTime.hour}:${_deliveryTime.minute.toString().padLeft(2, '0')}"
        : "${_pickupTime.hour}:${_pickupTime.minute.toString().padLeft(2, '0')}";

    final data = {
      'deliveryType': _deliveryType,
      'deliveryTime': timeStr,
      'name': _nameController.text,
      'facility': _facilityController.text,
      'address': _addressController.text,
      'phone': _phoneController.text,
      'items': _confirmedItems,
      'totalCount': _totalCountController.text,
      'totalPrice': _totalPriceController.text,
      'packaging': _packagingType,
      'remarks': _remarksController.text,
    };
    await PrintService.printOrder(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.initialOrder == null ? '電話受注システム' : '受注内容の編集', 
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: widget.initialOrder != null ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onSaveSuccess,
        ) : null,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                if (_incomingNumber != null) _buildIncomingCallBar(),
                _buildTopCustomerInfoArea(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildReceptionDetailsSection(),
                        const SizedBox(height: 24),
                        if (_confirmedItems.isNotEmpty) ...[
                          _buildConfirmedItemsSection(),
                          const SizedBox(height: 24),
                        ],
                        _buildOrderItemsSection(),
                        const SizedBox(height: 24),
                        _buildPaymentAndReceiptSection(),
                        const SizedBox(height: 24),
                        _buildConfirmationSection(),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            KButton(
                              label: widget.initialOrder == null ? '受注を確定して保存する (F10)' : '更新を保存する',
                              fullWidth: false,
                              onPressed: _handleSave,
                            ),
                            const SizedBox(width: 16),
                            KButton(
                              label: '印刷する',
                              color: Colors.blueGrey,
                              fullWidth: false,
                              onPressed: _handlePrint,
                            ),
                            if (widget.initialOrder != null) ...[
                              const SizedBox(width: 16),
                              KButton(
                                label: 'キャンセル',
                                color: Colors.grey,
                                fullWidth: false,
                                onPressed: widget.onSaveSuccess!,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey[300]!)),
            ),
            child: _buildSideMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomerInfoArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Colors.blueGrey, size: 20),
              const SizedBox(width: 8),
              const Text('基本・顧客情報', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_currentCustomer == null && widget.initialOrder == null)
                const Text('新規顧客', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
              else
                const Text('既往顧客', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: KTextField(
                  label: '電話番号 (ハイフンなし可)',
                  controller: _phoneController,
                  icon: Icons.phone,
                  onChanged: _lookupCustomer,
                  keyboardType: TextInputType.phone,
                  autofocus: widget.initialOrder == null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: widget.initialOrder != null 
                  ? KChoiceGroup<String>(
                      label: '担当店舗 (編集モード)',
                      selectedValue: _branchName,
                      items: [
                        KChoiceItem(label: '岡崎本店', value: '岡崎本店'),
                        KChoiceItem(label: '名古屋店', value: '名古屋店'),
                        KChoiceItem(label: '岐阜店', value: '岐阜店'),
                      ],
                      onSelected: (val) => setState(() => _branchName = val),
                    )
                  : KTextField(label: '名前', controller: _nameController, icon: Icons.badge),
              ),
            ],
          ),
          Row(
            children: [
              if (widget.initialOrder != null) ...[
                Expanded(child: KTextField(label: '名前', controller: _nameController, icon: Icons.badge)),
                const SizedBox(width: 16),
              ],
              Expanded(
                flex: 1,
                child: KTextField(label: '施設名・会社名', controller: _facilityController, icon: Icons.business),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: KTextField(
                  label: '住所', 
                  controller: _addressController, 
                  icon: Icons.location_on,
                  suffix: (_currentCustomer != null && _currentCustomer!.deliveryAddresses.isNotEmpty)
                      ? _buildAddressHistoryPopup()
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceptionDetailsSection() {
    return _buildSectionCard(
      title: '受電・配送詳細',
      icon: Icons.assignment,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStaffDropdown('受電者', _selectedReceiverId, (val) => setState(() => _selectedReceiverId = val))),
              const SizedBox(width: 16),
              Expanded(
                child: KDateTimePicker(
                  label: '受電日',
                  value: _receptionDate,
                  onSelected: (date) => setState(() => _receptionDate = date),
                  icon: Icons.calendar_today,
                ),
              ),
            ],
          ),
          KChoiceGroup<String>(
            label: '引取 / 配送',
            selectedValue: _deliveryType,
            items: [
              KChoiceItem(label: '配送', value: '配送'),
              KChoiceItem(label: '引取', value: '引取'),
            ],
            onSelected: (val) => setState(() => _deliveryType = val),
          ),
          Row(
            children: [
              Expanded(
                child: KDateTimePicker(
                  label: _deliveryType == '配送' ? '配送日' : '引取日',
                  value: _deliveryDate,
                  onSelected: (date) {
                    setState(() {
                      _deliveryDate = date;
                      _confirmationDate = date.subtract(const Duration(days: 1));
                    });
                  },
                  icon: Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KTimeField(
                  label: _deliveryType == '配送' ? '配送希望時間' : '引取予定時間',
                  value: _deliveryType == '配送' ? _deliveryTime : _pickupTime,
                  onSelected: (time) => setState(() {
                    if (_deliveryType == '配送') {
                      _deliveryTime = time;
                    } else {
                      _pickupTime = time;
                    }
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            children: [
              KLabeledCheckbox(label: '直取り', value: _isDirect, onChanged: (v) => setState(() => _isDirect = v ?? false)),
              KLabeledCheckbox(label: '結膳', value: _isKetsuzen, onChanged: (v) => setState(() => _isKetsuzen = v ?? false)),
              KLabeledCheckbox(label: '納品書あり', value: _hasDeliveryNote, onChanged: (v) => setState(() => _hasDeliveryNote = v ?? true)),
              KLabeledCheckbox(label: 'デリカ', value: _isDelica, onChanged: (v) => setState(() => _isDelica = v ?? false)),
            ],
          ),
          KTextField(label: 'その他作業内容', controller: _otherWorkController, icon: Icons.more_horiz),
        ],
      ),
    );
  }

  Widget _buildConfirmedItemsSection() {
    return _buildSectionCard(
      title: '確定した注文内容',
      icon: Icons.shopping_cart_checkout,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._confirmedItems.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(child: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                Text("${item['quantity']} 個", style: const TextStyle(fontSize: 16, color: Colors.orange, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Text("¥${(item['price'] * item['quantity']).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          )),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('合計個数', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Row(
                    children: [
                      Text(_totalCountController.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                      const Text(' 個', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 48),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('請求金額 (税込)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Row(
                    children: [
                      const Text('¥ ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(
                        _totalPriceController.text.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    return _buildSectionCard(
      title: '梱包・特記',
      icon: Icons.inventory_2,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: KTextField(
                  label: '合計個数',
                  controller: _totalCountController,
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KTextField(
                  label: '請求金額',
                  controller: _totalPriceController,
                  icon: Icons.currency_yen,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: KChoiceGroup<String>(
                  label: '梱包形態',
                  selectedValue: _packagingType,
                  items: [
                    KChoiceItem(label: '紙袋', value: '紙袋'),
                    KChoiceItem(label: '段ボール', value: '段ボール'),
                    KChoiceItem(label: '小分け', value: '小分け'),
                  ],
                  onSelected: (val) => setState(() => _packagingType = val),
                ),
              ),
              if (_packagingType == '小分け') ...[
                const SizedBox(width: 16),
                Expanded(flex: 1, child: KTextField(label: '個数', controller: _packagingCountController)),
              ],
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: KChoiceGroup<String>(
                  label: 'お茶',
                  selectedValue: _teaType,
                  items: [
                    KChoiceItem(label: '込み', value: '込み'),
                    KChoiceItem(label: '別', value: '別'),
                    KChoiceItem(label: 'なし', value: 'なし'),
                    KChoiceItem(label: '特典', value: '特典'),
                  ],
                  onSelected: (val) => setState(() => _teaType = val),
                ),
              ),
              if (_teaType == '特典' || _teaType == '別') ...[
                const SizedBox(width: 16),
                Expanded(flex: 1, child: KTextField(label: '本数', controller: _teaCountController)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          KTextField(label: '備考 (アレルギー、配送指示など)', controller: _remarksController, icon: Icons.notes),
        ],
      ),
    );
  }

  Widget _buildPaymentAndReceiptSection() {
    return _buildSectionCard(
      title: '支払・領収書',
      icon: Icons.payments,
      child: Column(
        children: [
          KChoiceGroup<String>(
            label: '支払方法',
            selectedValue: _paymentMethod,
            items: [
              KChoiceItem(label: '現金', value: '現金'),
              KChoiceItem(label: 'カード', value: 'カード'),
              KChoiceItem(label: '請求', value: '請求'),
              KChoiceItem(label: '売掛', value: '売掛'),
            ],
            onSelected: (val) => setState(() => _paymentMethod = val),
          ),
          KChoiceGroup<String>(
            label: '領収書',
            selectedValue: _receiptType,
            items: [
              KChoiceItem(label: '不要', value: '不要'),
              KChoiceItem(label: '手書き', value: '手書き'),
              KChoiceItem(label: '電子', value: '電子'),
              KChoiceItem(label: 'レシート', value: 'レシート'),
            ],
            onSelected: (val) => setState(() => _receiptType = val),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationSection() {
    return _buildSectionCard(
      title: '事前確認設定',
      icon: Icons.verified_user,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: KDateTimePicker(
                  label: '確認予定日',
                  value: _confirmationDate,
                  onSelected: (date) => setState(() => _confirmationDate = date),
                  icon: Icons.event_available,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildStaffDropdown('確認担当者', _selectedConfirmerId, (val) => setState(() => _selectedConfirmerId = val))),
            ],
          ),
          KChoiceGroup<String>(
            label: '確認方法',
            selectedValue: _confirmationMethod,
            items: [
              KChoiceItem(label: '電話', value: '電話'),
              KChoiceItem(label: 'メール', value: 'メール'),
            ],
            onSelected: (val) => setState(() => _confirmationMethod = val),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffDropdown(String label, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.badge_outlined),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _staffList.map((staff) {
          return DropdownMenuItem(
            value: staff.id,
            child: Text(staff.name),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orange, size: 22),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildSideMenu() {
    final categories = _menus.map((m) => m.category).toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            border: Border(bottom: BorderSide(color: Colors.orange.shade100)),
          ),
          child: const Row(
            children: [
              Icon(Icons.restaurant_menu, color: Colors.orange),
              SizedBox(width: 12),
              Text('メニュー選択', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, catIndex) {
              final category = categories[catIndex];
              final categoryMenus = _menus.where((m) => m.category == category).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(category, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  ),
                  ...categoryMenus.map((menu) {
                    final qty = _selectedQuantities[menu.id] ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          if (menu.imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                menu.imageUrl,
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 70,
                                  width: 70,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
                                ),
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(menu.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("¥${menu.price}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _buildQtyButton(Icons.remove, () {
                                if (qty > 0) setState(() => _selectedQuantities[menu.id] = qty - 1);
                              }),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ),
                              _buildQtyButton(Icons.add, () {
                                setState(() => _selectedQuantities[menu.id] = qty + 1);
                              }),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                onPressed: () {
                                  if (qty > 0) setState(() => _selectedQuantities[menu.id] = 0);
                                },
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: KButton(
            label: '選択内容を確定',
            fullWidth: false,
            onPressed: _confirmSelection,
          ),
        ),
      ],
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(icon, size: 16, color: Colors.orange),
      ),
    );
  }

  Widget _buildAddressHistoryPopup() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.orange),
      tooltip: '過去の配達先住所',
      onSelected: (String value) => _addressController.text = value,
      itemBuilder: (BuildContext context) {
        return _currentCustomer!.deliveryAddresses.map((String addr) {
          return PopupMenuItem<String>(
            value: addr,
            child: Text(addr, style: const TextStyle(fontSize: 13)),
          );
        }).toList();
      },
    );
  }

  Widget _buildIncomingCallBar() {
    return Container(
      color: Colors.orange[800],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.phone_in_talk, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Text(
            '着信中: $_incomingNumber',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 32),
          ElevatedButton(
            onPressed: () {
              if (_incomingNumber != null) {
                _phoneController.text = _incomingNumber!;
                _lookupCustomer(_incomingNumber!);
                setState(() => _incomingNumber = null);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange[800]),
            child: const Text('この番号で入力開始'),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => setState(() => _incomingNumber = null),
          ),
          const Spacer(),
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
    _otherWorkController.dispose();
    _totalCountController.dispose();
    _totalPriceController.dispose();
    _remarksController.dispose();
    _packagingCountController.dispose();
    _teaCountController.dispose();
    super.dispose();
  }
}
