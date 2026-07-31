import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../models/customer_model.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_text_field.dart';
import '../../../../widgets/k_responsive.dart';
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
  final TextEditingController combinedSearchController;
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
  final ValueNotifier<List<Map<String, dynamic>>> facilityResultsListenable;
  final ValueNotifier<bool> isLoadingListenable;
  
  final VoidCallback onNext;
  final Function(bool) onModeToggle;
  final Function(String) onHistoryCategoryChanged;
  final Function(String) onAddressSelected;
  final Function(int) onSearchTabChanged;
  final Function(String) onPrefChanged;
  final Function(String) onCityChanged;
  final Function(String) onTownChanged;
  final Function(String, String, String) onAddressConfirmed;
  final Future<List<String>> Function(String) onPrefInitialChanged;
  final Future<List<String>> Function(String pref, String initial) onCityInitialChanged;
  final Future<List<String>> Function(String pref, String city, String initial) onTownInitialChanged;
  final Function(String?) onCategoryChanged;
  final Function(String?) onGenreChanged;
  final Future<void> Function() onSearchSubmit;
  final Function(bool) onDialogVisibilityChanged;

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
    required this.combinedSearchController,
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
    required this.facilityResultsListenable,
    required this.isLoadingListenable,
    required this.onNext,
    required this.onModeToggle,
    required this.onHistoryCategoryChanged,
    required this.onAddressSelected,
    required this.onSearchTabChanged,
    required this.onPrefChanged,
    required this.onCityChanged,
    required this.onTownChanged,
    required this.onAddressConfirmed,
    required this.onPrefInitialChanged,
    required this.onCityInitialChanged,
    required this.onTownInitialChanged,
    required this.onCategoryChanged,
    required this.onGenreChanged,
    required this.onSearchSubmit,
    required this.onDialogVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OrderFormCard(
          title: '配達先の確定',
          icon: Icons.location_on,
          trailing: Text('受電: $phoneDisplay', 
            style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildModeToggleBtn(context, label: '履歴から選択', icon: Icons.history, isSelected: isHistoryMode, onTap: () => onModeToggle(true))),
                  SizedBox(width: rs(context, 16)),
                  Expanded(child: _buildModeToggleBtn(context, label: '新規登録', icon: Icons.add_location_alt, isSelected: !isHistoryMode, onTap: () => onModeToggle(false))),
                ],
              ),
              SizedBox(height: rs(context, 32)),
              if (isHistoryMode) _buildHistoryList(context) else _buildNewForm(context),
              SizedBox(height: rs(context, 40)),
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

  Widget _buildModeToggleBtn(BuildContext context, {required String label, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rs(context, 12)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rs(context, 10)),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
          border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey.shade300, width: rs(context, 2)),
          borderRadius: BorderRadius.circular(rs(context, 12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.deepPurple : Colors.grey, size: rs(context, 20)),
            SizedBox(width: rs(context, 12)),
            Text(label, style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: isSelected ? Colors.deepPurple : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    if (currentCustomer == null || currentCustomer!.deliveryAddresses.isEmpty) {
      return Center(child: Text('配達実績がありません。新規登録を行ってください。', style: TextStyle(color: Colors.grey, fontSize: rf(context, 14))));
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
                padding: EdgeInsets.only(right: rs(context, 8), bottom: rs(context, 16)),
                child: ChoiceChip(
                  label: Text(cat, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.blueGrey, fontSize: rf(context, 13))),
                  selected: isSelected,
                  onSelected: (val) => onHistoryCategoryChanged(cat),
                  selectedColor: Colors.deepPurple,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 8))),
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
            margin: EdgeInsets.only(bottom: rs(context, 8)),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rs(context, 8)), 
              side: BorderSide(color: isSelected ? Colors.orange : Colors.grey.shade200, width: isSelected ? 2 : 1)
            ),
            child: InkWell(
              onTap: () => onAddressSelected(fullAddr),
              borderRadius: BorderRadius.circular(rs(context, 8)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rs(context, 12)),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: rs(context, 20), color: isSelected ? Colors.orange : Colors.blueGrey.withValues(alpha: 0.5)),
                    SizedBox(width: rs(context, 12)),
                    SizedBox(width: rs(context, 90), child: Text('【${_extractGenre(facilityName)}】', style: TextStyle(fontSize: rf(context, 13), color: Colors.deepPurple, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    SizedBox(width: rs(context, 8)),
                    SizedBox(width: rs(context, 220), child: Text(facilityName, style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    SizedBox(width: rs(context, 16)),
                    Expanded(child: Text(addressOnly, style: TextStyle(fontSize: rf(context, 14), color: Colors.blueGrey), overflow: TextOverflow.ellipsis)),
                    if (isSelected) Icon(Icons.check_circle, color: Colors.orange, size: rs(context, 20)),
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
    if (name.contains('介護') || name.contains('ホーム') || name.contains('デイサービス')) return '介護施設';
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
    if (fullAddr.contains('病院') || fullAddr.contains('医院') || fullAddr.contains('介護')) return '医療・介護';
    if (fullAddr.contains('役所') || fullAddr.contains('消防')) return '公共施設';
    return '一般';
  }

  Widget _buildNewForm(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(rs(context, 12))),
          child: Row(
            children: [
              _buildSearchTab(context, 0, '地域・カテゴリ', Icons.category),
              _buildSearchTab(context, 1, '住所・郵便番号', Icons.pin_drop),
              _buildSearchTab(context, 2, '地域・キーワード', Icons.search),
            ],
          ),
        ),
        SizedBox(height: rs(context, 24)),
        if (searchTabIndex == 0) _buildAreaCategorySearchUI(context),
        if (searchTabIndex == 1) _buildDirectSearchUI(context),
        if (searchTabIndex == 2) _buildAreaKeywordSearchUI(context),
        
        // 検索ボタン以下のフィールド群を削除 (純鋭化)
      ],
    );
  }

  String _buildJoinedAddress() {
    String res = searchPrefecture;
    if (searchCity.isNotEmpty) res += " $searchCity";
    if (searchTown.isNotEmpty) res += " $searchTown";
    return res;
  }

  Widget _buildSearchTab(BuildContext context, int index, String label, IconData icon) {
    final isSelected = searchTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onSearchTabChanged(index),
        borderRadius: BorderRadius.circular(rs(context, 12)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: rs(context, 12)),
          decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(rs(context, 12))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: rs(context, 18), color: isSelected ? Colors.deepPurple : Colors.grey), SizedBox(width: rs(context, 8)), Text(label, style: TextStyle(fontSize: rf(context, 14), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.deepPurple : Colors.grey))]),
        ),
      ),
    );
  }

  Widget _buildAreaCategorySearchUI(BuildContext context) {
    return Column(
      children: [
        _AddressDialField(
          label: '地域・カテゴリ選択',
          value: _buildJoinedAddress() + (searchCategory != null ? " / $searchCategory > $searchGenre" : ""),
          onTap: () => _showIntegratedAddressPicker(context),
        ),
      ],
    );
  }

  Widget _buildDirectSearchUI(BuildContext context) {
    return Row(children: [
      Expanded(child: KTextField(label: '住所 または 郵便番号', controller: addressQueryController, icon: Icons.map)), 
      const SizedBox(width: 16), 
      SizedBox(width: 200, child: ValueListenableBuilder<bool>(
        valueListenable: isLoadingListenable,
        builder: (context, isLoading, child) {
          return KButton(
            label: isLoading ? '検索中...' : '検索', 
            onPressed: isLoading ? () {} : () {
              _showSearchResultsDialog(context);
              onSearchSubmit();
            }
          );
        }
      ))
    ]);
  }

  Widget _buildAreaKeywordSearchUI(BuildContext context) {
    return Column(children: [
      _AddressDialField(
        label: '地域選択',
        value: _buildJoinedAddress(),
        onTap: () => _showIntegratedAddressPicker(context),
      ),
      SizedBox(height: rs(context, 16)),
      Row(children: [
        Expanded(child: KTextField(label: 'キーワード', controller: keywordQueryController, icon: Icons.search)), 
        SizedBox(width: rs(context, 16)), 
        SizedBox(width: rs(context, 200), child: ValueListenableBuilder<bool>(
          valueListenable: isLoadingListenable,
          builder: (context, isLoading, child) {
            return KButton(
              label: isLoading ? '検索中...' : '検索', 
              onPressed: isLoading ? () {} : () {
                _showSearchResultsDialog(context);
                onSearchSubmit();
              }
            );
          }
        ))
      ])
    ]);
  }

  void _showIntegratedAddressPicker(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _IntegratedAddressPickerDialog(
        initialPrefList: prefList,
        initialPref: searchPrefecture,
        initialCity: searchCity,
        initialTown: searchTown,
        initialCategory: searchCategory,
        initialGenre: searchGenre,
        onPrefConfirmed: onPrefChanged,
        onCityConfirmed: onCityChanged,
        onTownConfirmed: onTownChanged,
        onAddressConfirmed: onAddressConfirmed,
        onPrefInitialChanged: onPrefInitialChanged,
        onCityInitialChanged: onCityInitialChanged,
        onTownInitialChanged: onTownInitialChanged,
        onCategoryChanged: onCategoryChanged,
        onGenreChanged: onGenreChanged,
        onSearchSubmit: () {
          Navigator.pop(context);
          _showSearchResultsDialog(context);
          onSearchSubmit();
        },
      ),
    );
  }

  void _showSearchResultsDialog(BuildContext context) {
    onDialogVisibilityChanged(true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 16))),
          child: Container(
            width: rs(context, 800),
            constraints: BoxConstraints(maxHeight: rs(context, 600)),
            padding: EdgeInsets.all(rs(context, 24)),
            child: ValueListenableBuilder<bool>(
              valueListenable: isLoadingListenable,
              builder: (context, isLoading, child) {
                return ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: facilityResultsListenable,
                  builder: (context, candidates, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.business_center, color: Colors.blueGrey, size: rs(context, 24)),
                            SizedBox(width: rs(context, 12)),
                            Text('施設検索結果', style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (!isLoading)
                              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                          ],
                        ),
                        const Divider(height: 32),
                        if (isLoading)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(),
                                  SizedBox(height: rs(context, 24)),
                                  Text('検索中...', style: TextStyle(fontSize: rf(context, 18), color: Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          )
                        else if (candidates.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text('候補が見つかりませんでした', style: TextStyle(fontSize: rf(context, 16), color: Colors.grey)),
                            ),
                          )
                        else
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: candidates.length,
                              itemBuilder: (context, i) {
                                final item = candidates[i];
                                final isSelected = addressControllerText == item['address'] && facilityControllerText == item['name'];
                                final isNearby = item['isNearby'] == true;
                                final cleanAddress = _cleanResultAddress(item['address'] ?? '');

                                return Card(
                                  margin: EdgeInsets.only(bottom: rs(context, 8)),
                                  elevation: 0,
                                  color: isNearby ? Colors.deepOrange.shade50 : Colors.blue.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(rs(context, 8)),
                                    side: BorderSide(color: isSelected ? Colors.orange : Colors.grey.shade200, width: isSelected ? 2 : 1),
                                  ),
                                  child: ListTile(
                                    leading: Icon(Icons.business, color: isSelected ? Colors.orange : (isNearby ? Colors.deepOrange : Colors.blue).withValues(alpha: 0.5)),
                                    title: Text(item['name'] ?? '名称なし', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 16))),
                                    subtitle: Text(cleanAddress, style: TextStyle(fontSize: rf(context, 14))),
                                    trailing: isSelected ? Icon(Icons.check_circle, color: Colors.orange) : Icon(Icons.chevron_right),
                                    onTap: () {
                                      onAddressSelected("${item['name']}: $cleanAddress (${item['lat']}, ${item['lng']})");
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  }
                );
              }
            ),
          ),
        );
      },
    ).then((_) => onDialogVisibilityChanged(false));
  }

  String _cleanResultAddress(String addr) {
    String res = addr.replaceAll('　', ' ').trim();
    
    // 1. "愛知県岡崎市" などの基本情報を取得
    final pref = '愛知県';
    final city = '岡崎市';
    
    // 2. 連続した重複を置換 (例: 愛知県愛知県 -> 愛知県)
    final List<String> regions = [pref, city];
    for (var region in regions) {
      while (res.contains('$region$region')) {
        res = res.replaceAll('$region$region', region);
      }
    }
    
    // 3. 全体構造としての重複を正規表現で一掃 (例: 愛知県岡崎市...愛知県岡崎市...)
    // 前方一致の重複を削る (Google Maps API特有の「建物名 住所」連結への対策)
    final fullRegion = '$pref$city';
    if (res.startsWith(fullRegion)) {
      final tail = res.substring(fullRegion.length);
      if (tail.contains(fullRegion)) {
        res = tail.trim(); // 後方の住所を生かし、前方の重複を削る
      }
    }
    
    // 4. それでも頭に都道府県がない場合は補完 (検索条件に合わせる)
    if (!res.startsWith(pref) && !res.contains('県')) {
      res = '$pref$city$res';
    }

    return res.trim();
  }
}

class _IntegratedAddressPickerDialog extends StatefulWidget {
  final List<String> initialPrefList;
  final String initialPref;
  final String initialCity;
  final String initialTown;
  final String? initialCategory;
  final String? initialGenre;
  final Function(String) onPrefConfirmed;
  final Function(String) onCityConfirmed;
  final Function(String) onTownConfirmed;
  final Function(String, String, String) onAddressConfirmed;
  final Future<List<String>> Function(String) onPrefInitialChanged;
  final Future<List<String>> Function(String pref, String initial) onCityInitialChanged;
  final Future<List<String>> Function(String pref, String city, String initial) onTownInitialChanged;
  final Function(String?) onCategoryChanged;
  final Function(String?) onGenreChanged;
  final VoidCallback onSearchSubmit;

  const _IntegratedAddressPickerDialog({
    required this.initialPrefList,
    required this.initialPref,
    required this.initialCity,
    required this.initialTown,
    this.initialCategory,
    this.initialGenre,
    required this.onPrefConfirmed,
    required this.onCityConfirmed,
    required this.onTownConfirmed,
    required this.onAddressConfirmed,
    required this.onPrefInitialChanged,
    required this.onCityInitialChanged,
    required this.onTownInitialChanged,
    required this.onCategoryChanged,
    required this.onGenreChanged,
    required this.onSearchSubmit,
  });

  @override
  State<_IntegratedAddressPickerDialog> createState() => _IntegratedAddressPickerDialogState();
}

class _IntegratedAddressPickerDialogState extends State<_IntegratedAddressPickerDialog> {
  int phase = 0; // 0: Pref, 1: City, 2: Town, 3: Category/Genre
  String selectedInitial = 'すべて';
  List<String> items = [];
  bool isSearching = false;
  
  String tempPref = "";
  String tempCity = "";
  String tempTown = "";
  String? tempCategory;
  String? tempGenre;

  final Map<String, List<String>> kanaMap = {
    'あ': ['あ', 'い', 'う', 'え', 'お'],
    'か': ['か', 'き', 'く', 'け', 'こ'],
    'さ': ['さ', 'し', 'す', 'せ', 'そ'],
    'た': ['た', 'ち', 'つ', 'て', 'と'],
    'な': ['な', 'に', 'ぬ', 'ね', 'の'],
    'は': ['は', 'ひ', 'ふ', 'へ', 'ほ'],
    'ま': ['ま', 'み', 'む', 'め', 'も'],
    'や': ['や', 'ゆ', 'よ'],
    'ら': ['ら', 'り', 'る', 'れ', 'ろ'],
    'わ': ['わ', 'を', 'ん'],
  };

  @override
  void initState() {
    super.initState();
    tempPref = widget.initialPref;
    tempCity = widget.initialCity;
    tempTown = widget.initialTown;
    tempCategory = widget.initialCategory;
    tempGenre = widget.initialGenre;

    if (tempPref.isNotEmpty && tempCity.isNotEmpty) {
      phase = 2; // 町名選択から開始
      if (tempTown.isEmpty) {
        tempTown = "（すべて）";
        widget.onTownConfirmed(tempTown);
        widget.onAddressConfirmed(tempPref, tempCity, tempTown);
      }
      _loadTowns();
    } else if (tempPref.isNotEmpty) {
      phase = 1; // 市区町村選択から開始
      _loadCities();
    } else {
      phase = 0;
      items = List.from(widget.initialPrefList);
    }
  }

  Future<void> _loadCities() async {
    setState(() => isSearching = true);
    final newList = await widget.onCityInitialChanged(tempPref, 'すべて');
    setState(() {
      items = newList;
      isSearching = false;
    });
  }

  Future<void> _loadTowns() async {
    setState(() => isSearching = true);
    final newList = await widget.onTownInitialChanged(tempPref, tempCity, 'すべて');
    setState(() {
      items = ['（すべて）', ...newList];
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentFull = tempPref;
    if (tempCity.isNotEmpty) currentFull += " " + tempCity;
    if (tempTown.isNotEmpty) currentFull += " " + tempTown;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 16))),
      child: Container(
        width: rs(context, 900),
        height: rs(context, 680), // ステッパー分少し高さを広げる
        padding: EdgeInsets.all(rs(context, 24)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('地域・施設カテゴリの検索', 
                  style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            _buildPickerStepper(context),
            const Divider(height: 32),
            Expanded(
              child: phase == 3 ? _buildCategoryGenreSelector(context) : _buildAddressPicker(context),
            ),
            if (phase == 3) ...[
              const Divider(height: 32),
              SizedBox(
                width: double.infinity,
                height: rs(context, 60),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (tempCategory != null && tempGenre != null) ? Colors.deepPurple : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
                  ),
                  onPressed: (tempCategory != null && tempGenre != null) ? widget.onSearchSubmit : null,
                  child: Text('この条件で検索', style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPickerStepper(BuildContext context) {
    final List<Map<String, dynamic>> steps = [
      {'title': '都道府県', 'value': tempPref, 'phase': 0},
      {'title': '市区町村', 'value': tempCity, 'phase': 1},
      {'title': '町名', 'value': tempTown, 'phase': 2},
      {'title': 'カテゴリ', 'value': tempCategory ?? '', 'phase': 3},
    ];

    return Row(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isActive = phase == step['phase'];
        final isCompleted = step['value'].toString().isNotEmpty;
        final isAvailable = index == 0 || steps[index - 1]['value'].toString().isNotEmpty;

        return Expanded(
          child: GestureDetector(
            onTap: isAvailable ? () {
              setState(() {
                phase = step['phase'];
                selectedInitial = 'すべて';
              });
              if (phase == 0) items = List.from(widget.initialPrefList);
              else if (phase == 1) _loadCities();
              else if (phase == 2) _loadTowns();
            } : null,
            child: Card(
              elevation: isActive ? 4 : 0,
              margin: EdgeInsets.symmetric(horizontal: rs(context, 4)),
              color: isActive ? Colors.white : (isCompleted ? Colors.deepPurple.withValues(alpha: 0.05) : Colors.grey.shade100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rs(context, 8)),
                side: BorderSide(
                  color: isActive ? Colors.deepPurple : (isCompleted ? Colors.deepPurple.withValues(alpha: 0.2) : Colors.transparent),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: rs(context, 8), horizontal: rs(context, 12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: rs(context, 24),
                      height: rs(context, 24),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.orange : (isCompleted ? Colors.deepPurple : Colors.grey.shade400),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted && !isActive
                          ? Icon(Icons.check, color: Colors.white, size: rs(context, 14))
                          : Text('${index + 1}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: rf(context, 12))),
                      ),
                    ),
                    SizedBox(width: rs(context, 8)),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step['title'], 
                            style: TextStyle(fontSize: rf(context, 11), color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                          Text(isCompleted ? step['value'] : (isActive ? '選択中' : '-'), 
                            style: TextStyle(
                              fontSize: rf(context, 13), 
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.orange : (isCompleted ? Colors.black87 : Colors.grey),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAddressPicker(BuildContext context) {
    return Row(
      children: [
        // 左側: 項目リスト
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: rs(context, 12)),
                child: Row(
                  children: [
                    Text('頭文字 [$selectedInitial] の項目', style: TextStyle(fontSize: rf(context, 14), color: Colors.grey, fontWeight: FontWeight.bold)),
                    if (isSearching) ...[
                      SizedBox(width: rs(context, 12)),
                      SizedBox(width: rs(context, 12), height: rs(context, 12), child: const CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                  ? Center(child: Text('該当する項目がありません', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = (phase == 0 && item == tempPref) || 
                                           (phase == 1 && item == tempCity) || 
                                           (phase == 2 && item == tempTown);
                        return ListTile(
                          tileColor: isSelected ? Colors.orange.withOpacity(0.1) : null,
                          title: Text(item, style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold, color: isSelected ? Colors.orange.shade900 : Colors.black87)),
                          trailing: Icon(isSelected ? Icons.check_circle : Icons.chevron_right, color: isSelected ? Colors.orange : Colors.deepPurple),
                          onTap: () => _handleItemSelect(item),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
        
        VerticalDivider(width: 32, color: Colors.grey.shade200),

        // 右側: かな入力パッド
        SizedBox(
          width: rs(context, 300),
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: rs(context, 12),
            crossAxisSpacing: rs(context, 12),
            childAspectRatio: 1.1,
            children: [
              ...kanaMap.entries.map((entry) {
                final baseChar = entry.key;
                final cycle = entry.value;
                final isMatch = cycle.contains(selectedInitial);

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMatch ? Colors.deepPurple : Colors.grey.shade100,
                    foregroundColor: isMatch ? Colors.white : Colors.black87,
                    elevation: isMatch ? 4 : 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => _handleKanaTap(baseChar, cycle, isMatch),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isMatch ? selectedInitial : baseChar, style: TextStyle(fontSize: rf(context, 24), fontWeight: FontWeight.bold)),
                      Text(cycle.join(''), style: TextStyle(fontSize: rf(context, 9), color: isMatch ? Colors.white70 : Colors.grey)),
                    ],
                  ),
                );
              }).toList(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedInitial == 'すべて' ? Colors.deepPurple : Colors.grey.shade100,
                  foregroundColor: selectedInitial == 'すべて' ? Colors.white : Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
                ),
                onPressed: () => _handleAllTap(),
                child: Text('すべて', style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
              ),
              if (phase > 0)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
                  ),
                  onPressed: () => _handleBack(),
                  child: Text('戻る', style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGenreSelector(BuildContext context) {
    final categories = AddressService.categoryHierarchy.keys.toList();
    final genres = tempCategory != null ? AddressService.categoryHierarchy[tempCategory]!.keys.toList() : [];

    return Row(
      children: [
        // 左側: カテゴリリスト
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: rs(context, 12)),
                child: Text('1. カテゴリを選択', style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = tempCategory == cat;
                    return Card(
                      elevation: isSelected ? 2 : 0,
                      color: isSelected ? Colors.deepPurple : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rs(context, 8)),
                        side: BorderSide(color: isSelected ? Colors.deepPurple : Colors.grey.shade300),
                      ),
                      child: ListTile(
                        title: Text(cat, style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                        onTap: () {
                          setState(() {
                            tempCategory = cat;
                            tempGenre = null;
                          });
                          widget.onCategoryChanged(cat);
                          widget.onGenreChanged(null);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        VerticalDivider(width: 32, color: Colors.grey.shade200),

        // 右側: ジャンルリスト
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: rs(context, 12)),
                child: Text(tempCategory == null ? '2. カテゴリを選択してください' : '2. ジャンルを選択 ($tempCategory)', 
                  style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ),
              Expanded(
                child: tempCategory == null 
                  ? Center(child: Icon(Icons.arrow_back, size: 64, color: Colors.grey.shade300))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        mainAxisSpacing: rs(context, 8),
                        crossAxisSpacing: rs(context, 8),
                      ),
                      itemCount: genres.length,
                      itemBuilder: (context, index) {
                        final gen = genres[index];
                        final isSelected = tempGenre == gen;
                        return InkWell(
                          onTap: () {
                            setState(() => tempGenre = gen);
                            widget.onGenreChanged(gen);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.orange : Colors.white,
                              borderRadius: BorderRadius.circular(rs(context, 8)),
                              border: Border.all(color: isSelected ? Colors.orange : Colors.grey.shade300),
                            ),
                            child: Text(gen, 
                              style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleKanaTap(String base, List<String> cycle, bool isMatch) async {
    String next;
    if (!isMatch) {
      next = base;
    } else {
      int idx = cycle.indexOf(selectedInitial);
      next = cycle[(idx + 1) % cycle.length];
    }
    
    // UIを即座に更新 (連打対応)
    setState(() {
      selectedInitial = next;
      isSearching = true;
    });

    try {
      List<String> newList;
      if (phase == 0) {
        newList = await widget.onPrefInitialChanged(next);
      } else if (phase == 1) {
        newList = await widget.onCityInitialChanged(tempPref, next);
      } else {
        newList = await widget.onTownInitialChanged(tempPref, tempCity, next);
      }

      if (mounted) {
        setState(() {
          items = (phase == 2) ? ['（すべて）', ...newList] : newList;
        });
      }
    } catch (e) {
      debugPrint("Kana search error: $e");
    } finally {
      if (mounted) setState(() => isSearching = false);
    }
  }

  Future<void> _handleAllTap() async {
    setState(() {
      selectedInitial = 'すべて';
      isSearching = true;
    });

    try {
      List<String> newList;
      if (phase == 0) {
        newList = await widget.onPrefInitialChanged('すべて');
      } else if (phase == 1) {
        newList = await widget.onCityInitialChanged(tempPref, 'すべて');
      } else {
        newList = await widget.onTownInitialChanged(tempPref, tempCity, 'すべて');
      }
      
      if (mounted) {
        setState(() {
          items = (phase == 2) ? ['（すべて）', ...newList] : newList;
        });
      }
    } catch (e) {
      debugPrint("All search error: $e");
    } finally {
      if (mounted) setState(() => isSearching = false);
    }
  }

  Future<void> _handleItemSelect(String item) async {
    setState(() => isSearching = true);
    try {
      if (phase == 0) {
        final newList = await widget.onCityInitialChanged(item, 'すべて');
        widget.onPrefConfirmed(item);
        if (mounted) {
          setState(() {
            tempPref = item;
            tempCity = "";
            tempTown = "";
            phase = 1;
            selectedInitial = 'すべて';
            items = newList;
          });
        }
      } else if (phase == 1) {
        final newList = await widget.onTownInitialChanged(tempPref, item, 'すべて');
        widget.onCityConfirmed(item);
        if (mounted) {
          setState(() {
            tempCity = item;
            tempTown = "（すべて）"; // デフォルトで「すべて」を選択
            phase = 2;
            selectedInitial = 'すべて';
            items = ['（すべて）', ...newList];
          });
          // 親コンポーネントの状態も即座に更新
          widget.onTownConfirmed("（すべて）");
          widget.onAddressConfirmed(tempPref, item, "（すべて）");
        }
      } else if (phase == 2) {
        widget.onTownConfirmed(item);
        widget.onAddressConfirmed(tempPref, tempCity, item);
        if (mounted) {
          setState(() {
            tempTown = item;
            phase = 3; // カテゴリ・ジャンル選択へ
          });
        }
      }
    } catch (e) {
      debugPrint("Item selection error: $e");
    } finally {
      if (mounted) setState(() => isSearching = false);
    }
  }

  Future<void> _handleBack() async {
    setState(() {
      if (phase == 1) {
        phase = 0;
        tempPref = "";
        tempCity = "";
        tempTown = "";
      } else if (phase == 2) {
        phase = 1;
        tempCity = "";
        tempTown = "";
      } else if (phase == 3) {
        phase = 2;
      }
      selectedInitial = 'すべて';
      isSearching = true;
    });
    
    try {
      List<String> newList = [];
      if (phase == 0) {
        newList = await widget.onPrefInitialChanged('すべて');
      } else if (phase == 1) {
        newList = await widget.onCityInitialChanged(tempPref, 'すべて');
      } else if (phase == 2) {
        newList = await widget.onTownInitialChanged(tempPref, tempCity, 'すべて');
      }
      
      if (mounted) {
        setState(() {
          items = (phase == 2) ? ['（すべて）', ...newList] : newList;
        });
      }
    } catch (e) {
      debugPrint("Back error: $e");
    } finally {
      if (mounted) setState(() => isSearching = false);
    }
  }
}

class _AddressDialField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isEnabled;

  const _AddressDialField({
    required this.label, 
    required this.value, 
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: rf(context, 12), color: isEnabled ? Colors.blueGrey : Colors.grey.shade400, fontWeight: FontWeight.bold)),
        SizedBox(height: rs(context, 4)),
        InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(rs(context, 8)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 12)),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.white : Colors.grey.shade50,
              border: Border.all(color: isEnabled ? Colors.grey.shade300 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(rs(context, 8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? '未選択' : value,
                    style: TextStyle(
                      fontSize: rf(context, 14), 
                      color: !isEnabled ? Colors.grey.shade400 : (value.isEmpty ? Colors.grey : Colors.black87),
                      fontWeight: value.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.unfold_more, size: rs(context, 18), color: isEnabled ? Colors.grey : Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
