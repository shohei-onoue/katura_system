import 'package:flutter/material.dart';
import '../constants.dart';
import '../../../widgets/k_text_field.dart';
import '../../../widgets/k_button.dart';
import '../../../widgets/k_responsive.dart';

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
      width: rs(context, 460),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(rs(context, 24)),
              child: _buildStepContent(context),
            ),
          ),
          if (currentStep != SearchStep.method && currentStep != SearchStep.finalForm) 
            _buildOptionArea(context),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (currentStep) {
      case SearchStep.method: return _buildMethodSelection(context);
      case SearchStep.category: return _buildCategorySelection(context);
      case SearchStep.subCategory: return _buildSubCategorySelection(context);
      case SearchStep.prefecture: return _buildAddressFieldSelection(context, '都道府県を選択', selectedState);
      case SearchStep.city: return _buildAddressFieldSelection(context, '市区町村を選択', selectedCity);
      case SearchStep.town: return _buildAddressFieldSelection(context, '町域を選択', selectedTown);
      case SearchStep.finalForm: return _buildFinalForm(context);
    }
  }

  Widget _buildMethodSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '登録方法を選択'),
        _buildLargeCard(context, Icons.business, '施設名から検索', () => onStepChange(SearchStep.category)),
        SizedBox(height: rs(context, 16)),
        _buildLargeCard(context, Icons.map, '住所から検索', () => onStepChange(SearchStep.prefecture)),
      ],
    );
  }

  Widget _buildCategorySelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '1. 施設カテゴリの選択'),
        _buildGuidanceBox(context, '下のパネルからカテゴリを選択してください'),
      ],
    );
  }

  Widget _buildSubCategorySelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '2. 種別の選択'),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(rs(context, 16)),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(rs(context, 8)),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('選択中のカテゴリ', style: TextStyle(fontSize: rf(context, 12), color: Colors.blueGrey)),
              SizedBox(height: rs(context, 4)),
              Text(selectedCategory ?? '', style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        SizedBox(height: rs(context, 16)),
        _buildGuidanceBox(context, '下のパネルから詳細な種別を選択してください'),
      ],
    );
  }

  Widget _buildGuidanceBox(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 20)),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(text, 
          style: TextStyle(color: Colors.blueGrey, fontSize: rf(context, 16), fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildAddressFieldSelection(BuildContext context, String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '3. 配送先住所の選択'),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(rs(context, 20)),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange, width: rs(context, 2)),
            borderRadius: BorderRadius.circular(rs(context, 12)),
            color: Colors.orange.withValues(alpha: 0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: rf(context, 14), color: Colors.grey)),
              SizedBox(height: rs(context, 8)),
              Text(value ?? '右側の入力パッドで絞り込み', 
                style: TextStyle(fontSize: rf(context, 24), fontWeight: FontWeight.bold, color: value == null ? Colors.grey : Colors.black)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionArea(BuildContext context) {
    if (displayOptions.isEmpty && !isLoading) {
      String message = '右側の入力パッドで絞り込むか\n選択肢が表示されるのをお待ちください';
      if (currentStep == SearchStep.category || currentStep == SearchStep.subCategory) {
        message = '選択肢がありません';
      }
      return Container(
        height: rs(context, 300),
        width: double.infinity,
        color: Colors.grey[100],
        child: Center(
          child: Text(message, 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey, fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Container(
      height: rs(context, 300),
      width: double.infinity,
      color: Colors.grey[100],
      child: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : GridView.builder(
            padding: EdgeInsets.all(rs(context, 12)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              mainAxisSpacing: rs(context, 8),
              crossAxisSpacing: rs(context, 8),
            ),
            itemCount: displayOptions.length,
            itemBuilder: (context, i) => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 8))),
              ),
              onPressed: () => onOptionSelect(displayOptions[i]),
              child: Text(displayOptions[i], 
                style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
    );
  }

  Widget _buildFinalForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '4. 最終確認'),
        KTextField(label: '施設・会社名', controller: facilityController, icon: Icons.business),
        SizedBox(height: rs(context, 16)),
        _buildStaticField(context, '住所 (自動入力)', "$selectedState$selectedCity$selectedTown"),
        SizedBox(height: rs(context, 16)),
        KTextField(label: '詳細住所（番地・号など）', controller: addressController, icon: Icons.map),
        SizedBox(height: rs(context, 16)),
        KTextField(label: '階数・部屋番号', controller: floorController, icon: Icons.layers),
        SizedBox(height: rs(context, 16)),
        KTextField(label: '受取人名', controller: receiverController, icon: Icons.badge),
        SizedBox(height: rs(context, 40)),
        KButton(label: 'この内容で登録', color: Colors.orange[800]!, onPressed: onSave),
      ],
    );
  }

  Widget _buildStaticField(BuildContext context, String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 8)),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(rs(context, 8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: rf(context, 12), color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 20)),
      child: Text(title, style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }

  Widget _buildLargeCard(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: rs(context, 100),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, size: rs(context, 32), color: Colors.orange[800]),
            SizedBox(width: rs(context, 16)),
            Text(title, style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
