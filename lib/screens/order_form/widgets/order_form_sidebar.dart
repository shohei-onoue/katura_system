import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/order_model.dart';
import '../../../models/customer_model.dart';
import '../../../models/menu_model.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_date_time_display.dart';
import 'order_form_parts.dart';
import 'sidebar/sidebar_phone_pad.dart';

class OrderFormSidebar extends StatefulWidget {
  final int currentStep;
  final bool isCompletingPhone;
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
  final String? estimatedDeliveryDuration;
  final String branchName;
  final List<Map<String, dynamic>> confirmedItems;
  final Function(String, int)? onQuantityChanged;
  
  // ゴミ回収情報
  final bool trashPickupRequested;
  final DateTime? trashPickupDateTime;
  final String trashPickupLocation;
  final String trashPickupLocationDetail;

  // 支払・完了ステップ（step 5）情報
  final String packagingType;
  final int packagingSmallQty;
  final String packagingOther;
  final String preConfirmationMethod;
  final String preConfirmationPhoneType;
  final String preConfirmationPhoneNumber;
  final DateTime? preConfirmationDateTime;
  final String preConfirmationSmsTime;
  final DateTime? scheduledSmsDateTime;
  final String phoneDisplay;
  final String paymentMethod;
  final String preConfirmationRecipient;
  final VoidCallback? onShowInvoice;

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
    this.isCompletingPhone = false,
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
    this.estimatedDeliveryDuration,
    this.branchName = '',
    this.confirmedItems = const [],
    this.onQuantityChanged,
    required this.trashPickupRequested,
    this.trashPickupDateTime,
    required this.trashPickupLocation,
    required this.trashPickupLocationDetail,
    this.packagingType = '',
    this.packagingSmallQty = 0,
    this.packagingOther = '',
    this.preConfirmationMethod = '',
    this.preConfirmationPhoneType = '',
    this.preConfirmationPhoneNumber = '',
    this.preConfirmationDateTime,
    this.preConfirmationSmsTime = '',
    this.scheduledSmsDateTime,
    this.phoneDisplay = '',
    this.paymentMethod = '',
    this.preConfirmationRecipient = '',
    this.onShowInvoice,
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
          color: KR.backgroundLight,
          border: Border(left: BorderSide(color: Colors.grey.shade200))
        ),
        child: Column(
          children: [
            _buildPhoneHeader(),
            Expanded(
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final totalHeight = constraints.maxHeight.floorToDouble();
                      final width = constraints.maxWidth.floorToDouble();

                      // マップが表示されるステップ(1・2)では正方形(幅と同じ高さ)にする
                      final double topAreaHeight;
                      if (widget.currentStep == 1 || widget.currentStep == 2) {
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

  // メイン画面の①〜⑥ステップタイトルバー(KStepper)と同じ高さの帯にする
  // (受電情報がないステップでも高さを空けておき、下のタイトルバーのY位置を全ステップで揃える)
  Widget _buildPhoneHeader() {
    return Container(
      width: double.infinity,
      height: rav(context, 50),
      decoration: BoxDecoration(
        color: widget.currentStep >= 2 ? Colors.deepOrange.shade50 : Colors.transparent,
        border: widget.currentStep >= 2 ? Border(bottom: BorderSide(color: Colors.deepOrange.shade100)) : null,
      ),
      child: null,
    );
  }

  Widget _buildContent(double topAreaHeight, double bottomHeight) {
    // ステップ0 (番号入力)
    if (widget.currentStep == 0) {
      return Column(
        children: [
          SizedBox(height: rav(context, 24)),
          Expanded(
            child: SingleChildScrollView(
              child: SidebarPhonePad(
                controller: widget.phoneController,
                onInput: widget.onPhoneInput,
                onClear: widget.onPhoneClear,
                onBackspace: widget.onPhoneBackspace
              ),
            ),
          ),
        ],
      );
    }

    // ステップ1 (顧客確認・新規顧客の登録) - 所属企業の場所をマップで表示
    if (widget.currentStep == 1) {
      return Column(
        children: [
          SizedBox(height: rav(context, 24)),
          const SidebarSectionTitle(title: '所属企業情報', icon: Icons.apartment),
          SizedBox(height: topAreaHeight, child: _buildMap()),
          Divider(height: rs(context, 1), thickness: 1),
          Expanded(child: _buildFacilitySummarySection()),
        ],
      );
    }

    // ステップ2 (配達先確定)
    if (widget.currentStep == 2) {
      return Column(
        children: [
          SizedBox(height: rav(context, 24)),
          const SidebarSectionTitle(title: '配達先情報の確認', icon: Icons.location_on),
          SizedBox(height: topAreaHeight, child: _buildMap()),
          Divider(height: rs(context, 1), thickness: 1),
          Expanded(child: _buildInfoTextSection()),
        ],
      );
    }

    // ステップ3 (配達日時) - 決定事項を大きく表示
    if (widget.currentStep == 3) {
      return Column(
        children: [
          SizedBox(height: rav(context, 24)),
          const SidebarSectionTitle(title: '現在の決定事項', icon: Icons.fact_check),
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
                          // 回収場所も日時フィールドと同じフィールド表示にする
                          _buildFieldLike(
                            widget.trashPickupLocation == '指定場所'
                                ? (widget.trashPickupLocationDetail.isEmpty ? '未入力' : widget.trashPickupLocationDetail)
                                : widget.trashPickupLocation,
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

                  SizedBox(height: rs(context, 16)),
                  _buildDecisionCard(
                    title: '受取人氏名',
                    icon: Icons.person_outline,
                    color: Colors.blueGrey,
                    child: _buildFieldLike(widget.receiverName.isEmpty ? "未確定" : widget.receiverName),
                  ),
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

    // ステップ5 (支払・完了)
    return _buildFinalizeSummary();
  }

  Widget _buildFinalizeSummary() {
    // 梱包方法の表示文言
    String packaging = widget.packagingType.isEmpty ? '未選択' : widget.packagingType;
    if (widget.packagingType == '小分け' && widget.packagingSmallQty > 0) {
      packaging = '小分け（${widget.packagingSmallQty}個ずつ）';
    } else if (widget.packagingType == 'その他' && widget.packagingOther.isNotEmpty) {
      packaging = 'その他（${widget.packagingOther}）';
    }

    // 事前連絡：宛先 / 方法 / 番号 / 日時
    final String preRecipient = widget.preConfirmationRecipient.isEmpty ? '未設定' : widget.preConfirmationRecipient;
    final String preMethod = widget.preConfirmationMethod.isEmpty
        ? '未設定'
        : (widget.preConfirmationMethod == 'SMS' ? 'SMS' : '電話連絡');
    final String preNumber = widget.preConfirmationPhoneType == '指定番号へ連絡'
        ? (widget.preConfirmationPhoneNumber.isEmpty ? '指定番号（未入力）' : widget.preConfirmationPhoneNumber)
        : (widget.phoneDisplay.isEmpty ? '受電番号' : widget.phoneDisplay);
    String preWhen = '未設定';
    if (widget.preConfirmationMethod == 'SMS') {
      if (widget.scheduledSmsDateTime != null) {
        preWhen = '${_fmtDateTime(widget.scheduledSmsDateTime!)} 送信予約';
      } else if (widget.preConfirmationSmsTime.isNotEmpty) {
        preWhen = '前日 ${widget.preConfirmationSmsTime} 自動送信';
      }
    } else if (widget.preConfirmationMethod == '電話') {
      preWhen = widget.preConfirmationDateTime != null ? _fmtDateTime(widget.preConfirmationDateTime!) : '未設定';
    }

    return Column(
      children: [
        SizedBox(height: rav(context, 24)),
        const SidebarSectionTitle(title: '最終確認', icon: Icons.receipt_long),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(rs(context, 12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDecisionCard(
                  title: '梱包方法',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.deepPurple,
                  child: _buildFieldLike(packaging),
                ),
                SizedBox(height: rs(context, 8)),
                _buildDecisionCard(
                  title: '事前連絡',
                  icon: Icons.notifications_active_outlined,
                  color: Colors.blue,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabeledLine(context, '宛先', preRecipient),
                      SizedBox(height: rs(context, 4)),
                      _buildLabeledLine(context, '方法', preMethod),
                      SizedBox(height: rs(context, 4)),
                      _buildLabeledLine(context, '番号', preNumber),
                      SizedBox(height: rs(context, 4)),
                      _buildLabeledLine(context, '日時', preWhen),
                    ],
                  ),
                ),
                SizedBox(height: rs(context, 8)),
                _buildDecisionCard(
                  title: '支払方法・金額',
                  icon: Icons.payments_outlined,
                  color: Colors.deepOrange,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLike(widget.paymentMethod.isEmpty ? '未選択' : widget.paymentMethod),
                      SizedBox(height: rs(context, 8)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('合計金額', style: TextStyle(fontSize: rf(context, 13), color: Colors.grey.shade700)),
                          Text('¥${widget.totalPrice}',
                              style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _fmtDateTime(DateTime d) =>
      '${d.month}/${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Widget _buildMap() {
    return widget.isSearchResultsDialogOpen
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
          );
  }

  /// ステップ1（顧客確認・新規顧客の登録）下部：施設名／住所／ストリートビュー画像（座標は非表示）
  Widget _buildFacilitySummarySection() {
    // 新規顧客は検索中の入力値、既存顧客は登録済みの所属企業情報を表示する
    final facilityName = widget.facilityName.isNotEmpty ? widget.facilityName : (widget.currentCustomer?.companyName ?? '');
    final address = widget.address.isNotEmpty ? widget.address : (widget.currentCustomer?.address ?? '');

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
          Text('[所属企業情報]', style: labelStyle),
          SizedBox(height: rs(context, 8)),
          _buildInfoRowIcon(Icons.business, facilityName.isEmpty ? "未確定" : facilityName,
              facilityName.isEmpty ? unconfirmedStyle : valueStyle),
          _buildInfoRowIcon(Icons.location_on, address.isEmpty ? "未確定" : address,
              address.isEmpty ? unconfirmedStyle : valueStyle),
          if (widget.deliveryDestinationImageUrl != null) ...[
            SizedBox(height: rs(context, 8)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(rs(context, 8)),
                child: Image.network(
                  widget.deliveryDestinationImageUrl!,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade100,
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDecisionCard({required String title, required IconData icon, required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 12)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: rs(context, 18)),
              SizedBox(width: rs(context, 8)),
              Text(title, style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          SizedBox(height: rs(context, 12)),
          child,
        ],
      ),
    );
  }

  Widget _buildCartView() {
    return Column(
      children: [
        SizedBox(height: rav(context, 24)),
        SidebarSectionTitle(
          title: 'カートの中身',
          icon: Icons.shopping_cart,
          trailing: Text('${widget.confirmedItems.length} 点', style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        Expanded(
          child: widget.confirmedItems.isEmpty
              ? Center(child: Text('カートは空です', style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  padding: EdgeInsets.all(rs(context, 16)),
                  itemCount: widget.confirmedItems.length,
                  separatorBuilder: (context, index) => SizedBox(height: rs(context, 12)),
                  itemBuilder: (context, i) {
                    final item = widget.confirmedItems[i];
                    final specialOrder = item['specialOrder'] as String? ?? '';
                    final specialOrderQty = item['specialOrderQuantity'] as int? ?? item['quantity'];
                    final teaOption = item['teaOption'] as String? ?? 'なし';
                    final teaQty = item['teaQuantity'] as int? ?? 0;
                    final qtyLabelStyle = TextStyle(fontSize: rf(context, 11), fontWeight: FontWeight.bold, color: Colors.black);

                    return Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rs(context, 8)),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(rs(context, 12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'], style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: (specialOrder.isNotEmpty || teaOption != 'なし') ? Colors.orange : null)),
                            if (specialOrder.isNotEmpty || teaOption != 'なし') ...[
                              SizedBox(height: rs(context, 4)),
                              if (specialOrder.isNotEmpty) ...[
                                Text.rich(
                                  TextSpan(
                                    style: qtyLabelStyle,
                                    children: [
                                      TextSpan(text: '特注 $specialOrderQty個: '),
                                      TextSpan(text: specialOrder, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                if ((item['quantity'] as int) - specialOrderQty > 0)
                                  Padding(
                                    padding: EdgeInsets.only(top: rs(context, 2)),
                                    child: Text('通常 ${(item['quantity'] as int) - specialOrderQty}個', style: qtyLabelStyle),
                                  ),
                              ],
                              if (teaOption != 'なし')
                                Text('・お茶: $teaOption${teaOption == '特典' ? ' ($teaQty本)' : ''}', style: TextStyle(fontSize: rf(context, 11), color: Colors.blueGrey)),
                            ],
                            SizedBox(height: rs(context, 8)),
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
                        ),
                      ),
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
              SizedBox(height: rs(context, 4)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('合計数量', style: TextStyle(fontSize: rf(context, 14), color: Colors.grey.shade700)),
                  Text('${widget.totalCount} 個', style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold)),
                ],
              ),
              if (widget.confirmedItems.isNotEmpty) ...[
                SizedBox(height: rs(context, 20)),
                KButton(
                  label: '注文内容を確定する',
                  onPressed: widget.onNext ?? () {},
                ),
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
        padding: EdgeInsets.all(rs(context, 4)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(rs(context, 4)),
        ),
        child: Icon(icon, size: rs(context, 16), color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildInfoTextSection() {
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
          // 配達元(青ピン) → 店舗名 → ＞＞＞ → 配達先(赤ピン)
          Row(
            children: [
              Icon(Icons.location_on, size: rs(context, 18), color: Colors.blue),
              SizedBox(width: rs(context, 6)),
              Flexible(
                child: Text(widget.branchName.isEmpty ? "未確定" : widget.branchName,
                    style: widget.branchName.isEmpty ? unconfirmedStyle : valueStyle,
                    overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: rs(context, 6)),
              Icon(Icons.keyboard_double_arrow_right, size: rs(context, 18), color: Colors.blueGrey.shade400),
              SizedBox(width: rs(context, 6)),
              Icon(Icons.location_on, size: rs(context, 18), color: Colors.red),
            ],
          ),
          SizedBox(height: rs(context, 10)),
          _buildInfoRowIcon(Icons.business, widget.facilityName.isEmpty ? "未確定" : widget.facilityName,
              widget.facilityName.isEmpty ? unconfirmedStyle : valueStyle),
          _buildInfoRowIcon(Icons.location_on, widget.address.isEmpty ? "未確定" : widget.address,
              widget.address.isEmpty ? unconfirmedStyle : valueStyle),

          if (widget.deliveryDestinationImageUrl != null) ...[
            SizedBox(height: rs(context, 8)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(rs(context, 8)),
                child: Image.network(
                  widget.deliveryDestinationImageUrl!,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade100,
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// カード内の日時フィールドと同じ見た目の値表示フィールド
  Widget _buildFieldLike(String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 8)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(rs(context, 12)),
      ),
      child: Text(
        value,
        style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  /// 小タイトル＋値フィールドを縦に並べる（事前連絡カードの 宛先/方法/番号/日時 用）
  Widget _buildLabeledLine(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: rf(context, 11), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade600)),
        SizedBox(height: rs(context, 3)),
        _buildFieldLike(value),
      ],
    );
  }

  Widget _buildInfoRowIcon(IconData icon, String value, TextStyle valueStyle) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: rs(context, 8), top: rs(context, 2)),
            child: Icon(icon, size: rs(context, 18), color: Colors.blueGrey.shade600),
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
