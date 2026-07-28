import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/customer_model.dart';
import '../models/menu_model.dart';
import '../models/staff_model.dart';
import '../models/order_model.dart';
import '../services/customer_service.dart';
import '../services/menu_service.dart';
import '../services/staff_service.dart';
import '../services/order_service.dart';
import '../widgets/k_stepper.dart';
import '../widgets/k_responsive.dart';
import 'order_form/widgets/order_form_parts.dart';
import 'order_form/widgets/step_widgets.dart';
import 'order_form/widgets/sidebar_widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OrderFormScreen extends StatefulWidget {
  final OrderModel? initialOrder;
  final VoidCallback? onSaveSuccess;

  const OrderFormScreen({super.key, this.initialOrder, this.onSaveSuccess});

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
  final _receiverController = TextEditingController();
  final _facilityController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliveryLocationController = TextEditingController();
  final _addressQueryController = TextEditingController();
  final _keywordQueryController = TextEditingController();
  final _combinedSearchController = TextEditingController();

  // Form State
  int _currentStep = 0;
  DateTime _receptionDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 1));
  String _deliveryType = '配送';
  DateTime _selectedTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0);
  String _paymentMethod = '現金';
  String _branchName = '岡崎本店';
  String? _selectedReceiverId;
  bool _collectContainer = false;
  Customer? _currentCustomer;
  List<Customer> _phoneSearchCandidates = [];
  List<OrderModel> _customerOrderHistory = [];
  List<OrderModel> _companyOrderHistory = [];
  OrderModel? _selectedHistoryItem;
  List<MenuModel> _menus = [];
  final Map<String, int> _selectedQuantities = {};
  List<Map<String, dynamic>> _confirmedItems = [];
  List<Staff> _staffList = [];
  bool _isLoading = false;
  String? _duplicateOrderAlert;
  bool _isHistoryMode = true;
  String _selectedHistoryCategory = 'すべて';
  List<Map<String, dynamic>> _facilitySearchCandidates = [];

  // Enhanced Search State
  int _searchTabIndex = 0;
  String _searchPrefecture = '愛知県';
  String _searchCity = '岡崎市';
  String _searchTown = '（すべて）';
  String _searchPrefInitial = 'すべて';
  String _searchCityInitial = 'すべて';
  String _searchTownInitial = 'すべて';
  String? _searchCategory;
  String? _searchGenre;
  List<String> _prefList = [];
  List<String> _cityList = [];
  List<String> _townList = [];

  // Map State
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  static const LatLng _initialCenter = LatLng(34.9563, 137.1685);
  final Map<String, LatLng> _branchCoordinates = {
    '岡崎本店': const LatLng(34.97596915388157, 137.16160761838935),
    '名古屋店': const LatLng(35.1815, 136.9066),
    '岐阜店': const LatLng(35.399434, 136.756889),
  };

  final List<String> _stepLabels = ['番号確認', '顧客確認', '配達先の確定', '配達日時', '注文内容', '支払・完了'];

  @override
  void initState() {
    super.initState();
    _keywordQueryController.addListener(_syncSearchQuery);
    _loadData().then((_) {
      if (widget.initialOrder != null) _populateForm(widget.initialOrder!);
    });
  }

  Future<void> _loadData() async {
    final menus = await _menuService.getAllMenus();
    final staff = await _staffService.getAllStaff();
    final prefs = await _customerService.getAddressService().getPrefecturesByInitial(_searchPrefInitial);
    final cities = await _customerService.getAddressService().getCitiesByInitial(_searchPrefecture, _searchCityInitial);
    final towns = await _customerService.getAddressService().getTownsByInitial(_searchPrefecture, _searchCity, _searchTownInitial);
    
    if (mounted) {
      setState(() {
        _menus = menus;
        _staffList = staff;
        _prefList = prefs;
        _cityList = cities;
        _townList = ['（すべて）', ...towns];
        if (!_prefList.contains(_searchPrefecture)) {
          _searchPrefecture = _prefList.isNotEmpty ? _prefList.first : '';
        }
        if (!_cityList.contains(_searchCity)) {
          _searchCity = _cityList.isNotEmpty ? _cityList.first : '';
        }
        _searchTown = '（すべて）';
      });
    }
    _syncSearchQuery();
  }

  Future<void> _updatePrefList(String initial) async {
    final list = await _customerService.getAddressService().getPrefecturesByInitial(initial);
    setState(() {
      _searchPrefInitial = initial;
      _prefList = list;
      if (list.isNotEmpty && !list.contains(_searchPrefecture)) {
        _searchPrefecture = list.first;
        _updateCityList(_searchPrefecture, _searchCityInitial);
      }
    });
    _syncSearchQuery();
  }

  Future<void> _updateCityList(String pref, String initial) async {
    final list = await _customerService.getAddressService().getCitiesByInitial(pref, initial);
    setState(() {
      _searchPrefecture = pref;
      _searchCityInitial = initial;
      _cityList = list;
      if (list.isNotEmpty && !list.contains(_searchCity)) {
        _searchCity = list.first;
        _updateTownList(pref, _searchCity, _searchTownInitial);
      }
    });
    _syncSearchQuery();
  }

  Future<void> _updateTownList(String pref, String city, String initial) async {
    final list = await _customerService.getAddressService().getTownsByInitial(pref, city, initial);
    setState(() {
      _searchPrefecture = pref;
      _searchCity = city;
      _searchTownInitial = initial;
      _townList = ['（すべて）', ...list];
      _searchTown = '（すべて）';
    });
    _syncSearchQuery();
  }

  void _syncSearchQuery() {
    final town = _searchTown == '（すべて）' ? '' : _searchTown;
    final area = '$_searchPrefecture$_searchCity$town';
    String suffix = '';
    if (_searchTabIndex == 0) {
      suffix = _searchGenre ?? '';
    } else if (_searchTabIndex == 2) {
      suffix = _keywordQueryController.text;
    }
    _combinedSearchController.text = '$area $suffix'.trim();
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
      if (timeParts.length == 2) _selectedTime = DateTime(2024, 1, 1, int.parse(timeParts[0]), int.parse(timeParts[1]));
      _selectedQuantities.clear();
      for (var item in order.items) { _selectedQuantities[item['id']] = item['quantity']; }
      _confirmedItems = List.from(order.items);
    });

    final coords = _parseCoordsFromAddress(order.address);
    if (coords != null && coords.latitude != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateMap(coords, order.facilityName.isEmpty ? '配送先' : order.facilityName);
      });
    }
  }

  Future<void> _lookupCustomer(String phone) async {
    final cleanDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanDigits.length == 4) {
      setState(() => _isLoading = true);
      final candidates = await _customerService.searchByPhoneSuffix(cleanDigits);
      setState(() { _isLoading = false; _phoneSearchCandidates = candidates; _currentCustomer = null; });
      return;
    }
    if (cleanDigits.length >= 10) {
      setState(() => _isLoading = true);
      final customer = await _customerService.findByPhoneNumber(phone);
      setState(() { _isLoading = false; if (customer != null) { _selectCustomer(customer); } else { _currentCustomer = null; } });
      return;
    }
    setState(() { _currentCustomer = null; _phoneSearchCandidates = []; });
  }

  void _selectCustomer(Customer customer) async {
    setState(() => _isLoading = true);
    final allOrders = await _orderService.getAllOrders();
    final myHistory = allOrders.where((o) => o.phoneNumber == customer.phoneNumber).toList();
    final companyHistory = allOrders.where((o) => o.facilityName == customer.companyName && o.phoneNumber != customer.phoneNumber).toList();
    setState(() {
      _isLoading = false;
      _currentCustomer = customer;
      _customerOrderHistory = myHistory;
      _companyOrderHistory = companyHistory;
      _phoneController.text = _formatPhone(customer.phoneNumber);
      _nameController.text = customer.name;
      _facilityController.text = customer.companyName;
      _addressController.text = customer.address;
      _checkDuplicateOrder(customer.address);
      _currentStep = 1;
    });
  }

  String _formatPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length == 11) return '${clean.substring(0, 3)}-${clean.substring(3, 7)}-${clean.substring(7)}';
    if (clean.length == 10) return '${clean.substring(0, 3)}-${clean.substring(3, 6)}-${clean.substring(6)}';
    return clean;
  }

  Future<void> _checkDuplicateOrder(String address) async {
    final allOrders = await _orderService.getAllOrders();
    final recent = allOrders.where((o) => o.address == address && o.deliveryDate.difference(DateTime.now()).inDays.abs() <= 3).toList();
    setState(() => _duplicateOrderAlert = recent.isNotEmpty ? "⚠️ 重複警告: 3日以内に同住所で注文があります (${recent.map((o) => o.customerName).toSet().join(', ')})" : null);
  }

  Future<void> _onAddressSelectedFromList(String fullAddr) async {
    final String facilityNamePart = fullAddr.split(': ').first;
    final matchingOrder = _customerOrderHistory.followedBy(_companyOrderHistory).firstWhere((o) => o.facilityName == facilityNamePart || fullAddr.contains(o.address), orElse: () => OrderModel.empty());
    
    LatLng? destPosition;
    if (_currentCustomer?.address == fullAddr || fullAddr.contains(_currentCustomer?.address ?? '')) {
      if (_currentCustomer?.latitude != null) destPosition = LatLng(_currentCustomer!.latitude!, _currentCustomer!.longitude!);
    }
    destPosition ??= _parseCoordsFromAddress(fullAddr);

    if (destPosition == null || (destPosition.latitude == 0 && destPosition.longitude == 0)) {
      final String addressOnly = fullAddr.split(RegExp(r'[(（]'))[0].split(': ').last.trim();
      debugPrint('Invalid coords detected. Repairing for: $facilityNamePart $addressOnly');
      final latLng = await _customerService.getGoogleMapsService().getLatLngFromAddress("$facilityNamePart $addressOnly");
      if (latLng != null) destPosition = LatLng(latLng['lat']!, latLng['lng']!);
    }

    setState(() {
      if (matchingOrder.id.isNotEmpty) _selectedHistoryItem = matchingOrder;
      if (destPosition != null) _updateMap(destPosition, facilityNamePart);
      _addressController.text = fullAddr.split(RegExp(r'[(（]'))[0].split(': ').last.trim();
      _facilityController.text = facilityNamePart;
      if (matchingOrder.id.isNotEmpty) { _receiverController.text = matchingOrder.receiverName; _deliveryLocationController.text = matchingOrder.deliveryLocation; }
    });
  }

  LatLng? _parseCoordsFromAddress(String fullAddr) {
    final regExp = RegExp(r'[(（]([-+]?\d*\.?\d+),\s*([-+]?\d*\.?\d+)[)）]');
    final matches = regExp.allMatches(fullAddr);
    if (matches.isNotEmpty) {
      try {
        final lat = double.parse(matches.last.group(1)!);
        final lng = double.parse(matches.last.group(2)!);
        return LatLng(lat, lng);
      } catch (_) {}
    }
    return null;
  }

  void _updateMap(LatLng position, String title) {
    final startPosition = _branchCoordinates[_branchName] ?? _initialCenter;
    setState(() {
      _markers = {
        Marker(markerId: const MarkerId('start'), position: startPosition, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)),
        Marker(markerId: const MarkerId('dest'), position: position, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), infoWindow: InfoWindow(title: title))
      };
    });
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(_getBounds([startPosition, position]), 80.0));
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double minLat = points.first.latitude, maxLat = points.first.latitude, minLng = points.first.longitude, maxLng = points.first.longitude;
    for (var p in points) { if (p.latitude < minLat) minLat = p.latitude; if (p.latitude > maxLat) maxLat = p.latitude; if (p.longitude < minLng) minLng = p.longitude; if (p.longitude > maxLng) maxLng = p.longitude; }
    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }

  String _normalize(String input) {
    return input
        .replaceAll(RegExp(r'[ 　〒()（）.]'), '')
        .replaceAll('１', '1').replaceAll('２', '2').replaceAll('３', '3').replaceAll('４', '4').replaceAll('５', '5')
        .replaceAll('６', '6').replaceAll('７', '7').replaceAll('８', '8').replaceAll('９', '9').replaceAll('０', '0');
  }

  Future<void> _onSearchSubmit({bool forceApi = false, bool ignoreFilter = false}) async {
    setState(() => _isLoading = true);
    List<Map<String, dynamic>> results = [];

    if (_searchTabIndex == 0 || _searchTabIndex == 2) {
      final townQuery = _searchTown == '（すべて）' ? '' : _searchTown;
      
      if (!forceApi && !ignoreFilter) {
        if (_searchTabIndex == 0) {
          results = await _customerService.getAddressService().searchByLocationAndCategory(
            prefecture: _searchPrefecture, city: _searchCity, category: _searchCategory!, genre: _searchGenre!,
          );
        } else {
          results = await _customerService.getAddressService().searchByLocationAndKeyword(
            prefecture: _searchPrefecture, city: _searchCity, keyword: _keywordQueryController.text,
          );
        }
      }

      if (results.isEmpty || forceApi || ignoreFilter) {
        debugPrint('Using Google Maps API...');
        final keyword = _combinedSearchController.text.trim();
        if (keyword.isEmpty) {
          setState(() => _isLoading = false);
          return;
        }
        
        final branchPos = _branchCoordinates[_branchName];
        final rawResults = await _customerService.getGoogleMapsService().searchPlacesByText(keyword, location: branchPos);
        debugPrint('API Raw Response: ${rawResults.length} items found.');

        if (ignoreFilter) {
          results = rawResults;
        } else {
          final nCity = _normalize(_searchCity);
          final nTown = _normalize(townQuery);
          final nPref = _normalize(_searchPrefecture);

          results = rawResults.where((item) {
            final nAddr = _normalize(item['address'] ?? '');
            final nName = _normalize(item['name'] ?? '');
            bool cityMatch = nAddr.contains(nCity) || nName.contains(nCity);
            bool prefMatch = nAddr.contains('都') || nAddr.contains('道') || nAddr.contains('府') || nAddr.contains('県') 
                ? nAddr.contains(nPref) : true;
            bool townMatch = townQuery.isEmpty || (nAddr.contains(nTown) || nName.contains(nTown));
            if (!townMatch && townQuery.isNotEmpty && townQuery.length > 1) {
              final shortTown = _normalize(townQuery.substring(0, townQuery.length - 1));
              townMatch = nAddr.contains(shortTown) || nName.contains(shortTown);
            }
            return cityMatch && prefMatch && townMatch;
          }).toList();
        }

        if (results.isEmpty && rawResults.isNotEmpty && !ignoreFilter && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('指定エリア内にはありませんが、付近に ${rawResults.length} 件あります'),
              action: SnackBarAction(label: '全表示', onPressed: () => _onSearchSubmit(ignoreFilter: true)),
            )
          );
        }

        for (var item in results) {
          await _customerService.getAddressService().upsertKigyouEntity(
            name: item['name'], address: item['address'], lat: item['lat'], lng: item['lng'],
          );
        }
      }
    } else if (_searchTabIndex == 1) {
      results = await _customerService.getAddressService().searchByAddressOrZip(_addressQueryController.text);
    }

    setState(() {
      _isLoading = false;
      _facilitySearchCandidates = results;
    });

    if (results.isEmpty && mounted) {
      String msg = '指定されたエリア内で施設が見つかりませんでした。';
      if (kIsWeb) msg += ' (Web版ではGoogleマップ検索が制限される場合があります)';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 4)));
    }
  }

  void _selectFacilityCandidate(Map<String, dynamic> f) async {
    setState(() { _facilityController.text = f['name']; _addressController.text = f['address']; _facilitySearchCandidates = []; });
    LatLng? pos = (f['lat'] != null && f['lat'] != 0.0) ? LatLng(f['lat'], f['lng']) : null;
    if (pos == null) {
      final latLng = await _customerService.getGoogleMapsService().getLatLngFromAddress("${f['name']} ${f['address']}");
      if (latLng != null) {
        pos = LatLng(latLng['lat']!, latLng['lng']!);
        await _customerService.getAddressService().upsertKigyouEntity(name: f['name'], address: f['address'], lat: pos.latitude, lng: pos.longitude);
      }
    }
    if (pos != null) _updateMap(pos, f['name']);
  }

  double _calculateRiceAmount() {
    final factor = (_deliveryDate.month >= 6 && _deliveryDate.month <= 9) ? 1.15 : (_deliveryDate.month >= 12 || _deliveryDate.month <= 2) ? 1.25 : 1.0;
    return _totalCount * 0.15 * factor;
  }

  int get _totalCount => _confirmedItems.fold(0, (sum, i) => sum + (i['quantity'] as int));
  int get _totalPrice => _confirmedItems.fold(0, (sum, i) => sum + (i['price'] as int) * (i['quantity'] as int));

  Future<void> _handleSave() async {
    final order = OrderModel(
      id: widget.initialOrder?.id ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}',
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
      packagingType: _totalCount >= 20 ? 'ダンボール' : '紙袋',
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
            flex: 65,
            child: Column(
              children: [
                KStepper(currentStep: _currentStep, steps: _stepLabels, onStepTapped: (s) { if (s < _currentStep) setState(() => _currentStep = s); }),
                if (_duplicateOrderAlert != null) _buildDuplicateAlert(),
                Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: _buildStepContent())),
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
      case 0: return PhoneConfirmStep(phoneController: _phoneController, isLoading: _isLoading, candidates: _phoneSearchCandidates, currentCustomer: _currentCustomer, onNext: () => setState(() => _currentStep = 1), onSelectCustomer: _selectCustomer);
      case 1: return CustomerConfirmationStep(phoneController: _phoneController, currentCustomer: _currentCustomer, onNext: () => setState(() => _currentStep = 2), onBack: () => setState(() => _currentStep = 0));
      case 2: return DeliveryDestinationStep(
        currentCustomer: _currentCustomer,
        phoneDisplay: _phoneController.text,
        isHistoryMode: _isHistoryMode,
        selectedHistoryCategory: _selectedHistoryCategory,
        facilityControllerText: _facilityController.text,
        addressControllerText: _addressController.text,
        nameController: _nameController,
        facilityController: _facilityController,
        addressController: _addressController,
        receiverController: _receiverController,
        deliveryLocationController: _deliveryLocationController,
        addressQueryController: _addressQueryController,
        keywordQueryController: _keywordQueryController,
        combinedSearchController: _combinedSearchController,
        prefList: _prefList,
        cityList: _cityList,
        townList: _townList,
        searchPrefecture: _searchPrefecture,
        searchCity: _searchCity,
        searchTown: _searchTown,
        searchPrefInitial: _searchPrefInitial,
        searchCityInitial: _searchCityInitial,
        searchTownInitial: _searchTownInitial,
        searchCategory: _searchCategory,
        searchGenre: _searchGenre,
        searchTabIndex: _searchTabIndex,
        onNext: () => setState(() => _currentStep = 3),
        onModeToggle: (v) => setState(() => _isHistoryMode = v),
        onHistoryCategoryChanged: (v) => setState(() => _selectedHistoryCategory = v),
        onAddressSelected: _onAddressSelectedFromList,
        onSearchTabChanged: (v) {
          setState(() => _searchTabIndex = v);
          _syncSearchQuery();
        },
        onPrefChanged: (v) => _updateCityList(v, _searchCityInitial),
        onCityChanged: (v) => _updateTownList(_searchPrefecture, v, _searchTownInitial),
        onTownChanged: (v) {
          setState(() => _searchTown = v);
          _syncSearchQuery();
        },
        onPrefInitialChanged: (v) => _updatePrefList(v),
        onCityInitialChanged: (v) => _updateCityList(_searchPrefecture, v),
        onTownInitialChanged: (v) => _updateTownList(_searchPrefecture, _searchCity, v),
        onCategoryChanged: (v) {
          setState(() { _searchCategory = v; _searchGenre = null; });
          _syncSearchQuery();
        },
        onGenreChanged: (v) {
          setState(() => _searchGenre = v);
          _syncSearchQuery();
        },
        onSearchSubmit: _onSearchSubmit,
      );
      case 3: return DeliveryTimeStep(deliveryDate: _deliveryDate, deliveryType: _deliveryType, selectedTime: _selectedTime, onDateSelected: (v) => setState(() => _deliveryDate = v), onTypeSelected: (v) => setState(() => _deliveryType = v), onTimeSelected: (v) => setState(() { _selectedTime = v; _currentStep = 4; }));
      case 4: return ItemsSelectionStep(menus: _menus, confirmedItems: _confirmedItems, selectedQuantities: _selectedQuantities, riceAmount: _calculateRiceAmount(), packaging: _totalCount >= 20 ? 'ダンボール' : '紙袋', totalPrice: _totalPrice, onAddItem: (m) => setState(() { _selectedQuantities[m.id] = (_selectedQuantities[m.id] ?? 0) + 1; _confirmedItems = _menus.where((x) => (_selectedQuantities[x.id] ?? 0) > 0).map((x) => {'id': x.id, 'name': x.name, 'price': x.price, 'quantity': _selectedQuantities[x.id]}).toList(); }), onQuantityChanged: (id, v) => setState(() { _selectedQuantities[id] = v; _confirmedItems = _menus.where((x) => (_selectedQuantities[x.id] ?? 0) > 0).map((x) => {'id': x.id, 'name': x.name, 'price': x.price, 'quantity': _selectedQuantities[x.id]}).toList(); }), onNext: () => setState(() => _currentStep = 5));
      case 5: return FinalizeStep(branchName: _branchName, paymentMethod: _paymentMethod, collectContainer: _collectContainer, selectedReceiverId: _selectedReceiverId, staffList: _staffList, onBranchChanged: (v) { setState(() => _branchName = v); final m = _markers.where((x) => x.markerId.value == 'dest'); if (m.isNotEmpty) _updateMap(m.first.position, _facilityController.text); }, onPaymentChanged: (v) => setState(() => _paymentMethod = v), onCollectChanged: (v) => setState(() => _collectContainer = v), onReceiverChanged: (v) => setState(() => _selectedReceiverId = v), onSave: _handleSave);
      default: return Container();
    }
  }

  Widget _buildRightSideMenu() {
    return Expanded(
      flex: 20,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: Colors.grey.shade200))),
        child: Column(
          children: [
            if (_currentStep == 0) Expanded(child: SidebarPhonePad(controller: _phoneController, onInput: (d) { _phoneController.text = _formatPhone((_phoneController.text + d).replaceAll(RegExp(r'[^0-9]'), '')); _lookupCustomer(_phoneController.text); }, onClear: () { _phoneController.clear(); _lookupCustomer(''); }, onBackspace: () { if (_phoneController.text.isNotEmpty) { final clean = _phoneController.text.replaceAll('-', ''); _phoneController.text = _formatPhone(clean.substring(0, clean.length - 1)); _lookupCustomer(_phoneController.text); } })),
            if (_currentStep == 1) Expanded(child: SidebarAnalysis(history: _customerOrderHistory, onRegenerate: () async { setState(() => _isLoading = true); await _customerService.regenerateDummyCustomers(); if (mounted) setState(() { _isLoading = false; _currentStep = 0; }); })),
            if (_currentStep >= 2) ...[
              SizedBox(height: rs(context, 300), child: GoogleMap(initialCameraPosition: const CameraPosition(target: _initialCenter, zoom: 12), onMapCreated: (c) => _mapController = c, markers: _markers, myLocationButtonEnabled: false, zoomControlsEnabled: true)),
              Expanded(child: SingleChildScrollView(child: _facilitySearchCandidates.isNotEmpty ? SidebarSearchResults(results: _facilitySearchCandidates, onClose: () => setState(() => _facilitySearchCandidates = []), onSelect: _selectFacilityCandidate, onForceApiSearch: () => _onSearchSubmit(forceApi: true)) : (_selectedHistoryItem != null ? SidebarHistoryDetail(order: _selectedHistoryItem!) : SidebarSummary(date: _deliveryDate, time: _selectedTime, customerName: _nameController.text, receiverName: _receiverController.text, totalPrice: _totalPrice, totalCount: _totalCount)))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDuplicateAlert() {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)), child: Row(children: [const Icon(Icons.warning, color: Colors.red), const SizedBox(width: 12), Expanded(child: Text(_duplicateOrderAlert!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))]));
  }

  @override
  void dispose() { 
    _phoneController.dispose(); 
    _nameController.dispose(); 
    _receiverController.dispose(); 
    _facilityController.dispose(); 
    _addressController.dispose(); 
    _deliveryLocationController.dispose(); 
    _addressQueryController.dispose(); 
    _keywordQueryController.dispose(); 
    _combinedSearchController.dispose(); 
    super.dispose(); 
  }
}
