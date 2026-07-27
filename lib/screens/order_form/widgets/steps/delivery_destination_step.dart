import 'package:flutter/material.dart';
import '../../../../models/customer_model.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_text_field.dart';
import '../../../../services/address_service.dart';
import '../order_form_parts.dart';

class DeliveryDestinationStep extends StatelessWidget {
  final Customer? currentCustomer;
  final String phoneDisplay;
  final bool isHistoryMode;
  final String selectedHistoryCategory;
  final String facilityControllerText;
  final String addressControllerText;
  final TextEditingController nameController;
  final TextEditingController facilityController;
  final TextEditingController addressController;
  final TextEditingController receiverController;
  final TextEditingController deliveryLocationController;
  final TextEditingController addressQueryController;
  final TextEditingController keywordQueryController;
  final TextEditingController combinedSearchController; // 追加
  final List<String> prefList;
  final List<String> cityList;
  final List<String> townList;
  final String searchPrefecture;
  final String searchCity;
  final String searchTown;
  final String searchPrefInitial;
  final String searchCityInitial;
  final String searchTownInitial;
  final String? searchCategory;
  final String? searchGenre;
  final int searchTabIndex;
  
  final VoidCallback onNext;
  final Function(bool) onModeToggle;
  final Function(String) onHistoryCategoryChanged;
  final Function(String) onAddressSelected;
  final Function(int) onSearchTabChanged;
  final Function(String) onPrefChanged;
  final Function(String) onCityChanged;
  final Function(String) onTownChanged;
  final Function(String) onPrefInitialChanged;
  final Function(String) onCityInitialChanged;
  final Function(String) onTownInitialChanged;
  final Function(String?) onCategoryChanged;
  final Function(String?) onGenreChanged;
  final VoidCallback onSearchSubmit;

  const DeliveryDestinationStep({
    super.key,
    required this.currentCustomer,
    required this.phoneDisplay,
    required this.isHistoryMode,
    required this.selectedHistoryCategory,
    required this.facilityControllerText,
    required this.addressControllerText,
    required this.nameController,
    required this.facilityController,
    required this.addressController,
    required this.receiverController,
    required this.deliveryLocationController,
    required this.addressQueryController,
    required this.keywordQueryController,
    required this.combinedSearchController, // 追加
    required this.prefList,
    required this.cityList,
    required this.townList,
    required this.searchPrefecture,
    required this.searchCity,
    required this.searchTown,
    required this.searchPrefInitial,
    required this.searchCityInitial,
    required this.searchTownInitial,
    required this.searchCategory,
    required this.searchGenre,
    required this.searchTabIndex,
    required this.onNext,
    required this.onModeToggle,
    required this.onHistoryCategoryChanged,
    required this.onAddressSelected,
    required this.onSearchTabChanged,
    required this.onPrefChanged,
    required this.onCityChanged,
    required this.onTownChanged,
    required this.onPrefInitialChanged,
    required this.onCityInitialChanged,
    required this.onTownInitialChanged,
    required this.onCategoryChanged,
    required this.onGenreChanged,
    required this.onSearchSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomerInfoBanner(customer: currentCustomer),
        const SizedBox(height: 24),
        OrderFormCard(
          title: '配達先の確定',
          icon: Icons.location_on,
          trailing: Text('受電: $phoneDisplay', 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildModeToggleBtn(label: '履歴から選択', icon: Icons.history, isSelected: isHistoryMode, onTap: () => onModeToggle(true))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildModeToggleBtn(label: '新規登録', icon: Icons.add_location_alt, isSelected: !isHistoryMode, onTap: () => onModeToggle(false))),
                ],
              ),
              const SizedBox(height: 32),
              if (isHistoryMode) _buildHistoryList() else _buildNewForm(),
              const SizedBox(height: 40),
              KButton(
                label: '配達日時の選択へ', 
                onPressed: (facilityControllerText.isNotEmpty && addressControllerText.isNotEmpty) ? onNext : () {},
                color: (facilityControllerText.isNotEmpty && addressControllerText.isNotEmpty) ? Colors.deepPurple : Colors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggleBtn({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
          border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.deepPurple : Colors.grey),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.deepPurple : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (currentCustomer == null || currentCustomer!.deliveryAddresses.isEmpty) {
      return const Center(child: Text('配達実績がありません。新規登録を行ってください。', style: TextStyle(color: Colors.grey)));
    }

    final categories = {'すべて'};
    for (var addr in currentCustomer!.deliveryAddresses) {
      categories.add(_extractCategory(addr));
    }
    final categoryList = categories.toList()..sort();

    final filteredAddresses = selectedHistoryCategory == 'すべて'
        ? currentCustomer!.deliveryAddresses
        : currentCustomer!.deliveryAddresses.where((addr) => _extractCategory(addr) == selectedHistoryCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categoryList.map((cat) {
              final isSelected = selectedHistoryCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 16),
                child: ChoiceChip(
                  label: Text(cat, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.blueGrey)),
                  selected: isSelected,
                  onSelected: (val) => onHistoryCategoryChanged(cat),
                  selectedColor: Colors.deepPurple,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
        ...filteredAddresses.map((fullAddr) {
          final parts = fullAddr.split(': ');
          final facilityName = parts.length > 1 ? parts[0] : (fullAddr.startsWith('[') ? fullAddr.split(']')[0].replaceAll('[', '') : '名称なし');
          final addressOnly = parts.length > 1 ? parts[1].split(' (')[0] : fullAddr.split(' (')[0].split(']').last.trim();
          final isSelected = addressControllerText == addressOnly && facilityControllerText == facilityName;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), 
              side: BorderSide(color: isSelected ? Colors.orange : Colors.grey.shade200, width: isSelected ? 2 : 1)
            ),
            child: InkWell(
              onTap: () => onAddressSelected(fullAddr),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 20, color: isSelected ? Colors.orange : Colors.blueGrey.withValues(alpha: 0.5)),
                    const SizedBox(width: 12),
                    SizedBox(width: 90, child: Text('【${_extractGenre(facilityName)}】', style: const TextStyle(fontSize: 13, color: Colors.deepPurple, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    SizedBox(width: 220, child: Text(facilityName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 16),
                    Expanded(child: Text(addressOnly, style: const TextStyle(fontSize: 14, color: Colors.blueGrey), overflow: TextOverflow.ellipsis)),
                    if (isSelected) const Icon(Icons.check_circle, color: Colors.orange, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  String _extractGenre(String name) {
    if (name.contains('歯科')) return '歯科医院';
    if (name.contains('病院')) return '総合病院';
    if (name.contains('医院') || name.contains('クリニック')) return 'クリニック';
    if (name.contains('役所') || name.contains('センター')) return '公共施設';
    if (name.contains('消防')) return '消防署';
    if (name.contains('警察')) return '警察署';
    if (name.contains('神社')) return '神社';
    if (name.contains('寺')) return '寺院';
    if (name.contains('工場') || name.contains('製作所')) return '工場・工業';
    if (name.contains('自宅') || name.contains('個人')) return '個人宅';
    return '一般施設';
  }

  String _extractCategory(String fullAddr) {
    if (fullAddr.startsWith('[') && fullAddr.contains(']')) return fullAddr.substring(1, fullAddr.indexOf(']'));
    if (fullAddr.contains('病院') || fullAddr.contains('医院')) return '医療関係';
    if (fullAddr.contains('役所') || fullAddr.contains('消防')) return '公共施設';
    return '一般';
  }

  Widget _buildNewForm() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              _buildSearchTab(0, '地域・カテゴリ', Icons.category),
              _buildSearchTab(1, '住所・郵便番号', Icons.pin_drop),
              _buildSearchTab(2, '地域・キーワード', Icons.search),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (searchTabIndex == 0) _buildAreaCategorySearchUI(),
        if (searchTabIndex == 1) _buildDirectSearchUI(),
        if (searchTabIndex == 2) _buildAreaKeywordSearchUI(),
        const Divider(height: 48),
        Row(
          children: [
            Expanded(child: KTextField(label: '注文者名 (必須)', controller: nameController, icon: Icons.person)),
            const SizedBox(width: 16),
            Expanded(child: KTextField(label: '施設・会社名', controller: facilityController, icon: Icons.business)),
          ],
        ),
        const SizedBox(height: 16),
        KTextField(label: '確定住所 (必須)', controller: addressController, icon: Icons.map),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: KTextField(label: 'お渡し場所 (例: 1Fロビー)', controller: deliveryLocationController, icon: Icons.location_on)),
            const SizedBox(width: 16),
            Expanded(child: KTextField(label: '受取人名', controller: receiverController, icon: Icons.badge)),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchTab(int index, String label, IconData icon) {
    final isSelected = searchTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onSearchTabChanged(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 18, color: isSelected ? Colors.deepPurple : Colors.grey), const SizedBox(width: 8), Text(label, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.deepPurple : Colors.grey))]),
        ),
      ),
    );
  }

  Widget _buildAreaCategorySearchUI() {
    return Column(
      children: [
        _buildAreaSelectionRow(),
        const SizedBox(height: 16),
        _buildCategoryHierarchyUI(),
        const SizedBox(height: 24),
        
        // Googleマップ風 検索窓 (自動挿入・手動編集)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.deepPurple.shade200, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.deepPurple),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: combinedSearchController,
                  decoration: const InputDecoration(
                    hintText: 'マップを検索（住所＋ジャンル）',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => combinedSearchController.clear(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        KButton(label: 'この条件で検索', onPressed: (searchCategory != null && searchGenre != null) ? onSearchSubmit : () {}, color: (searchCategory != null && searchGenre != null) ? Colors.deepPurple : Colors.grey),
      ],
    );
  }

  Widget _buildDirectSearchUI() {
    return Row(children: [Expanded(child: KTextField(label: '住所 または 郵便番号', controller: addressQueryController, icon: Icons.map)), const SizedBox(width: 16), SizedBox(width: 200, child: KButton(label: '検索', onPressed: onSearchSubmit))]);
  }

  Widget _buildAreaKeywordSearchUI() {
    return Column(children: [_buildAreaSelectionRow(), const SizedBox(height: 16), Row(children: [Expanded(child: KTextField(label: 'キーワード', controller: keywordQueryController, icon: Icons.search)), const SizedBox(width: 16), SizedBox(width: 200, child: KButton(label: '検索', onPressed: onSearchSubmit))])]);
  }

  Widget _buildAreaSelectionRow() {
    return Column(
      children: [
        _buildInitialAndDropdown(
          label: '都道府県',
          initial: searchPrefInitial,
          value: searchPrefecture,
          items: prefList,
          onInitialChanged: onPrefInitialChanged,
          onChanged: onPrefChanged,
        ),
        const SizedBox(height: 12),
        _buildInitialAndDropdown(
          label: '市区町村',
          initial: searchCityInitial,
          value: searchCity,
          items: cityList,
          onInitialChanged: onCityInitialChanged,
          onChanged: onCityChanged,
        ),
        const SizedBox(height: 12),
        _buildInitialAndDropdown(
          label: '町名',
          initial: searchTownInitial,
          value: searchTown,
          items: townList,
          onInitialChanged: onTownInitialChanged,
          onChanged: onTownChanged,
        ),
      ],
    );
  }

  Widget _buildInitialAndDropdown({
    required String label,
    required String initial,
    required String value,
    required List<String> items,
    required Function(String) onInitialChanged,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Expanded(child: KInitialRowSelector(selectedInitial: initial, onSelected: onInitialChanged)),
          ],
        ),
        const SizedBox(height: 4),
        _buildSimpleDropdown(label: '', value: value, items: items, onChanged: onChanged),
      ],
    );
  }

  Widget _buildCategoryHierarchyUI() {
    final categories = AddressService.categoryHierarchy.keys.toList();
    final genres = searchCategory != null ? AddressService.categoryHierarchy[searchCategory]!.keys.toList() : [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('カテゴリ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
        Wrap(spacing: 8, children: categories.map((cat) => ChoiceChip(label: Text(cat), selected: searchCategory == cat, onSelected: (val) => onCategoryChanged(val ? cat : null))).toList()),
        if (searchCategory != null) ...[
          const SizedBox(height: 16),
          const Text('ジャンル', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
          Wrap(spacing: 8, children: genres.map((gen) => ChoiceChip(label: Text(gen), selected: searchGenre == gen, onSelected: (val) => onGenreChanged(val ? gen : null))).toList()),
        ],
      ],
    );
  }

  Widget _buildSimpleDropdown({required String label, required String value, required List<String> items, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) Text(label, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value.isEmpty && items.isNotEmpty ? items.first : value, isExpanded: true, items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: (v) => onChanged(v!))),
        ),
      ],
    );
  }
}
