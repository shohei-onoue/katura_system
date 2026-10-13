import 'package:katura_system/utils/history_entry.dart';
import 'package:flutter/material.dart';
import '../../../models/customer_model.dart';
import '../../../services/customer_service.dart';
import '../../../widgets/k_responsive.dart';
import '../../../widgets/k_pen_input_dialog.dart';
import '../../../widgets/k_numeric_input_dialog.dart';
import '../../../widgets/k_facility_search_dialog.dart';
import 'package:katura_system/utils/app_colors.dart';

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
  late String _email;
  late String _phone;
  late String _companyName;
  late String _address;
  late double? _latitude;
  late double? _longitude;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = widget.customer.name;
    _furigana = widget.customer.furigana;
    _email = widget.customer.email;
    _phone = widget.customer.phoneNumber;
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

  Future<void> _openFacilitySearch(int tab) async {
    final result = await showKFacilitySearchDialog(context, initialTab: tab, initialArea: _address);
    if (result == null) return;
    setState(() {
      _companyName = result.name;
      _address = result.address;
      _latitude = result.lat;
      _longitude = result.lng;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final updated = widget.customer.copyWith(
      name: _name,
      furigana: _furigana,
      email: _email,
      phoneNumber: _phone,
      companyName: _companyName,
      address: _address,
      latitude: _latitude,
      longitude: _longitude,
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.popupBackground,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: rs(context, 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            // 詳細情報エリア（白背景）
            Flexible(
              child: Container(
                color: AppColors.mainBackground,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(rs(context, 24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 顧客名 / 所属企業
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _editableField(context, '顧客名', _name,
                                onEdit: () => _editText(_name, (t) => _name = t)),
                          ),
                          SizedBox(width: rs(context, 24)),
                          Expanded(
                            child: _editableField(context, '所属企業', _companyName.isEmpty ? '未設定' : _companyName,
                                searchMenu: true),
                          ),
                        ],
                      ),
                      SizedBox(height: rs(context, 14)),
                      // ふりがな / 住所
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _editableField(context, 'ふりがな', _furigana.isEmpty ? '未設定' : _furigana,
                                onEdit: () => _editText(_furigana, (t) => _furigana = t)),
                          ),
                          SizedBox(width: rs(context, 24)),
                          Expanded(
                            child: _editableField(context, '住所', _address.isEmpty ? '未設定' : _address,
                                onEdit: () => _openFacilitySearch(2)),
                          ),
                        ],
                      ),
                      SizedBox(height: rs(context, 14)),
                      // 電話番号 / 位置座標
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _editableField(context, '電話番号', _phone.isEmpty ? '未設定' : _phone, onEdit: _editPhone),
                          ),
                          SizedBox(width: rs(context, 24)),
                          Expanded(
                            child: _editableField(context, '位置座標', '${_latitude ?? "-"}, ${_longitude ?? "-"}',
                                onEdit: () => _openFacilitySearch(2)),
                          ),
                        ],
                      ),
                      SizedBox(height: rs(context, 14)),
                      // メールアドレス
                      Row(
                        children: [
                          Expanded(
                            child: _editableField(context, 'メールアドレス', _email.isEmpty ? '未設定' : _email,
                                onEdit: () => _editText(_email, (t) => _email = t)),
                          ),
                          SizedBox(width: rs(context, 24)),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      Divider(height: rs(context, 40), thickness: 1),
                      Text('配達先履歴',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 18), color: Colors.blueGrey)),
                      SizedBox(height: rs(context, 16)),
                      if (widget.customer.deliveryAddresses.isEmpty)
                        const Text('履歴なし', style: TextStyle(color: Colors.grey))
                      else
                        ...widget.customer.deliveryAddresses.map((rawAddr) {
                          final addr = normalizeHistoryEntry(rawAddr);
                          final parts = addr.split(': ');
                          final facilityName = parts.length > 1 ? parts[0] : '個人宅';
                          final rest = parts.length > 1 ? parts.sublist(1).join(': ') : addr;
                          final addressOnly = rest.split(' (')[0];
                          return Container(
                            margin: EdgeInsets.only(bottom: rs(context, 12)),
                            padding: EdgeInsets.all(rs(context, 16)),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(rs(context, 8)),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.business, size: rs(context, 18), color: AppColors.accentOrange),
                                    SizedBox(width: rs(context, 8)),
                                    Expanded(
                                      child: Text(facilityName,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 16))),
                                    ),
                                  ],
                                ),
                                SizedBox(height: rs(context, 6)),
                                Padding(
                                  padding: EdgeInsets.only(left: rs(context, 26)),
                                  child: Text(addressOnly, style: const TextStyle(color: Colors.black87)),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
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
    );
  }

  /// ラベル（右に鉛筆アイコン）＋値。鉛筆から、その項目だけを編集する。
  /// [searchMenu] が true のときは、所属企業を検索して反映するメニューを開く。
  Widget _editableField(BuildContext context, String label, String value,
      {VoidCallback? onEdit, bool searchMenu = false}) {
    final pencil = Icon(Icons.edit, size: rs(context, 18), color: Colors.blueGrey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _fieldLabel(context, label),
            const Spacer(),
            if (searchMenu)
              PopupMenuButton<int>(
                icon: pencil,
                padding: EdgeInsets.zero,
                tooltip: '$labelを編集',
                onSelected: _openFacilitySearch,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 0, child: Text('地域・カテゴリで検索')),
                  PopupMenuItem(value: 1, child: Text('地域・キーワードで検索')),
                  PopupMenuItem(value: 2, child: Text('住所で検索')),
                ],
              )
            else
              InkWell(
                onTap: onEdit,
                child: Padding(padding: EdgeInsets.all(rs(context, 4)), child: pencil),
              ),
          ],
        ),
        _readonlyValue(context, value),
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
