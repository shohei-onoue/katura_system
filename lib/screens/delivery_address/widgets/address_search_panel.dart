import 'package:flutter/material.dart';
import '../constants.dart';
import '../../../widgets/k_text_field.dart';
import '../../../widgets/k_button.dart';

class AddressSearchPanel extends StatelessWidget {
  final SearchStep currentStep;
  final String? selectedCategory;
  final String? selectedSubCategory;
  final String? selectedState;
  final String? selectedCity;
  final String? selectedTown;
  final List<String> displayOptions;
  final bool isLoading;
  
  final TextEditingController facilityController;
  final TextEditingController addressController;
  final TextEditingController floorController;
  final TextEditingController receiverController;
  
  final void Function(SearchStep) onStepChange;
  final void Function(String) onCategorySelect;
  final void Function(String) onSubCategorySelect;
  final void Function(String) onOptionSelect;
  final VoidCallback onSave;
  final VoidCallback onGoBack;

  const AddressSearchPanel({
    super.key,
    required this.currentStep,
    this.selectedCategory,
    this.selectedSubCategory,
    this.selectedState,
    this.selectedCity,
    this.selectedTown,
    required this.displayOptions,
    required this.isLoading,
    required this.facilityController,
    required this.addressController,
    required this.floorController,
    required this.receiverController,
    required this.onStepChange,
    required this.onCategorySelect,
    required this.onSubCategorySelect,
    required this.onOptionSelect,
    required this.onSave,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
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
          if (currentStep != SearchStep.method && currentStep != SearchStep.finalForm) 
            _buildOptionArea(),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case SearchStep.method: return _buildMethodSelection();
      case SearchStep.category: return _buildCategorySelection();
      case SearchStep.subCategory: return _buildSubCategorySelection();
      case SearchStep.prefecture: return _buildAddressFieldSelection('都道府県を選択', selectedState);
      case SearchStep.city: return _buildAddressFieldSelection('市区町村を選択', selectedCity);
      case SearchStep.town: return _buildAddressFieldSelection('町域を選択', selectedTown);
      case SearchStep.finalForm: return _buildFinalForm();
    }
  }

  Widget _buildMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('登録方法を選択'),
        _buildLargeCard(Icons.business, '施設名から検索', () => onStepChange(SearchStep.category)),
        const SizedBox(height: 16),
        _buildLargeCard(Icons.map, '住所から検索', () => onStepChange(SearchStep.prefecture)),
      ],
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('1. 施設カテゴリ'),
        ...facilityCategories.keys.map((cat) => _buildSelectionItem(cat, () => onCategorySelect(cat))),
      ],
    );
  }

  Widget _buildSubCategorySelection() {
    final subCats = facilityCategories[selectedCategory!] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('2. 種別 ($selectedCategory)'),
        ...subCats.map((sub) => _buildSelectionItem(sub, () => onSubCategorySelect(sub))),
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
    if (displayOptions.isEmpty && !isLoading) {
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
      child: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: displayOptions.length,
            itemBuilder: (context, i) => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => onOptionSelect(displayOptions[i]),
              child: Text(displayOptions[i], 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
    );
  }

  Widget _buildFinalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('4. 最終確認'),
        KTextField(label: '施設・会社名', controller: facilityController, icon: Icons.business),
        const SizedBox(height: 16),
        _buildStaticField('住所 (自動入力)', "$selectedState$selectedCity$selectedTown"),
        const SizedBox(height: 16),
        KTextField(label: '詳細住所（番地・号など）', controller: addressController, icon: Icons.map),
        const SizedBox(height: 16),
        KTextField(label: '階数・部屋番号', controller: floorController, icon: Icons.layers),
        const SizedBox(height: 16),
        KTextField(label: '受取人名', controller: receiverController, icon: Icons.badge),
        const SizedBox(height: 40),
        KButton(label: 'この内容で登録', color: Colors.orange[800]!, onPressed: onSave),
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
}
