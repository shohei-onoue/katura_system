import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';
import '../services/google_maps_service.dart';
import '../services/address_service.dart';
import '../widgets/k_text_field.dart';
import '../widgets/k_button.dart';
import '../widgets/k_japanese_input_pad.dart';

/// 施設検索のカテゴリマスタ
const Map<String, List<String>> facilityCategories = {
  '公共施設': ['役所・官公庁', '警察・消防', '図書館・文化施設', '公園・運動施設'],
  '医療関係': ['総合病院', '内科・外科', '歯科医', '小児科医', '産婦人科'],
  '寺社仏閣': ['寺院', '神社', '教会・その他'],
};

enum SearchStep { method, category, subCategory, prefecture, city, town, finalForm }

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
          Expanded(child: _buildMapArea()),
          _buildSearchPanel(),
          _buildInputPadPanel(),
        ],
      ),
    );
  }

  void _goBack() {
    setState(() {
      if (_currentStep == SearchStep.category) _currentStep = SearchStep.method;
      else if (_currentStep == SearchStep.subCategory) _currentStep = SearchStep.category;
      else if (_currentStep == SearchStep.prefecture) _currentStep = SearchStep.subCategory;
      else if (_currentStep == SearchStep.city) _currentStep = SearchStep.prefecture;
      else if (_currentStep == SearchStep.town) _currentStep = SearchStep.city;
      else if (_currentStep == SearchStep.finalForm) _currentStep = SearchStep.town;
      _displayOptions = [];
    });
    _autoPopulateOptions();
  }

  Future<void> _autoPopulateOptions() async {
    if (_currentStep == SearchStep.prefecture) {
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

  Widget _buildMapArea() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _selectedLocation, zoom: 15),
      onMapCreated: (controller) => _mapController = controller,
      onTap: (pos) => setState(() => _selectedLocation = pos),
      markers: {
        Marker(
          markerId: const MarkerId('selected_pos'),
          position: _selectedLocation,
          draggable: true,
          onDragEnd: (pos) => setState(() => _selectedLocation = pos),
        )
      },
    );
  }

  Widget _buildSearchPanel() {
    return Container(
      width: 460,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(),
            ),
          ),
          if (_currentStep != SearchStep.method && _currentStep != SearchStep.finalForm) 
            _buildOptionArea(),
        ],
      ),
    );
  }

  Widget _buildInputPadPanel() {
    return Container(
      width: 400,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Center(
        child: KJapaneseInputPad(
          controller: _dummySearchController,
          onRowTap: _handleInputPadTap,
          onCompleted: () {},
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case SearchStep.method: return _buildMethodSelection();
      case SearchStep.category: return _buildCategorySelection();
      case SearchStep.subCategory: return _buildSubCategorySelection();
      case SearchStep.prefecture: return _buildAddressFieldSelection('都道府県を選択', _selectedState);
      case SearchStep.city: return _buildAddressFieldSelection('市区町村を選択', _selectedCity);
      case SearchStep.town: return _buildAddressFieldSelection('町域を選択', _selectedTown);
      case SearchStep.finalForm: return _buildFinalForm();
    }
  }

  Widget _buildMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('登録方法を選択'),
        _buildLargeCard(Icons.business, '施設名から検索', () => setState(() => _currentStep = SearchStep.category)),
        const SizedBox(height: 16),
        _buildLargeCard(Icons.map, '住所から検索', () => _onStepChange(SearchStep.prefecture)),
      ],
    );
  }

  void _onStepChange(SearchStep step) {
    setState(() => _currentStep = step);
    _autoPopulateOptions();
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('1. 施設カテゴリ'),
        ...facilityCategories.keys.map((cat) => _buildSelectionItem(cat, () => setState(() {
          _selectedCategory = cat;
          _currentStep = SearchStep.subCategory;
        }))),
      ],
    );
  }

  Widget _buildSubCategorySelection() {
    final subCats = facilityCategories[_selectedCategory!] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('2. 種別 ($_selectedCategory)'),
        ...subCats.map((sub) => _buildSelectionItem(sub, () => _onStepChange(SearchStep.prefecture))),
      ],
    );
  }

  Widget _buildAddressFieldSelection(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('3. 配送先住所の選択'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.orange.withOpacity(0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(value ?? '右側の入力パッドで絞り込み', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: value == null ? Colors.grey : Colors.black)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionArea() {
    if (_displayOptions.isEmpty && !_isLoading) {
      return Container(
        height: 300,
        width: double.infinity,
        color: Colors.grey[100],
        child: const Center(
          child: Text('右側の入力パッドで「あ・か・さ…」を\nタップして絞り込んでください', 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[100],
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _displayOptions.length,
            itemBuilder: (context, i) => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _handleOptionSelect(_displayOptions[i]),
              child: Text(_displayOptions[i], 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
    );
  }

  Future<void> _handleInputPadTap(String initial) async {
    if (_currentStep != SearchStep.prefecture && _currentStep != SearchStep.city && _currentStep != SearchStep.town) return;

    setState(() => _isLoading = true);

    try {
      List<String> results = [];
      if (_currentStep == SearchStep.prefecture) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('データ取得に失敗しました。もう一度タップしてください'))
      );
    }
  }

  void _handleOptionSelect(String value) async {
    if (_currentStep == SearchStep.prefecture) {
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
        _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
      }
    }
  }

  Widget _buildFinalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('4. 最終確認'),
        KTextField(label: '施設・会社名', controller: _facilityController, icon: Icons.business),
        const SizedBox(height: 16),
        _buildStaticField('住所 (自動入力)', "$_selectedState$_selectedCity$_selectedTown"),
        const SizedBox(height: 16),
        KTextField(label: '詳細住所（番地・号など）', controller: _addressController, icon: Icons.map),
        const SizedBox(height: 16),
        KTextField(label: '階数・部屋番号', controller: _floorController, icon: Icons.layers),
        const SizedBox(height: 16),
        KTextField(label: '受取人名', controller: _receiverController, icon: Icons.badge),
        const SizedBox(height: 40),
        KButton(label: 'この内容で登録', color: Colors.orange[800]!, onPressed: _handleSave),
      ],
    );
  }

  Widget _buildStaticField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }

  Widget _buildLargeCard(IconData icon, String title, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.orange[800]),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionItem(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 70,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: onTap,
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_facilityController.text.isEmpty || _selectedTown == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('施設名と住所を確定させてください')));
      return;
    }
    final fullAddress = "$_selectedState$_selectedCity$_selectedTown${_addressController.text}";
    final displayEntry = "${_facilityController.text}: $fullAddress";
    final updatedAddresses = List<String>.from(widget.customer.deliveryAddresses);
    if (!updatedAddresses.contains(displayEntry)) updatedAddresses.add(displayEntry);
    await _customerService.updateCustomer(widget.customer.copyWith(deliveryAddresses: updatedAddresses));
    if (mounted) Navigator.pop(context, displayEntry);
  }

  @override
  void dispose() {
    _facilityController.dispose();
    _addressController.dispose();
    _receiverController.dispose();
    _floorController.dispose();
    _dummySearchController.dispose();
    super.dispose();
  }
}
