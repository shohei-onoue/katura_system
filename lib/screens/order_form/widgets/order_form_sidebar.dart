import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../models/order_model.dart';
import '../../../models/customer_model.dart';
import '../../../models/menu_model.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_date_time_display.dart';
import 'sidebar/sidebar_phone_pad.dart';
import 'sidebar/sidebar_history_detail.dart';
import 'sidebar/sidebar_summary.dart';
import 'sidebar/sidebar_analysis.dart';
import 'sidebar/sidebar_ranking.dart';

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
  final String deliveryType;
  final DateTime deliveryDate;
  final DateTime selectedTime;
  final bool isDateSelected;
  final bool isTimeSelected;
  final bool isTypeSelected;
  final String customerName;
  final String facilityName;
  final String address;
  final String deliveryLocation;
  final String receiverName;
  final int totalPrice;
  final int totalCount;
  final Set<Marker> markers;
  final LatLng initialCenter;
  final String? deliveryDestinationImageUrl;
  final List<Map<String, dynamic>> confirmedItems;
  final Function(String, int)? onQuantityChanged;
  
  // ゴミ回収情報
  final bool trashPickupRequested;
  final DateTime? trashPickupDateTime;
  final String trashPickupLocation;
  final String trashPickupLocationDetail;

  final Function(String) onPhoneInput;
  final VoidCallback onPhoneClear;
  final VoidCallback onPhoneBackspace;
  final Function(GoogleMapController) onMapCreated;
  final VoidCallback onSidebarResultsClose;
  final Function(Map<String, dynamic>) onFacilitySelect;
  final VoidCallback onForceApiSearch;
  final VoidCallback? onNext;
  final VoidCallback? onReset;
  final Function(LatLng)? onMapTap;
  final Function(LatLng)? onMarkerDragEnd;
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
    required this.deliveryType,
    required this.deliveryDate,
    required this.selectedTime,
    this.isDateSelected = false,
    this.isTimeSelected = false,
    this.isTypeSelected = false,
    required this.customerName,
    required this.facilityName,
    required this.address,
    required this.deliveryLocation,
    required this.receiverName,
    required this.totalPrice,
    required this.totalCount,
    required this.markers,
    required this.initialCenter,
    this.onMarkerDragEnd,
    this.deliveryDestinationImageUrl,
    this.confirmedItems = const [],
    this.onQuantityChanged,
    required this.trashPickupRequested,
    this.trashPickupDateTime,
    required this.trashPickupLocation,
    required this.trashPickupLocationDetail,
    required this.onPhoneInput,
    required this.onPhoneClear,
    required this.onPhoneBackspace,
    required this.onMapCreated,
    required this.onSidebarResultsClose,
    required this.onFacilitySelect,
    required this.onForceApiSearch,
    this.onNext,
    this.onReset,
    this.onMapTap,
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
        child: Column(
          children: [
            if (widget.currentStep >= 2) _buildPhoneHeader(),
            Expanded(
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final totalHeight = constraints.maxHeight.floorToDouble();
                      final width = constraints.maxWidth.floorToDouble();

                      // マップが表示されるステップ(2)では正方形(幅と同じ高さ)にする
                      final double topAreaHeight;
                      if (widget.currentStep == 2) {
                        topAreaHeight = width;
                      } else if (widget.currentStep == 3) {
                        topAreaHeight = 0; // ステップ3ではマップを非表示
                      } else {
                        topAreaHeight = (totalHeight / 2).floorToDouble();
                      }

                      final bottomAreaHeight = totalHeight - topAreaHeight - 1.0;

                      return _buildContent(topAreaHeight, bottomAreaHeight);
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
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: rs(context, 12), horizontal: rs(context, 16)),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50,
        border: Border(bottom: BorderSide(color: Colors.deepOrange.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_callback, size: rs(context, 18), color: Colors.deepOrange),
          const SizedBox(width: 12),
          Text(
            '受電：${widget.phoneController.text}',
            style: TextStyle(
              fontSize: rf(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(double topAreaHeight, double bottomHeight) {
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
            height: topAreaHeight,
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

    // ステップ2 (配達先確定)
    if (widget.currentStep == 2) {
      return Column(
        children: [
          SizedBox(
            height: topAreaHeight,
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
                    onTap: widget.onMapTap,
                    markers: widget.markers.map((m) {
                      if (m.markerId.value == 'dest') {
                        return m.copyWith(
                          draggableParam: true,
                          onDragEndParam: widget.onMarkerDragEnd,
                        );
                      }
                      return m;
                    }).toSet(),
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                  ),
          ),
          const Divider(height: 1, thickness: 1),
          SizedBox(
            height: bottomHeight,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildInfoTextSection(),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // ステップ3 (配達日時) - 決定事項を大きく表示
    if (widget.currentStep == 3) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(rs(context, 16)),
            color: Colors.blueGrey.shade50,
            child: Row(
              children: [
                Icon(Icons.fact_check, color: Colors.blueGrey, size: rs(context, 20)),
                SizedBox(width: 8),
                Text('現在の決定事項', style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(rs(context, 12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDecisionCard(
                    title: '配達・引取情報',
                    icon: Icons.local_shipping,
                    color: Colors.deepPurple,
                    child: KDateTimeDisplay(
                      label: '', 
                      dateTime: widget.isDateSelected && widget.isTimeSelected 
                        ? widget.deliveryDate.copyWith(hour: widget.selectedTime.hour, minute: widget.selectedTime.minute) 
                        : null,
                      onTap: () {}, // サイドバーからは操作不可
                      themeColor: Colors.deepPurple,
                      isCompact: true,
                    ),
                  ),
                  SizedBox(height: rs(context, 16)),
                  if (widget.trashPickupRequested)
                    _buildDecisionCard(
                      title: 'ゴミ回収情報',
                      icon: Icons.delete_outline,
                      color: Colors.orange,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KDateTimeDisplay(
                            label: '', 
                            dateTime: widget.trashPickupDateTime,
                            onTap: () {},
                            themeColor: Colors.orange,
                            isCompact: true,
                          ),
                          SizedBox(height: rs(context, 8)),
                          Text(
                            '回収場所：${widget.trashPickupLocation == '指定場所' ? (widget.trashPickupLocationDetail.isEmpty ? '未入力' : widget.trashPickupLocationDetail) : widget.trashPickupLocation}', 
                            style: TextStyle(
                              fontSize: rf(context, 12), 
                              fontWeight: FontWeight.bold, 
                              color: Colors.black
                            )
                          ),
                        ],
                      ),
                    )
                  else
                    _buildDecisionCard(
                      title: 'ゴミ回収',
                      icon: Icons.delete_sweep_outlined,
                      color: Colors.grey,
                      child: const Text('ゴミ回収希望なし', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  
                  const Divider(height: 48),
                  Text('[基本情報]', style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  SizedBox(height: 8),
                  _buildInfoRow('顧客名：', widget.customerName, TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold)),
                  _buildInfoRow('施設名：', widget.facilityName.isEmpty ? "未確定" : widget.facilityName, TextStyle(fontSize: rf(context, 14))),
                  _buildInfoRow('受取人：', widget.receiverName.isEmpty ? "未確定" : widget.receiverName, TextStyle(fontSize: rf(context, 14))),
                  
                  if (widget.onReset != null) ...[
                    const Divider(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onReset,
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('受注をキャンセル', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    // ステップ4 (注文内容) - カート表示
    if (widget.currentStep == 4) {
      return _buildCartView();
    }

    // ステップ5 (支払・完了) 以降
    return Column(
      children: [
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
                if (widget.onReset != null) ...[
                  Padding(
                    padding: EdgeInsets.all(rs(context, 16)),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onReset,
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('受注をキャンセル', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
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
    );
  }

  Widget _buildDecisionCard({required String title, required IconData icon, required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 12)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCartView() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(rs(context, 16)),
          color: Colors.deepOrange.shade50,
          child: Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.deepOrange, size: rs(context, 20)),
              SizedBox(width: 8),
              Text('カートの中身', style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: Colors.deepOrange.shade900)),
              Spacer(),
              Text('${widget.confirmedItems.length} 点', style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: widget.confirmedItems.isEmpty
              ? Center(child: Text('カートは空です', style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  padding: EdgeInsets.all(rs(context, 16)),
                  itemCount: widget.confirmedItems.length,
                  separatorBuilder: (context, index) => Divider(height: 24),
                  itemBuilder: (context, i) {
                    final item = widget.confirmedItems[i];
                    final specialOrder = item['specialOrder'] as String? ?? '';
                    final specialOrderQty = item['specialOrderQuantity'] as int? ?? item['quantity'];
                    final teaOption = item['teaOption'] as String? ?? 'なし';
                    final teaQty = item['teaQuantity'] as int? ?? 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'], style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold)),
                        if (specialOrder.isNotEmpty || teaOption != 'なし') ...[
                          const SizedBox(height: 4),
                          if (specialOrder.isNotEmpty) 
                            Text('・特注 ($specialOrderQty個): $specialOrder', style: TextStyle(fontSize: rf(context, 11), color: Colors.blueGrey)),
                          if (teaOption != 'なし') 
                            Text('・お茶: $teaOption${teaOption == '特典' ? ' ($teaQty本)' : ''}', style: TextStyle(fontSize: rf(context, 11), color: Colors.blueGrey)),
                        ],
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text('¥${item['price']}', style: TextStyle(color: Colors.blueGrey, fontSize: rf(context, 12))),
                            Spacer(),
                            _buildCompactCounter(i, item),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text('小計: ¥${item['price'] * item['quantity']}', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 13))),
                        ),
                      ],
                    );
                  },
                ),
        ),
        Container(
          padding: EdgeInsets.all(rs(context, 20)),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('合計金額', style: TextStyle(fontSize: rf(context, 14), color: Colors.grey.shade700)),
                  Text('¥${widget.totalPrice}', style: TextStyle(fontSize: rf(context, 24), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                ],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('合計数量', style: TextStyle(fontSize: rf(context, 14), color: Colors.grey.shade700)),
                  Text('${widget.totalCount} 個', style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold)),
                ],
              ),
              if (widget.confirmedItems.isNotEmpty) ...[
                SizedBox(height: 20),
                KButton(
                  label: '注文内容を確定する',
                  onPressed: widget.onNext ?? () {},
                ),
                if (widget.onReset != null) ...[
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: widget.onReset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('受注をキャンセル', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactCounter(int index, Map<String, dynamic> item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _counterBtn(Icons.remove, () {
          if (item['quantity'] > 0) widget.onQuantityChanged?.call(index.toString(), item['quantity'] - 1);
        }),
        Container(
          width: rs(context, 40),
          alignment: Alignment.center,
          child: Text('${item['quantity']}', style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
        ),
        _counterBtn(Icons.add, () {
          widget.onQuantityChanged?.call(index.toString(), item['quantity'] + 1);
        }),
      ],
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: Colors.deepPurple),
      ),
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

          const Divider(height: 16),
          Text('[配達日時情報]', style: labelStyle),
          SizedBox(height: rs(context, 8)),
          _buildInfoRow('区分：', widget.isTypeSelected ? widget.deliveryType : "未確定", 
              widget.isTypeSelected ? valueStyle : unconfirmedStyle),
          _buildInfoRow('配達日：', widget.isDateSelected ? DateFormat('yyyy/MM/dd(E)', 'ja_JP').format(widget.deliveryDate) : "未確定", 
              widget.isDateSelected ? valueStyle : unconfirmedStyle),
          _buildInfoRow('時間：', widget.isTimeSelected ? "${widget.selectedTime.hour}:${widget.selectedTime.minute.toString().padLeft(2, '0')}" : "未確定", 
              widget.isTimeSelected ? valueStyle : unconfirmedStyle),
          _buildInfoRow('受取人：', widget.receiverName.isEmpty ? "未確定" : widget.receiverName, 
              widget.receiverName.isEmpty ? unconfirmedStyle : valueStyle),

          if (widget.deliveryDestinationImageUrl != null) ...[
            const Divider(height: 16),
            Text('[配達先写真]', style: labelStyle),
            SizedBox(height: rs(context, 8)),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.deliveryDestinationImageUrl!,
                height: rs(context, 200),
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: rs(context, 150),
                  color: Colors.grey.shade100,
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
          ],
          if (widget.onReset != null) ...[
            const Divider(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onReset,
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('受注をキャンセル', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
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
