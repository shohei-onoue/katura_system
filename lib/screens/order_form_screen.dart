import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/customer_model.dart';
import '../models/menu_model.dart';
import '../models/staff_model.dart';
import '../models/order_model.dart';
import '../services/customer_service.dart';
import '../services/menu_service.dart';
import '../services/staff_service.dart';
import '../services/order_service.dart';
import '../widgets/k_text_field.dart';
import '../widgets/k_button.dart';
import '../widgets/k_choice_group.dart';
import '../widgets/k_date_time_picker.dart';
import '../widgets/k_time_slot_selector.dart';
import '../widgets/k_quantity_counter.dart';
import '../widgets/k_tile_selector.dart';
import '../widgets/k_stepper.dart';
import '../widgets/k_phone_input_pad.dart';
import 'delivery_address_registration_screen.dart';

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
  final _nameController = TextEditingController(); // 注文者名
  final _receiverController = TextEditingController(); // 受取人名（新規追加）
  final _facilityController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliveryLocationController = TextEditingController(); // お渡し場所

  // Form State
  int _currentStep = 0;
  DateTime _receptionDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 1));
  String _deliveryType = '配送';
  DateTime _selectedTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0);
  
  String _paymentMethod = '現金';
  String _branchName = '岡崎本店';
  String? _selectedReceiverId;
  String? _selectedReceiverName;

  bool _collectContainer = false;

  Customer? _currentCustomer;
  List<MenuModel> _menus = [];
  Map<String, int> _selectedQuantities = {};
  List<Map<String, dynamic>> _confirmedItems = [];
  List<Staff> _staffList = [];
  
  bool _isLoading = false;
  String? _duplicateOrderAlert;
  List<String> _otherStaffHistory = [];

  // Map State
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  BitmapDescriptor? _startPointIcon;
  static const LatLng _initialCenter = LatLng(34.9563, 137.1685); // 岡崎市役所付近

  final Map<String, LatLng> _branchCoordinates = {
    '岡崎本店': const LatLng(34.97596915388157, 137.16160761838935),
    '名古屋店': const LatLng(35.1815, 136.9066),
    '岐阜店': const LatLng(35.4233, 136.7606),
  };

  final List<String> _stepLabels = ['番号確認', '顧客・施設', '配達日時', '注文内容', '支払・完了'];

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      if (widget.initialOrder != null) {
        _populateForm(widget.initialOrder!);
      }
    });
    _loadMapIcons();
  }

  Future<void> _loadMapIcons() async {
    final icon = await _createBlueCircleIcon();
    if (mounted) {
      setState(() => _startPointIcon = icon);
    }
  }

  Future<BitmapDescriptor> _createBlueCircleIcon() async {
    const double size = 30.0;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2.8, Paint()..color = Colors.deepPurple);
    final image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
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
      _receiverController.text = order.receiverName;
      _facilityController.text = order.facilityName;
      _addressController.text = order.address;
      _deliveryLocationController.text = order.deliveryLocation;
      _deliveryDate = order.deliveryDate;
      _receptionDate = order.receptionDate;
      _deliveryType = order.deliveryType;
      _paymentMethod = order.paymentMethod;
      _branchName = order.branchName;
      _collectContainer = order.collectContainer;
      
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

  Future<void> _lookupCustomer(String phone) async {
    final cleanDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanDigits.length < 10) {
      setState(() {
        _currentCustomer = null;
        _otherStaffHistory = [];
      });
      return;
    }

    setState(() => _isLoading = true);
    final customer = await _customerService.findByPhoneNumber(phone);
    
    List<String> otherHistory = [];
    if (customer != null && customer.companyName.isNotEmpty) {
      final allCustomers = await _customerService.getAllCustomers();
      final otherStaff = allCustomers.where((c) => 
        c.companyName == customer.companyName && c.id != customer.id
      ).toList();
      
      for (var staff in otherStaff) {
        for (var h in staff.orderHistory) {
          otherHistory.add('${staff.name}: $h');
        }
      }
      otherHistory.sort((a, b) => b.compareTo(a));
      if (otherHistory.length > 5) otherHistory = otherHistory.sublist(0, 5);
    }

    setState(() {
      _isLoading = false;
      if (customer != null) {
        _currentCustomer = customer;
        _otherStaffHistory = otherHistory;
        _nameController.text = customer.name;
        _facilityController.text = customer.companyName;
        _addressController.text = customer.address;
        _checkDuplicateOrder(customer.address);
      } else {
        _currentCustomer = null;
        _otherStaffHistory = [];
      }
    });
  }

  String _formatPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length == 11) {
      return '${clean.substring(0, 3)}-${clean.substring(3, 7)}-${clean.substring(7)}';
    } else if (clean.length == 10) {
      if (clean.startsWith('03') || clean.startsWith('06')) {
        return '${clean.substring(0, 2)}-${clean.substring(2, 6)}-${clean.substring(6)}';
      } else if (clean.startsWith('0564')) {
        return '${clean.substring(0, 4)}-${clean.substring(4, 6)}-${clean.substring(6)}';
      } else {
        return '${clean.substring(0, 3)}-${clean.substring(3, 6)}-${clean.substring(6)}';
      }
    }
    return clean;
  }

  Future<void> _checkDuplicateOrder(String address) async {
    final allOrders = await _orderService.getAllOrders();
    final recent = allOrders.where((o) => 
      o.address == address && 
      o.deliveryDate.difference(DateTime.now()).inDays.abs() <= 3
    ).toList();

    if (recent.isNotEmpty) {
      final names = recent.map((o) => o.customerName).toSet().join(', ');
      setState(() => _duplicateOrderAlert = "⚠️ 重複警告: 3日以内に同住所で注文があります ($names)");
    } else {
      setState(() => _duplicateOrderAlert = null);
    }
  }

  String _formatJapaneseDate(DateTime dt) {
    final weekDays = ['日', '月', '火', '水', '木', '金', '土'];
    return "${dt.year}年${dt.month}月${dt.day}日(${weekDays[dt.weekday % 7]})";
  }

  void _onAddressSelected(String fullAddress) {
    final regExp = RegExp(r'\(([-+]?\d*\.?\d+),\s*([-+]?\d*\.?\d+)\)');
    final match = regExp.firstMatch(fullAddress);

    String facilityName = '配送先';
    if (fullAddress.contains(': ')) {
      facilityName = fullAddress.split(': ')[0];
    } else if (fullAddress.startsWith('[')) {
      facilityName = fullAddress.split(']')[0].replaceAll('[', '');
    }

    if (match != null) {
      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);

      if (lat != null && lng != null) {
        final destPosition = LatLng(lat, lng);
        final startPosition = _branchCoordinates[_branchName] ?? _initialCenter;

        setState(() {
          _markers = {
            Marker(
              markerId: const MarkerId('start_point_marker'),
              position: startPosition,
              infoWindow: InfoWindow(title: '出発店舗: $_branchName'),
              icon: _startPointIcon ?? BitmapDescriptor.defaultMarkerWithHue(240.0),
              anchor: const Offset(0.5, 0.5),
              zIndex: 10,
            ),
            Marker(
              markerId: const MarkerId('delivery_dest_marker'),
              position: destPosition,
              infoWindow: InfoWindow(title: '配送先: $facilityName'),
              icon: BitmapDescriptor.defaultMarkerWithHue(0.0),
              zIndex: 5,
            )
          };
          _polylines = {};
        });
        
        Future.delayed(const Duration(milliseconds: 100), () {
          _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(
                startPosition.latitude < destPosition.latitude ? startPosition.latitude : destPosition.latitude,
                startPosition.longitude < destPosition.longitude ? startPosition.longitude : destPosition.longitude,
              ),
              northeast: LatLng(
                startPosition.latitude > destPosition.latitude ? startPosition.latitude : destPosition.latitude,
                startPosition.longitude > destPosition.longitude ? startPosition.longitude : destPosition.longitude,
              ),
            ),
            80,
          ));
        });
      }
    }

    setState(() {
      String displayAddr = fullAddress.split(' (')[0];
      if (displayAddr.contains(': ')) {
        displayAddr = displayAddr.split(': ')[1];
      } else if (displayAddr.contains('] ')) {
        displayAddr = displayAddr.split('] ')[1];
      }
      _addressController.text = displayAddr;
      _facilityController.text = facilityName;

      // 受取人の候補セット（施設名に紐づく過去の受取人を抽出）
      final knownReceivers = _currentCustomer?.facilityReceivers[facilityName] ?? [];
      if (knownReceivers.isNotEmpty) {
        _receiverController.text = knownReceivers.first;
        _selectedReceiverName = knownReceivers.first;
      } else {
        _receiverController.text = '';
        _selectedReceiverName = null;
      }
    });
  }

  void _nextStep() {
    if (_currentStep < _stepLabels.length - 1) {
      setState(() => _currentStep++);
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

  String _calculatePackaging() {
    if (_totalCount >= 20) return 'ダンボール';
    return '紙袋';
  }

  double _calculateRiceAmount() {
    final month = _deliveryDate.month;
    final factor = (month >= 6 && month <= 9) ? 1.15 : (month >= 12 || month <= 2) ? 1.25 : 1.0;
    return _totalCount * 0.15 * factor; // 1人前150g(生米換算)想定
  }

  Future<void> _handleSave() async {
    final orderId = widget.initialOrder?.id ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final order = OrderModel(
      id: orderId,
      customerName: _nameController.text,
      receiverName: _receiverController.text,
      facilityName: _facilityController.text,
      address: _addressController.text,
      deliveryLocation: _deliveryLocationController.text,
      phoneNumber: _phoneController.text,
      receptionDate: _receptionDate,
      deliveryDate: _deliveryDate,
      deliveryTime: "${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}",
      deliveryType: _deliveryType,
      items: _confirmedItems,
      totalCount: _totalCount,
      packagingType: _calculatePackaging(),
      collectContainer: _collectContainer,
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
          title: '電話番号の確認',
          icon: Icons.phone_callback,
          child: Column(
            children: [
              TextField(
                controller: _phoneController,
                textAlign: TextAlign.center,
                readOnly: true,
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.deepOrange, letterSpacing: 10),
                decoration: const InputDecoration(border: InputBorder.none),
                keyboardType: TextInputType.none,
              ),
              if (_currentCustomer != null) _buildCustomerInfoCard(showHistory: true),
              const SizedBox(height: 48),
              if (_phoneController.text.length >= 10)
                KButton(
                  label: _currentCustomer != null ? 'この内容で間違いない（受注フォームへ）' : '新規顧客として受注フォームへ',
                  onPressed: _nextStep,
                  color: Colors.deepPurple,
                )
              else
                Text(
                  '10桁以上の番号を入力してください (${_phoneController.text.length.toString()}/10)',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
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
          trailing: Text('受電: ${_phoneController.text}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
          child: Column(
            children: [
              if (_currentCustomer != null) ...[
                _buildCustomerInfoCard(showHistory: false),
                const SizedBox(height: 24),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('配達先情報', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  KButton(
                    label: '新規配達先を追加', 
                    fullWidth: false, 
                    color: Colors.blueGrey,
                    onPressed: () async {
                      if (_currentCustomer == null) return;
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeliveryAddressRegistrationScreen(customer: _currentCustomer!),
                        ),
                      );
                      if (result != null && result is String) {
                        _onAddressSelected(result);
                      }
                    }
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: KTextField(label: '施設・会社名', controller: _facilityController, icon: Icons.business)),
                  const SizedBox(width: 16),
                  Expanded(child: KTextField(label: '住所', controller: _addressController, icon: Icons.map)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: KTextField(label: 'お渡し場所 (例: 1Fロビー)', controller: _deliveryLocationController, icon: Icons.location_on)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KTextField(
                      label: '受取人名 (ドクター等)', 
                      controller: _receiverController, 
                      icon: Icons.badge,
                      suffix: (_currentCustomer?.facilityReceivers[_facilityController.text]?.isNotEmpty ?? false)
                        ? PopupMenuButton<String>(
                            icon: const Icon(Icons.history),
                            onSelected: (val) {
                              setState(() {
                                _receiverController.text = val;
                                _selectedReceiverName = val;
                              });
                            },
                            itemBuilder: (context) => _currentCustomer!.facilityReceivers[_facilityController.text]!
                                .map((name) => PopupMenuItem(value: name, child: Text(name)))
                                .toList(),
                          )
                        : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              KButton(label: '配達日時の選択へ', onPressed: _nextStep),
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
                  Expanded(
                    child: KDateTimePicker(
                      label: '配達日', 
                      value: _deliveryDate, 
                      icon: Icons.calendar_month, 
                      onSelected: (d) => setState(() => _deliveryDate = d)
                    )
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KChoiceGroup(
                      label: '区分', 
                      selectedValue: _deliveryType, 
                      items: [KChoiceItem(label: '配送', value: '配送'), KChoiceItem(label: '引取', value: '引取')], 
                      onSelected: (v) => setState(() => _deliveryType = v)
                    )
                  ),
                ],
              ),
              const SizedBox(height: 24),
              KTimeSlotSelector(label: '希望時間枠 (15分刻みタップ)', selectedTime: _selectedTime, onSelected: (t) {
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
    final categories = _menus.map((m) => m.category).toSet().toList();
    return Column(
      children: [
        _buildCard(
          title: '商品選択',
          icon: Icons.restaurant_menu,
          child: SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final category = categories[i];
                final categoryMenus = _menus.where((m) => m.category == category).toList();
                return Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: double.infinity,
                        color: Colors.grey.shade50,
                        child: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: categoryMenus.length,
                          itemBuilder: (context, j) {
                            final menu = categoryMenus[j];
                            return ListTile(
                              dense: true,
                              title: Text(menu.name),
                              trailing: Text('¥${menu.price}'),
                              onTap: () {
                                setState(() {
                                  _selectedQuantities[menu.id] = (_selectedQuantities[menu.id] ?? 0) + 1;
                                  _confirmSelection();
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildCard(
          title: '注文内容・数量調整',
          icon: Icons.restaurant,
          trailing: _confirmedItems.isEmpty ? null : Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('生米換算: ${_calculateRiceAmount().toStringAsFixed(2)}kg', style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              Text('資材目安: ${_calculatePackaging()}', style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
            ],
          ),
          child: Column(
            children: [
              if (_confirmedItems.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('メニューをタップして追加してください')))
              else
                ..._confirmedItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('合計: ¥${_totalPrice}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
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
          title: '支払・完了',
          icon: Icons.check_circle,
          child: Column(
            children: [
              KTileSelector(label: '担当店舗', selectedValue: _branchName, items: [KTileItem(label: '岡崎本店', value: '岡崎本店'), KTileItem(label: '名古屋店', value: '名古屋店'), KTileItem(label: '岐阜店', value: '岐阜店')], onSelected: (v) => setState(() => _branchName = v)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: KTileSelector(label: '支払方法', selectedValue: _paymentMethod, items: [KTileItem(label: '現金', value: '現金'), KTileItem(label: 'カード', value: 'カード'), KTileItem(label: '請求書', value: '請求')], onSelected: (v) => setState(() => _paymentMethod = v))),
                  const SizedBox(width: 24),
                  Container(
                    width: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        const Text('容器回収', style: TextStyle(fontWeight: FontWeight.bold)),
                        Switch(value: _collectContainer, onChanged: (v) => setState(() => _collectContainer = v)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              KTileSelector(label: '受電担当者', selectedValue: _selectedReceiverId, items: _staffList.map((s) => KTileItem(label: s.name, value: s.id)).toList(), onSelected: (v) => setState(() => _selectedReceiverId = v)),
              const SizedBox(height: 40),
              KButton(label: '受注を確定して保存する', color: Colors.deepOrange, onPressed: _handleSave),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfoCard({required bool showHistory}) {
    if (_currentCustomer == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade200),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('[ 注文者 ]', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_currentCustomer!.furigana.isEmpty ? ' ' : _currentCustomer!.furigana, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                  Text(_currentCustomer!.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 80),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('[ 企業・施設名 ]', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(' ', style: TextStyle(fontSize: 12)),
                  Text(_currentCustomer!.companyName.isEmpty ? '-' : _currentCustomer!.companyName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          if (showHistory) ...[
            const Divider(height: 32, thickness: 1),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('【 本人の直近履歴 】', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      const SizedBox(height: 8),
                      if (_currentCustomer!.orderHistory.isEmpty)
                        const Text('履歴なし', style: TextStyle(color: Colors.grey))
                      else
                        ..._currentCustomer!.orderHistory.take(3).map((h) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $h', style: const TextStyle(fontSize: 14)),
                        )),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('【 同企業の他社員履歴 】', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      const SizedBox(height: 8),
                      if (_otherStaffHistory.isEmpty)
                        const Text('履歴なし', style: TextStyle(color: Colors.grey))
                      else
                        ..._otherStaffHistory.map((h) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $h', style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                        )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child, Widget? trailing}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: Colors.deepOrange, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (trailing != null) ...[const Spacer(), trailing],
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _buildRightSideMenu() {
    return Container(
      width: 400,
      decoration: BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: Colors.grey.shade200))),
      child: Column(
        children: [
          if (_currentStep == 0) ...[
            const SizedBox(height: 40),
            const Text('入力ダイヤル', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            KPhoneInputPad(
              controller: _phoneController,
              onInput: (digit) {
                final clean = (_phoneController.text + digit).replaceAll(RegExp(r'[^0-9]'), '');
                _phoneController.text = _formatPhone(clean);
                _lookupCustomer(_phoneController.text);
              },
              onClear: () => _lookupCustomer(''),
            ),
            const Spacer(),
          ] else if (_currentStep == 1 && _currentCustomer != null) ...[
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(target: _initialCenter, zoom: 12),
                onMapCreated: (controller) => _mapController = controller,
                markers: _markers,
                polylines: _polylines,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
              ),
            ),
            const Padding(padding: EdgeInsets.all(24), child: Text('実績から配達先を選択', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _currentCustomer!.deliveryAddresses.length,
                itemBuilder: (context, index) {
                  final fullAddr = _currentCustomer!.deliveryAddresses[index];
                  final parts = fullAddr.split(': ');
                  final facilityName = parts.length > 1 ? parts[0] : '名称なし';
                  final addressOnly = parts.length > 1 ? parts[1].split(' (')[0] : fullAddr.split(' (')[0];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                    child: InkWell(
                      onTap: () => _onAddressSelected(fullAddr),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [const Icon(Icons.location_on, size: 18, color: Colors.deepOrange), const SizedBox(width: 8), Expanded(child: Text(facilityName, style: const TextStyle(fontWeight: FontWeight.bold)))]),
                            const SizedBox(height: 4),
                            Text(addressOnly, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            const SizedBox(height: 40),
            _buildSummaryCard(),
            const Spacer(),
            const Center(child: Text('ガイダンス表示エリア', style: TextStyle(color: Colors.grey))),
            const Spacer(),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('受注サマリー', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(),
          _summaryRow('配達日', _formatJapaneseDate(_deliveryDate)),
          _summaryRow('時間', '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
          _summaryRow('注文者', _nameController.text),
          if (_receiverController.text.isNotEmpty) _summaryRow('受取人', _receiverController.text),
          _summaryRow('合計', '¥$_totalPrice (${_totalCount}点)'),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Text('$label: ', style: const TextStyle(color: Colors.grey)), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)))]),
    );
  }

  Widget _buildDuplicateAlert() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
      child: Row(children: [const Icon(Icons.warning, color: Colors.red), const SizedBox(width: 12), Expanded(child: Text(_duplicateOrderAlert!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))]),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _receiverController.dispose();
    _facilityController.dispose();
    _addressController.dispose();
    _deliveryLocationController.dispose();
    super.dispose();
  }
}

class _JapanesePhoneFormatter extends TextInputFormatter {
  final String Function(String) formatFunc;
  _JapanesePhoneFormatter(this.formatFunc);
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final formatted = formatFunc(newValue.text);
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length), composing: TextRange.empty);
  }
}
