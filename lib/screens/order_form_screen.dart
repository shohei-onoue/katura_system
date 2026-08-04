import 'dart:math';
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
import '../constants/address_constants.dart';
import '../widgets/k_stepper.dart';
import '../widgets/k_location_adjustment_dialog.dart';
import 'order_form/widgets/step_widgets.dart';
import 'order_form/widgets/order_form_sidebar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

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
  
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _receiverController = TextEditingController();
  final _facilityController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliveryLocationController = TextEditingController();
  final _addressQueryController = TextEditingController();
  final _keywordQueryController = TextEditingController();
  final _combinedSearchController = TextEditingController();
  final _remarksController = TextEditingController();

  int _currentStep = 0;
  DateTime _receptionDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 1));
  String _deliveryType = '配送';
  DateTime _selectedTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 0);
  
  // 時間設定のカスタマイズ用
  int _timePickerInterval = 15;
  TimeOfDay _timePickerMin = const TimeOfDay(hour: 11, minute: 0);
  TimeOfDay _timePickerMax = const TimeOfDay(hour: 12, minute: 0);

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
  final _isLoadingNotifier = ValueNotifier<bool>(false);
  final _facilityResultsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  bool _isSearchResultsDialogOpen = false;
  OrderModel? _duplicateOrder;
  bool _isHistoryMode = true;
  String _selectedHistoryCategory = 'すべて';
  String _lastPhoneQuery = '';

  int _searchTabIndex = 0;
  String _searchPrefecture = '愛知県';
  String _searchCity = '岡崎市';
  String _searchTown = '（すべて）';
  String _searchPrefInitial = 'すべて';
  String _searchCityInitial = 'すべて';
  String _searchTownInitial = 'すべて';
  String? _searchCategory;
  String? _searchGenre;
  bool _isApproximateLocation = false;
  String? _pendingStreetViewImageUrl;
  List<String> _prefList = [];
  List<String> _cityList = [];
  List<String> _townList = [];

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  static const LatLng _initialCenter = LatLng(34.9563, 137.1685);
  final Map<String, LatLng> _branchCoordinates = {'岡崎本店': const LatLng(34.97596915388157, 137.16160761838935), '名古屋店': const LatLng(35.1815, 136.9066), '岐阜店': const LatLng(35.399434, 136.756889)};
  final List<String> _stepLabels = ['番号確認', '顧客確認', '配達先の確定', '配達日時', '注文内容', '支払・完了'];

  @override
  void initState() {
    super.initState();
    _keywordQueryController.addListener(_syncSearchQuery);
    _loadData().then((_) { 
      if (widget.initialOrder != null) {
        _populateForm(widget.initialOrder!);
      } else {
        _setInitialBranchMarker();
      }
    });
  }

  void _setInitialBranchMarker() {
    final start = _branchCoordinates[_branchName] ?? _initialCenter;
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('start'), 
          position: start, 
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: _branchName)
        )
      };
    });
  }

  Future<void> _loadData() async {
    final menus = await _menuService.getAllMenus();
    final staff = await _staffService.getAllStaff();
    final prefs = await _customerService.getAddressService().getPrefecturesByInitial(_searchPrefInitial);
    final cities = await _customerService.getAddressService().getCitiesByInitial(_searchPrefecture, _searchCityInitial);
    final towns = await _customerService.getAddressService().getTownsByInitial(_searchPrefecture, _searchCity, _searchTownInitial);
    if (mounted) setState(() { _menus = menus; _staffList = staff; _prefList = prefs; _cityList = cities; _townList = ['（すべて）', ...towns]; if (!_prefList.contains(_searchPrefecture)) _searchPrefecture = _prefList.isNotEmpty ? _prefList.first : ''; if (!_cityList.contains(_searchCity)) _searchCity = _cityList.isNotEmpty ? _cityList.first : ''; _searchTown = '（すべて）'; });
    _syncSearchQuery();
  }

  Future<List<String>> _updatePrefList(String initial) async {
    final list = await _customerService.getAddressService().getPrefecturesByInitial(initial);
    setState(() {
      _searchPrefInitial = initial;
      _prefList = list;
    });
    _syncSearchQuery();
    return list;
  }

  Future<List<String>> _updateCityList(String pref, String initial) async {
    final list = await _customerService.getAddressService().getCitiesByInitial(pref, initial);
    setState(() {
      _searchPrefecture = pref;
      _searchCity = ''; // 都道府県が変わったら市区町村をクリア
      _searchTown = '（すべて）';
      _searchCityInitial = initial;
      _cityList = list;
    });
    _syncSearchQuery();
    return list;
  }

  Future<List<String>> _updateTownList(String pref, String city, String initial) async {
    final list = await _customerService.getAddressService().getTownsByInitial(pref, city, initial);
    setState(() {
      _searchPrefecture = pref;
      _searchCity = city;
      _searchTown = '（すべて）'; // 市区町村が変わったら町名をすべてにリセット
      _searchTownInitial = initial;
      _townList = ['（すべて）', ...list];
    });
    _syncSearchQuery();
    return list;
  }

  void _onAddressConfirmed(String pref, String city, String town) {
    setState(() {
      _searchPrefecture = pref;
      _searchCity = city;
      _searchTown = town;
    });
    _syncSearchQuery();
  }

  void _syncSearchQuery() {
    final town = _searchTown == '（すべて）' ? '' : _searchTown;
    final area = '$_searchPrefecture$_searchCity$town';
    String suffix = _searchTabIndex == 0 ? (_searchGenre ?? '') : (_searchTabIndex == 2 ? _keywordQueryController.text : '');
    _combinedSearchController.text = '$area $suffix'.trim();
  }

  void _populateForm(OrderModel order) {
    setState(() {
      _phoneController.text = order.phoneNumber; _nameController.text = order.customerName; _receiverController.text = order.receiverName; _facilityController.text = order.facilityName; _addressController.text = order.address; _deliveryLocationController.text = order.deliveryLocation; _deliveryDate = order.deliveryDate; _receptionDate = order.receptionDate; _deliveryType = order.deliveryType; _paymentMethod = order.paymentMethod; _branchName = order.branchName; _collectContainer = order.collectContainer;
      final timeParts = order.deliveryTime.split(':'); if (timeParts.length == 2) _selectedTime = DateTime(2024, 1, 1, int.parse(timeParts[0]), int.parse(timeParts[1]));
      _selectedQuantities.clear(); for (var item in order.items) { _selectedQuantities[item['id']] = item['quantity']; }
      _confirmedItems = List.from(order.items);
    });
    final coords = _parseCoordsFromAddress(order.address);
    if (coords != null && coords.latitude != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _updateMap(coords, order.facilityName.isEmpty ? '配送先' : order.facilityName);
      });
    }
  }

  Future<void> _lookupCustomer(String phone) async {
    final cleanDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    _lastPhoneQuery = cleanDigits;
    if (cleanDigits.length >= 4) {
      _isLoadingNotifier.value = true;
      final candidates = await _customerService.searchByPhoneSuffix(cleanDigits);
      if (candidates.length == 1 && cleanDigits.length >= 10) { _selectCustomer(candidates.first); } else { setState(() { _isLoadingNotifier.value = false; _phoneSearchCandidates = candidates; _currentCustomer = null; }); }
      return;
    }
    setState(() { _currentCustomer = null; _phoneSearchCandidates = []; _isLoadingNotifier.value = false; });
  }

  void _selectCustomer(Customer customer) async {
    _isLoadingNotifier.value = true;
    
    // 全注文データを再取得
    final allOrders = await _orderService.getAllOrders();
    
    // 電話番号を正規化して比較 (ハイフンありなし両対応)
    final targetPhone = customer.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    
    // 本人の履歴: 電話番号一致 かつ 顧客名一致 (空白を除去して比較)
    final normCustomerName = customer.name.replaceAll(RegExp(r'\s+'), '');
    final myHistory = allOrders.where((o) {
      final orderPhone = o.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final normOrderName = o.customerName.replaceAll(RegExp(r'\s+'), '');
      return orderPhone == targetPhone && normOrderName == normCustomerName;
    }).toList();
    
    // 同施設他顧客の履歴: 施設名一致 かつ 上記「本人」ではない
    final companyHistory = allOrders.where((o) {
      final orderPhone = o.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final normOrderName = o.customerName.replaceAll(RegExp(r'\s+'), '');
      final isSelf = orderPhone == targetPhone && normOrderName == normCustomerName;
      return o.facilityName == customer.companyName && !isSelf;
    }).toList();

    // グラフ表示のためのフォールバック: 注文コレクションが空でも、顧客ドキュメントの文字列履歴からデータを復元
    if (myHistory.isEmpty && customer.orderHistory.isNotEmpty) {
      for (var h in customer.orderHistory) {
        try {
          // フォーマット: "YYYY-MM-DD: [店舗] [施設] 商品 x個"
          final parts = h.split(': ');
          if (parts.length < 2) continue;
          final datePart = parts[0];
          final detailPart = parts[1];
          
          final date = DateTime.parse(datePart);
          
          // メニュー名と個数を取り出す。フォーマット: "[店舗] [施設] メニュー名 x個"
          // ] の後の空白から x数字 の前までをメニュー名とする
          String menuName = '不明な商品';
          int qty = 1;
          
          final qtyMatch = RegExp(r'x(\d+)$').firstMatch(detailPart);
          if (qtyMatch != null) {
            qty = int.parse(qtyMatch.group(1)!);
            final namePart = detailPart.substring(0, qtyMatch.start).trim();
            final lastBracketIdx = namePart.lastIndexOf(']');
            if (lastBracketIdx != -1) {
              menuName = namePart.substring(lastBracketIdx + 1).trim();
            } else {
              menuName = namePart;
            }
          }
          
          myHistory.add(OrderModel(
            id: 'dummy-${date.millisecondsSinceEpoch}',
            customerName: customer.name,
            address: customer.address,
            phoneNumber: customer.phoneNumber,
            receptionDate: date,
            deliveryDate: date,
            deliveryTime: '12:00',
            deliveryType: '配送',
            items: [{'name': menuName, 'price': 1000, 'quantity': qty}], 
            totalCount: qty,
            packagingType: '紙袋',
            paymentMethod: '不明',
          ));
        } catch (_) {}
      }
    }
    
    setState(() { 
      _isLoadingNotifier.value = false; 
      _currentCustomer = customer; 
      _customerOrderHistory = myHistory; 
      _companyOrderHistory = companyHistory; 
      _phoneController.text = _formatPhone(customer.phoneNumber); 
      _nameController.text = customer.name; 
      // 配達先情報は明示的に選択されるまで空にする
      _facilityController.clear();
      _addressController.clear();
      _deliveryLocationController.clear();
      _receiverController.clear();
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
    setState(() => _duplicateOrder = recent.isNotEmpty ? recent.first : null);
  }

  void _showOrderDetailsDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('過去の受注詳細'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailText('顧客名', '${order.customerName} 様'),
                _buildDetailText('企業・施設', order.facilityName.isEmpty ? '（なし）' : order.facilityName),
                _buildDetailText('配達日', "${order.deliveryDate.year}-${order.deliveryDate.month}-${order.deliveryDate.day}"),
                _buildDetailText('時間', order.deliveryTime),
                const Divider(),
                const Text('注文内容:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['name'] ?? ''),
                      Text('x${item['quantity']}'),
                    ],
                  ),
                )),
                const Divider(),
                _buildDetailText('合計個数', '${order.totalCount} 個'),
                _buildDetailText('支払方法', order.paymentMethod),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
        ],
      ),
    );
  }

  Widget _buildDetailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _showLocationAdjustmentDialog() async {
    final destMarker = _markers.any((m) => m.markerId.value == 'dest') 
        ? _markers.firstWhere((m) => m.markerId.value == 'dest') : null;
    final initialPos = destMarker?.position ?? _initialCenter;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => KLocationAdjustmentDialog(
        initialPosition: initialPos,
        initialAddress: _addressController.text,
        getAddressFromLatLng: (pos) => _customerService.getGoogleMapsService().getAddressFromLatLng(pos),
      ),
    );

    if (result != null) {
      final pos = result['position'] as LatLng;
      final imageUrl = result['staticImageUrl'] as String;
      
      await _onMapPositionAdjusted(pos);
      setState(() {
        _pendingStreetViewImageUrl = imageUrl;
      });
    }
  }

  Future<void> _onAddressSelectedFromList(String fullAddr) async {
    final parts = fullAddr.split(': ');
    final facilityNamePart = parts.length > 1 ? parts[0] : (fullAddr.startsWith('[') ? fullAddr.split(']')[0].replaceAll('[', '') : '名称なし');
    final addressOnlyPart = parts.length > 1 ? parts[1].split(' (')[0] : fullAddr.split(' (')[0].split(']').last.trim();

    // トグル動作: すでに選択されている場合は解除
    if (_facilityController.text == facilityNamePart && _addressController.text == addressOnlyPart) {
      setState(() {
        _facilityController.clear();
        _addressController.clear();
        _deliveryLocationController.clear();
        _receiverController.clear();
        _selectedHistoryItem = null;
        _markers = {
          Marker(
            markerId: const MarkerId('start'), 
            position: _branchCoordinates[_branchName] ?? _initialCenter, 
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
          )
        };
      });
      return;
    }

    final matchingOrder = _customerOrderHistory.followedBy(_companyOrderHistory).firstWhere((o) => o.facilityName == facilityNamePart || fullAddr.contains(o.address), orElse: () => OrderModel.empty());
    LatLng? pos = _parseCoordsFromAddress(fullAddr);
    if (pos == null || (pos.latitude == 0 && pos.longitude == 0)) {
      final latLng = await _customerService.getGoogleMapsService().getLatLngFromAddress("$facilityNamePart $addressOnlyPart");
      if (latLng != null) {
        pos = LatLng(latLng['lat']!, latLng['lng']!);
        final isApprox = latLng['location_type'] != 'ROOFTOP';
        
        setState(() {
          _isApproximateLocation = isApprox;
        });
      }
    } else {
      setState(() {
        _isApproximateLocation = false;
      });
    }

    setState(() { if (matchingOrder.id.isNotEmpty) _selectedHistoryItem = matchingOrder; if (pos != null) _updateMap(pos, facilityNamePart); _addressController.text = addressOnlyPart; _facilityController.text = facilityNamePart; if (matchingOrder.id.isNotEmpty) { _receiverController.text = matchingOrder.receiverName; _deliveryLocationController.text = matchingOrder.deliveryLocation; } });
  }

  LatLng? _parseCoordsFromAddress(String fullAddr) {
    final matches = RegExp(r'[(（]([-+]?\d*\.?\d+),\s*([-+]?\d*\.?\d+)[)）]').allMatches(fullAddr);
    if (matches.isNotEmpty) { try { return LatLng(double.parse(matches.last.group(1)!), double.parse(matches.last.group(2)!)); } catch (_) {} }
    return null;
  }

  Future<void> _onMapPositionAdjusted(LatLng position) async {
    // 住所の逆引きを実行
    final newAddress = await _customerService.getGoogleMapsService().getAddressFromLatLng(position);

    setState(() {
      _isApproximateLocation = false; // 手動調整されたため警告解除
      if (newAddress != null) {
        _addressController.text = newAddress;
      }
      
      final destMarker = Marker(
        markerId: const MarkerId('dest'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: _facilityController.text.isNotEmpty ? _facilityController.text : '指定地点'),
        draggable: true,
        onDragEnd: _onMapPositionAdjusted,
      );

      _markers = _markers.where((m) => m.markerId.value != 'dest').toSet()..add(destMarker);
    });
  }

  void _updateMap(LatLng position, String title) {
    final start = _branchCoordinates[_branchName] ?? _initialCenter;
    setState(() { 
      _markers = { 
        Marker(markerId: const MarkerId('start'), position: start, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), infoWindow: InfoWindow(title: _branchName)), 
        Marker(markerId: const MarkerId('dest'), position: position, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), infoWindow: InfoWindow(title: title)) 
      }; 
    });
    
    // レイアウト確定後に実行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitMapToMarkers();
    });
  }

  void _fitMapToMarkers() {
    if (!mounted || _mapController == null || _markers.isEmpty || _isSearchResultsDialogOpen) return;

    try {
      if (_markers.length == 1) {
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_markers.first.position, 15.0));
        return;
      }

      double minLat = 90.0;
      double maxLat = -90.0;
      double minLng = 180.0;
      double maxLng = -180.0;

      for (final marker in _markers) {
        if (marker.position.latitude < minLat) minLat = marker.position.latitude;
        if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
        if (marker.position.longitude < minLng) minLng = marker.position.longitude;
        if (marker.position.longitude > maxLng) maxLng = marker.position.longitude;
      }

      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80.0, // padding
      ));
    } catch (e) {
      debugPrint('GoogleMapController Error in _fitMapToMarkers: $e');
    }
  }

  Future<void> _onSearchSubmit({bool forceApi = false, bool ignoreFilter = false}) async {
    _isLoadingNotifier.value = true;
    _facilityResultsNotifier.value = [];
    List<Map<String, dynamic>> results = [];
    
    if (_searchTabIndex == 0 || _searchTabIndex == 1) {
      // 1. ローカルDBまたはカスタムサービスからの検索
      if (!forceApi && !ignoreFilter) {
        results = _searchTabIndex == 0 
          ? await _customerService.getAddressService().searchByLocationAndCategory(prefecture: _searchPrefecture, city: _searchCity, town: _searchTown, category: _searchCategory!, genre: _searchGenre!) 
          : await _customerService.getAddressService().searchByLocationAndKeyword(prefecture: _searchPrefecture, city: _searchCity, town: _searchTown, keyword: _keywordQueryController.text);
      }
      
      // 2. Google Maps API または フィルタリングが必要な場合
      if (results.isEmpty || forceApi || ignoreFilter) {
        // ジャンルに関連するキーワードを取得 (コンビニなら「セブン」「ローソン」等)
        final List<String> genreKeywords = (_searchTabIndex == 0 && _searchCategory != null && _searchGenre != null)
            ? (AddressConstants.categoryHierarchy[_searchCategory]?[_searchGenre] ?? [])
            : [];

        final kw = _combinedSearchController.text.trim();
        if (kw.isEmpty) { _isLoadingNotifier.value = false; return; }
        
        final raw = await _customerService.getGoogleMapsService().searchPlacesByText(kw, location: _branchCoordinates[_branchName]);
        
        final nC = _normalize(_searchCity);
        final nT = _normalize(_searchTown == '（すべて）' ? '' : _searchTown);
        final nP = _normalize(_searchPrefecture);

        // 各結果にエリア判定タグを付与
        final processed = raw.map((item) {
          final nA = _normalize(item['address'] ?? '');
          final nN = _normalize(item['name'] ?? '');
          
          // 指定地域内かどうかの判定
          bool isMatch = (nA.contains(nC) || nN.contains(nC)) && 
                         (nA.contains('都') || nA.contains('道') || nA.contains('府') || nA.contains('県') ? nA.contains(nP) : true) && 
                         (nT.isEmpty || nA.contains(nT) || nN.contains(nT));
          
          // ジャンルキーワードとの一致確認 (コンビニ検索なのにスーパーが出るのを防ぐ)
          bool matchesGenre = genreKeywords.isEmpty || 
                              genreKeywords.any((k) => nN.contains(_normalize(k)) || nA.contains(_normalize(k)));

          return {
            ...item,
            'isNearby': !isMatch,
            'matchesGenre': matchesGenre,
          };
        }).toList();

        // フィルタリング戦略: 
        // 1. 指定地域内で、かつジャンルに合致するものを最優先
        // 2. 指定地域付近（Nearby）でも、ジャンルに合致するものを優先 (コンビニ優先!)
        // 3. なければ、指定地域内の全候補
        // 4. 最後はGoogle検索の全候補
        
        final inAreaMatchGenre = processed.where((i) => !i['isNearby'] && i['matchesGenre']).toList();
        final nearbyMatchGenre = processed.where((i) => i['isNearby'] && i['matchesGenre']).toList();
        final inAreaAll = processed.where((i) => !i['isNearby']).toList();

        if (inAreaMatchGenre.isNotEmpty && !ignoreFilter) {
          results = inAreaMatchGenre;
        } else if (nearbyMatchGenre.isNotEmpty && !ignoreFilter) {
          results = nearbyMatchGenre;
        } else if (inAreaAll.isNotEmpty && !ignoreFilter) {
          results = inAreaAll;
        } else {
          results = processed;
        }
        
        for (var i in results) {
          await _customerService.getAddressService().upsertKigyouEntity(
            name: i['name'], 
            address: i['address'], 
            lat: i['lat'], 
            lng: i['lng'],
            prefecture: _searchPrefecture,
            city: _searchCity,
          );
        }
      }
    } else if (_searchTabIndex == 2) {
      // 住所・郵便番号
      final raw = await _customerService.getAddressService().searchByAddressOrZip(_addressQueryController.text);
      results = raw.map((i) => {...i, 'isNearby': false}).toList();
    }
    
    // 結果の反映
    _isLoadingNotifier.value = false;
    _facilityResultsNotifier.value = List.from(results); // 確実にリビルドを走らせる
  }

  String _normalize(String i) => i.replaceAll(RegExp(r'[ 　〒()（）.]'), '').replaceAll('１', '1').replaceAll('２', '2').replaceAll('３', '3').replaceAll('４', '4').replaceAll('５', '5').replaceAll('６', '6').replaceAll('７', '7').replaceAll('８', '8').replaceAll('９', '9').replaceAll('０', '0');
  double _calculateRiceAmount() => _confirmedItems.fold(0, (sum, i) => sum + (i['quantity'] as int)) * 0.15 * ((_deliveryDate.month >= 6 && _deliveryDate.month <= 9) ? 1.15 : ((_deliveryDate.month >= 12 || _deliveryDate.month <= 2) ? 1.25 : 1.0));
  int get _totalCount => _confirmedItems.fold(0, (s, i) => s + (i['quantity'] as int));
  int get _totalPrice => _confirmedItems.fold(0, (s, i) => s + (i['price'] as int) * (i['quantity'] as int));

  Future<void> _handleSave() async {
    setState(() => _isLoadingNotifier.value = true);

    String? imageUrl;
    if (_pendingStreetViewImageUrl != null) {
      try {
        final response = await http.get(Uri.parse(_pendingStreetViewImageUrl!));
        if (response.statusCode == 200) {
          final orderId = widget.initialOrder?.id ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}';
          final storageRef = FirebaseStorage.instance.ref().child('delivery_destinations/$orderId.jpg');
          await storageRef.putData(response.bodyBytes);
          imageUrl = await storageRef.getDownloadURL();
        }
      } catch (e) {
        debugPrint('Street View Image Upload Error: $e');
      }
    }

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
      remarks: _remarksController.text,
      deliveryDestinationImageUrl: imageUrl ?? widget.initialOrder?.deliveryDestinationImageUrl,
    );
    
    // 注文確定時に配達先情報と受取人履歴を顧客マスターへ登録
    if (_currentCustomer != null) {
      bool customerUpdated = false;
      Customer updatedCustomer = _currentCustomer!;

      // 1. 住所・座標の登録
      if (_addressController.text.isNotEmpty) {
        final destMarker = _markers.any((m) => m.markerId.value == 'dest') 
            ? _markers.firstWhere((m) => m.markerId.value == 'dest') : null;
        if (destMarker != null) {
          String displayEntry = "${_facilityController.text}: ${_addressController.text} (${destMarker.position.latitude}, ${destMarker.position.longitude})";
          if (imageUrl != null) displayEntry += " [IMG:$imageUrl]";
          
          final exists = updatedCustomer.deliveryAddresses.any((a) => a.contains(_addressController.text));
          if (!exists) {
            final newList = List<String>.from(updatedCustomer.deliveryAddresses)..add(displayEntry);
            updatedCustomer = updatedCustomer.copyWith(deliveryAddresses: newList);
            customerUpdated = true;
          }
        }
      }

      // 2. 受取人履歴の登録
      if (_receiverController.text.isNotEmpty && _facilityController.text.isNotEmpty) {
        final facility = _facilityController.text;
        final receiver = _receiverController.text;
        final currentReceivers = List<String>.from(updatedCustomer.facilityReceivers[facility] ?? []);
        if (!currentReceivers.contains(receiver)) {
          currentReceivers.add(receiver);
          final newMap = Map<String, List<String>>.from(updatedCustomer.facilityReceivers);
          newMap[facility] = currentReceivers;
          updatedCustomer = updatedCustomer.copyWith(facilityReceivers: newMap);
          customerUpdated = true;
        }
      }

      if (customerUpdated) {
        await _customerService.updateCustomer(updatedCustomer);
      }
    }

    await _orderService.saveOrder(order); 
    setState(() => _isLoadingNotifier.value = false);
    if (mounted) widget.onSaveSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          Expanded(
            flex: 62,
            child: Column(
              children: [
                KStepper(currentStep: _currentStep, steps: _stepLabels, onStepTapped: (s) { 
                  if (s < _currentStep) {
                    setState(() {
                      _currentStep = s;
                      if (s == 0) {
                        // 番号確認に戻る場合は入力した下4桁等を復元
                        _phoneController.text = _lastPhoneQuery;
                        _lookupCustomer(_lastPhoneQuery);
                      }
                    });
                  }
                }),
                // ステップ2 (配達先確定) のみ重複警告を表示
                if (_duplicateOrder != null && _currentStep == 2) _buildDuplicateAlert(),
                Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: _buildStepContent())),
              ],
            ),
          ),
          OrderFormSidebar(
            currentStep: _currentStep, 
            phoneController: _phoneController, 
            isLoading: _isLoadingNotifier.value, 
            currentCustomer: _currentCustomer,
            allMenus: _menus,
            customerOrderHistory: _customerOrderHistory, 
            companyOrderHistory: _companyOrderHistory,
            facilitySearchCandidates: _facilityResultsNotifier.value, 
            selectedHistoryItem: _selectedHistoryItem, 
            deliveryDate: _deliveryDate, 
            selectedTime: _selectedTime, 
            customerName: _nameController.text, 
            facilityName: _facilityController.text,
            address: _addressController.text,
            deliveryLocation: _deliveryLocationController.text,
            receiverName: _receiverController.text, 
            totalPrice: _totalPrice, 
            totalCount: _totalCount, 
            markers: _markers, 
            initialCenter: _initialCenter, 
            onPhoneInput: (d) { _phoneController.text = _formatPhone((_phoneController.text + d).replaceAll(RegExp(r'[^0-9]'), '')); _lookupCustomer(_phoneController.text); }, 
            onPhoneClear: () { _phoneController.clear(); _lookupCustomer(''); }, 
            onPhoneBackspace: () { if (_phoneController.text.isNotEmpty) { final clean = _phoneController.text.replaceAll('-', ''); _phoneController.text = _formatPhone(clean.substring(0, clean.length - 1)); _lookupCustomer(_phoneController.text); } }, 
            onMapCreated: (c) {
              _mapController = c;
              _fitMapToMarkers(); // マップ生成直後（再表示時含む）にフィットさせる
            }, 
            onSidebarResultsClose: () => _facilityResultsNotifier.value = [], 
            onFacilitySelect: (f) async { 
              setState(() { _facilityController.text = f['name']; _addressController.text = f['address']; _facilityResultsNotifier.value = []; }); 
              LatLng? pos = (f['lat'] != null && f['lat'] != 0.0) ? LatLng(f['lat'], f['lng']) : null; 
              if (pos == null) { 
                final latLng = await _customerService.getGoogleMapsService().getLatLngFromAddress("${f['name']} ${f['address']}"); 
                if (latLng != null) { 
                  pos = LatLng(latLng['lat']!, latLng['lng']!); 
                  await _customerService.getAddressService().upsertKigyouEntity(name: f['name'], address: f['address'], lat: pos.latitude, lng: pos.longitude); 
                  
                  // 代表地点（ROOFTOP以外）の場合に精度フラグを更新
                  if (mounted) {
                    setState(() {
                      _isApproximateLocation = latLng['location_type'] != 'ROOFTOP';
                    });
                  }
                } 
              } 
              if (pos != null) _updateMap(pos, f['name']); 
            }, 
            onForceApiSearch: () => _onSearchSubmit(forceApi: true),
            onMapTap: _onMapPositionAdjusted,
            onMarkerDragEnd: _onMapPositionAdjusted,
            deliveryDestinationImageUrl: _pendingStreetViewImageUrl ?? widget.initialOrder?.deliveryDestinationImageUrl,
            isSearchResultsDialogOpen: _isSearchResultsDialogOpen,
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return PhoneConfirmStep(phoneController: _phoneController, isLoading: _isLoadingNotifier.value, candidates: _phoneSearchCandidates, currentCustomer: _currentCustomer, onNext: () => setState(() => _currentStep = 1), onSelectCustomer: _selectCustomer);
      case 1: return CustomerConfirmationStep(
          phoneController: _phoneController, 
          currentCustomer: _currentCustomer, 
          onNext: () => setState(() => _currentStep = 2), 
          onBack: () {
            setState(() {
              _currentStep = 0;
              _phoneController.text = _lastPhoneQuery;
              _lookupCustomer(_lastPhoneQuery);
            });
          }
      );
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
          isApproximateLocation: _isApproximateLocation,
          remarksController: _remarksController,
          facilityResultsListenable: _facilityResultsNotifier,
          isLoadingListenable: _isLoadingNotifier,
          onNext: () => setState(() => _currentStep = 3), 
          onModeToggle: (v) => setState(() => _isHistoryMode = v), 
          onHistoryCategoryChanged: (v) => setState(() => _selectedHistoryCategory = v), 
          onAddressSelected: _onAddressSelectedFromList, 
          onSearchTabChanged: (v) { setState(() => _searchTabIndex = v); _syncSearchQuery(); }, 
          onPrefChanged: (v) => _updateCityList(v, 'すべて'), 
          onCityChanged: (v) => _updateTownList(_searchPrefecture, v, 'すべて'), 
          onTownChanged: (v) { setState(() => _searchTown = v); _syncSearchQuery(); }, 
          onAddressConfirmed: _onAddressConfirmed,
          onPrefInitialChanged: _updatePrefList, 
          onCityInitialChanged: _updateCityList, 
          onTownInitialChanged: _updateTownList, 
          onCategoryChanged: (v) { setState(() { _searchCategory = v; _searchGenre = null; }); _syncSearchQuery(); }, 
          onGenreChanged: (v) { setState(() => _searchGenre = v); _syncSearchQuery(); }, 
          onSearchSubmit: _onSearchSubmit,
          onDialogVisibilityChanged: (v) => setState(() => _isSearchResultsDialogOpen = v),
          onAdjustTap: _showLocationAdjustmentDialog
      );
      case 3: return DeliveryTimeStep(
          deliveryDate: _deliveryDate, 
          deliveryType: _deliveryType, 
          selectedTime: _selectedTime, 
          timeMin: _timePickerMin,
          timeMax: _timePickerMax,
          timeInterval: _timePickerInterval,
          receiverController: _receiverController,
          currentCustomer: _currentCustomer,
          facilityName: _facilityController.text,
          onDateSelected: (v) => setState(() => _deliveryDate = v), 
          onTypeSelected: (v) => setState(() => _deliveryType = v), 
          onTimeSelected: (v) => setState(() => _selectedTime = v),
          onTimeSettingsChanged: (min, max, interval) {
            setState(() {
              _timePickerMin = min;
              _timePickerMax = max;
              _timePickerInterval = interval;
            });
          },
          onNext: () => setState(() => _currentStep = 4)
      );
      case 4: return ItemsSelectionStep(menus: _menus, confirmedItems: _confirmedItems, selectedQuantities: _selectedQuantities, riceAmount: _calculateRiceAmount(), packaging: _totalCount >= 20 ? 'ダンボール' : '紙袋', totalPrice: _totalPrice, onAddItem: (m) => setState(() { _selectedQuantities[m.id] = (_selectedQuantities[m.id] ?? 0) + 1; _confirmedItems = _menus.where((x) => (_selectedQuantities[x.id] ?? 0) > 0).map((x) => {'id': x.id, 'name': x.name, 'price': x.price, 'quantity': _selectedQuantities[x.id]}).toList(); }), onQuantityChanged: (id, v) => setState(() { _selectedQuantities[id] = v; _confirmedItems = _menus.where((x) => (_selectedQuantities[x.id] ?? 0) > 0).map((x) => {'id': x.id, 'name': x.name, 'price': x.price, 'quantity': _selectedQuantities[x.id]}).toList(); }), onNext: () => setState(() => _currentStep = 5));
      case 5: return FinalizeStep(branchName: _branchName, paymentMethod: _paymentMethod, collectContainer: _collectContainer, selectedReceiverId: _selectedReceiverId, staffList: _staffList, onBranchChanged: (v) { 
        setState(() => _branchName = v); 
        final m = _markers.where((x) => x.markerId.value == 'dest'); 
        if (m.isNotEmpty) {
          _updateMap(m.first.position, _facilityController.text);
        } else {
          _setInitialBranchMarker();
        }
      }, onPaymentChanged: (v) => setState(() => _paymentMethod = v), onCollectChanged: (v) => setState(() => _collectContainer = v), onReceiverChanged: (v) => setState(() => _selectedReceiverId = v), onSave: _handleSave);
      default: return Container();
    }
  }

  Widget _buildDuplicateAlert() {
    return InkWell(
      onTap: () => _showOrderDetailsDialog(_duplicateOrder!),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '⚠️ 重複警告: 3日以内に同住所で注文があります\n企業名：${_duplicateOrder!.facilityName}　顧客名：${_duplicateOrder!.customerName} 様',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.red),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController = null;
    _phoneController.dispose();
    _nameController.dispose();
    _receiverController.dispose();
    _facilityController.dispose();
    _addressController.dispose();
    _deliveryLocationController.dispose();
    _addressQueryController.dispose();
    _keywordQueryController.dispose();
    _combinedSearchController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}
