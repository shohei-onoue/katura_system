import 'package:katura_system/utils/history_entry.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/customer_model.dart';
import '../../../services/customer_service.dart';
import '../../../services/street_view_image_service.dart';
import '../../../widgets/k_location_adjustment_dialog.dart';
import '../../../widgets/k_responsive.dart';
import '../../../widgets/k_pen_input_dialog.dart';
import '../../../widgets/k_numeric_input_dialog.dart';
import '../../order_form/widgets/steps/facility_search_host_dialog.dart';
import 'package:katura_system/utils/app_colors.dart';
import '../../phone/phone_common.dart';
import '../../phone/phone_customer_style.dart';

class CustomerDetailDialog extends StatefulWidget {
  final Customer customer;
  final CustomerService customerService;
  final VoidCallback? onSaved;

  const CustomerDetailDialog({
    super.key,
    required this.customer,
    required this.customerService,
    this.onSaved,
  });

  @override
  State<CustomerDetailDialog> createState() => _CustomerDetailDialogState();
}

class _CustomerDetailDialogState extends State<CustomerDetailDialog> {
  late String _name;
  late String _furigana;
  late String _phone;
  late String _companyName;
  late String _address;
  late double? _latitude;
  late double? _longitude;
  bool _saving = false;
  bool _busy = false; // 配達先の調整（地図・画像保存）中
  int _selected = 0; // 選択中の配達先履歴
  late List<String> _addresses; // 配達先履歴（調整した分は「保存」で確定）
  String? _svUrl;
  String? _svPath;

  @override
  void initState() {
    super.initState();
    _name = widget.customer.name;
    _furigana = widget.customer.furigana;
    _phone = widget.customer.phoneNumber;
    _addresses = List.of(widget.customer.deliveryAddresses);
    _svUrl = widget.customer.streetViewImageUrl;
    _svPath = widget.customer.streetViewImagePath;
    _companyName = widget.customer.companyName;
    _address = widget.customer.address;
    _latitude = widget.customer.latitude;
    _longitude = widget.customer.longitude;
  }

  /// 文字の項目（顧客名・ふりがな・メール）を、手書き（またはキーボード）入力ダイアログで編集する。
  void _editText(String current, ValueChanged<String> apply) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => KPenInputDialog(
        initialText: current,
        onTextRecognized: (t) => setState(() => apply(t.trim())),
      ),
    );
  }

  void _editPhone() {
    showDialog(
      context: context,
      builder: (_) => KNumericInputDialog(
        title: '電話番号の入力',
        initialValue: _phone.replaceAll(RegExp(r'[^0-9]'), ''),
        emptyHint: '番号を入力してください',
        maxLength: 11,
        onConfirmed: (v) => setState(() => _phone = _formatPhone(v)),
      ),
    );
  }

  String _formatPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length == 11) {
      return '${clean.substring(0, 3)}-${clean.substring(3, 7)}-${clean.substring(7)}';
    } else if (clean.length == 10) {
      if (clean.startsWith('03') || clean.startsWith('06')) {
        return '${clean.substring(0, 2)}-${clean.substring(2, 6)}-${clean.substring(6)}';
      } else if (clean.startsWith('0564')) {
        return '${clean.substring(0, 4)}-${clean.substring(4, 6)}-${clean.substring(6)}';
      } else if (clean.startsWith('0120') || clean.startsWith('0800')) {
        return '${clean.substring(0, 4)}-${clean.substring(4, 7)}-${clean.substring(7)}';
      } else {
        return '${clean.substring(0, 3)}-${clean.substring(3, 6)}-${clean.substring(6)}';
      }
    }
    return clean;
  }

  /// 企業名の編集（受注入力と同じ検索ダイアログ）。確定したら企業名・住所・座標を即保存する。
  Future<void> _editCompany() => _searchAndSave(initialTab: 0, withCompany: true);

  /// 住所の編集（住所タブで開く）。確定したら住所・座標を即保存する。
  Future<void> _editAddress() => _searchAndSave(initialTab: 2, withCompany: false);

  Future<void> _searchAndSave({required int initialTab, required bool withCompany}) async {
    final result = await showFacilitySearchHostDialog(context, initialTab: initialTab);
    if (result == null || !mounted) return;
    final coordChanged = result.lat != _latitude || result.lng != _longitude;
    final oldSv = _svUrl;
    setState(() {
      if (withCompany) _companyName = result.name;
      _address = result.address;
      _latitude = result.lat;
      _longitude = result.lng;
      if (coordChanged) {
        _svUrl = null;
        _svPath = null;
      }
    });
    try {
      await widget.customerService.updateCustomer(widget.customer.copyWith(
        companyName: withCompany ? _companyName : null,
        address: _address,
        latitude: _latitude,
        longitude: _longitude,
        deliveryAddresses: _addresses,
        streetViewImageUrl: _svUrl,
        streetViewImagePath: _svPath,
        clearStreetViewImage: _svUrl == null,
      ));
      widget.onSaved?.call();
      if (coordChanged && oldSv != null) await StreetViewImageService().deleteByUrl(oldSv);
    } catch (e) {
      debugPrint('Customer search persist error: $e');
    }
  }

  /// 配達先履歴の1件を、Googleマップ（ストリートビュー）で位置調整・画像撮影して更新する。
  Future<void> _adjustAddress(int index) async {
    final entry = normalizeHistoryEntry(_addresses[index]);
    final parts = entry.split(': ');
    final facility = parts.length > 1 ? parts[0] : '個人宅';
    final address = (parts.length > 1 ? parts.sublist(1).join(': ') : entry)
        .split(' (')[0]
        .replaceAll(RegExp(r'\[[^\]]*\]'), '')
        .trim();
    final remarks = RegExp(r'\[RMK:([^\]]*)\]').firstMatch(entry)?.group(1);
    final oldImg = RegExp(r'\[IMG:([^\]]+)\]').firstMatch(entry)?.group(1);
    final m = RegExp(r'[(（]([-+]?\d*\.?\d+),\s*([-+]?\d*\.?\d+)[)）]').allMatches(entry);
    LatLng? pos;
    if (m.isNotEmpty) {
      final la = double.tryParse(m.last.group(1)!);
      final ln = double.tryParse(m.last.group(2)!);
      if (la != null && ln != null && !(la == 0 && ln == 0)) pos = LatLng(la, ln);
    }
    final maps = widget.customerService.getGoogleMapsService();
    if (pos == null) {
      setState(() => _busy = true);
      final geo = await maps.getLatLngFromAddress(address);
      if (!mounted) return;
      setState(() => _busy = false);
      if (geo != null) pos = LatLng(geo['lat'] as double, geo['lng'] as double);
    }
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => KLocationAdjustmentDialog(
        initialPosition: pos ?? const LatLng(34.9546, 137.1744),
        initialAddress: '$facility $address'.trim(),
        getAddressFromLatLng: (p) => maps.getAddressFromLatLng(p),
      ),
    );
    if (result == null || !mounted) return;
    final newPos = result['position'] as LatLng;
    final imageUrl = result['staticImageUrl'] as String;
    setState(() {
      _selected = index; // 右側の地図・写真を、調整したカードに切り替える
      _busy = true;
    });
    String? img = imageUrl; // 保存に失敗しても、撮影した写真が表示されるよう元のURLを使う
    try {
      final svc = StreetViewImageService();
      final bytes = await svc.downloadBytes(imageUrl);
      if (bytes != null) {
        final up = await svc.uploadHistoryImage(widget.customer.id, bytes);
        img = up.url;
      }
    } catch (e) {
      debugPrint('Street View history save error: $e');
      img = imageUrl;
    }
    if (!mounted) return;
    setState(() {
      _addresses[index] = '$facility: $address (${newPos.latitude}, ${newPos.longitude})'
          '${img != null ? ' [IMG:$img]' : ''}'
          '${(remarks ?? '').isNotEmpty ? ' [RMK:$remarks]' : ''}';
    });
    // 確定したらすぐ保存して反映する（他の未保存の編集内容は「保存」まで確定しない）
    try {
      await widget.customerService.updateCustomer(widget.customer.copyWith(
        deliveryAddresses: _addresses,
        streetViewImageUrl: _svUrl,
        streetViewImagePath: _svPath,
        clearStreetViewImage: _svUrl == null,
      ));
      widget.onSaved?.call();
      // 同じ配達先の古い写真は上書きされたものとして、Storageから削除する
      if (oldImg != null && oldImg != img) await StreetViewImageService().deleteByUrl(oldImg);
    } catch (e) {
      debugPrint('Street View history persist error: $e');
    }
    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final updated = widget.customer.copyWith(
      name: _name,
      furigana: _furigana,
      phoneNumber: _phone,
      companyName: _companyName,
      address: _address,
      latitude: _latitude,
      longitude: _longitude,
      deliveryAddresses: _addresses,
      streetViewImageUrl: _svUrl,
      streetViewImagePath: _svPath,
      clearStreetViewImage: _svUrl == null,
    );
    try {
      await widget.customerService.updateCustomer(updated);
      widget.onSaved?.call();
    } catch (e) {
      debugPrint('Customer update error: $e');
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
  }

  /// スマホ版（幅600未満）：全画面の縦1列レイアウト
  Widget _buildPhone(BuildContext context) {
    Widget field(String label, String value, {VoidCallback? onEdit}) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PcLabel(label),
              const SizedBox(height: 6),
              PcFieldBox(text: value, trailing: Icons.edit, onTap: onEdit),
            ],
          ),
        );
    return Dialog.fullscreen(
      backgroundColor: PcColors.bg,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                color: PcColors.purple,
                padding: EdgeInsets.fromLTRB(4, MediaQuery.of(context).padding.top, 16, 0),
                height: 52 + MediaQuery.of(context).padding.top,
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
                    const Text('顧客詳細', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
                  children: [
                    field('顧客名', _name, onEdit: () => _editText(_name, (t) => _name = t)),
                    field('ふりがな', _furigana.isEmpty ? '未設定' : _furigana, onEdit: () => _editText(_furigana, (t) => _furigana = t)),
                    field('電話番号', _phone.isEmpty ? '未設定' : _phone, onEdit: _editPhone),
                    field('企業名', _companyName.isEmpty ? '未設定' : _companyName, onEdit: _editCompany),
                    field('住所', _address.isEmpty ? '未設定' : _address, onEdit: _editAddress),
                    field('座標', '${_latitude ?? "-"}, ${_longitude ?? "-"}'),
                    const SizedBox(height: 10),
                    const Padding(padding: EdgeInsets.only(left: 2, bottom: 8), child: Text('配達先履歴', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PcColors.sub))),
                    if (_addresses.isEmpty)
                      const Padding(padding: EdgeInsets.all(8), child: Text('履歴なし', style: TextStyle(color: PcColors.hint))),
                    for (var i = 0; i < _addresses.length; i++) _phoneHistoryCard(i),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: PcColors.line))),
                padding: EdgeInsets.fromLTRB(14, 11, 14, 12 + MediaQuery.of(context).padding.bottom),
                child: Row(
                  children: [
                    Expanded(child: PcOutlineButton(label: '閉じる', onTap: () => Navigator.pop(context))),
                    const SizedBox(width: 10),
                    Expanded(child: PcButton(label: '保存', onTap: _saving ? null : _save)),
                  ],
                ),
              ),
            ],
          ),
          if (_busy)
            const Positioned.fill(
              child: AbsorbPointer(child: ColoredBox(color: Color(0x80000000), child: Center(child: CircularProgressIndicator()))),
            ),
        ],
      ),
    );
  }

  Widget _phoneHistoryCard(int i) {
    final info = _info(_addresses[i]);
    final selected = i == _selected;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 58,
      decoration: BoxDecoration(color: selected ? PcColors.green : Colors.white, border: Border.all(color: PcColors.line2), borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selected = i),
        child: Row(
          children: [
            const SizedBox(width: 13),
            const Icon(Icons.business, size: 20, color: PcColors.orangeSoft),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.facility, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PcColors.text)),
                  const SizedBox(height: 2),
                  Text(info.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: PcColors.sub)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _adjustAddress(i),
              child: Container(
                width: 54,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: PcColors.red), borderRadius: BorderRadius.circular(15)),
                child: const Text('調整', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PcColors.red)),
              ),
            ),
            const SizedBox(width: 13),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isPhoneWidth(context)) return _buildPhone(context);
    return Dialog(
      backgroundColor: AppColors.popupBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 16))),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rs(context, 16)),
        child: Stack(
        children: [
          SizedBox(
        width: math.min(rs(context, 1180), MediaQuery.of(context).size.width * 0.95),
        height: math.min(rs(context, 680), MediaQuery.of(context).size.height * 0.92),
        child: Column(
          children: [
            // ヘッダー
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: rs(context, 20), vertical: rs(context, 12)),
              child: Row(
                children: [
                  Text('詳細', style: TextStyle(color: AppColors.mainBackground, fontWeight: FontWeight.bold, fontSize: rf(context, 16))),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: AppColors.mainBackground),
                  ),
                ],
              ),
            ),
            // 詳細情報エリア（白背景）：左＝顧客情報／中央＝配達先履歴／右＝地図と写真
            Expanded(
              child: Container(
                color: AppColors.mainBackground,
                padding: EdgeInsets.all(rs(context, 20)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 10,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _editableField(context, '顧客名', _name, onEdit: () => _editText(_name, (t) => _name = t)),
                            SizedBox(height: rs(context, 12)),
                            _editableField(context, 'ふりがな', _furigana.isEmpty ? '未設定' : _furigana,
                                onEdit: () => _editText(_furigana, (t) => _furigana = t)),
                            SizedBox(height: rs(context, 12)),
                            _editableField(context, '電話番号', _phone.isEmpty ? '未設定' : _phone, onEdit: _editPhone),
                            SizedBox(height: rs(context, 12)),
                            _editableField(context, '企業名', _companyName.isEmpty ? '未設定' : _companyName,
                                onEdit: _editCompany),
                            SizedBox(height: rs(context, 12)),
                            _editableField(context, '住所', _address.isEmpty ? '未設定' : _address,
                                onEdit: _editAddress),
                            SizedBox(height: rs(context, 12)),
                            _editableField(context, '座標', '${_latitude ?? "-"}, ${_longitude ?? "-"}'),
                          ],
                        ),
                      ),
                    ),
                    VerticalDivider(width: rs(context, 32), thickness: 1),
                    Expanded(flex: 11, child: _buildHistoryColumn(context)),
                    VerticalDivider(width: rs(context, 32), thickness: 1),
                    Expanded(flex: 11, child: _buildMapAndPhoto(context)),
                  ],
                ),
              ),
            ),
            // アクション
            Container(
              color: AppColors.mainBackground,
              padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 8), rs(context, 20), rs(context, 12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
                  SizedBox(width: rs(context, 8)),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.mainBackground,
                    ),
                    child: _saving
                        ? SizedBox(
                            width: rs(context, 16),
                            height: rs(context, 16),
                            child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.mainBackground),
                          )
                        : const Text('保存'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
          // 読み込み中は灰色にしてクルクルを出し、操作を受け付けない
          if (_busy)
            const Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: Color(0x80000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  /// 履歴1件の施設名・住所・座標・画像URLを取り出す。
  ({String facility, String address, LatLng? pos, String? img}) _info(String raw) {
    final entry = normalizeHistoryEntry(raw);
    final parts = entry.split(': ');
    final facility = parts.length > 1 ? parts[0] : '個人宅';
    final address = (parts.length > 1 ? parts.sublist(1).join(': ') : entry)
        .split(' (')[0]
        .replaceAll(RegExp(r'\[[^\]]*\]'), '')
        .trim();
    final img = RegExp(r'\[IMG:([^\]]+)\]').firstMatch(entry)?.group(1);
    final m = RegExp(r'[(（]([-+]?\d*\.?\d+),\s*([-+]?\d*\.?\d+)[)）]').allMatches(entry);
    LatLng? pos;
    if (m.isNotEmpty) {
      final la = double.tryParse(m.last.group(1)!);
      final ln = double.tryParse(m.last.group(2)!);
      if (la != null && ln != null && !(la == 0 && ln == 0)) pos = LatLng(la, ln);
    }
    return (facility: facility, address: address, pos: pos, img: img);
  }

  /// 中央：配達先履歴（上下にスクロール）。タップで選択すると右側の地図・写真が切り替わる。
  Widget _buildHistoryColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('配達先履歴',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 18), color: Colors.blueGrey)),
        SizedBox(height: rs(context, 12)),
        Expanded(
          child: _addresses.isEmpty
              ? const Text('履歴なし', style: TextStyle(color: Colors.grey))
              : ListView.builder(
                  itemCount: _addresses.length,
                  itemBuilder: (context, i) {
                    final info = _info(_addresses[i]);
                    final selected = i == _selected;
                    return Container(
                      margin: EdgeInsets.only(bottom: rs(context, 10)),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.selectButton : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(rs(context, 8)),
                        border: selected ? null : Border.all(color: Colors.grey.shade200),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(rs(context, 8)),
                        onTap: () => setState(() => _selected = i),
                        child: Padding(
                          padding: EdgeInsets.all(rs(context, 14)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.business, size: rs(context, 18), color: AppColors.accentOrange),
                                        SizedBox(width: rs(context, 8)),
                                        Expanded(
                                          child: Text(info.facility,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: rf(context, 16),
                                                  color: AppColors.primaryText)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: rs(context, 6)),
                                    Padding(
                                      padding: EdgeInsets.only(left: rs(context, 26)),
                                      child: Text(info.address, style: const TextStyle(color: Colors.black87)),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: rs(context, 8)),
                              OutlinedButton(
                                onPressed: () => _adjustAddress(i),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.accentOrange,
                                  side: const BorderSide(color: AppColors.accentOrange),
                                ),
                                child: const Text('調整', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// 右：選択中の配達先履歴の地図（上）と撮影した写真（下）。
  Widget _buildMapAndPhoto(BuildContext context) {
    final info = (_addresses.isEmpty || _selected >= _addresses.length) ? null : _info(_addresses[_selected]);
    final pos = info?.pos;
    final img = info?.img;
    Widget placeholder(String text) => Center(child: Text(text, style: const TextStyle(color: Colors.grey)));
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(rs(context, 8)),
            child: Container(
              color: Colors.grey.shade100,
              child: pos == null
                  ? placeholder('地図を表示できる座標がありません')
                  : GoogleMap(
                      key: ValueKey('${pos.latitude},${pos.longitude}'),
                      initialCameraPosition: CameraPosition(target: pos, zoom: 16),
                      markers: {Marker(markerId: const MarkerId('dest'), position: pos)},
                      myLocationButtonEnabled: false,
                      mapToolbarEnabled: false,
                    ),
            ),
          ),
        ),
        SizedBox(height: rs(context, 12)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(rs(context, 8)),
            child: Container(
              width: double.infinity,
              color: Colors.grey.shade100,
              child: img == null
                  ? placeholder('撮影した写真がありません')
                  : Image.network(img, key: ValueKey('$_selected|$img'), fit: BoxFit.cover, webHtmlElementStrategy: WebHtmlElementStrategy.prefer, errorBuilder: (c, e, st) => placeholder('写真を読み込めません')),
            ),
          ),
        ),
      ],
    );
  }

  /// ラベル（右に鉛筆アイコン）＋値。[onEdit] が null のときは読み取り専用（アイコン分の幅は確保）。
  Widget _editableField(BuildContext context, String label, String value, {VoidCallback? onEdit}) {
    final pencil = Icon(Icons.edit, size: rs(context, 18), color: Colors.blueGrey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel(context, label),
        Row(
          children: [
            Expanded(child: _readonlyValue(context, value)),
            SizedBox(width: rs(context, 4)),
            if (onEdit == null)
              SizedBox(width: rs(context, 30))
            else
              InkWell(
                onTap: onEdit,
                child: Padding(padding: EdgeInsets.all(rs(context, 6)), child: pencil),
              ),
          ],
        ),
      ],
    );
  }

  Widget _fieldLabel(BuildContext context, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 6)),
      child: Text(label, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: rf(context, 13))),
    );
  }

  Widget _readonlyValue(BuildContext context, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 12)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(rs(context, 8)),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(value, style: TextStyle(fontSize: rf(context, 15), color: Colors.black87)),
    );
  }
}
