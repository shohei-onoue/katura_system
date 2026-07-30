import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/order_model.dart';
import '../../../models/customer_model.dart';
import '../../../models/menu_model.dart';
import '../../../../widgets/k_responsive.dart';
import 'order_form_parts.dart';
import 'sidebar/sidebar_phone_pad.dart';
import 'sidebar/sidebar_results.dart';
import 'sidebar/sidebar_history_detail.dart';
import 'sidebar/sidebar_summary.dart';
import 'sidebar/sidebar_analysis.dart';
import 'sidebar/sidebar_ranking.dart';
import 'sidebar/sidebar_destination_info.dart';

class OrderFormSidebar extends StatelessWidget {
  final int currentStep;
  final TextEditingController phoneController;
  final bool isLoading;
  final Customer? currentCustomer;
  final List<MenuModel> allMenus;
  final List<OrderModel> customerOrderHistory;
  final List<OrderModel> companyOrderHistory;
  final List<Map<String, dynamic>> facilitySearchCandidates;
  final OrderModel? selectedHistoryItem;
  final DateTime deliveryDate;
  final DateTime selectedTime;
  final String customerName;
  final String facilityName;
  final String address;
  final String deliveryLocation;
  final String receiverName;
  final int totalPrice;
  final int totalCount;
  final Set<Marker> markers;
  final LatLng initialCenter;
  
  final Function(String) onPhoneInput;
  final VoidCallback onPhoneClear;
  final VoidCallback onPhoneBackspace;
  final Function(GoogleMapController) onMapCreated;
  final VoidCallback onSidebarResultsClose;
  final Function(Map<String, dynamic>) onFacilitySelect;
  final VoidCallback onForceApiSearch;

  const OrderFormSidebar({
    super.key,
    required this.currentStep,
    required this.phoneController,
    required this.isLoading,
    this.currentCustomer,
    required this.allMenus,
    required this.customerOrderHistory,
    required this.companyOrderHistory,
    required this.facilitySearchCandidates,
    required this.selectedHistoryItem,
    required this.deliveryDate,
    required this.selectedTime,
    required this.customerName,
    required this.facilityName,
    required this.address,
    required this.deliveryLocation,
    required this.receiverName,
    required this.totalPrice,
    required this.totalCount,
    required this.markers,
    required this.initialCenter,
    required this.onPhoneInput,
    required this.onPhoneClear,
    required this.onPhoneBackspace,
    required this.onMapCreated,
    required this.onSidebarResultsClose,
    required this.onFacilitySelect,
    required this.onForceApiSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 23,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          border: Border(left: BorderSide(color: Colors.grey.shade200))
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalHeight = constraints.maxHeight.floorToDouble();
            final halfHeight = (totalHeight / 2).floorToDouble();

            // ステップ0 (番号入力)
            if (currentStep == 0) {
              return SingleChildScrollView(
                child: SidebarPhonePad(
                  controller: phoneController, 
                  onInput: onPhoneInput, 
                  onClear: onPhoneClear, 
                  onBackspace: onPhoneBackspace
                ),
              );
            }

            // ステップ1 (顧客確認)
            if (currentStep == 1) {
              return Column(
                children: [
                  SizedBox(
                    height: halfHeight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: rs(context, 12)),
                      child: SidebarAnalysis(
                        history: customerOrderHistory, 
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SizedBox(
                    height: totalHeight - halfHeight - 1,
                    child: SidebarRanking(
                      history: customerOrderHistory,
                      allMenus: allMenus,
                    ),
                  ),
                ],
              );
            }

            // ステップ2 (配達先確定) 以降
            // Stack + Positioned による絶対配置で、マップの描画エラーを物理的に回避
            return Stack(
              children: [
                // 上部 50%: マップ
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: halfHeight,
                  child: GoogleMap(
                    key: const PageStorageKey('sidebar_map'),
                    initialCameraPosition: CameraPosition(target: initialCenter, zoom: 12),
                    onMapCreated: onMapCreated,
                    markers: markers,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                  ),
                ),
                // 中央の境界線
                Positioned(
                  top: halfHeight,
                  left: 0,
                  right: 0,
                  child: const Divider(height: 1),
                ),
                // 下部 50%: 各種情報
                Positioned(
                  top: halfHeight + 1,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    children: [
                      // 顧客情報・配達先情報
                      _buildInfoTextSection(context),
                      
                      // スクロールエリア (履歴詳細や統計グラフ)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              if (facilitySearchCandidates.isNotEmpty) 
                                SidebarSearchResults(
                                  results: facilitySearchCandidates, 
                                  onClose: onSidebarResultsClose, 
                                  onSelect: onFacilitySelect, 
                                  onForceApiSearch: onForceApiSearch
                                ) 
                              else ...[
                                if (selectedHistoryItem != null) 
                                  SidebarHistoryDetail(order: selectedHistoryItem!) 
                                else 
                                  SidebarSummary(
                                    date: deliveryDate, 
                                    time: selectedTime, 
                                    customerName: customerName, 
                                    receiverName: receiverName, 
                                    totalPrice: totalPrice, 
                                    totalCount: totalCount
                                  ),
                                const Divider(height: 1),
                                Padding(
                                  padding: EdgeInsets.all(rs(context, 24)),
                                  child: SidebarAnalysis(
                                    history: customerOrderHistory, 
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoTextSection(BuildContext context) {
    final destMarker = markers.any((m) => m.markerId.value == 'dest')
        ? markers.firstWhere((m) => m.markerId.value == 'dest')
        : null;
    final coordsText = destMarker != null 
        ? "${destMarker.position.latitude.toStringAsFixed(6)}, ${destMarker.position.longitude.toStringAsFixed(6)}" 
        : null;

    final labelStyle = TextStyle(fontSize: rf(context, 12), color: Colors.blueGrey.shade700, fontWeight: FontWeight.bold);
    final valueStyle = TextStyle(fontSize: rf(context, 14), color: Colors.black87, fontWeight: FontWeight.w500);
    final unconfirmedStyle = TextStyle(fontSize: rf(context, 14), color: Colors.red, fontWeight: FontWeight.bold);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('[顧客情報]', style: labelStyle),
          SizedBox(height: rs(context, 8)),
          _buildInfoRow(context, '顧客名：', currentCustomer?.name ?? "-", valueStyle),
          _buildInfoRow(context, '企業名：', currentCustomer?.companyName ?? "-", valueStyle),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          
          Text('[配達先情報]', style: labelStyle),
          SizedBox(height: rs(context, 8)),
          _buildInfoRow(context, '施設名：', facilityName.isEmpty ? "未確定" : facilityName, 
              facilityName.isEmpty ? unconfirmedStyle : valueStyle),
          _buildInfoRow(context, '住所：', address.isEmpty ? "未確定" : address, 
              address.isEmpty ? unconfirmedStyle : valueStyle),
          _buildInfoRow(context, '座標：', coordsText ?? "未確定", 
              coordsText == null ? unconfirmedStyle : valueStyle),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, TextStyle valueStyle) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: rs(context, 65), // ラベルの幅を固定してインデントを揃える
            child: Text(label, style: TextStyle(fontSize: rf(context, 14), color: Colors.black87)),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle,
              softWrap: true, // 自動改行
            ),
          ),
        ],
      ),
    );
  }
}
