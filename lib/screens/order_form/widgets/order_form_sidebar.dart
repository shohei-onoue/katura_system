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

class OrderFormSidebar extends StatefulWidget {
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
  final bool isSearchResultsDialogOpen;

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
    this.isSearchResultsDialogOpen = false,
  });

  @override
  State<OrderFormSidebar> createState() => _OrderFormSidebarState();
}

class _OrderFormSidebarState extends State<OrderFormSidebar> {
  // Mapのライフサイクルを安定させるためのKey
  final GlobalKey _mapKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 23,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          border: Border(left: BorderSide(color: Colors.grey.shade200))
        ),
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                // 小数点誤差を排除した絶対ピクセル計算
                final totalHeight = constraints.maxHeight.floorToDouble();
                final halfHeight = (totalHeight / 2).floorToDouble();
                final bottomAreaHeight = totalHeight - halfHeight - 1.0;

                return _buildContent(halfHeight, bottomAreaHeight);
              },
            ),
            if (widget.isLoading)
              Container(
                color: Colors.white.withValues(alpha: 0.6),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(double halfHeight, double bottomHeight) {
    // ステップ0 (番号入力)
    if (widget.currentStep == 0) {
      return SingleChildScrollView(
        child: SidebarPhonePad(
          controller: widget.phoneController, 
          onInput: widget.onPhoneInput, 
          onClear: widget.onPhoneClear, 
          onBackspace: widget.onPhoneBackspace
        ),
      );
    }

    // ステップ1 (顧客確認)
    if (widget.currentStep == 1) {
      return Column(
        children: [
          SizedBox(
            height: halfHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: rs(context, 12)),
              child: SidebarAnalysis(
                history: widget.customerOrderHistory, 
              ),
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: bottomHeight,
            child: SidebarRanking(
              history: widget.customerOrderHistory,
              allMenus: widget.allMenus,
            ),
          ),
        ],
      );
    }

    // ステップ2 (配達先確定) 以降
    return Column(
      children: [
        // 上部 50%: マップ (物理サイズ固定でエラー封殺)
        SizedBox(
          height: halfHeight,
          child: widget.isSearchResultsDialogOpen
              ? Container(
                  color: Colors.grey.shade100,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: rs(context, 48), color: Colors.grey.shade400),
                        SizedBox(height: rs(context, 12)),
                        Text('施設を選択中...', 
                          style: TextStyle(fontSize: rf(context, 16), color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              : GoogleMap(
                  key: _mapKey,
                  initialCameraPosition: CameraPosition(target: widget.initialCenter, zoom: 12),
                  onMapCreated: widget.onMapCreated,
                  markers: widget.markers,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                ),
        ),
        const Divider(height: 1, thickness: 1),
        // 下部 50%: 情報表示エリア
        SizedBox(
          height: bottomHeight,
          child: Column(
            children: [
              // 固定表示: 顧客・配達先テキスト
              _buildInfoTextSection(),
              
              // 配達先の確定ステップ (Step 2) の場合はここで終了 (マップと情報のみにする)
              if (widget.currentStep == 2) const Spacer(),

              // ステップ3以降はサマリーや分析を表示
              if (widget.currentStep > 2)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (widget.selectedHistoryItem != null) 
                          SidebarHistoryDetail(order: widget.selectedHistoryItem!) 
                        else 
                          SidebarSummary(
                            date: widget.deliveryDate, 
                            time: widget.selectedTime, 
                            customerName: widget.customerName, 
                            receiverName: widget.receiverName, 
                            totalPrice: widget.totalPrice, 
                            totalCount: widget.totalCount
                          ),
                        const Divider(height: 1),
                        Padding(
                          padding: EdgeInsets.all(rs(context, 24)),
                          child: SidebarAnalysis(
                            history: widget.customerOrderHistory, 
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTextSection() {
    final destMarker = widget.markers.any((m) => m.markerId.value == 'dest')
        ? widget.markers.firstWhere((m) => m.markerId.value == 'dest')
        : null;
    final coordsText = destMarker != null 
        ? "${destMarker.position.latitude.toStringAsFixed(6)}, ${destMarker.position.longitude.toStringAsFixed(6)}" 
        : null;

    final labelStyle = TextStyle(fontSize: rf(context, 12), color: Colors.blueGrey.shade700, fontWeight: FontWeight.bold);
    final valueStyle = TextStyle(fontSize: rf(context, 14), color: Colors.black87, fontWeight: FontWeight.w600);
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
          _buildInfoRow('顧客名：', widget.currentCustomer?.name ?? "-", valueStyle),
          _buildInfoRow('企業名：', widget.currentCustomer?.companyName ?? "-", valueStyle),
          _buildInfoRow('電話番号：', widget.currentCustomer?.phoneNumber ?? "-", valueStyle),
          
          const Divider(height: 16),
          
          Text('[配達先情報]', style: labelStyle),
          SizedBox(height: rs(context, 8)),
          _buildInfoRow('施設名：', widget.facilityName.isEmpty ? "未確定" : widget.facilityName, 
              widget.facilityName.isEmpty ? unconfirmedStyle : valueStyle),
          _buildInfoRow('住所：', widget.address.isEmpty ? "未確定" : widget.address, 
              widget.address.isEmpty ? unconfirmedStyle : valueStyle),
          _buildInfoRow('座標：', coordsText ?? "未確定", 
              coordsText == null ? unconfirmedStyle : valueStyle),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, TextStyle valueStyle) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: rs(context, 75), // 固定幅ラベルで「ぶら下げインデント」を実現
            child: Text(label, style: TextStyle(fontSize: rf(context, 14), color: Colors.blueGrey.shade800)),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
