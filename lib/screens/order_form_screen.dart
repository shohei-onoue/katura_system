import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/customer_model.dart';
import '../models/menu_model.dart';
import '../models/order_model.dart';
import '../services/customer_service.dart';
import '../services/menu_service.dart';
import '../services/staff_service.dart';
import '../services/order_service.dart';
import '../services/branch_service.dart';
import '../services/sms_service.dart';
import '../widgets/k_stepper.dart';
import '../widgets/k_location_adjustment_dialog.dart';
import '../widgets/k_branch_select_dialog.dart';
import '../widgets/k_receipt_preview_dialog.dart';
import 'order_form/widgets/step_widgets.dart';
import 'order_form/widgets/order_form_sidebar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import '../widgets/k_responsive.dart';

class OrderFormScreen extends StatefulWidget {
  final OrderModel? initialOrder;
  final VoidCallback? onSaveSuccess;
  final VoidCallback? onCancel;

  const OrderFormScreen({super.key, this.initialOrder, this.onSaveSuccess, this.onCancel});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _customerService = CustomerService();
  final _menuService = MenuService();
  final _staffService = StaffService();
  final _orderService = OrderService();
  final _branchService = BranchService();
  
  final _phoneController = TextEditingController();
  final _phonePrefixController = TextEditingController();
  bool _isCompletingPhone = false;
  final _nameController = TextEditingController();
  final _furiganaController = TextEditingController();
  final _receiverController = TextEditingController();
  final _facilityController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliveryLocationController = TextEditingController();
  final _addressQueryController = TextEditingController();
  final _keywordQueryController = TextEditingController();
  final _combinedSearchController = TextEditingController();
  final _remarksController = TextEditingController();
  final _trashPickupLocationController = TextEditingController();
  final _orderSourceOtherController = TextEditingController();
  final _packagingOtherController = TextEditingController();

  int _currentStep = 0;
  int _maxStepReached = 0;
  DateTime _receptionDate = DateTime.now();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 1));
  String _deliveryType = '配送';
  DateTime _selectedTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 0);
  
  int _timePickerInterval = 15;
  TimeOfDay _timePickerMin = const TimeOfDay(hour: 11, minute: 0);
  TimeOfDay _timePickerMax = const TimeOfDay(hour: 12, minute: 0);

  // ゴミ回収用
  int _trashTimePickerInterval = 15;
  TimeOfDay _trashTimePickerMin = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _trashTimePickerMax = const TimeOfDay(hour: 18, minute: 0);

  String _paymentMethod = '現金';
  String _branchName = '岡崎本店';
  Customer? _currentCustomer;

  // 追加項目：受注区分・梱包・ゴミ・お茶・事前確認
  String _orderSource = '直取';
  String _packagingType = '紙袋';
  int _packagingSmallQty = 0;
  bool _trashPickupRequested = false;
  DateTime? _trashPickupDateTime;
  String _trashPickupLocation = '引渡し場所';
  String _teaOption = 'なし';
  int _teaQuantity = 0;
  String _preConfirmationMethod = 'SMS';
  String _preConfirmationPhoneType = 'この電話番号';
  String _preConfirmationPhoneNumber = '';
  DateTime? _preConfirmationDateTime;
  String _preConfirmationSmsTime = '09:00';
  String _preConfirmationCallbackPhone = ''; // 設定画面で登録する事前連絡（電話）用の折り返し番号
  DateTime? _scheduledSmsDateTime; // 追加
  final _preConfirmationPhoneController = TextEditingController();
  final _preConfirmationRecipientController = TextEditingController();

  List<Customer> _phoneSearchCandidates = [];
  List<OrderModel> _customerOrderHistory = [];
  List<OrderModel> _companyOrderHistory = [];
  OrderModel? _selectedHistoryItem;
  List<MenuModel> _menus = [];
  final Map<String, int> _selectedQuantities = {};
  List<Map<String, dynamic>> _confirmedItems = [];
  final _isLoadingNotifier = ValueNotifier<bool>(false);
  final _facilityResultsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  bool _isSearchResultsDialogOpen = false;
  bool _isHistoryMode = true;
  // 履歴カードは手動タップされるまで未選択。タップ時に右端チェックアイコン座標を保持し配達元メニューの展開起点にする
  bool _historyManuallySelected = false;
  Offset? _pendingBranchAnchor;
  String _selectedHistoryCategory = 'すべて';
  String _lastPhoneQuery = '';

  int _searchTabIndex = 0;
  String _searchPrefecture = '';
  String _searchCity = '';
  String _searchTown = '（すべて）';
  String _searchPrefInitial = 'すべて';
  String _searchCityInitial = 'すべて';
  String _searchTownInitial = 'すべて';
  String? _searchCategory;
  String? _searchGenre;
  bool _isApproximateLocation = false;
  String? _pendingStreetViewImageUrl;
  // 直近に選択した検索結果／履歴の施設名・住所・座標（座標調整ダイヤログへ正確に渡すため保持）
  String _selectedFacilityName = '';
  String _selectedFacilityAddress = '';
  LatLng? _selectedDestPos;
  List<String> _prefList = [];
  List<String> _cityList = [];
  List<String> _townList = [];

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  String? _estimatedDeliveryDuration;
  static const LatLng _initialCenter = LatLng(34.9563, 137.1685);
  Map<String, LatLng> _branchCoordinates = {};
  final List<String> _stepLabels = ['番号確認', '顧客確認', '配達先の確定', '配達日時', '注文内容', '支払・完了'];

  bool _isDeliveryDateSelected = true;
  bool _isDeliveryTimeSelected = true;
  bool _isDeliveryTypeSelected = true;

  // 受注一覧の受注カード「編集」から遷移してきた場合 true
  bool get _isEditingOrder => widget.initialOrder != null;

  @override
  void initState() {
    super.initState();
    _keywordQueryController.addListener(_syncSearchQuery);
    _receiverController.addListener(() => setState(() {}));
    _trashPickupLocationController.addListener(() => setState(() {}));
    _preConfirmationRecipientController.addListener(() {
      if (!mounted) return;
      if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      } else {
        setState(() {});
      }
    });
    _loadData().then((_) {
      if (widget.initialOrder != null) {
        _populateForm(widget.initialOrder!);
      } else {
        _setInitialBranchMarker();
      }
      _loadGlobalSmsSettings(); // グローバル設定の読み込み
    });
  }

  Future<void> _loadGlobalSmsSettings() async {
    try {
      final doc = await FirebaseFirestore.instanceFor(
        app: Firebase.app(), 
        databaseId: 'katura-system-database'
      ).collection('settings').doc('sms_config').get();
      
      if (doc.exists) {
        setState(() {
          _preConfirmationSmsTime = doc.data()?['sendingTime'] ?? '09:00';
          _preConfirmationCallbackPhone = doc.data()?['preConfirmationCallbackPhone'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading SMS settings: $e');
    }
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
    await _staffService.getAllStaff();
    final branches = await _branchService.getAllBranches();
    final prefs = await _customerService.getAddressService().getPrefecturesByInitial(_searchPrefInitial);
    final cities = await _customerService.getAddressService().getCitiesByInitial(_searchPrefecture, _searchCityInitial);
    final towns = await _customerService.getAddressService().getTownsByInitial(_searchPrefecture, _searchCity, _searchTownInitial);
    if (mounted) {
      setState(() {
        _menus = menus; _prefList = prefs; _cityList = cities; _townList = ['（すべて）', ...towns];
        if (branches.isNotEmpty) {
          _branchCoordinates = {for (final b in branches) b.name: LatLng(b.latitude, b.longitude)};
          if (!_branchCoordinates.containsKey(_branchName)) _branchName = _branchCoordinates.keys.first;
        }
        if (_searchPrefecture.isNotEmpty && !_prefList.contains(_searchPrefecture)) _searchPrefecture = _prefList.isNotEmpty ? _prefList.first : ''; if (_searchCity.isNotEmpty && !_cityList.contains(_searchCity)) _searchCity = _cityList.isNotEmpty ? _cityList.first : ''; _searchTown = '（すべて）';
      });
    }
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
      _searchCity = ''; 
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
      _searchTown = '（すべて）'; 
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
    final town = (_searchTown == '（すべて）' || _searchTown.isEmpty) ? '' : _searchTown;
    final area = '$_searchPrefecture$_searchCity$town';
    String suffix = _searchTabIndex == 0 ? (_searchGenre ?? '') : (_searchTabIndex == 1 ? _keywordQueryController.text : '');
    _combinedSearchController.text = '$area $suffix'.trim();
  }

  void _populateForm(OrderModel order) {
    setState(() {
      _phoneController.text = order.phoneNumber; 
      _nameController.text = order.customerName; 
      _receiverController.text = order.receiverName;
      _facilityController.text = order.facilityName;
      _addressController.text = order.address;
      _selectedFacilityName = order.facilityName;
      _selectedFacilityAddress = order.address;
      _selectedDestPos = null;
      _deliveryLocationController.text = order.deliveryLocation;
      _deliveryDate = order.deliveryDate; 
      _receptionDate = order.receptionDate; 
      _deliveryType = order.deliveryType; 
      _paymentMethod = order.paymentMethod; 
      _branchName = order.branchName;
      
      _orderSource = order.orderSource;
      _orderSourceOtherController.text = order.orderSourceOther;
      _packagingType = order.packagingType;
      _packagingSmallQty = order.packagingSmallQty;
      _packagingOtherController.text = order.packagingOther;
      _trashPickupRequested = order.trashPickupRequested;
      _trashPickupDateTime = order.trashPickupDateTime;
      _trashPickupLocation = order.trashPickupLocation;
      _trashPickupLocationController.text = order.trashPickupLocationDetail;
      _teaOption = order.teaOption;
      _teaQuantity = order.teaQuantity;
      _preConfirmationMethod = order.preConfirmationMethod;
      _preConfirmationPhoneType = order.preConfirmationPhoneType;
      _preConfirmationPhoneNumber = order.preConfirmationPhoneNumber;
      _preConfirmationPhoneController.text = order.preConfirmationPhoneNumber;
      _preConfirmationDateTime = order.preConfirmationDateTime;
      _preConfirmationSmsTime = order.preConfirmationSmsTime;

      final timeParts = order.deliveryTime.split(':'); if (timeParts.length == 2) _selectedTime = DateTime(2024, 1, 1, int.parse(timeParts[0]), int.parse(timeParts[1]));
      _selectedQuantities.clear(); for (var item in order.items) { _selectedQuantities[item['id']] = item['quantity']; }
      _confirmedItems = List.from(order.items);
      _isDeliveryDateSelected = true;
      _isDeliveryTimeSelected = true;
      _isDeliveryTypeSelected = true;
      // 受注一覧からの編集は「配達日時」ステップから開始
      _currentStep = 3;
      _maxStepReached = _stepLabels.length - 1;
    });
    final coords = _parseCoordsFromAddress(order.address);
    if (coords != null && coords.latitude != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _updateMap(coords, order.facilityName.isEmpty ? '配送先' : order.facilityName, promptBranch: false);
      });
    }
  }

  /// キャンセル／中止ボタン用：確認ダイヤログを挟んでからフォームを破棄する
  Future<void> _confirmCancelOrder() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(_isEditingOrder ? '編集を中止しますか？' : '注文入力を中止しますか？'),
        content: const Text('入力中の内容は破棄されます。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('戻る')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('中止する'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) _resetForm();
  }

  void _resetForm() {
    setState(() {
      _phoneController.clear();
      _phonePrefixController.clear();
      _isCompletingPhone = false;
      _nameController.clear();
      _furiganaController.clear();
      _receiverController.clear();
      _facilityController.clear();
      _addressController.clear();
      _selectedFacilityName = '';
      _selectedFacilityAddress = '';
      _selectedDestPos = null;
      _historyManuallySelected = false;
      _pendingBranchAnchor = null;
      _deliveryLocationController.clear();
      _remarksController.clear();
      _trashPickupLocationController.clear();
      _orderSourceOtherController.clear();
      _packagingOtherController.clear();
      _preConfirmationPhoneController.clear();
      _preConfirmationRecipientController.clear();
      _currentStep = 0;
      _maxStepReached = 0;
      _currentCustomer = null;
      _confirmedItems = [];
      _selectedQuantities.clear();
      _customerOrderHistory = [];
      _companyOrderHistory = [];
      _trashPickupRequested = false;
      _isDeliveryDateSelected = false;
      _isDeliveryTimeSelected = false;
      _isDeliveryTypeSelected = false;
      _preConfirmationMethod = 'SMS';
      _preConfirmationPhoneType = 'この電話番号';
      _preConfirmationPhoneNumber = '';
      _preConfirmationDateTime = null;
      _preConfirmationSmsTime = '09:00';
      _scheduledSmsDateTime = null;
      _markers = {};
      _setInitialBranchMarker();
    });
    widget.onCancel?.call();
  }

  void _handlePhoneInput(String d) {
    if (_isCompletingPhone) {
      setState(() {
        _phonePrefixController.text += d;
      });
    } else {
      _phoneController.text = _formatPhone((_phoneController.text + d).replaceAll(RegExp(r'[^0-9]'), '')); 
      _lookupCustomer(_phoneController.text); 
    }
  }

  void _handlePhoneClear() {
    if (_isCompletingPhone) {
      setState(() {
        _phonePrefixController.clear();
      });
    } else {
      _phoneController.clear(); 
      _lookupCustomer(''); 
    }
  }

  void _handlePhoneBackspace() {
    if (_isCompletingPhone) {
      setState(() {
        if (_phonePrefixController.text.isNotEmpty) {
          _phonePrefixController.text = _phonePrefixController.text.substring(0, _phonePrefixController.text.length - 1);
        }
      });
    } else {
      if (_phoneController.text.isNotEmpty) { 
        final clean = _phoneController.text.replaceAll('-', ''); 
        _phoneController.text = _formatPhone(clean.substring(0, clean.length - 1)); 
        _lookupCustomer(_phoneController.text); 
      } 
    }
  }

  void _updateStep(int newStep) {
    if (newStep != 0) {
      _isCompletingPhone = false;
    }

    // ステップ遷移時のデータ同期
    if (newStep > _currentStep) {
      if (_currentStep == 1) {
        // ステップ1（顧客確認）から進む際、名前を受取人に反映
        if (_receiverController.text.isEmpty || 
            (_currentCustomer != null && _receiverController.text == _currentCustomer!.name) ||
            (_currentCustomer == null)) {
          _receiverController.text = _nameController.text;
        }
      }
    }

    setState(() {
      _currentStep = newStep;
      if (newStep > _maxStepReached) {
        _maxStepReached = newStep;
      }
    });
  }

  Future<void> _lookupCustomer(String phone) async {
    final cleanDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    _lastPhoneQuery = cleanDigits;
    if (cleanDigits.length >= 4) {
      _isLoadingNotifier.value = true;
      final candidates = await _customerService.searchByPhoneSuffix(cleanDigits);
      if (mounted) {
        if (candidates.length == 1 && cleanDigits.length >= 10) {
          _selectCustomer(candidates.first);
        } else {
          setState(() {
            _isLoadingNotifier.value = false;
            _phoneSearchCandidates = candidates;
            _currentCustomer = null;
            _nameController.clear();
            _furiganaController.clear();
            _facilityController.clear();
          });
        }
      }
      return;
    }
    setState(() {
      _currentCustomer = null;
      _phoneSearchCandidates = [];
      _isLoadingNotifier.value = false;
    });
  }

  void _selectCustomer(Customer customer) async {
    // 同一顧客の再選択ならフィールドをクリアせずステップ1へ
    if (_currentCustomer?.id == customer.id) {
      _updateStep(1);
      setState(() {
        _phoneController.text = _formatPhone(customer.phoneNumber);
      });
      return;
    }

    _isLoadingNotifier.value = true;
    final allOrders = await _orderService.getAllOrders();
    if (!mounted) return;
    
    final targetPhone = customer.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final normCustomerName = customer.name.replaceAll(RegExp(r'\s+'), '');
    final myHistory = allOrders.where((o) {
      final orderPhone = o.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final normOrderName = o.customerName.replaceAll(RegExp(r'\s+'), '');
      return orderPhone == targetPhone && normOrderName == normCustomerName;
    }).toList();
    
    final companyHistory = allOrders.where((o) {
      final isSelf = o.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '') == targetPhone && o.customerName.replaceAll(RegExp(r'\s+'), '') == normCustomerName;
      return o.facilityName == customer.companyName && !isSelf;
    }).toList();

    setState(() {
      _isLoadingNotifier.value = false;
      _currentCustomer = customer;
      _isCompletingPhone = false;
      _customerOrderHistory = myHistory;
      _companyOrderHistory = companyHistory;
      _phoneController.text = _formatPhone(customer.phoneNumber);
      _nameController.text = customer.name;
      _furiganaController.text = customer.furigana;
      _facilityController.clear();
      _addressController.clear();
      _selectedFacilityName = '';
      _selectedFacilityAddress = '';
      _selectedDestPos = null;
      _deliveryLocationController.clear();
      _receiverController.text = customer.name;
      // 所属企業の所在地のみにピンを表示する（配達元店舗のピンはこの段階では表示しない）
      if (customer.latitude != null && customer.longitude != null) {
        _markers = {
          Marker(
            markerId: const MarkerId('dest'),
            position: LatLng(customer.latitude!, customer.longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: customer.companyName.isNotEmpty ? customer.companyName : customer.name),
          ),
        };
      } else {
        _markers = {};
      }
      _updateStep(1);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitMapToMarkers();
    });
  }

  /// 顧客確認ステップ完了時の処理。
  /// 新規顧客の場合はこの時点で即座にCustomerを登録し、以降のステップ
  /// （配達先の確定「履歴から選択」等）に反映されるようにする。
  Future<void> _completeCustomerConfirmation() async {
    if (_currentCustomer == null && (_nameController.text.isNotEmpty || _furiganaController.text.isNotEmpty)) {
      _isLoadingNotifier.value = true;
      final destMarker = _markers.any((m) => m.markerId.value == 'dest') ? _markers.firstWhere((m) => m.markerId.value == 'dest') : null;
      final facility = _facilityController.text;
      final address = _addressController.text;
      final newCustomer = Customer(
        id: '',
        name: _nameController.text,
        furigana: _furiganaController.text,
        companyName: facility,
        phoneNumber: _phoneController.text,
        address: address,
        latitude: destMarker?.position.latitude,
        longitude: destMarker?.position.longitude,
        deliveryAddresses: (facility.isNotEmpty && address.isNotEmpty)
            ? ["$facility: $address (${destMarker?.position.latitude ?? 0}, ${destMarker?.position.longitude ?? 0})"]
            : [],
        facilityReceivers: (facility.isNotEmpty && _nameController.text.isNotEmpty)
            ? {facility: [_nameController.text]}
            : {},
      );
      final created = await _customerService.createCustomer(newCustomer);
      if (!mounted) return;
      setState(() {
        _currentCustomer = created;
        _isLoadingNotifier.value = false;
      });
    }
    _updateStep(2);
  }

  String _formatPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length == 11) return '${clean.substring(0, 3)}-${clean.substring(3, 7)}-${clean.substring(7)}';
    if (clean.length == 10) return '${clean.substring(0, 3)}-${clean.substring(3, 6)}-${clean.substring(6)}';
    return clean;
  }

  Future<void> _showLocationAdjustmentDialog() async {
    // Googleマップの検索フィールド／ピンには、選択した検索結果カードの施設名・住所・座標を優先して使う。
    final String namePart = _selectedFacilityName.trim().isNotEmpty
        ? _selectedFacilityName.trim()
        : _facilityController.text.trim();
    final String addrPart = _selectedFacilityAddress.trim().isNotEmpty
        ? _selectedFacilityAddress.trim()
        : _addressController.text.trim();
    String query = [namePart, addrPart].where((s) => s.isNotEmpty).join(' ').trim();
    if (query.isEmpty) query = _combinedSearchController.text.trim();

    final destMarker = _markers.any((m) => m.markerId.value == 'dest')
        ? _markers.firstWhere((m) => m.markerId.value == 'dest') : null;
    // カードが保持する座標 → destマーカー → （最後の手段）住所のみのジオコード。
    LatLng initialPos = _selectedDestPos ?? destMarker?.position ?? _initialCenter;
    if (_selectedDestPos == null && destMarker == null && addrPart.isNotEmpty) {
      final geo = await _customerService.getGoogleMapsService().getLatLngFromAddress(addrPart);
      if (geo != null) initialPos = LatLng(geo['lat'] as double, geo['lng'] as double);
    }

    if (!mounted) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => KLocationAdjustmentDialog(
        initialPosition: initialPos,
        initialAddress: query.isNotEmpty ? query : addrPart,
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

    if (_facilityController.text == facilityNamePart && _addressController.text == addressOnlyPart) {
      setState(() {
        _facilityController.clear();
        _addressController.clear();
        _deliveryLocationController.clear();
        _receiverController.clear();
        _selectedHistoryItem = null;
        _selectedFacilityName = '';
        _selectedFacilityAddress = '';
        _selectedDestPos = null;
        _pendingStreetViewImageUrl = null;
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

    // 選択直後に施設名・住所を確定保持（座標調整ダイヤログへ正確に渡すため）
    _selectedFacilityName = facilityNamePart;
    _selectedFacilityAddress = addressOnlyPart;

    // 履歴エントリに保存されたストリートビュー画像URL（[IMG:...]）があれば復元する
    final imgMatch = RegExp(r'\[IMG:([^\]]+)\]').firstMatch(fullAddr);
    _pendingStreetViewImageUrl = imgMatch?.group(1);

    final matchingOrder = _customerOrderHistory.followedBy(_companyOrderHistory).firstWhere((o) => o.facilityName == facilityNamePart || fullAddr.contains(o.address), orElse: () => OrderModel.empty());
    LatLng? pos = _parseCoordsFromAddress(fullAddr);
    if (pos == null || (pos.latitude == 0 && pos.longitude == 0)) {
      // 施設名を含めると誤マッチしやすいため住所のみでジオコードする
      final latLng = await _customerService.getGoogleMapsService().getLatLngFromAddress(addressOnlyPart);
      if (latLng != null) {
        pos = LatLng(latLng['lat']!, latLng['lng']!);
        setState(() {
          _isApproximateLocation = latLng['location_type'] != 'ROOFTOP';
        });
      }
    } else {
      setState(() {
        _isApproximateLocation = false;
      });
    }
    _selectedDestPos = pos;

    final Offset? branchAnchor = _pendingBranchAnchor;
    _pendingBranchAnchor = null;
    setState(() { if (matchingOrder.id.isNotEmpty) _selectedHistoryItem = matchingOrder; if (pos != null) _updateMap(pos, facilityNamePart, branchAnchor: branchAnchor); _addressController.text = addressOnlyPart; _facilityController.text = facilityNamePart; if (matchingOrder.id.isNotEmpty) { _receiverController.text = matchingOrder.receiverName; _deliveryLocationController.text = matchingOrder.deliveryLocation; } });
  }

  LatLng? _parseCoordsFromAddress(String fullAddr) {
    final matches = RegExp(r'[(（]([-+]?\d*\.?\d+),\s*([-+]?\d*\.?\d+)[)）]').allMatches(fullAddr);
    if (matches.isNotEmpty) { try { return LatLng(double.parse(matches.last.group(1)!), double.parse(matches.last.group(2)!)); } catch (_) {} }
    return null;
  }

  Future<void> _onMapPositionAdjusted(LatLng position) async {
    final newAddress = await _customerService.getGoogleMapsService().getAddressFromLatLng(position);
    _selectedDestPos = position;
    if (newAddress != null) _selectedFacilityAddress = newAddress;
    setState(() {
      _isApproximateLocation = false;
      if (newAddress != null) _addressController.text = newAddress;
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
    _updateEstimatedDuration();
  }

  void _updateMap(LatLng position, String title, {bool promptBranch = true, Offset? branchAnchor}) {
    final start = _branchCoordinates[_branchName] ?? _initialCenter;
    setState(() {
      _markers = {
        Marker(markerId: const MarkerId('start'), position: start, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), infoWindow: InfoWindow(title: _branchName)),
        Marker(markerId: const MarkerId('dest'), position: position, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), infoWindow: InfoWindow(title: title))
      };
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitMapToMarkers();
    });
    _updateEstimatedDuration();
    // 新規顧客の登録ステップ（step 1）では配達元店舗の選択メニューは使用しない
    if (promptBranch && _currentStep != 1) _promptNearestBranchDialog(position, anchor: branchAnchor);
  }

  /// 配達先の座標に最も近い店舗をデフォルト選択したダイアログで配達元店舗を確定する
  Future<void> _promptNearestBranchDialog(LatLng destination, {Offset? anchor}) async {
    String nearest = _branchName;
    double minDist = double.infinity;
    _branchCoordinates.forEach((name, coord) {
      final d = _distanceMeters(coord, destination);
      if (d < minDist) {
        minDist = d;
        nearest = name;
      }
    });

    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (context) => KBranchSelectDialog(
        branches: _branchCoordinates.keys.toList(),
        initialSelected: nearest,
        anchor: anchor,
      ),
    );
    if (selected == null || !mounted || selected == _branchName) return;

    setState(() {
      _branchName = selected;
      _markers = _markers.where((m) => m.markerId.value != 'start').toSet()
        ..add(Marker(
          markerId: const MarkerId('start'),
          position: _branchCoordinates[selected] ?? _initialCenter,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: selected),
        ));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitMapToMarkers();
    });
    _updateEstimatedDuration();
  }

  double _distanceMeters(LatLng a, LatLng b) {
    const earthRadius = 6371000.0;
    final dLat = (b.latitude - a.latitude) * (pi / 180);
    final dLng = (b.longitude - a.longitude) * (pi / 180);
    final lat1 = a.latitude * (pi / 180);
    final lat2 = b.latitude * (pi / 180);
    final h = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    return 2 * earthRadius * asin(sqrt(h));
  }

  /// 配達元店舗から配達先までのナビ経路の予想所要時間を取得する
  Future<void> _updateEstimatedDuration() async {
    final start = _markers.any((m) => m.markerId.value == 'start') ? _markers.firstWhere((m) => m.markerId.value == 'start') : null;
    final dest = _markers.any((m) => m.markerId.value == 'dest') ? _markers.firstWhere((m) => m.markerId.value == 'dest') : null;
    if (start == null || dest == null) {
      if (mounted) setState(() => _estimatedDeliveryDuration = null);
      return;
    }
    final duration = await _customerService.getGoogleMapsService().getEstimatedDuration(start.position, dest.position);
    if (!mounted) return;
    setState(() => _estimatedDeliveryDuration = duration);
  }

  void _fitMapToMarkers() {
    if (!mounted || _mapController == null || _markers.isEmpty || _isSearchResultsDialogOpen) return;
    try {
      if (_markers.length == 1) {
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_markers.first.position, 15.0));
        return;
      }
      double minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;
      for (final marker in _markers) {
        if (marker.position.latitude < minLat) minLat = marker.position.latitude;
        if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
        if (marker.position.longitude < minLng) minLng = marker.position.longitude;
        if (marker.position.longitude > maxLng) maxLng = marker.position.longitude;
      }
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)), 80.0));
    } catch (e) {
      debugPrint('GoogleMapController Error: $e');
    }
  }

  Future<void> _onSearchSubmit({bool forceApi = false, bool ignoreFilter = false}) async {
    _isLoadingNotifier.value = true;
    _facilityResultsNotifier.value = [];
    List<Map<String, dynamic>> results = [];
    
    if (_searchTabIndex == 0 || _searchTabIndex == 1) {
      // 地域（都道府県・市区町村・町名）を住所、カテゴリ／キーワードを施設名・カテゴリとして
      // Google Maps テキスト検索を行う。ローカルDBの住所部分一致
      // （例: キーワード「寺」で住所に「寺」を含む企業がヒットする）は使用しない。
      {
        final hierarchy = await _customerService.getAddressService().getCategoryHierarchy();
        final List<String> genreKeywords = (_searchTabIndex == 0 && _searchCategory != null && _searchGenre != null)
          ? (hierarchy[_searchCategory]?[_searchGenre] ?? []) : [];

        final town = (_searchTown == '（すべて）' || _searchTown.isEmpty) ? '' : _searchTown;
        final String areaPart = '$_searchPrefecture$_searchCity$town'.trim();
        final String facilityTerm = (_searchTabIndex == 0 ? (_searchGenre ?? '') : _keywordQueryController.text).trim();
        final kw = '$areaPart $facilityTerm'.trim();

        if (areaPart.isEmpty || facilityTerm.isEmpty) { _isLoadingNotifier.value = false; return; }
        
        final raw = await _customerService.getGoogleMapsService().searchPlacesByText(kw, location: _branchCoordinates[_branchName]);
        
        final nC = _normalize(_searchCity), nT = _normalize(_searchTown == '（すべて）' ? '' : _searchTown), nP = _normalize(_searchPrefecture);
        
        final processed = raw.map((item) {
          final nA = _normalize(item['address'] ?? ''), nN = _normalize(item['name'] ?? '');
          bool isMatch = nA.contains(nP) || nA.contains(nC) || nN.contains(nC) || (nT.isNotEmpty && (nA.contains(nT) || nN.contains(nT)));
          bool matchesGenre = genreKeywords.isEmpty || genreKeywords.any((k) => nN.contains(_normalize(k)) || nA.contains(_normalize(k)));
          return { ...item, 'isNearby': !isMatch, 'matchesGenre': matchesGenre };
        }).toList();

        final List<Map<String, dynamic>> sortedResults = [];
        sortedResults.addAll(processed.where((i) => !i['isNearby'] && i['matchesGenre']));
        sortedResults.addAll(processed.where((i) => !i['isNearby'] && !i['matchesGenre']));
        sortedResults.addAll(processed.where((i) => i['isNearby'] && i['matchesGenre']));
        sortedResults.addAll(processed.where((i) => i['isNearby'] && !i['matchesGenre']));
        
        results = sortedResults;

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
      final raw = await _customerService.getAddressService().searchByAddressOrZip(_addressQueryController.text);
      results = raw.map((i) => {...i, 'isNearby': false}).toList();
    }
    _isLoadingNotifier.value = false;
    _facilityResultsNotifier.value = List.from(results);
  }

  String _normalize(String i) => i.replaceAll(RegExp(r'[ 　〒()（）.]'), '').replaceAll('１', '1').replaceAll('２', '2').replaceAll('３', '3').replaceAll('４', '4').replaceAll('５', '5').replaceAll('６', '6').replaceAll('７', '7').replaceAll('８', '8').replaceAll('９', '9').replaceAll('０', '0');
  double _calculateRiceAmount() => _confirmedItems.fold(0.0, (acc, i) => acc + (i['quantity'] as int)) * 0.15 * ((_deliveryDate.month >= 6 && _deliveryDate.month <= 9) ? 1.15 : ((_deliveryDate.month >= 12 || _deliveryDate.month <= 2) ? 1.25 : 1.0));
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
      } catch (e) { debugPrint('Street View Image Upload Error: $e'); }
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
      packagingType: _packagingType,
      packagingSmallQty: _packagingSmallQty,
      packagingOther: _packagingOtherController.text,
      orderSource: _orderSource,
      orderSourceOther: _orderSourceOtherController.text,
      trashPickupRequested: _trashPickupRequested,
      trashPickupDateTime: _trashPickupDateTime,
      trashPickupLocation: _trashPickupLocation,
      trashPickupLocationDetail: _trashPickupLocationController.text,
      teaOption: _teaOption,
      teaQuantity: _teaQuantity,
      preConfirmationMethod: _preConfirmationMethod,
      preConfirmationPhoneType: _preConfirmationPhoneType,
      preConfirmationPhoneNumber: _preConfirmationPhoneController.text,
      preConfirmationDateTime: _preConfirmationDateTime,
      preConfirmationSmsTime: _preConfirmationSmsTime,
      scheduledSmsDateTime: _scheduledSmsDateTime ?? _calculateScheduledSmsDateTime(),
      smsSent: false,
      paymentMethod: _paymentMethod, 
      status: '受注済み',
      branchName: _branchName, 
      remarks: _remarksController.text,
      deliveryDestinationImageUrl: imageUrl ?? widget.initialOrder?.deliveryDestinationImageUrl,
      latitude: _markers.any((m) => m.markerId.value == 'dest') 
          ? _markers.firstWhere((m) => m.markerId.value == 'dest').position.latitude : null,
      longitude: _markers.any((m) => m.markerId.value == 'dest') 
          ? _markers.firstWhere((m) => m.markerId.value == 'dest').position.longitude : null,
    );
    
    if (_currentCustomer != null) {
      bool customerUpdated = false;
      Customer updatedCustomer = _currentCustomer!;
      if (_addressController.text.isNotEmpty) {
        final destMarker = _markers.any((m) => m.markerId.value == 'dest') ? _markers.firstWhere((m) => m.markerId.value == 'dest') : null;
        // マップにピンが無い（＝手入力の新規配達先）場合も履歴登録できるよう座標はフォールバックする
        final double destLat = destMarker?.position.latitude ?? order.latitude ?? 0;
        final double destLng = destMarker?.position.longitude ?? order.longitude ?? 0;
        final idx = updatedCustomer.deliveryAddresses.indexWhere((a) => a.contains(_addressController.text));
        // 今回調整していなければ既存エントリのストリートビュー画像を引き継ぐ
        String? keepImg = imageUrl;
        if (keepImg == null && idx != -1) {
          keepImg = RegExp(r'\[IMG:([^\]]+)\]').firstMatch(updatedCustomer.deliveryAddresses[idx])?.group(1);
        }
        String displayEntry = "${_facilityController.text}: ${_addressController.text} ($destLat, $destLng)";
        if (keepImg != null) displayEntry += " [IMG:$keepImg]";
        final newList = List<String>.from(updatedCustomer.deliveryAddresses);
        if (idx == -1) {
          newList.add(displayEntry); // 新規配達先を履歴へ登録
          customerUpdated = true;
        } else if (newList[idx] != displayEntry) {
          newList[idx] = displayEntry; // 座標・画像を最新へ更新
          customerUpdated = true;
        }
        updatedCustomer = updatedCustomer.copyWith(deliveryAddresses: newList);
      }
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
      if (customerUpdated) await _customerService.updateCustomer(updatedCustomer);
    } else if (_nameController.text.isNotEmpty) {
      // 新規顧客として保存
      final destMarker = _markers.any((m) => m.markerId.value == 'dest') ? _markers.firstWhere((m) => m.markerId.value == 'dest') : null;
      final newCustomer = Customer(
        id: '',
        name: _nameController.text,
        furigana: _furiganaController.text,
        companyName: _facilityController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        latitude: destMarker?.position.latitude ?? 0,
        longitude: destMarker?.position.longitude ?? 0,
        deliveryAddresses: ["${_facilityController.text}: ${_addressController.text} (${destMarker?.position.latitude ?? 0}, ${destMarker?.position.longitude ?? 0})"],
        facilityReceivers: {_facilityController.text: [_nameController.text]},
      );
      await _customerService.createCustomer(newCustomer);
    }

    await _orderService.saveOrder(order);

    // 事前連絡が「電話」の場合、設定画面で登録した折り返し番号あてにSMSを送信する
    if (_preConfirmationMethod == '電話' && _preConfirmationCallbackPhone.trim().isNotEmpty) {
      await _sendPreConfirmationCallSms(order);
    }

    if (mounted) {
      setState(() => _isLoadingNotifier.value = false);
      widget.onSaveSuccess?.call();
    }
  }

  Future<void> _sendPreConfirmationCallSms(OrderModel order) async {
    final when = order.preConfirmationDateTime ?? order.deliveryDate;
    final target = _preConfirmationRecipientController.text.trim().isNotEmpty
        ? _preConfirmationRecipientController.text.trim()
        : (order.receiverName.isNotEmpty ? order.receiverName : order.customerName);
    final itemsText = order.items.map((i) => '・${i['name']} ${i['quantity']}個').join('\n');
    // リマインドSMSの送信先＝事前電話連絡を行う担当者の番号
    final staffPhone = _preConfirmationCallbackPhone.trim();
    // 本文に載せる「連絡すべき相手の番号」＝顧客の事前連絡先番号
    final callTo = order.preConfirmationPhoneType == '指定番号へ連絡'
        ? (order.preConfirmationPhoneNumber.isNotEmpty ? order.preConfirmationPhoneNumber : order.phoneNumber)
        : order.phoneNumber;
    final body = '${when.month}月${when.day}日${when.hour.toString().padLeft(2, '0')}時までに'
        '$targetさまへ事前電話連絡をしてください。\n'
        '連絡先電話番号：\n'
        '$callTo\n\n'
        '【ご注文内容】\n$itemsText\n'
        '【配達先情報】\n${order.facilityName} ${order.address}';
    try {
      await SmsService().sendPreConfirmationCall(to: staffPhone, body: body, orderId: order.id);
    } catch (e) {
      debugPrint('Pre-confirmation SMS enqueue error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: KR.backgroundLight,
      endDrawer: isMobile ? Drawer(
        width: screenWidth * 0.85,
        child: _buildSidebar(),
      ) : null,
      appBar: isMobile ? AppBar(
        title: Text(_stepLabels[_currentStep], style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ) : null,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: isMobile ? 100 : 62,
              child: Column(
                children: [
                KStepper(
                  currentStep: _currentStep,
                  maxReachedStep: _maxStepReached,
                  isFinalStepAvailable: _confirmedItems.isNotEmpty,
                  steps: _stepLabels,
                  onStepTapped: (s) {
                    // 受注内容(s=4)が確定している、または移動先が到達済みステップなら移動可能
                    bool isJumpableToFinal = _confirmedItems.isNotEmpty && s == 5;
                    if (s <= _maxStepReached || isJumpableToFinal) {
                      _updateStep(s);
                      if (s == 0) {
                        setState(() => _isCompletingPhone = false);
                        _phoneController.text = _lastPhoneQuery;
                        _lookupCustomer(_lastPhoneQuery);
                      }
                    }
                  }
                ),
                  Expanded(
                    child: _currentStep == 4
                        // 注文内容ステップ：タブ以上を固定し、メニュー一覧のみ内部スクロール
                        ? Padding(padding: EdgeInsets.all(rav(context, isMobile ? 12 : 24)), child: _buildStepContent())
                        : SingleChildScrollView(padding: EdgeInsets.all(rav(context, isMobile ? 12 : 24)), child: _buildStepContent()),
                  ),
                ],
              ),
            ),
            if (!isMobile)
              OrderFormSidebar(
                currentStep: _currentStep, 
                isCompletingPhone: _isCompletingPhone,
                phoneController: _isCompletingPhone ? _phonePrefixController : _phoneController, 
                isLoading: _isLoadingNotifier.value, 
                currentCustomer: _currentCustomer,
                allMenus: _menus,
                customerOrderHistory: _customerOrderHistory, 
                companyOrderHistory: _companyOrderHistory,
                facilitySearchCandidates: _facilityResultsNotifier.value, 
                selectedHistoryItem: _selectedHistoryItem, 
                deliveryType: _deliveryType,
                deliveryDate: _deliveryDate, 
                selectedTime: _selectedTime, 
                isDateSelected: _isDeliveryDateSelected,
                isTimeSelected: _isDeliveryTimeSelected,
                isTypeSelected: _isDeliveryTypeSelected,
                confirmedItems: _confirmedItems,
                onQuantityChanged: (indexOrId, v) => setState(() { 
                  final index = int.tryParse(indexOrId);
                  if (index != null && index < _confirmedItems.length) {
                    if (v > 0) {
                      _confirmedItems[index]['quantity'] = v;
                      _confirmedItems = List.from(_confirmedItems);
                    } else {
                      _confirmedItems = List.from(_confirmedItems)..removeAt(index);
                    }
                  } else {
                    final existingIdx = _confirmedItems.indexWhere((i) => i['id'] == indexOrId);
                    if (existingIdx != -1) {
                      if (v > 0) {
                        _confirmedItems[existingIdx]['quantity'] = v;
                        _confirmedItems = List.from(_confirmedItems);
                      } else {
                        _confirmedItems = List.from(_confirmedItems)..removeAt(existingIdx);
                      }
                    }
                  }
                  _selectedQuantities.clear();
                  for (var item in _confirmedItems) {
                    final String id = item['id'];
                    _selectedQuantities[id] = (_selectedQuantities[id] ?? 0) + (item['quantity'] as int);
                  }
                }),
                onNext: () {
                  if (_currentStep < 5) _updateStep(_currentStep + 1);
                },
                onReset: _resetForm,
                trashPickupRequested: _trashPickupRequested,
                trashPickupDateTime: _trashPickupDateTime,
                trashPickupLocation: _trashPickupLocation,
                trashPickupLocationDetail: _trashPickupLocationController.text,
                packagingType: _packagingType,
                packagingSmallQty: _packagingSmallQty,
                packagingOther: _packagingOtherController.text,
                preConfirmationMethod: _preConfirmationMethod,
                preConfirmationPhoneType: _preConfirmationPhoneType,
                preConfirmationPhoneNumber: _preConfirmationPhoneNumber,
                preConfirmationDateTime: _preConfirmationDateTime,
                preConfirmationSmsTime: _preConfirmationSmsTime,
                scheduledSmsDateTime: _scheduledSmsDateTime,
                phoneDisplay: _phoneController.text,
                paymentMethod: _paymentMethod,
                preConfirmationRecipient: _preConfirmationRecipientController.text,
                onShowInvoice: _showInvoicePreviewDialog,
                customerName: _nameController.text,
                facilityName: _facilityController.text,
                address: _addressController.text,
                deliveryLocation: _deliveryLocationController.text,
                receiverName: _receiverController.text, 
                totalPrice: _totalPrice, 
                totalCount: _totalCount, 
                markers: _markers, 
                initialCenter: _initialCenter, 
                onPhoneInput: _handlePhoneInput, 
                onPhoneClear: _handlePhoneClear, 
                onPhoneBackspace: _handlePhoneBackspace, 
                onMapCreated: (c) {
                  _mapController = c;
                  _fitMapToMarkers();
                }, 
                onSidebarResultsClose: () => _facilityResultsNotifier.value = [], 
                onFacilitySelect: (f) async {
                  setState(() { _facilityController.text = f['name']; _addressController.text = f['address']; _facilityResultsNotifier.value = []; });
                  _selectedFacilityName = f['name'];
                  _selectedFacilityAddress = f['address'];
                  LatLng? pos = (f['lat'] != null && f['lat'] != 0.0) ? LatLng(f['lat'], f['lng']) : null;
                  if (pos == null) {
                    final latLng = await _customerService.getGoogleMapsService().getLatLngFromAddress(f['address']);
                    if (latLng != null) {
                      pos = LatLng(latLng['lat']!, latLng['lng']!);
                      await _customerService.getAddressService().upsertKigyouEntity(name: f['name'], address: f['address'], lat: pos.latitude, lng: pos.longitude);
                      if (mounted) setState(() { _isApproximateLocation = latLng['location_type'] != 'ROOFTOP'; });
                    }
                  }
                  _selectedDestPos = pos;
                  if (pos != null) _updateMap(pos, f['name']);
                },
                onForceApiSearch: () => _onSearchSubmit(forceApi: true),
                onMapTap: _onMapPositionAdjusted,
                onMarkerDragEnd: _onMapPositionAdjusted,
                deliveryDestinationImageUrl: _pendingStreetViewImageUrl ?? widget.initialOrder?.deliveryDestinationImageUrl,
                estimatedDeliveryDuration: _estimatedDeliveryDuration,
                branchName: _branchName,
                isSearchResultsDialogOpen: _isSearchResultsDialogOpen,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return OrderFormSidebar(
      currentStep: _currentStep, 
      isCompletingPhone: _isCompletingPhone,
      phoneController: _isCompletingPhone ? _phonePrefixController : _phoneController, 
      isLoading: _isLoadingNotifier.value, 
      currentCustomer: _currentCustomer,
      allMenus: _menus,
      customerOrderHistory: _customerOrderHistory, 
      companyOrderHistory: _companyOrderHistory,
      facilitySearchCandidates: _facilityResultsNotifier.value, 
      selectedHistoryItem: _selectedHistoryItem, 
      deliveryType: _deliveryType,
      deliveryDate: _deliveryDate, 
      selectedTime: _selectedTime, 
      isDateSelected: _isDeliveryDateSelected,
      isTimeSelected: _isDeliveryTimeSelected,
      isTypeSelected: _isDeliveryTypeSelected,
      confirmedItems: _confirmedItems,
      onQuantityChanged: (indexOrId, v) => setState(() { 
        final index = int.tryParse(indexOrId);
        if (index != null && index < _confirmedItems.length) {
          if (v > 0) {
            _confirmedItems[index]['quantity'] = v;
            _confirmedItems = List.from(_confirmedItems);
          } else {
            _confirmedItems = List.from(_confirmedItems)..removeAt(index);
          }
        } else {
          final existingIdx = _confirmedItems.indexWhere((i) => i['id'] == indexOrId);
          if (existingIdx != -1) {
            if (v > 0) {
              _confirmedItems[existingIdx]['quantity'] = v;
              _confirmedItems = List.from(_confirmedItems);
            } else {
              _confirmedItems = List.from(_confirmedItems)..removeAt(existingIdx);
            }
          }
        }
        _selectedQuantities.clear();
        for (var item in _confirmedItems) {
          final String id = item['id'];
          _selectedQuantities[id] = (_selectedQuantities[id] ?? 0) + (item['quantity'] as int);
        }
      }),
      onNext: () {
        if (_currentStep < 5) _updateStep(_currentStep + 1);
      },
      onReset: _resetForm,
      trashPickupRequested: _trashPickupRequested,
      trashPickupDateTime: _trashPickupDateTime,
      trashPickupLocation: _trashPickupLocation,
      trashPickupLocationDetail: _trashPickupLocationController.text,
      packagingType: _packagingType,
      packagingSmallQty: _packagingSmallQty,
      packagingOther: _packagingOtherController.text,
      preConfirmationMethod: _preConfirmationMethod,
      preConfirmationPhoneType: _preConfirmationPhoneType,
      preConfirmationPhoneNumber: _preConfirmationPhoneNumber,
      preConfirmationDateTime: _preConfirmationDateTime,
      preConfirmationSmsTime: _preConfirmationSmsTime,
      scheduledSmsDateTime: _scheduledSmsDateTime,
      phoneDisplay: _phoneController.text,
      paymentMethod: _paymentMethod,
      preConfirmationRecipient: _preConfirmationRecipientController.text,
      onShowInvoice: _showInvoicePreviewDialog,
      customerName: _nameController.text,
      facilityName: _facilityController.text,
      address: _addressController.text,
      deliveryLocation: _deliveryLocationController.text,
      receiverName: _receiverController.text, 
      totalPrice: _totalPrice, 
      totalCount: _totalCount, 
      markers: _markers, 
      initialCenter: _initialCenter, 
      onPhoneInput: _handlePhoneInput, 
      onPhoneClear: _handlePhoneClear, 
      onPhoneBackspace: _handlePhoneBackspace, 
      onMapCreated: (c) {
        _mapController = c;
        _fitMapToMarkers();
      }, 
      onSidebarResultsClose: () => _facilityResultsNotifier.value = [], 
      onFacilitySelect: (f) async {
        setState(() { _facilityController.text = f['name']; _addressController.text = f['address']; _facilityResultsNotifier.value = []; });
        _selectedFacilityName = f['name'];
        _selectedFacilityAddress = f['address'];
        LatLng? pos = (f['lat'] != null && f['lat'] != 0.0) ? LatLng(f['lat'], f['lng']) : null;
        if (pos == null) {
          final latLng = await _customerService.getGoogleMapsService().getLatLngFromAddress(f['address']);
          if (latLng != null) {
            pos = LatLng(latLng['lat']!, latLng['lng']!);
            await _customerService.getAddressService().upsertKigyouEntity(name: f['name'], address: f['address'], lat: pos.latitude, lng: pos.longitude);
            if (mounted) setState(() { _isApproximateLocation = latLng['location_type'] != 'ROOFTOP'; });
          }
        }
        _selectedDestPos = pos;
        if (pos != null) _updateMap(pos, f['name']);
      },
      onForceApiSearch: () => _onSearchSubmit(forceApi: true),
      onMapTap: _onMapPositionAdjusted,
      onMarkerDragEnd: _onMapPositionAdjusted,
      deliveryDestinationImageUrl: _pendingStreetViewImageUrl ?? widget.initialOrder?.deliveryDestinationImageUrl,
      estimatedDeliveryDuration: _estimatedDeliveryDuration,
      branchName: _branchName,
      isSearchResultsDialogOpen: _isSearchResultsDialogOpen,
    );
  }

  Widget _buildStepContent() {
    final phoneDisplay = _phoneController.text;
    switch (_currentStep) {
      case 0: return PhoneConfirmStep(
          phoneController: _phoneController, 
          isLoading: _isLoadingNotifier.value, 
          candidates: _phoneSearchCandidates, 
          currentCustomer: _currentCustomer, 
          phoneDisplay: phoneDisplay, 
          isCompletingPhone: _isCompletingPhone,
          phonePrefixController: _phonePrefixController,
          onNext: () {
            if (!_isCompletingPhone && _currentCustomer == null) {
              setState(() {
                _isCompletingPhone = true;
              });
            } else {
              if (_isCompletingPhone) {
                final prefix = _phonePrefixController.text;
                final suffix = _phoneController.text;
                _phoneController.text = _formatPhone("$prefix$suffix");
                setState(() => _isCompletingPhone = false);
              }
              _updateStep(1);
            }
          }, 
          onSelectCustomer: _selectCustomer
      );
      case 1: return CustomerConfirmationStep(
          phoneController: _phoneController,
          nameController: _nameController,
          furiganaController: _furiganaController,
          companyController: _facilityController,
          currentCustomer: _currentCustomer,
          phoneDisplay: phoneDisplay,
          onNext: _completeCustomerConfirmation,
          onBack: () {
            setState(() {
              _currentStep = 0;
              _isCompletingPhone = false;
              _phoneController.text = _lastPhoneQuery;
              _lookupCustomer(_lastPhoneQuery);
            });
          },
          facilityControllerText: _facilityController.text,
          addressControllerText: _addressController.text,
          prefList: _prefList,
          searchPrefecture: _searchPrefecture,
          searchCity: _searchCity,
          searchTown: _searchTown,
          searchCategory: _searchCategory,
          searchGenre: _searchGenre,
          searchTabIndex: _searchTabIndex,
          isApproximateLocation: _isApproximateLocation,
          keywordQueryController: _keywordQueryController,
          facilityResultsListenable: _facilityResultsNotifier,
          isLoadingListenable: _isLoadingNotifier,
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
          onAdjustTap: _showLocationAdjustmentDialog,
          onCancelOrder: _confirmCancelOrder,
          isEditingOrder: _isEditingOrder,
      );
      case 2: return DeliveryDestinationStep(
          phoneNumberText: _phoneController.text,
          currentCustomer: _currentCustomer,
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
          onNext: () => _updateStep(3),
          onCancelOrder: _confirmCancelOrder,
          isEditingOrder: _isEditingOrder,
          onModeToggle: (v) => setState(() { _isHistoryMode = v; _historyManuallySelected = false; }),
          onHistoryCategoryChanged: (v) => setState(() => _selectedHistoryCategory = v),
          onAddressSelected: _onAddressSelectedFromList,
          historyManuallySelected: _historyManuallySelected,
          onBranchMenuAnchor: (o) => setState(() { _pendingBranchAnchor = o; _historyManuallySelected = true; }),
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
          phoneNumberText: _phoneController.text,
          deliveryDate: _deliveryDate,
          deliveryType: _deliveryType, 
          selectedTime: _selectedTime, 
          timeMin: _timePickerMin,
          timeMax: _timePickerMax,
          timeInterval: _timePickerInterval,
          isDateSelected: _isDeliveryDateSelected,
          isTimeSelected: _isDeliveryTimeSelected,
          isTypeSelected: _isDeliveryTypeSelected,
          receiverController: _receiverController,
          currentCustomer: _currentCustomer,
          customerName: _nameController.text,
          facilityName: _facilityController.text,
          orderSource: _orderSource,
          orderSourceOtherController: _orderSourceOtherController,
          onOrderSourceChanged: (v) => setState(() => _orderSource = v),
          trashPickupRequested: _trashPickupRequested,
          trashPickupDateTime: _trashPickupDateTime,
          trashPickupLocation: _trashPickupLocation,
          trashPickupLocationController: _trashPickupLocationController,
          trashTimeMin: _trashTimePickerMin,
          trashTimeMax: _trashTimePickerMax,
          trashTimeInterval: _trashTimePickerInterval,
          onTrashPickupRequestedChanged: (v) => setState(() => _trashPickupRequested = v),
          onTrashPickupDateTimeChanged: (v) => setState(() => _trashPickupDateTime = v),
          onTrashPickupLocationChanged: (v) => setState(() => _trashPickupLocation = v),
          onDateSelected: (v) => setState(() { _deliveryDate = v; _isDeliveryDateSelected = true; }), 
          onTypeSelected: (v) => setState(() { _deliveryType = v; _isDeliveryTypeSelected = true; }), 
          onTimeSelected: (v) => setState(() { _selectedTime = v; _isDeliveryTimeSelected = true; }),
          onTimeSettingsChanged: (min, max, interval) { setState(() { _timePickerMin = min; _timePickerMax = max; _timePickerInterval = interval; }); },
          onTrashTimeSettingsChanged: (min, max, interval) { setState(() { _trashTimePickerMin = min; _trashTimePickerMax = max; _trashTimePickerInterval = interval; }); },
          onNext: () => _updateStep(4),
          onCancelOrder: _confirmCancelOrder,
          isEditingOrder: _isEditingOrder,
      );
      case 4: return ItemsSelectionStep(
          phoneNumberText: _phoneController.text,
          menus: _menus,
          confirmedItems: _confirmedItems, 
          selectedQuantities: _selectedQuantities, 
          riceAmount: _calculateRiceAmount(), 
          packaging: _packagingType, 
          totalPrice: _totalPrice, 
          onAddItem: (itemsList) => setState(() {
            for (var newItem in itemsList) {
              final String id = newItem['id'];
              // 特注がないシンプルな追加の場合は、既存の同IDアイテム（特注なし）を削除してから追加（置換）
              if ((newItem['specialOrder'] as String? ?? '').isEmpty && (newItem['teaOption'] as String? ?? 'なし') == 'なし') {
                _confirmedItems.removeWhere((i) => i['id'] == id && (i['specialOrder'] as String? ?? '').isEmpty && (i['teaOption'] as String? ?? 'なし') == 'なし');
              }
            }
            _confirmedItems = List.from(_confirmedItems)..addAll(itemsList);
            
            // 数量マップを全再計算して整合性を保つ
            _selectedQuantities.clear();
            for (var item in _confirmedItems) {
              final String id = item['id'];
              _selectedQuantities[id] = (_selectedQuantities[id] ?? 0) + (item['quantity'] as int);
            }
          }), 
          onQuantityChanged: (id, v) => setState(() { 
            _selectedQuantities[id] = v;
            final index = _confirmedItems.indexWhere((i) => i['id'] == id);
            if (index != -1) {
              if (v > 0) {
                _confirmedItems[index]['quantity'] = v;
                _confirmedItems = List.from(_confirmedItems); // 参照を更新
              } else {
                _confirmedItems = List.from(_confirmedItems)..removeAt(index);
              }
            }
          }), 
          onReloadMenus: _loadData,
          onNext: () => _updateStep(5)
      );
      case 5: return FinalizeStep(
          branchName: _branchName,
          paymentMethod: _paymentMethod,
          preConfirmationRecipientController: _preConfirmationRecipientController,
          recipientHistory: _currentCustomer?.facilityReceivers[_facilityController.text] ?? const [],
          packagingType: _packagingType,
          packagingSmallQty: _packagingSmallQty,
          packagingOtherController: _packagingOtherController,
          preConfirmationMethod: _preConfirmationMethod,
          preConfirmationPhoneType: _preConfirmationPhoneType,
          preConfirmationPhoneNumber: _preConfirmationPhoneNumber,
          preConfirmationPhoneController: _preConfirmationPhoneController,
          preConfirmationDateTime: _preConfirmationDateTime,
          preConfirmationSmsTime: _preConfirmationSmsTime,
          scheduledSmsDateTime: _scheduledSmsDateTime,
          phoneDisplay: phoneDisplay,
          customerName: _nameController.text,
          receiverName: _receiverController.text,
          deliveryType: _deliveryType,
          deliveryDate: _deliveryDate,
          deliveryTime: "${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}",
          address: _addressController.text,
          items: _confirmedItems,
          totalPrice: _totalPrice,
          trashPickupDateTime: _trashPickupDateTime,
          trashPickupLocationDetail: _trashPickupLocationController.text,
          onPackagingTypeChanged: (v) => setState(() => _packagingType = v),
          onPackagingSmallQtyChanged: (v) => setState(() => _packagingSmallQty = v),
          onPaymentChanged: (v) => setState(() => _paymentMethod = v),
          onPreConfirmationMethodChanged: (v) => setState(() => _preConfirmationMethod = v),
          onPreConfirmationPhoneTypeChanged: (v) => setState(() => _preConfirmationPhoneType = v),
          onPreConfirmationPhoneNumberChanged: (v) => setState(() {
            _preConfirmationPhoneNumber = v;
            _preConfirmationPhoneController.text = v;
          }),
          onPreConfirmationDateTimeChanged: (v) => setState(() => _preConfirmationDateTime = v),
          onScheduledSmsDateTimeChanged: (v) => setState(() => _scheduledSmsDateTime = v),
          onSave: _handleSave,
          onCancelOrder: _confirmCancelOrder,
          onShowReceipt: _showReceiptPreviewDialog,
          isEditingOrder: _isEditingOrder,
      );
      default: return Container();
    }
  }

  /// 領収書のプレビュー（受注内容から自動生成、WebView表示・印刷）
  void _showReceiptPreviewDialog() {
    final hasFacility = _facilityController.text.trim().isNotEmpty;
    final recipient = hasFacility
        ? _facilityController.text.trim()
        : (_receiverController.text.trim().isNotEmpty
            ? _receiverController.text.trim()
            : _nameController.text.trim());
    showDialog(
      context: context,
      builder: (context) => KReceiptPreviewDialog(
        branchName: _branchName,
        recipientName: recipient,
        recipientHonorific: hasFacility ? '御中' : '様',
        totalPrice: _totalPrice,
        items: _confirmedItems,
        paymentMethod: _paymentMethod,
        issueDate: DateTime.now(),
      ),
    );
  }

  /// 請求書の印刷プレビュー（暫定表示。今後プレビュー内容を拡充予定）
  void _showInvoicePreviewDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 16))),
        child: Container(
          width: rs(context, 560),
          constraints: BoxConstraints(maxHeight: rs(context, 720)),
          padding: EdgeInsets.all(rs(context, 24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description_outlined, color: const Color(0xFF000038), size: rs(context, 24)),
                  SizedBox(width: rs(context, 12)),
                  Text('請求書 印刷プレビュー', style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              Divider(height: rs(context, 24)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('宛名：${_facilityController.text.isEmpty ? _nameController.text : _facilityController.text}',
                          style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold)),
                      SizedBox(height: rs(context, 4)),
                      Text('住所：${_addressController.text}', style: TextStyle(fontSize: rf(context, 13))),
                      SizedBox(height: rs(context, 12)),
                      ..._confirmedItems.map((i) => Padding(
                            padding: EdgeInsets.only(bottom: rs(context, 4)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${i['name']} × ${i['quantity']}', style: TextStyle(fontSize: rf(context, 13))),
                                Text('¥${(i['price'] as int) * (i['quantity'] as int)}', style: TextStyle(fontSize: rf(context, 13))),
                              ],
                            ),
                          )),
                      Divider(height: rs(context, 24)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('合計金額', style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.bold)),
                          Text('¥$_totalPrice',
                              style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        ],
                      ),
                      Text('支払方法：$_paymentMethod', style: TextStyle(fontSize: rf(context, 13))),
                    ],
                  ),
                ),
              ),
              SizedBox(height: rs(context, 16)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('閉じる'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime? _calculateScheduledSmsDateTime() {
    if (_preConfirmationMethod != 'SMS') {
      return null;
    }
    
    try {
      // 配達日の前日を算出
      final prevDay = _deliveryDate.subtract(const Duration(days: 1));
      
      // 時間と分をパース
      final timeParts = _preConfirmationSmsTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      return DateTime(prevDay.year, prevDay.month, prevDay.day, hour, minute);
    } catch (e) {
      debugPrint('Error calculating scheduled SMS time: $e');
      return null;
    }
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
    _trashPickupLocationController.dispose();
    _orderSourceOtherController.dispose();
    _packagingOtherController.dispose();
    _preConfirmationPhoneController.dispose();
    _preConfirmationRecipientController.dispose();
    super.dispose();
  }
}
