import 'package:flutter/material.dart';
import '../../../../models/customer_model.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_multimodal_text_field.dart';
import '../order_form_parts.dart';
import 'delivery_destination_step.dart' show FacilitySearchForm;

/// 顧客確認および新規登録ステップ
/// [評価] 高齢者配慮のペン入力統合、右手操作用のボタン配置を徹底。
class CustomerConfirmationStep extends StatefulWidget {
  final TextEditingController phoneController;
  final TextEditingController nameController;
  final TextEditingController furiganaController;
  final TextEditingController companyController;
  final Customer? currentCustomer;
  final String phoneDisplay;
  final VoidCallback onNext;
  final VoidCallback onBack;

  // 所属企業・住所の検索（「配達先の確定」ステップと共通のFacilitySearchFormを利用）
  final String facilityControllerText;
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

  const CustomerConfirmationStep({
    super.key,
    required this.phoneController,
    required this.nameController,
    required this.furiganaController,
    required this.companyController,
    required this.currentCustomer,
    required this.phoneDisplay,
    required this.onNext,
    required this.onBack,
    required this.facilityControllerText,
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
  State<CustomerConfirmationStep> createState() => _CustomerConfirmationStepState();
}

class _CustomerConfirmationStepState extends State<CustomerConfirmationStep> {
  @override
  Widget build(BuildContext context) {
    final bool isNewCustomer = widget.currentCustomer == null;
    
    return OrderFormCard(
      title: isNewCustomer ? '新規顧客の登録' : '受注者（本人）の確認',
      icon: isNewCustomer ? Icons.person_add_alt_1_rounded : Icons.person_search_rounded,
      child: Column(
        children: [
          // 受電番号を大きく、美しく中央に。
          Container(
            padding: EdgeInsets.symmetric(vertical: rs(context, 16)),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(rs(context, 12)),
            ),
            child: Text(
              widget.phoneController.text,
              style: TextStyle(
                fontSize: rf(context, 64), 
                fontWeight: FontWeight.w900, 
                color: Colors.deepOrange, 
                letterSpacing: 4
              ),
            ),
          ),
          
          SizedBox(height: rs(context, 32)),

          if (!isNewCustomer) ...[
            // 既存顧客の場合：詳細情報を表示
            CustomerInfoBanner(customer: widget.currentCustomer),
          ] else ...[
            // 新規顧客の場合：整列された入力フォームを表示（ペン入力対応）
            // ふりがな・顧客名はどちらか一方の入力を必須とする
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: KMultimodalTextField(
                    label: 'ふりがな',
                    controller: widget.furiganaController,
                    hintText: 'ふりがなを書いてください',
                  ),
                ),
                SizedBox(width: rs(context, 24)),
                Expanded(
                  child: KMultimodalTextField(
                    label: '顧客名',
                    controller: widget.nameController,
                    hintText: 'お名前を書いてください',
                  ),
                ),
              ],
            ),
            Text('※ふりがな・顧客名のいずれか一方は必ず入力してください。',
              style: TextStyle(fontSize: rf(context, 11), color: Colors.grey)),

            SizedBox(height: rs(context, 24)),

            Text('所属企業・住所の確定',
              style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
            SizedBox(height: rs(context, 8)),
            FacilitySearchForm(
              facilityControllerText: widget.facilityControllerText,
              addressControllerText: widget.addressControllerText,
              prefList: widget.prefList,
              searchPrefecture: widget.searchPrefecture,
              searchCity: widget.searchCity,
              searchTown: widget.searchTown,
              searchCategory: widget.searchCategory,
              searchGenre: widget.searchGenre,
              searchTabIndex: widget.searchTabIndex,
              isApproximateLocation: widget.isApproximateLocation,
              keywordQueryController: widget.keywordQueryController,
              facilityResultsListenable: widget.facilityResultsListenable,
              isLoadingListenable: widget.isLoadingListenable,
              onAddressSelected: widget.onAddressSelected,
              onSearchTabChanged: widget.onSearchTabChanged,
              onPrefChanged: widget.onPrefChanged,
              onCityChanged: widget.onCityChanged,
              onTownChanged: widget.onTownChanged,
              onAddressConfirmed: widget.onAddressConfirmed,
              onPrefInitialChanged: widget.onPrefInitialChanged,
              onCityInitialChanged: widget.onCityInitialChanged,
              onTownInitialChanged: widget.onTownInitialChanged,
              onCategoryChanged: widget.onCategoryChanged,
              onGenreChanged: widget.onGenreChanged,
              onSearchSubmit: widget.onSearchSubmit,
              onDialogVisibilityChanged: widget.onDialogVisibilityChanged,
              onAdjustTap: widget.onAdjustTap,
            ),
          ],

          SizedBox(height: rs(context, 64)),

          // 右手で押しやすい操作ボタン（大きく、整列）
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: rs(context, 200),
                height: rs(context, 50),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey, width: rs(context, 2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
                  ),
                  onPressed: widget.onBack,
                  child: Text('番号を打ち直す', 
                    style: TextStyle(fontSize: rf(context, 16), color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(width: rs(context, 24)),
              SizedBox(
                width: rs(context, 320),
                height: rs(context, 50),
                child: KButton(
                  label: isNewCustomer ? '新規登録して次へ進む' : 'この顧客で受注する', 
                  onPressed: () {
                    if (isNewCustomer && widget.nameController.text.isEmpty && widget.furiganaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ふりがな・顧客名のいずれかを入力してください'), backgroundColor: Colors.redAccent)
                      );
                      return;
                    }
                    widget.onNext();
                  },
                  color: Colors.deepPurple
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
