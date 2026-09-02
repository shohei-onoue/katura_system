import 'package:flutter/material.dart';
import '../../../models/customer_model.dart';
import '../../../services/customer_service.dart';
import '../../../widgets/k_responsive.dart';
import '../../../widgets/k_multimodal_text_field.dart';
import '../../../widgets/k_facility_search_dialog.dart';

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
  late final TextEditingController _nameController;
  late final TextEditingController _furiganaController;
  late String _companyName;
  late String _address;
  late double? _latitude;
  late double? _longitude;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _furiganaController = TextEditingController(text: widget.customer.furigana);
    _companyName = widget.customer.companyName;
    _address = widget.customer.address;
    _latitude = widget.customer.latitude;
    _longitude = widget.customer.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _furiganaController.dispose();
    super.dispose();
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
      name: _nameController.text.trim(),
      furigana: _furiganaController.text.trim(),
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
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: rs(context, 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー
            Container(
              width: double.infinity,
              color: const Color(0xFF000038),
              padding: EdgeInsets.symmetric(horizontal: rs(context, 20), vertical: rs(context, 12)),
              child: Row(
                children: [
                  Text('詳細', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: rf(context, 16))),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // 詳細情報エリア（白背景）
            Flexible(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(rs(context, 24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 顧客名 / 所属企業
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _fieldLabel(context, '顧客名'),
                                KMultimodalTextField(
                                  label: '',
                                  showLabel: false,
                                  controller: _nameController,
                                  maxLines: 1,
                                  height: rs(context, 52),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: rs(context, 24)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    _fieldLabel(context, '所属企業'),
                                    const Spacer(),
                                    PopupMenuButton<int>(
                                      icon: Icon(Icons.more_vert, size: rs(context, 20), color: Colors.blueGrey),
                                      padding: EdgeInsets.zero,
                                      tooltip: '検索して所属企業・住所・座標を反映',
                                      onSelected: _openFacilitySearch,
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(value: 0, child: Text('地域・カテゴリで検索')),
                                        PopupMenuItem(value: 1, child: Text('地域・キーワードで検索')),
                                        PopupMenuItem(value: 2, child: Text('住所で検索')),
                                      ],
                                    ),
                                  ],
                                ),
                                _readonlyValue(context, _companyName.isEmpty ? '未設定' : _companyName),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: rs(context, 14)),
                      // ふりがな / 住所
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _fieldLabel(context, 'ふりがな'),
                                KMultimodalTextField(
                                  label: '',
                                  showLabel: false,
                                  controller: _furiganaController,
                                  maxLines: 1,
                                  height: rs(context, 52),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: rs(context, 24)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _fieldLabel(context, '住所'),
                                _readonlyValue(context, _address.isEmpty ? '未設定' : _address),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: rs(context, 14)),
                      // 電話番号 / 位置座標
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _fieldLabel(context, '電話番号'),
                                _readonlyValue(context, widget.customer.phoneNumber),
                              ],
                            ),
                          ),
                          SizedBox(width: rs(context, 24)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _fieldLabel(context, '位置座標'),
                                _readonlyValue(context, '${_latitude ?? "-"}, ${_longitude ?? "-"}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(height: rs(context, 40), thickness: 1),
                      Text('配達先履歴',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 18), color: Colors.blueGrey)),
                      SizedBox(height: rs(context, 16)),
                      if (widget.customer.deliveryAddresses.isEmpty)
                        const Text('履歴なし', style: TextStyle(color: Colors.grey))
                      else
                        ...widget.customer.deliveryAddresses.map((addr) {
                          final parts = addr.split(': ');
                          final facilityName = parts.length > 1 ? parts[0] : '名称なし';
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
                                    Icon(Icons.business, size: rs(context, 18), color: Colors.deepOrange),
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
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 8), rs(context, 20), rs(context, 12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
                  SizedBox(width: rs(context, 8)),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000038),
                      foregroundColor: Colors.white,
                    ),
                    child: _saving
                        ? SizedBox(
                            width: rs(context, 16),
                            height: rs(context, 16),
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
