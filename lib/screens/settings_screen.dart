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

/// アプリ全体の設定を一括管理する画面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('設定', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 18))),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(rav(context, 24)),
        child: Container(
          constraints: BoxConstraints(maxWidth: rs(context, 880)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(rs(context, 12)),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          padding: EdgeInsets.all(rs(context, 24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.deepPurple.withValues(alpha: 0.7)),
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
                    selectedColor: Colors.deepPurple,
                    onSelected: (newMode) {
                      SettingsService.setInputMode(newMode);
                    },
                    items: [
                      KChoiceItem(label: 'ペンタブ', value: KInputMode.pen),
                      KChoiceItem(label: 'キーボード', value: KInputMode.keyboard),
                    ],
                  );
                },
              ),
              SizedBox(height: rs(context, 32)),
              const Divider(),
              SizedBox(height: rs(context, 16)),
              Row(
                children: [
                  Icon(Icons.email_outlined, color: Colors.deepPurple.withValues(alpha: 0.7)),
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
              Row(
                children: [
                  Icon(Icons.storefront_outlined, color: Colors.deepPurple.withValues(alpha: 0.7)),
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
    showDialog(
      context: context,
      builder: (_) => KNumericInputDialog(
        title: '事前確認メールの送信時刻（前日 HHMM）',
        initialValue: digits,
        maxLength: 4,
        overwrite: true,
        emptyHint: 'HHMM',
        themeColor: Colors.deepPurple,
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
        themeColor: Colors.deepPurple,
        onConfirmed: (v) => _update(callbackPhone: v),
      ),
    );
  }

  Widget _row({required IconData icon, required String label, required String value, required VoidCallback onTap}) {
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
            Icon(Icons.edit, size: rs(context, 16), color: Colors.deepPurple.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      children: [
        _row(
          icon: Icons.schedule,
          label: '送信時刻',
          value: _sendingTime.isEmpty ? '' : '前日 $_sendingTime',
          onTap: _editSendingTime,
        ),
        SizedBox(height: rs(context, 8)),
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

  _BranchRowData(this.branch, {this.editing = false})
      : nameController = TextEditingController(text: branch.name),
        companyController = TextEditingController(text: branch.companyName),
        addressController = TextEditingController(text: branch.address),
        phoneController = TextEditingController(text: branch.phone);

  void dispose() {
    nameController.dispose();
    companyController.dispose();
    addressController.dispose();
    phoneController.dispose();
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
    if (name == row.branch.name && company == row.branch.companyName && address == row.branch.address && phone == row.branch.phone && row.branch.id.isNotEmpty) {
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
      );
      if (!mounted) return;
      setState(() => row.branch = created);
    } else {
      final updated = row.branch.copyWith(name: name, companyName: company, address: address, phone: phone);
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._rows.map(_buildBranchRow),
        SizedBox(height: rs(context, 8)),
        TextButton.icon(
          onPressed: _addNewRow,
          icon: const Icon(Icons.add),
          label: const Text('店舗を追加'),
        ),
      ],
    );
  }

  Widget _buildBranchRow(_BranchRowData row) {
    return Container(
      margin: EdgeInsets.only(bottom: rs(context, 12)),
      padding: EdgeInsets.all(rs(context, 12)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(rs(context, 10)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: row.editing ? _buildEditView(row) : _buildDisplayView(row),
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
            color: Colors.white,
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
                    Icon(Icons.edit_location_alt, size: rs(context, 16), color: Colors.deepOrange),
                    SizedBox(width: rs(context, 4)),
                    Text('調整', style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
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
            color: Colors.white,
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
            color: Colors.white,
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

  Widget _buildDisplayView(_BranchRowData row) {
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
