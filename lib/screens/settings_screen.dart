import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/branch_model.dart';
import '../services/settings_service.dart';
import '../services/branch_service.dart';
import '../services/google_maps_service.dart';
import '../widgets/k_choice_group.dart';
import '../widgets/k_numeric_input_dialog.dart';
import '../widgets/k_multimodal_text_field.dart';
import '../widgets/k_direct_address_picker_dialog.dart';
import '../widgets/k_responsive.dart';
import '../widgets/k_location_adjustment_dialog.dart';
import 'package:katura_system/utils/app_colors.dart';
import '../services/pre_contact_settings_service.dart';
import 'phone/phone_common.dart';
import 'phone/phone_shell.dart';

/// アプリ全体の設定を一括管理する画面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.onOpenMenu, this.onNavigate});

  final VoidCallback? onOpenMenu;
  final void Function(int)? onNavigate;

  @override
  Widget build(BuildContext context) {
    if (isPhoneWidth(context)) return const _PhoneSettingsBody();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('設定', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 18))),
        backgroundColor: AppColors.mainBackground,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(rav(context, 24)),
        child: Container(
          constraints: BoxConstraints(maxWidth: rs(context, 880)),
          decoration: BoxDecoration(
            color: AppColors.mainBackground,
            borderRadius: BorderRadius.circular(rs(context, 12)),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: AppColors.primaryText.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          padding: EdgeInsets.all(rs(context, 24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_note, color: AppColors.accentPurple.withValues(alpha: 0.7)),
                  SizedBox(width: rs(context, 8)),
                  Text('文字入力方式',
                    style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: rs(context, 4)),
              Text(
                'アプリ内すべての文字入力欄に、選択した入力方式が一括で反映されます。',
                style: TextStyle(fontSize: rf(context, 12), color: Colors.grey.shade600),
              ),
              SizedBox(height: rs(context, 16)),
              ValueListenableBuilder<KInputMode>(
                valueListenable: SettingsService.inputMode,
                builder: (context, mode, _) {
                  return KChoiceGroup<KInputMode>(
                    label: '',
                    showLabel: false,
                    selectedValue: mode,
                    selectedColor: AppColors.selectButton,
                    selectedTextColor: AppColors.primaryText,
                    onSelected: (newMode) {
                      SettingsService.setInputMode(newMode);
                    },
                    items: [
                      KChoiceItem(label: 'ペンタブ入力', value: KInputMode.pen, hint: 'タブレット推奨'),
                      KChoiceItem(label: 'キーボード入力', value: KInputMode.keyboard, hint: 'PC推奨'),
                    ],
                  );
                },
              ),
              SizedBox(height: rs(context, 32)),
              const Divider(),
              SizedBox(height: rs(context, 16)),
              Row(
                children: [
                  Icon(Icons.email_outlined, color: AppColors.accentPurple.withValues(alpha: 0.7)),
                  SizedBox(width: rs(context, 8)),
                  Text('事前確認・事前連絡',
                    style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: rs(context, 4)),
              Text(
                '事前確認メールを配達前日に自動送信する時刻と、事前電話連絡の担当者番号を設定します。担当者番号には、電話連絡のし忘れ防止リマインドSMSが送信されます。',
                style: TextStyle(fontSize: rf(context, 12), color: Colors.grey.shade600),
              ),
              SizedBox(height: rs(context, 16)),
              const _PreConfirmSettingsSection(),
              SizedBox(height: rs(context, 32)),
              const Divider(),
              SizedBox(height: rs(context, 16)),
              const _PhonePreContactSection(),
              SizedBox(height: rs(context, 32)),
              const Divider(),
              SizedBox(height: rs(context, 16)),
              Row(
                children: [
                  Icon(Icons.storefront_outlined, color: AppColors.accentPurple.withValues(alpha: 0.7)),
                  SizedBox(width: rs(context, 8)),
                  Text('店舗登録',
                    style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: rs(context, 16)),
              const _BranchSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// スマホ用の設定画面(Figma 08/09/63/33/41)
class _PhoneSettingsBody extends StatelessWidget {
  const _PhoneSettingsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PhoneColors.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 15, 14, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _phoneSectionTitle(Icons.mail_outline_rounded, '事前確認・事前連絡'),
            _phoneCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(15, 13, 15, 8),
                    child: Text(
                      '事前確認メールを配達前日に自動送信する時刻と、事前電話連絡の担当者番号を設定します。担当者番号には、電話連絡のし忘れ防止リマインドSMSが送信されます。',
                      style: _phoneDescStyle,
                    ),
                  ),
                  _PreConfirmSettingsSection(),
                ],
              ),
            ),
            const SizedBox(height: 15),
            _phoneSectionTitle(Icons.storefront_rounded, '店舗登録'),
            const _BranchSettingsSection(),
            const SizedBox(height: 15),
            const _PhonePreContactSection(),
          ],
        ),
      ),
    );
  }
}

const TextStyle _phoneDescStyle = TextStyle(fontSize: 11.5, color: PhoneColors.sub, height: 1.35);

Widget _phoneSectionTitle(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: PhoneColors.purple),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PhoneColors.sub)),
        ],
      ),
    );

Widget _phoneCard(Widget child) => Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PhoneColors.cardBorder),
      ),
      child: child,
    );

/// 角丸の入力枠(薄グレー背景)
Widget _phoneBox({required Widget child, VoidCallback? onTap}) => InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 44,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: PhoneColors.fieldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: PhoneColors.border),
        ),
        child: child,
      ),
    );

Widget _phoneLabeled(String label, Widget field) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: PhoneColors.sub)),
          const SizedBox(height: 6),
          field,
        ],
      ),
    );

/// 事前確認メールの送信時刻・事前連絡（電話）用の電話番号設定
class _PreConfirmSettingsSection extends StatefulWidget {
  const _PreConfirmSettingsSection();

  @override
  State<_PreConfirmSettingsSection> createState() => _PreConfirmSettingsSectionState();
}

class _PreConfirmSettingsSectionState extends State<_PreConfirmSettingsSection> {
  String _sendingTime = '09:00';
  String _callbackPhone = '';
  bool _loading = true;

  DocumentReference<Map<String, dynamic>> get _doc => FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'katura-system-database',
      ).collection('settings').doc('sms_config');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snap = await _doc.get();
      if (snap.exists && mounted) {
        setState(() {
          _sendingTime = snap.data()?['sendingTime'] ?? '09:00';
          _callbackPhone = snap.data()?['preConfirmationCallbackPhone'] ?? '';
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _update({String? sendingTime, String? callbackPhone}) async {
    setState(() {
      if (sendingTime != null) _sendingTime = sendingTime;
      if (callbackPhone != null) _callbackPhone = callbackPhone;
    });
    try {
      await _doc.set({
        'sendingTime': _sendingTime,
        'preConfirmationCallbackPhone': _callbackPhone,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  void _editSendingTime() {
    final digits = _sendingTime.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0');
    if (isPhoneWidth(context)) {
      showPhoneTimePadSheet(context, title: '送信時刻（前日 HH:MM）', initial: digits).then((v) {
        if (v != null) _update(sendingTime: '${v.substring(0, 2)}:${v.substring(2, 4)}');
      });
      return;
    }
    showDialog(
      context: context,
      builder: (_) => KNumericInputDialog(
        title: '事前確認メールの送信時刻（前日 HHMM）',
        timeFormat: true,
        initialValue: digits,
        maxLength: 4,
        overwrite: true,
        emptyHint: 'HHMM',
        themeColor: AppColors.accentPurple,
        onConfirmed: (text) {
          final d = text.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0');
          int h = int.tryParse(d.substring(0, 2)) ?? 0;
          int m = int.tryParse(d.substring(2, 4)) ?? 0;
          if (h > 23) h = 23;
          if (m > 59) m = 59;
          _update(sendingTime: '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
        },
      ),
    );
  }

  void _editCallbackPhone() {
    showDialog(
      context: context,
      builder: (_) => KNumericInputDialog(
        title: '事前電話連絡の担当者番号（リマインドSMS送信先）',
        initialValue: _callbackPhone,
        emptyHint: '番号を入力してください',
        themeColor: AppColors.accentPurple,
        onConfirmed: (v) => _update(callbackPhone: v),
      ),
    );
  }

  Widget _row({required IconData icon, required String label, required String value, required VoidCallback onTap}) {
    if (isPhoneWidth(context)) {
      final empty = value.isEmpty;
      return InkWell(
        onTap: onTap,
        child: Container(
          height: 49,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: PhoneColors.sub),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 11.5, color: PhoneColors.sub)),
              const Spacer(),
              Text(
                empty ? '未設定' : value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: empty ? FontWeight.normal : FontWeight.bold,
                  color: empty ? PhoneColors.sub : PhoneColors.text,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.edit_rounded, size: 18, color: PhoneColors.purple),
            ],
          ),
        ),
      );
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rs(context, 8)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 12)),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(rs(context, 8)),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: rs(context, 18), color: Colors.blueGrey.shade600),
            SizedBox(width: rs(context, 10)),
            Text(label, style: TextStyle(fontSize: rf(context, 13), color: Colors.grey.shade700)),
            SizedBox(width: rs(context, 12)),
            Expanded(
              child: Text(
                value.isEmpty ? '未設定' : value,
                style: TextStyle(
                  fontSize: rf(context, 15),
                  fontWeight: FontWeight.bold,
                  color: value.isEmpty ? Colors.grey.shade400 : Colors.black87,
                ),
              ),
            ),
            Icon(Icons.edit, size: rs(context, 16), color: AppColors.accentPurple.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: rs(context, 16)),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final phone = isPhoneWidth(context);
    return Column(
      children: [
        _row(
          icon: Icons.schedule,
          label: '送信時刻',
          value: _sendingTime.isEmpty ? '' : '前日 $_sendingTime',
          onTap: _editSendingTime,
        ),
        SizedBox(height: phone ? 0 : rs(context, 8)),
        _row(
          icon: Icons.phone_forwarded,
          label: '担当者番号',
          value: _callbackPhone,
          onTap: _editCallbackPhone,
        ),
      ],
    );
  }
}

class _BranchRowData {
  BranchModel branch;
  bool editing;
  final TextEditingController nameController;
  final TextEditingController companyController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController vehicleController;

  _BranchRowData(this.branch, {this.editing = false})
      : nameController = TextEditingController(text: branch.name),
        companyController = TextEditingController(text: branch.companyName),
        addressController = TextEditingController(text: branch.address),
        phoneController = TextEditingController(text: branch.phone),
        vehicleController = TextEditingController(text: branch.deliveryVehicleCount.toString());

  void dispose() {
    nameController.dispose();
    companyController.dispose();
    addressController.dispose();
    phoneController.dispose();
    vehicleController.dispose();
  }
}

class _BranchSettingsSection extends StatefulWidget {
  const _BranchSettingsSection();

  @override
  State<_BranchSettingsSection> createState() => _BranchSettingsSectionState();
}

class _BranchSettingsSectionState extends State<_BranchSettingsSection> {
  final _branchService = BranchService();
  final _mapsService = GoogleMapsService();
  final List<_BranchRowData> _rows = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final branches = await _branchService.getAllBranches();
    if (!mounted) return;
    setState(() {
      _rows.addAll(branches.map((b) => _BranchRowData(b)));
      _isLoading = false;
    });
  }

  void _addNewRow() {
    setState(() {
      _rows.add(_BranchRowData(
        const BranchModel(id: '', name: '', address: '', phone: '', latitude: 0, longitude: 0),
        editing: true,
      ));
    });
  }

  /// フォーカスアウト・編集終了時のサイレント自動保存（新規は作成）
  Future<void> _autoSave(_BranchRowData row) async {
    final name = row.nameController.text.trim();
    if (name.isEmpty) return;
    final company = row.companyController.text.trim();
    final address = row.addressController.text.trim();
    final phone = row.phoneController.text.trim();
    final vehicleCount = int.tryParse(row.vehicleController.text.trim()) ?? 0;
    if (name == row.branch.name && company == row.branch.companyName && address == row.branch.address && phone == row.branch.phone && vehicleCount == row.branch.deliveryVehicleCount && row.branch.id.isNotEmpty) {
      return;
    }
    if (row.branch.id.isEmpty) {
      final created = await _branchService.addBranch(
        name: name,
        companyName: company,
        address: address,
        phone: phone,
        latitude: row.branch.latitude,
        longitude: row.branch.longitude,
        imageUrl: row.branch.imageUrl,
        deliveryVehicleCount: vehicleCount,
      );
      if (!mounted) return;
      setState(() => row.branch = created);
    } else {
      final updated = row.branch.copyWith(name: name, companyName: company, address: address, phone: phone, deliveryVehicleCount: vehicleCount);
      await _branchService.updateBranch(updated);
      if (!mounted) return;
      setState(() => row.branch = updated);
    }
  }

  Future<void> _delete(_BranchRowData row) async {
    if (row.branch.id.isEmpty) {
      setState(() {
        _rows.remove(row);
      });
      row.dispose();
      return;
    }
    final confirmed = isPhoneWidth(context)
        ? await showPhoneConfirmDialog(
            context,
            icon: Icons.storefront_rounded,
            title: '店舗を削除しますか？',
            message: '「${row.branch.name}」を削除します。この操作は取り消せません。',
          )
        : await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.popupBackground,
        title: const Text('店舗を削除しますか？'),
        content: Text('「${row.branch.name}」を削除します。この操作は取り消せません。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _branchService.deleteBranch(row.branch.id);
    if (!mounted) return;
    setState(() {
      _rows.remove(row);
    });
    row.dispose();
  }

  Future<void> _adjustCoordinates(_BranchRowData row) async {
    final hasCoords = row.branch.latitude != 0 || row.branch.longitude != 0;
    final initialPos = hasCoords ? LatLng(row.branch.latitude, row.branch.longitude) : const LatLng(34.9563, 137.1685);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => KLocationAdjustmentDialog(
        initialPosition: initialPos,
        initialAddress: row.addressController.text,
        getAddressFromLatLng: (pos) => _mapsService.getAddressFromLatLng(pos),
      ),
    );
    if (result == null || !mounted) return;

    final pos = result['position'] as LatLng;
    final staticImageUrl = result['staticImageUrl'] as String?;
    final newAddress = await _mapsService.getAddressFromLatLng(pos);

    // ストリートビュー写真を取得してStorageへ保存
    String uploadedUrl = row.branch.imageUrl;
    if (staticImageUrl != null) {
      try {
        final resp = await http.get(Uri.parse(staticImageUrl));
        if (resp.statusCode == 200) {
          final key = row.branch.id.isNotEmpty ? row.branch.id : 'new-${DateTime.now().millisecondsSinceEpoch}';
          final ref = FirebaseStorage.instance.ref().child('branches/$key.jpg');
          await ref.putData(resp.bodyBytes, SettableMetadata(contentType: 'image/jpeg'));
          uploadedUrl = await ref.getDownloadURL();
        }
      } catch (e) {
        debugPrint('Branch Street View upload error: $e');
      }
    }

    if (!mounted) return;
    setState(() {
      row.branch = row.branch.copyWith(
        latitude: pos.latitude,
        longitude: pos.longitude,
        address: newAddress ?? row.branch.address,
        imageUrl: uploadedUrl,
      );
      row.addressController.text = row.branch.address;
    });

    // 自動保存（新規は作成）
    if (row.branch.id.isEmpty) {
      if (row.nameController.text.trim().isNotEmpty) {
        final created = await _branchService.addBranch(
          name: row.nameController.text.trim(),
          address: row.branch.address,
          phone: row.phoneController.text.trim(),
          deliveryVehicleCount: int.tryParse(row.vehicleController.text.trim()) ?? 0,
          latitude: row.branch.latitude,
          longitude: row.branch.longitude,
          imageUrl: row.branch.imageUrl,
        );
        if (!mounted) return;
        setState(() => row.branch = created);
      }
    } else {
      await _branchService.updateBranch(row.branch);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('座標・写真を保存しました'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: rs(context, 16)),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: _onReorder,
          children: [
            for (var i = 0; i < _rows.length; i++)
              KeyedSubtree(key: ObjectKey(_rows[i]), child: _buildBranchRow(_rows[i], i)),
          ],
        ),
        SizedBox(height: rs(context, 8)),
        if (isPhoneWidth(context))
          Center(
            child: TextButton.icon(
              onPressed: _addNewRow,
              style: TextButton.styleFrom(foregroundColor: PhoneColors.orange),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('店舗を追加', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        else
          TextButton.icon(
            onPressed: _addNewRow,
            icon: const Icon(Icons.add),
            label: const Text('店舗を追加'),
          ),
      ],
    );
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      _rows.insert(newIndex, _rows.removeAt(oldIndex));
      // 後続の自動保存で古い並び順が上書きされないよう、手元のデータにも反映する
      for (var i = 0; i < _rows.length; i++) {
        _rows[i].branch = _rows[i].branch.copyWith(sortOrder: i);
      }
    });
    final saved = _rows.where((r) => r.branch.id.isNotEmpty).map((r) => r.branch).toList();
    await _branchService.saveOrder(saved);
  }

  Widget _buildBranchRow(_BranchRowData row, int index) {
    if (isPhoneWidth(context)) {
      return ReorderableDelayedDragStartListener(
        index: index,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: _phoneCard(row.editing ? _phoneEditView(row) : _phoneDisplayView(row)),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(bottom: rs(context, 12)),
      padding: EdgeInsets.all(rs(context, 12)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(rs(context, 10)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: row.editing ? _buildEditView(row) : _buildDisplayView(row, index),
    );
  }

  /// スマホ用：店舗の写真(高さ110)。[showDelete]のとき右下に削除チップ
  Widget _phoneImage(_BranchRowData row, {required bool showDelete}) {
    final placeholder = const Center(child: Icon(Icons.storefront_rounded, size: 36, color: Color(0xFFB5BAC0)));
    return SizedBox(
      height: 110,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: const Color(0xFFEEF0F2),
            child: row.branch.imageUrl.isEmpty
                ? placeholder
                : Image.network(
                    row.branch.imageUrl,
                    webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => placeholder,
                  ),
          ),
          if (showDelete)
            Positioned(
              right: 10,
              bottom: 10,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => _delete(row),
                child: Container(
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(6)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 12, color: Color(0xFFD32F2F)),
                      SizedBox(width: 1),
                      Text('削除', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _phoneDisplayView(_BranchRowData row) {
    const sub = TextStyle(fontSize: 11.5, color: PhoneColors.sub);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _phoneImage(row, showDelete: true),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.branch.name.isEmpty ? '（店舗名未設定）' : row.branch.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PhoneColors.text)),
                    const SizedBox(height: 3),
                    Text(row.branch.companyName.isEmpty ? '社名未設定' : row.branch.companyName, style: sub),
                    const SizedBox(height: 2),
                    Text(row.branch.address.isEmpty ? '住所未設定' : row.branch.address, style: sub),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.call_rounded, size: 12, color: PhoneColors.sub),
                        const SizedBox(width: 2),
                        Flexible(child: Text(row.branch.phone.isEmpty ? '電話番号未設定' : row.branch.phone, style: sub)),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20, color: PhoneColors.hint),
                onSelected: (v) {
                  if (v == 'edit') {
                    setState(() => row.editing = true);
                  } else if (v == 'delete') {
                    _delete(row);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('編集')),
                  PopupMenuItem(value: 'delete', child: Text('削除', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _phoneCancelEdit(_BranchRowData row) {
    if (row.branch.id.isEmpty) {
      setState(() => _rows.remove(row));
      row.dispose();
      return;
    }
    row.nameController.text = row.branch.name;
    row.companyController.text = row.branch.companyName;
    row.addressController.text = row.branch.address;
    row.phoneController.text = row.branch.phone;
    row.vehicleController.text = row.branch.deliveryVehicleCount.toString();
    setState(() => row.editing = false);
  }

  Widget _phoneEditView(_BranchRowData row) {
    const valueStyle = TextStyle(fontSize: 14, color: PhoneColors.text);
    const hintStyle = TextStyle(fontSize: 14, color: PhoneColors.hint);
    Widget text(String v, String hint) => Text(v.isEmpty ? hint : v,
        maxLines: 1, overflow: TextOverflow.ellipsis, style: v.isEmpty ? hintStyle : valueStyle);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _phoneImage(row, showDelete: false),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _phoneLabeled('店舗名', _penField(row, row.nameController)),
              _phoneLabeled('社名', _penField(row, row.companyController)),
              _phoneLabeled(
                '住所',
                _phoneBox(
                  onTap: () => showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => KDirectAddressPickerDialog(
                      initialPref: '',
                      initialCity: '',
                      initialTown: '',
                      onAddressConfirmed: (fullAddr) {
                        setState(() => row.addressController.text = fullAddr);
                        _autoSave(row);
                      },
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: text(row.addressController.text, '住所を検索')),
                      InkWell(
                        onTap: () => _adjustCoordinates(row),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.edit_location_alt_rounded, size: 18, color: PhoneColors.sub),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _phoneLabeled(
                '電話番号',
                _phoneBox(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => KNumericInputDialog(
                      title: '電話番号の入力',
                      initialValue: row.phoneController.text,
                      emptyHint: '番号を入力してください',
                      onConfirmed: (v) {
                        setState(() => row.phoneController.text = v);
                        _autoSave(row);
                      },
                    ),
                  ),
                  child: text(row.phoneController.text, '番号を入力'),
                ),
              ),
              _phoneLabeled(
                '配送車両数',
                _phoneBox(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => KNumericInputDialog(
                      title: '配送車両数の入力',
                      emptyHint: '台数を入力してください',
                      unit: '台',
                      maxLength: 3,
                      onConfirmed: (v) {
                        final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                        setState(() => row.vehicleController.text = digits);
                        _autoSave(row);
                      },
                    ),
                  ),
                  child: text(row.vehicleController.text, '台数を入力'),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        onPressed: () => _phoneCancelEdit(row),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: PhoneColors.text,
                          side: const BorderSide(color: PhoneColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('キャンセル', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _autoSave(row);
                          if (!mounted) return;
                          setState(() => row.editing = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PhoneColors.purple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('完了', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
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

  Widget _buildBranchImage(_BranchRowData row) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(rs(context, 8)),
          child: Container(
            width: double.infinity,
            height: rs(context, 150),
            color: Colors.grey.shade200,
            child: row.branch.imageUrl.isEmpty
                ? Center(
                    child: Icon(Icons.storefront_outlined, size: rs(context, 40), color: Colors.grey.shade400),
                  )
                : Image.network(
                    row.branch.imageUrl,
                    webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Center(
                      child: Icon(Icons.broken_image_outlined, size: rs(context, 40), color: Colors.grey.shade400),
                    ),
                  ),
          ),
        ),
        Positioned(
          right: rs(context, 8),
          bottom: rs(context, 8),
          child: Material(
            color: AppColors.mainBackground,
            elevation: 3,
            borderRadius: BorderRadius.circular(rs(context, 8)),
            child: InkWell(
              onTap: () => _adjustCoordinates(row),
              borderRadius: BorderRadius.circular(rs(context, 8)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rs(context, 6)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_location_alt, size: rs(context, 16), color: AppColors.accentOrange),
                    SizedBox(width: rs(context, 4)),
                    Text('調整', style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: AppColors.accentOrange)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ラベル（フィールド外・左）とフィールドを上下中央で揃えた編集行
  Widget _labeledField(String label, Widget field) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: rs(context, 88),
            child: Text(label,
                style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ),
          Expanded(child: field),
        ],
      ),
    );
  }

  /// テキスト入力（ペンタブ対応の共有ウィジェット）
  Widget _penField(_BranchRowData row, TextEditingController controller) {
    return Focus(
      onFocusChange: (has) {
        if (!has) _autoSave(row);
      },
      child: KMultimodalTextField(
        label: '',
        showLabel: false,
        controller: controller,
        maxLines: 1,
        height: rs(context, 44),
      ),
    );
  }

  /// 番号入力（ダイヤル入力の共有ウィジェット）
  Widget _dialField(_BranchRowData row) {
    return SizedBox(
      height: rs(context, 44),
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (_) => KNumericInputDialog(
            title: '電話番号の入力',
            initialValue: row.phoneController.text,
            emptyHint: '番号を入力してください',
            onConfirmed: (v) {
              setState(() => row.phoneController.text = v);
              _autoSave(row);
            },
          ),
        ),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
          decoration: BoxDecoration(
            color: AppColors.mainBackground,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(rs(context, 8)),
          ),
          child: Text(
            row.phoneController.text.isEmpty ? '番号を入力' : row.phoneController.text,
            style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
              color: row.phoneController.text.isEmpty ? Colors.grey.shade400 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  /// 配送車両数入力（数字のみ・電話番号と同じダイヤル入力）
  Widget _vehicleField(_BranchRowData row) {
    return SizedBox(
      height: rs(context, 44),
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (_) => KNumericInputDialog(
            title: '配送車両数の入力',
            emptyHint: '台数を入力してください',
            unit: '台',
            maxLength: 3,
            onConfirmed: (v) {
              final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
              setState(() => row.vehicleController.text = digits);
              _autoSave(row);
            },
          ),
        ),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
          decoration: BoxDecoration(
            color: AppColors.mainBackground,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(rs(context, 8)),
          ),
          child: Text(
            row.vehicleController.text.isEmpty ? '台数を入力' : row.vehicleController.text,
            style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
              color: row.vehicleController.text.isEmpty ? Colors.grey.shade400 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  /// 住所入力（受注入力「配達先の確定」の「住所検索」と同じダイヤログ）
  Widget _addressField(_BranchRowData row) {
    return SizedBox(
      height: rs(context, 44),
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => KDirectAddressPickerDialog(
            initialPref: '',
            initialCity: '',
            initialTown: '',
            onAddressConfirmed: (fullAddr) {
              setState(() => row.addressController.text = fullAddr);
              _autoSave(row);
            },
          ),
        ),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
          decoration: BoxDecoration(
            color: AppColors.mainBackground,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(rs(context, 8)),
          ),
          child: Text(
            row.addressController.text.isEmpty ? '住所を検索' : row.addressController.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
              color: row.addressController.text.isEmpty ? Colors.grey.shade400 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisplayView(_BranchRowData row, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBranchImage(row),
        SizedBox(height: rs(context, 10)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.branch.name.isEmpty ? '（店舗名未設定）' : row.branch.name,
                    style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: rs(context, 2)),
                  Text(
                    row.branch.companyName.isEmpty ? '社名未設定' : row.branch.companyName,
                    style: TextStyle(fontSize: rf(context, 12), color: Colors.grey.shade600),
                  ),
                  SizedBox(height: rs(context, 4)),
                  Text(
                    row.branch.address.isEmpty ? '住所未設定' : row.branch.address,
                    style: TextStyle(fontSize: rf(context, 13), color: Colors.grey.shade700),
                  ),
                  SizedBox(height: rs(context, 2)),
                  Row(
                    children: [
                      Icon(Icons.phone, size: rs(context, 14), color: Colors.grey.shade700),
                      SizedBox(width: rs(context, 4)),
                      Flexible(
                        child: Text(
                          row.branch.phone.isEmpty ? '電話番号未設定' : row.branch.phone,
                          style: TextStyle(fontSize: rf(context, 13), color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: EdgeInsets.all(rs(context, 8)),
                child: Icon(Icons.drag_handle, color: Colors.grey.shade600),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'edit') {
                  setState(() => row.editing = true);
                } else if (v == 'delete') {
                  _delete(row);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('編集')]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('削除', style: TextStyle(color: Colors.red))]),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditView(_BranchRowData row) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBranchImage(row),
        SizedBox(height: rs(context, 12)),
        _labeledField('店舗名', _penField(row, row.nameController)),
        _labeledField('社名', _penField(row, row.companyController)),
        _labeledField('住所', _addressField(row)),
        _labeledField('電話番号', _dialField(row)),
        _labeledField('配送車両数', _vehicleField(row)),
        SizedBox(height: rs(context, 4)),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () async {
              await _autoSave(row);
              if (!mounted) return;
              setState(() => row.editing = false);
            },
            child: const Text('完了'),
          ),
        ),
      ],
    );
  }
}


/// スマホ用：事前連絡方法の設定・メール/SMSテンプレート作成
class _PhonePreContactSection extends StatefulWidget {
  const _PhonePreContactSection();

  @override
  State<_PhonePreContactSection> createState() => _PhonePreContactSectionState();
}

class _PhonePreContactSectionState extends State<_PhonePreContactSection> {
  final _smsCtrl = TextEditingController();
  String _method = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    PreContactSettingsService.load().then((s) {
      if (!mounted) return;
      setState(() {
        _method = s.defaultMethod;
        _smsCtrl.text = s.smsTemplate;
      });
    });
  }

  @override
  void dispose() {
    _smsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await PreContactSettingsService.save(
        defaultMethod: _method,
        smsTemplate: _smsCtrl.text,
        mailTemplate: '',
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存しました')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(TextEditingController c, String hint) => TextField(
        controller: c,
        minLines: 4,
        maxLines: 8,
        style: const TextStyle(fontSize: 14, color: PhoneColors.text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: PhoneColors.hint),
          filled: true,
          fillColor: PhoneColors.fieldBg,
          contentPadding: const EdgeInsets.all(13),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PhoneColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: PhoneColors.purple)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: PhoneColors.sub);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _phoneSectionTitle(Icons.phone_in_talk_outlined, '事前連絡方法の設定'),
        _phoneCard(
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('事前連絡で最初に使う連絡方法を選びます。', style: _phoneDescStyle),
                const SizedBox(height: 14),
                PhoneSegmented<String>(
                  items: const [('電話', '電話'), ('SMS', 'SMS')],
                  value: _method,
                  onChanged: (v) => setState(() => _method = v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        _phoneSectionTitle(Icons.sms_outlined, 'SMSのテンプレート文章の作成'),
        _phoneCard(
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('次の差し込みキーを文中に入れると、お客様ごとに自動で置き換わります。\n{お客様名}  {配達日}  {配達時間}  {お弁当}  {お会計}  {お支払い方法}', style: _phoneDescStyle),
                const SizedBox(height: 14),
                const Text('SMS用', style: labelStyle),
                const SizedBox(height: 6),
                _field(_smsCtrl, '例：{お客様名} 様 {配達日} {配達時間} のお届けで間違いございませんか。'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PhoneColors.purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? '保存中...' : '保存', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
