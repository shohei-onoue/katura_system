import 'package:flutter/material.dart';
import '../../../../models/customer_model.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_dial_pad.dart';
import '../../../../widgets/k_direct_address_picker_dialog.dart';
import '../../../../widgets/k_multimodal_text_field.dart';
import '../../../../widgets/k_pen_input_dialog.dart';
import '../../../../widgets/k_text_field.dart';
import '../../../../services/category_service.dart';
import '../order_form_parts.dart';
import 'receiver_selector.dart';
import 'package:katura_system/utils/app_colors.dart';

class DeliveryDestinationStep extends StatelessWidget {
  final Customer? currentCustomer;
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
  final bool isApproximateLocation;
  final String customerName;
  final TextEditingController remarksController;
  final ValueNotifier<List<Map<String, dynamic>>> facilityResultsListenable;
  final ValueNotifier<bool> isLoadingListenable;
  final String phoneNumberText;

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
  final Future<void> Function() onAdjustTap;
  /// 履歴カードは手動タップされるまで未選択にする
  final bool historyManuallySelected;
  /// 履歴カードタップ時、右端チェックアイコンのグローバル座標を親へ渡す（配達元メニューの展開起点）
  final void Function(Offset globalAnchor)? onBranchMenuAnchor;
  final VoidCallback onCancelOrder;
  final bool isEditingOrder; // 受注一覧の編集から遷移した場合 true

  const DeliveryDestinationStep({
    super.key,
    required this.currentCustomer,
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
    this.isApproximateLocation = false,
    this.customerName = '',
    required this.remarksController,
    required this.facilityResultsListenable,
    required this.isLoadingListenable,
    this.phoneNumberText = '',
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
    required this.onAdjustTap,
    this.historyManuallySelected = false,
    this.onBranchMenuAnchor,
    required this.onCancelOrder,
    this.isEditingOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OrderFormCard(
          title: '配達先の確定',
          icon: Icons.location_on,
          trailing: PhoneReceivedBadge(phoneNumber: phoneNumberText),
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
              SizedBox(height: rs(context, 32)),
              Divider(height: rs(context, 1), color: Colors.grey.shade200),
              SizedBox(height: rs(context, 20)),
              ReceiverSelector(
                receiverController: receiverController,
                currentCustomer: currentCustomer,
                customerName: customerName,
                facilityName: facilityControllerText,
              ),
              SizedBox(height: rs(context, 40)),
              Row(
                children: [
                  Expanded(
                    child: KButton(label: isEditingOrder ? '編集キャンセル' : '注文キャンセル', isSecondary: !isEditingOrder, color: isEditingOrder ? Colors.red : Colors.redAccent, onPressed: onCancelOrder),
                  ),
                  SizedBox(width: rs(context, 12)),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final bool ready = facilityControllerText.isNotEmpty &&
                            addressControllerText.isNotEmpty &&
                            receiverController.text.isNotEmpty;
                        return KButton(
                          label: '注文商品の選択へ',
                          onPressed: ready ? onNext : () {},
                          color: ready ? Colors.deepPurple : Colors.grey,
                        );
                      },
                    ),
                  ),
                ],
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
          color: isSelected ? Colors.deepPurple.shade50 : AppColors.background,
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

    final filteredAddresses = currentCustomer!.deliveryAddresses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...filteredAddresses.map((fullAddr) {
          final parts = fullAddr.split(': ');
          final fName = parts.length > 1 ? parts[0] : (fullAddr.startsWith('[') ? fullAddr.split(']')[0].replaceAll('[', '') : '名称なし');
          final aOnly = parts.length > 1 ? parts[1].split(' (')[0] : fullAddr.split(' (')[0].split(']').last.trim();
          // デフォルト未選択：手動タップされて初めて選択状態にする
          final isSelected = historyManuallySelected && addressControllerText == aOnly && facilityControllerText == fName;
          final GlobalKey checkKey = GlobalKey();

          return Padding(
            padding: EdgeInsets.only(bottom: rs(context, 8)),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rs(context, 8)),
                      side: BorderSide(color: isSelected ? Colors.orange : Colors.grey.shade200, width: isSelected ? 2 : 1)
                    ),
                    child: InkWell(
                      onTap: () {
                        // 右端チェックアイコン位置を配達元メニューの展開起点として親へ通知
                        final box = checkKey.currentContext?.findRenderObject() as RenderBox?;
                        if (box != null && box.hasSize) {
                          onBranchMenuAnchor?.call(box.localToGlobal(box.size.center(Offset.zero)));
                        }
                        onAddressSelected(fullAddr);
                      },
                      borderRadius: BorderRadius.circular(rs(context, 8)),
                      child: Container(
                        height: rs(context, 50),
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, size: rs(context, 20), color: isSelected ? Colors.orange : Colors.blueGrey.withValues(alpha: 0.5)),
                            SizedBox(width: rs(context, 12)),
                            SizedBox(width: rs(context, 220), child: Text(fName, style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                            SizedBox(width: rs(context, 16)),
                            Expanded(child: Text(aOnly, style: TextStyle(fontSize: rf(context, 14), color: Colors.blueGrey), overflow: TextOverflow.ellipsis)),
                            SizedBox(
                              key: checkKey,
                              width: rs(context, 20),
                              height: rs(context, 20),
                              child: isSelected ? Icon(Icons.check_circle, color: Colors.orange, size: rs(context, 20)) : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: rs(context, 12)),
                SizedBox(
                  height: rs(context, 50),
                  child: ElevatedButton.icon(
                    onPressed: onAdjustTap,
                    icon: Icon(Icons.map, size: rs(context, 20)),
                    label: const Text('調整', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApproximateLocation ? Colors.orange : Colors.blueGrey.shade400,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 8))),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNewForm(BuildContext context) {
    return FacilitySearchForm(
      facilityControllerText: facilityControllerText,
      facilityController: facilityController,
      addressControllerText: addressControllerText,
      prefList: prefList,
      searchPrefecture: searchPrefecture,
      searchCity: searchCity,
      searchTown: searchTown,
      searchCategory: searchCategory,
      searchGenre: searchGenre,
      searchTabIndex: searchTabIndex,
      isApproximateLocation: isApproximateLocation,
      keywordQueryController: keywordQueryController,
      remarksController: remarksController,
      facilityResultsListenable: facilityResultsListenable,
      isLoadingListenable: isLoadingListenable,
      onAddressSelected: onAddressSelected,
      onSearchTabChanged: onSearchTabChanged,
      onPrefChanged: onPrefChanged,
      onCityChanged: onCityChanged,
      onTownChanged: onTownChanged,
      onAddressConfirmed: onAddressConfirmed,
      onPrefInitialChanged: onPrefInitialChanged,
      onCityInitialChanged: onCityInitialChanged,
      onTownInitialChanged: onTownInitialChanged,
      onCategoryChanged: onCategoryChanged,
      onGenreChanged: onGenreChanged,
      onSearchSubmit: onSearchSubmit,
      onDialogVisibilityChanged: onDialogVisibilityChanged,
      onAdjustTap: onAdjustTap,
    );
  }
}

/// 施設・住所の検索フォーム（地域・カテゴリ／地域・キーワード／住所・郵便番号）
/// 「配達先の確定」ステップと「新規顧客の登録」ステップの双方から共通利用する。
class FacilitySearchForm extends StatelessWidget {
  final String facilityControllerText;
  final TextEditingController facilityController;
  final String addressControllerText;
  final List<String> prefList;
  final String searchPrefecture;
  final String searchCity;
  final String searchTown;
  final String? searchCategory;
  final String? searchGenre;
  final int searchTabIndex;
  final bool isApproximateLocation;
  final TextEditingController keywordQueryController;
  /// nullの場合は備考フィールドを表示しない
  final TextEditingController? remarksController;
  final ValueNotifier<List<Map<String, dynamic>>> facilityResultsListenable;
  final ValueNotifier<bool> isLoadingListenable;

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
  final Future<void> Function() onAdjustTap;

  const FacilitySearchForm({
    super.key,
    required this.facilityControllerText,
    required this.facilityController,
    required this.addressControllerText,
    required this.prefList,
    required this.searchPrefecture,
    required this.searchCity,
    required this.searchTown,
    required this.searchCategory,
    required this.searchGenre,
    required this.searchTabIndex,
    this.isApproximateLocation = false,
    required this.keywordQueryController,
    this.remarksController,
    required this.facilityResultsListenable,
    required this.isLoadingListenable,
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
    required this.onAdjustTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(rs(context, 12))),
          child: Row(
            children: [
              _buildSearchTab(context, 0, '地域・カテゴリ', Icons.category),
              _buildSearchTab(context, 1, '地域・キーワード', Icons.search),
              _buildSearchTab(context, 2, '住所・郵便番号', Icons.pin_drop),
            ],
          ),
        ),
        SizedBox(height: rs(context, 24)),
        if (searchTabIndex == 0) _buildAreaCategorySearchUI(context),
        if (searchTabIndex == 1) _buildAreaKeywordSearchUI(context),
        if (searchTabIndex == 2) _buildDirectSearchUI(context),

        if (remarksController != null) ...[
          SizedBox(height: rs(context, 16)),
          KMultimodalTextField(
            label: '備考 (地図上の目印、搬入口情報など)',
            controller: remarksController!,
            maxLines: 1,
            height: rs(context, 50),
          ),
        ],
      ],
    );
  }

  String _buildJoinedAddress() {
    String res = searchPrefecture;
    if (searchCity.isNotEmpty) {
      res += " $searchCity";
    }
    if (searchTown.isNotEmpty) {
      res += " $searchTown";
    }
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
          decoration: BoxDecoration(color: isSelected ? AppColors.background : Colors.transparent, borderRadius: BorderRadius.circular(rs(context, 12))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: rs(context, 18), color: isSelected ? Colors.deepPurple : Colors.grey), SizedBox(width: rs(context, 8)), Text(label, style: TextStyle(fontSize: rf(context, 14), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.deepPurple : Colors.grey))]),
        ),
      ),
    );
  }

  Widget _buildAreaCategorySearchUI(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _AddressDialField(
                label: '地域・カテゴリ選択',
                value: _buildJoinedAddress() + (searchCategory != null ? " / $searchCategory > $searchGenre" : ""),
                onTap: () => _showIntegratedAddressPicker(context),
                isWarning: isApproximateLocation,
                warningLabel: '代表地点',
              ),
            ),
            SizedBox(width: rs(context, 12)),
            SizedBox(
              height: rs(context, 50),
              child: ElevatedButton.icon(
                onPressed: onAdjustTap,
                icon: Icon(Icons.map, size: rs(context, 20)),
                label: const Text('調整', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApproximateLocation ? Colors.orange : Colors.blueGrey.shade400,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 8))),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectSearchUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _AddressDialField(
                label: '住所・郵便番号から検索',
                value: addressControllerText.isEmpty ? 'タップして入力' : addressControllerText,
                onTap: () => _showDirectAddressPicker(context),
                isWarning: isApproximateLocation,
                warningLabel: '代表地点',
              ),
            ),
            SizedBox(width: rs(context, 12)),
            SizedBox(
              height: rs(context, 50),
              child: ElevatedButton.icon(
                onPressed: onAdjustTap,
                icon: Icon(Icons.map, size: rs(context, 20)),
                label: const Text('調整', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApproximateLocation ? Colors.orange : Colors.blueGrey.shade400,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 8))),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: rs(context, 12)),
        KMultimodalTextField(
          label: '施設名（未入力の場合は「個人宅」）',
          controller: facilityController,
          maxLines: 1,
          height: rs(context, 50),
        ),
      ],
    );
  }

  void _showDirectAddressPicker(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => KDirectAddressPickerDialog(
        initialPref: searchPrefecture,
        initialCity: searchCity,
        initialTown: searchTown,
        onAddressConfirmed: (fullAddr) {
          final String facilityName =
              facilityController.text.trim().isEmpty ? '個人宅' : facilityController.text.trim();
          onAddressSelected("$facilityName: $fullAddr (0, 0)");
        },
      ),
    );
  }

  Widget _buildAreaKeywordSearchUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _AddressDialField(
                label: '地域・キーワードを設定',
                value: _buildJoinedAddress(),
                onTap: () => _showIntegratedAddressPicker(context, isKeywordMode: true),
                isWarning: isApproximateLocation,
                warningLabel: '代表地点',
              ),
            ),
            SizedBox(width: rs(context, 12)),
            SizedBox(
              height: rs(context, 50),
              child: ElevatedButton.icon(
                onPressed: onAdjustTap,
                icon: Icon(Icons.map, size: rs(context, 20)),
                label: const Text('調整', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApproximateLocation ? Colors.orange : Colors.blueGrey.shade400,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 8))),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showIntegratedAddressPicker(BuildContext context, {bool isKeywordMode = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _IntegratedAddressPickerDialog(
        initialPrefList: prefList,
        initialPref: searchPrefecture,
        initialCity: searchCity,
        initialTown: searchTown,
        initialCategory: searchCategory,
        initialGenre: searchGenre,
        isKeywordMode: isKeywordMode,
        keywordController: keywordQueryController,
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
          Navigator.of(dialogContext).pop();
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
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.popupBackground,
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
                              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(dialogContext).pop()),
                          ],
                        ),
                        Divider(height: rs(context, 32)),
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
                                  color: isNearby ? Colors.grey.shade300 : Colors.blue.shade50,
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
                                      final cleanAddress = _cleanResultAddress(item['address'] ?? '');
                                      final payload = "${item['name']}: $cleanAddress (${item['lat']}, ${item['lng']})";
                                      // 1タップで確実に閉じてから選択を伝搬する
                                      Navigator.of(dialogContext).pop();
                                      onAddressSelected(payload);
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

    // 住所中に埋め込まれた郵便番号（〒000-0000）は、都道府県より前へ並べ替える
    String zipPrefix = '';
    final zipMatch = RegExp(r'〒\s*\d{3}-?\d{4}').firstMatch(res);
    if (zipMatch != null) {
      final digits = zipMatch.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
      zipPrefix = '〒${digits.substring(0, 3)}-${digits.substring(3)} ';
      res = (res.substring(0, zipMatch.start) + res.substring(zipMatch.end)).trim();
    }

    final pref = searchPrefecture;
    final city = searchCity;
    if (pref.isEmpty) return (zipPrefix + res).trim();
    final List<String> regions = [pref, if (city.isNotEmpty) city];
    for (var region in regions) {
      while (res.contains('$region$region')) {
        res = res.replaceAll('$region$region', region);
      }
    }
    final fullRegion = '$pref$city';
    if (fullRegion.isNotEmpty && res.startsWith(fullRegion)) {
      final tail = res.substring(fullRegion.length);
      if (tail.contains(fullRegion)) {
        res = tail.trim();
      }
    }
    if (!res.startsWith(pref) && !res.contains('県')) {
      res = '$pref$city$res';
    }
    return (zipPrefix + res).trim();
  }
}

class _IntegratedAddressPickerDialog extends StatefulWidget {
  final List<String> initialPrefList;
  final String initialPref;
  final String initialCity;
  final String initialTown;
  final String? initialCategory;
  final String? initialGenre;
  final bool isKeywordMode;
  final TextEditingController? keywordController;
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
    this.isKeywordMode = false,
    this.keywordController,
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
  int phase = 0; 
  String selectedInitial = 'すべて';
  List<String> items = [];
  bool isSearching = false;
  
  String tempPref = "";
  String tempCity = "";
  String tempTown = "";
  String? tempCategory;
  String? tempGenre;

  Map<String, Map<String, List<String>>> categoryHierarchy = {};
  final _categoryService = CategoryService();

  String _recognizedKeyword = "";
  // 複数キーワード（最大3件）。Google Maps検索へはスペース区切りで渡す。
  final List<String> _keywords = ["", "", ""];

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
    if (widget.isKeywordMode) {
      final parts = (widget.keywordController?.text ?? "")
          .split(RegExp(r'\s+'))
          .where((e) => e.isNotEmpty)
          .toList();
      for (int i = 0; i < _keywords.length && i < parts.length; i++) {
        _keywords[i] = parts[i];
      }
      _recognizedKeyword = _keywords.where((k) => k.trim().isNotEmpty).join(' ');
    }

    if (tempPref.isNotEmpty && tempCity.isNotEmpty) {
      phase = 2; 
      if (tempTown.isEmpty) {
        tempTown = "（すべて）";
        widget.onTownConfirmed(tempTown);
        widget.onAddressConfirmed(tempPref, tempCity, tempTown);
      }
      _loadTowns();
    } else if (tempPref.isNotEmpty) {
      phase = 1; 
      _loadCities();
    } else {
      phase = 0;
      items = List.from(widget.initialPrefList);
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final hierarchy = await _categoryService.getCategoryHierarchy();
    if (mounted) setState(() => categoryHierarchy = hierarchy);
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
    return Dialog(
      backgroundColor: AppColors.popupBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 16))),
      child: Container(
        width: rs(context, 900),
        height: rs(context, 680), 
        padding: EdgeInsets.all(rs(context, 24)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.isKeywordMode ? '地域・キーワードの検索' : '地域・施設カテゴリの検索',
                  style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: rs(context, 16)),
            _buildPickerStepper(context),
            Divider(height: rs(context, 32)),
            Expanded(
              child: phase == 3 
                ? (widget.isKeywordMode ? _buildKeywordHandwritingUI(context) : _buildCategoryGenreSelector(context)) 
                : _buildAddressPicker(context),
            ),
            if (phase == 3) ...[
              Divider(height: rs(context, 32)),
              KButton(
                label: 'この条件で検索',
                fontSize: rf(context, 20),
                color: widget.isKeywordMode
                    ? (_recognizedKeyword.isNotEmpty ? KR.primaryColor : Colors.grey)
                    : (tempCategory != null && tempGenre != null ? KR.primaryColor : Colors.grey),
                onPressed: widget.isKeywordMode
                    ? (_recognizedKeyword.isNotEmpty ? widget.onSearchSubmit : null)
                    : (tempCategory != null && tempGenre != null ? widget.onSearchSubmit : null),
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
      {
        'title': widget.isKeywordMode ? 'キーワード' : 'カテゴリ',
        'value': widget.isKeywordMode ? _recognizedKeyword : (tempCategory ?? ''), 
        'phase': 3
      },
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
              if (phase == 0) {
                items = List.from(widget.initialPrefList);
              } else if (phase == 1) {
                _loadCities();
              } else if (phase == 2) {
                _loadTowns();
              }
            } : null,
            child: Card(
              elevation: isActive ? 4 : 0,
              margin: EdgeInsets.symmetric(horizontal: rs(context, 4)),
              color: isActive ? AppColors.background : (isCompleted ? Colors.deepPurple.withValues(alpha: 0.05) : Colors.grey.shade100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rs(context, 8)),
                side: BorderSide(
                  color: isActive ? Colors.deepPurple : (isCompleted ? Colors.deepPurple.withValues(alpha: 0.2) : Colors.transparent),
                  width: rs(context, 2),
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
                          ? Icon(Icons.check, color: AppColors.background, size: rs(context, 14))
                          : Text('${index + 1}', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold, fontSize: rf(context, 12))),
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
                          tileColor: isSelected ? Colors.orange.withValues(alpha: 0.1) : null,
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
        
        VerticalDivider(width: rs(context, 32), color: Colors.grey.shade200),

        // 右側: かな入力パッド
        SizedBox(
          width: rs(context, 300),
          child: _buildKanaDialPad(),
        ),
      ],
    );
  }

  Widget _buildKanaDialPad() {
    final List<KDialKey> keys = [];
    for (var entry in kanaMap.entries) {
      final baseChar = entry.key;
      final cycle = entry.value;
      final isMatch = cycle.contains(selectedInitial);
      keys.add(KDialKey(
        label: isMatch ? selectedInitial : baseChar,
        subLabel: cycle.join(''),
        isHighlight: isMatch,
        onTap: () => _handleKanaTap(baseChar, cycle, isMatch),
      ));
    }
    keys.add(KDialKey(label: 'すべて', isHighlight: selectedInitial == 'すべて', onTap: _handleAllTap));
    if (phase > 0) keys.add(KDialKey(label: '戻る', onTap: _handleBack));
    return KDialPad(keys: keys);
  }

  void _openKeywordPenInput(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => KPenInputDialog(
        initialText: _keywords[index],
        onTextRecognized: (text) {
          setState(() => _keywords[index] = text.trim());
          _syncKeywords();
        },
      ),
    );
  }

  /// 各キーワードをスペース区切りで結合し、検索用コントローラへ反映する。
  void _syncKeywords() {
    final joined = _keywords
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .join(' ');
    setState(() => _recognizedKeyword = joined);
    widget.keywordController?.text = joined;
  }

  Widget _buildKeywordHandwritingUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('判定されたキーワード', style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        SizedBox(height: rs(context, 8)),
        for (int i = 0; i < _keywords.length; i++) ...[
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _openKeywordPenInput(i),
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                  child: Container(
                    height: rs(context, 56),
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: rs(context, 12)),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(rs(context, 12)),
                      border: Border.all(color: Colors.deepPurple.shade200, width: rs(context, 2)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _keywords[i].isEmpty ? "タップしてペン入力で書いてください" : _keywords[i],
                        style: TextStyle(
                          fontSize: rf(context, 24),
                          fontWeight: FontWeight.bold,
                          color: _keywords[i].isEmpty ? Colors.grey : Colors.deepPurple.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: rs(context, 8)),
              IconButton(
                onPressed: _keywords[i].isEmpty
                    ? null
                    : () {
                        setState(() => _keywords[i] = "");
                        _syncKeywords();
                      },
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                tooltip: 'このキーワードを削除',
              ),
            ],
          ),
          SizedBox(height: rs(context, 12)),
        ],
      ],
    );
  }

  Widget _buildCategoryGenreSelector(BuildContext context) {
    if (categoryHierarchy.isEmpty) return const Center(child: CircularProgressIndicator());

    final categories = categoryHierarchy.keys.toList();
    final genres = tempCategory != null ? categoryHierarchy[tempCategory]!.keys.toList() : [];

    return Row(
      children: [
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
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == categories.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: rs(context, 8)),
                        child: OutlinedButton.icon(
                          onPressed: () => _showAddCategoryDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('カテゴリ追加'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.deepPurple.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 8))),
                          ),
                        ),
                      );
                    }
                    final cat = categories[index];
                    final isSelected = tempCategory == cat;
                    return Card(
                      elevation: isSelected ? 2 : 0,
                      color: isSelected ? Colors.deepPurple : AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rs(context, 8)),
                        side: BorderSide(color: isSelected ? Colors.deepPurple : Colors.grey.shade300),
                      ),
                      child: ListTile(
                        title: Text(cat, style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: isSelected ? AppColors.background : Colors.black87)),
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
        
        VerticalDivider(width: rs(context, 32), color: Colors.grey.shade200),

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
                  ? Center(child: Icon(Icons.arrow_back, size: rs(context, 64), color: Colors.grey.shade300))
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
                              color: isSelected ? Colors.orange : AppColors.background,
                              borderRadius: BorderRadius.circular(rs(context, 8)),
                              border: Border.all(color: isSelected ? Colors.orange : Colors.grey.shade300),
                            ),
                            child: Text(gen, 
                              style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: isSelected ? AppColors.background : Colors.black87),
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

  void _showAddCategoryDialog(BuildContext context) {
    final genreController = TextEditingController();
    final keywordController = TextEditingController();
    String? selectedParent = tempCategory ?? categoryHierarchy.keys.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('新しいカテゴリジャンルを追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedParent,
                decoration: const InputDecoration(labelText: '親カテゴリ'),
                items: categoryHierarchy.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setDialogState(() => selectedParent = v),
              ),
              SizedBox(height: rs(context, 16)),
              KTextField(label: 'ジャンル名（例：美容院）', controller: genreController),
              SizedBox(height: rs(context, 16)),
              KTextField(label: 'キーワード（カンマ区切り。例：ヘア,理容）', controller: keywordController),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
            ElevatedButton(
              onPressed: () async {
                if (selectedParent != null && genreController.text.isNotEmpty) {
                  final keywords = keywordController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                  if (keywords.isEmpty) keywords.add(genreController.text);
                  
                  await _categoryService.addCategory(selectedParent!, genreController.text, keywords);
                  await _loadCategories();
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('登録'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleKanaTap(String base, List<String> cycle, bool isMatch) async {
    String next = isMatch ? cycle[(cycle.indexOf(selectedInitial) + 1) % cycle.length] : base;
    setState(() {
      selectedInitial = next;
      isSearching = true;
    });
    _refreshItems();
  }

  Future<void> _handleAllTap() async {
    setState(() {
      selectedInitial = 'すべて';
      isSearching = true;
    });
    _refreshItems();
  }

  Future<void> _refreshItems() async {
    List<String> newList;
    if (phase == 0) {
      newList = await widget.onPrefInitialChanged(selectedInitial);
    } else if (phase == 1) {
      newList = await widget.onCityInitialChanged(tempPref, selectedInitial);
    } else {
      newList = await widget.onTownInitialChanged(tempPref, tempCity, selectedInitial);
    }

    if (mounted) {
      setState(() {
        items = (phase == 2 && selectedInitial == 'すべて') ? ['（すべて）', ...newList] : newList;
        isSearching = false;
      });
    }
  }

  Future<void> _handleItemSelect(String item) async {
    setState(() => isSearching = true);
    if (phase == 0) {
      final newList = await widget.onCityInitialChanged(item, 'すべて');
      widget.onPrefConfirmed(item);
      setState(() {
        tempPref = item;
        tempCity = "";
        tempTown = "";
        phase = 1;
        selectedInitial = 'すべて';
        items = newList;
        isSearching = false;
      });
    } else if (phase == 1) {
      final newList = await widget.onTownInitialChanged(tempPref, item, 'すべて');
      widget.onCityConfirmed(item);
      setState(() {
        tempCity = item;
        tempTown = "（すべて）"; 
        phase = 2;
        selectedInitial = 'すべて';
        items = ['（すべて）', ...newList];
        isSearching = false;
      });
      widget.onTownConfirmed("（すべて）");
      widget.onAddressConfirmed(tempPref, item, "（すべて）");
    } else if (phase == 2) {
      widget.onTownConfirmed(item);
      widget.onAddressConfirmed(tempPref, tempCity, item);
      setState(() {
        tempTown = item;
        phase = 3; 
        isSearching = false;
      });
    }
  }

  Future<void> _handleBack() async {
    setState(() {
      if (phase == 1) {
        phase = 0;
        tempPref = "";
        items = List.from(widget.initialPrefList);
      } else if (phase == 2) {
        phase = 1;
        tempCity = "";
        _loadCities();
      } else if (phase == 3) {
        phase = 2;
        _loadTowns();
      }
      selectedInitial = 'すべて';
    });
  }
}

class _AddressDialField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isWarning;
  final String? warningLabel;

  const _AddressDialField({
    required this.label, 
    required this.value, 
    required this.onTap,
    this.isWarning = false,
    this.warningLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: rf(context, 12), color: Colors.blueGrey, fontWeight: FontWeight.bold)),
        SizedBox(height: rs(context, 4)),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(rs(context, 8)),
          child: Container(
            height: kFieldHeight(context),
            padding: EdgeInsets.symmetric(horizontal: rs(context, 12)),
            decoration: BoxDecoration(
              color: isWarning ? Colors.pink.shade50 : AppColors.background,
              border: Border.all(color: isWarning ? Colors.pink.shade200 : Colors.grey.shade300, width: isWarning ? 2 : 1),
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
                      color: value.isEmpty ? Colors.grey : Colors.black87,
                      fontWeight: value.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isWarning && warningLabel != null)
                  Padding(
                    padding: EdgeInsets.only(left: rs(context, 8)),
                    child: Text(warningLabel!, style: TextStyle(color: Colors.pink.shade800, fontWeight: FontWeight.bold, fontSize: rf(context, 12))),
                  ),
                Icon(Icons.unfold_more, size: rs(context, 18), color: isWarning ? Colors.pink.shade400 : Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
