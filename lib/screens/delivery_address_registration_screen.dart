import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';
import '../services/google_maps_service.dart';
import '../services/address_service.dart';
import 'delivery_address/constants.dart';
import 'delivery_address/widgets/address_search_panel.dart';
import 'delivery_address/widgets/delivery_map_area.dart';
import 'delivery_address/widgets/registration_input_pad.dart';

class DeliveryAddressRegistrationScreen extends StatefulWidget {
  final Customer customer;

  const DeliveryAddressRegistrationScreen({super.key, required this.customer});

  @override
  State<DeliveryAddressRegistrationScreen> createState() => _DeliveryAddressRegistrationScreenState();
}

class _DeliveryAddressRegistrationScreenState extends State<DeliveryAddressRegistrationScreen> {
  final _customerService = CustomerService();
  final _googleMapsService = GoogleMapsService();
  final _addressService = AddressService(); // シングルトン
  
  // Controllers
  final _facilityController = TextEditingController();
  final _addressController = TextEditingController();
  final _receiverController = TextEditingController();
  final _floorController = TextEditingController();
  final _dummySearchController = TextEditingController();

  // State
  SearchStep _currentStep = SearchStep.method;
  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _selectedState;
  String? _selectedCity;
  String? _selectedTown;
  
  List<String> _displayOptions = [];
  bool _isLoading = false;

  LatLng _selectedLocation = const LatLng(34.9563, 137.1685);
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _autoPopulateOptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('新規配達先の登録', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep != SearchStep.method 
          ? IconButton(
              icon: const Icon(Icons.arrow_back), 
              onPressed: _goBack
            )
          : null,
      ),
      body: Row(
        children: [
          Expanded(
            child: DeliveryMapArea(
              selectedLocation: _selectedLocation,
              onLocationChanged: (pos) => setState(() => _selectedLocation = pos),
              onMapCreated: (controller) => _mapController = controller,
            ),
          ),
          AddressSearchPanel(
            currentStep: _currentStep,
            selectedCategory: _selectedCategory,
            selectedSubCategory: _selectedSubCategory,
            selectedState: _selectedState,
            selectedCity: _selectedCity,
            selectedTown: _selectedTown,
            displayOptions: _displayOptions,
            isLoading: _isLoading,
            facilityController: _facilityController,
            addressController: _addressController,
            floorController: _floorController,
            receiverController: _receiverController,
            onStepChange: _onStepChange,
            onCategorySelect: (cat) => setState(() {
              _selectedCategory = cat;
              _currentStep = SearchStep.subCategory;
            }),
            onSubCategorySelect: (sub) => _onStepChange(SearchStep.prefecture),
            onOptionSelect: _handleOptionSelect,
            onSave: _handleSave,
            onGoBack: _goBack,
          ),
          RegistrationInputPad(
            controller: _dummySearchController,
            onRowTap: _handleInputPadTap,
          ),
        ],
      ),
    );
  }

  void _goBack() {
    setState(() {
      if (_currentStep == SearchStep.category) {
        _currentStep = SearchStep.method;
      } else if (_currentStep == SearchStep.subCategory) {
        _currentStep = SearchStep.category;
      } else if (_currentStep == SearchStep.prefecture) {
        _currentStep = SearchStep.subCategory;
      } else if (_currentStep == SearchStep.city) {
        _currentStep = SearchStep.prefecture;
      } else if (_currentStep == SearchStep.town) {
        _currentStep = SearchStep.city;
      } else if (_currentStep == SearchStep.finalForm) {
        _currentStep = SearchStep.town;
      }
      _displayOptions = [];
    });
    _autoPopulateOptions();
  }

  Future<void> _autoPopulateOptions() async {
    if (_currentStep == SearchStep.category) {
      setState(() {
        _displayOptions = facilityCategories.keys.toList();
        _isLoading = false;
      });
    } else if (_currentStep == SearchStep.subCategory) {
      setState(() {
        _displayOptions = facilityCategories[_selectedCategory!] ?? [];
        _isLoading = false;
      });
    } else if (_currentStep == SearchStep.prefecture) {
      setState(() => _isLoading = true);
      try {
        final results = await _addressService.getPrefectures();
        setState(() {
          _displayOptions = results;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() {
        _displayOptions = [];
        _isLoading = false;
      });
    }
  }

  void _onStepChange(SearchStep step) {
    setState(() => _currentStep = step);
    _autoPopulateOptions();
  }

  Future<void> _handleInputPadTap(String initial) async {
    if (_currentStep == SearchStep.method || _currentStep == SearchStep.finalForm) return;

    setState(() => _isLoading = true);

    try {
      List<String> results = [];
      if (_currentStep == SearchStep.category) {
        // カテゴリの読み（仮定）に基づき簡易フィルタリング
        results = _filterByInitial(facilityCategories.keys.toList(), initial);
      } else if (_currentStep == SearchStep.subCategory) {
        results = _filterByInitial(facilityCategories[_selectedCategory!] ?? [], initial);
      } else if (_currentStep == SearchStep.prefecture) {
        results = await _addressService.getPrefecturesByInitial(initial);
      } else if (_currentStep == SearchStep.city) {
        results = await _addressService.getCitiesByInitial(_selectedState!, initial);
      } else if (_currentStep == SearchStep.town) {
        results = await _addressService.getTownsByInitial(_selectedState!, _selectedCity!, initial);
      }
      setState(() {
        _displayOptions = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('データ取得に失敗しました。もう一度タップしてください'))
        );
      }
    }
  }

  List<String> _filterByInitial(List<String> list, String initial) {
    if (initial == 'すべて') return list;
    // 簡易的なカタカナ読みマッピング（現場のスピード重視）
    final Map<String, String> rowMap = {
      'あ': 'アイウエオ', 'か': 'カキクケコガギグゲゴ', 'さ': 'サシスセソザジズゼゾ',
      'た': 'タチツテトダヂヅデド', 'な': 'ナニヌネノ', 'は': 'ハヒフヘホバビブベボパピプペポ',
      'ま': 'マミムメモ', 'や': 'ヤユヨ', 'ら': 'ラリルレロ', 'わ': 'ワヲン'
    };
    final targets = rowMap[initial] ?? '';
    return list.where((item) {
      if (targets.isEmpty) return false;
      final firstChar = item.substring(0, 1);
      return targets.contains(firstChar);
    }).toList();
  }

  void _handleOptionSelect(String value) async {
    if (_currentStep == SearchStep.category) {
      setState(() {
        _selectedCategory = value;
        _currentStep = SearchStep.subCategory;
      });
      _autoPopulateOptions();
    } else if (_currentStep == SearchStep.subCategory) {
      setState(() {
        _selectedSubCategory = value;
        _currentStep = SearchStep.prefecture;
      });
      _autoPopulateOptions();
    } else if (_currentStep == SearchStep.prefecture) {
      setState(() {
        _selectedState = value;
        _selectedCity = null;
        _selectedTown = null;
      });
      _onStepChange(SearchStep.city);
    } else if (_currentStep == SearchStep.city) {
      setState(() {
        _selectedCity = value;
        _selectedTown = null;
      });
      _onStepChange(SearchStep.town);
    } else if (_currentStep == SearchStep.town) {
      setState(() {
        _selectedTown = value;
        _currentStep = SearchStep.finalForm;
        _displayOptions = [];
        _addressController.text = ""; 
      });
      
      final fullAddr = "$_selectedState$_selectedCity$value";
      final latLng = await _googleMapsService.getLatLngFromAddress(fullAddr);
      if (latLng != null) {
        final pos = LatLng(latLng['lat']!, latLng['lng']!);
        setState(() => _selectedLocation = pos);
        
        // 代表地点（ROOFTOP以外）の場合に警告を表示
        if (latLng['location_type'] != 'ROOFTOP' && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ 正確な番地が特定できませんでした。地図のピンが「代表地点」の可能性があります。必ず地図上で場所を確認し、微調整してください。'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 8),
            ),
          );
        }
        if (mounted) {
          try {
            _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
          } catch (e) {
            debugPrint('GoogleMapController Error: $e');
          }
        }
      }
    }
  }

  Future<void> _handleSave() async {
    if (_facilityController.text.isEmpty || _selectedTown == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('施設名と住所を確定させてください')));
      return;
    }
    final fullAddress = "$_selectedState$_selectedCity$_selectedTown${_addressController.text}";
    
    // 最終的な座標の確定とローカルDBへの保存
    await _addressService.upsertKigyouEntity(
      name: _facilityController.text,
      address: fullAddress,
      lat: _selectedLocation.latitude,
      lng: _selectedLocation.longitude,
    );

    final displayEntry = "${_facilityController.text}: $fullAddress (${_selectedLocation.latitude}, ${_selectedLocation.longitude})";
    final updatedAddresses = List<String>.from(widget.customer.deliveryAddresses);
    if (!updatedAddresses.contains(displayEntry)) updatedAddresses.add(displayEntry);
    
    await _customerService.updateCustomer(widget.customer.copyWith(deliveryAddresses: updatedAddresses));
    if (mounted) Navigator.pop(context, displayEntry);
  }

  @override
  void dispose() {
    _mapController = null;
    _facilityController.dispose();
    _addressController.dispose();
    _receiverController.dispose();
    _floorController.dispose();
    _dummySearchController.dispose();
    super.dispose();
  }
}
