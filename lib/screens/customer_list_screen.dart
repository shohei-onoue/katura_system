import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _customerService = CustomerService();
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final data = await _customerService.getAllCustomers();
      setState(() {
        _customers = data;
        _filteredCustomers = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading customers: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('データの取得に失敗しました: $e')),
        );
      }
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      final lowerQuery = query.toLowerCase();
      final numericQuery = query.replaceAll('-', '');
      
      _filteredCustomers = _customers.where((c) {
        final nameMatch = c.name.toLowerCase().contains(lowerQuery);
        final companyMatch = c.companyName.toLowerCase().contains(lowerQuery);
        final addressMatch = c.address.toLowerCase().contains(lowerQuery);
        
        // 電話番号はハイフンあり・なし両方で判定（入力側がハイフンなしでもヒットするように）
        final phoneMatch = c.phoneNumber.contains(lowerQuery) || 
                          c.phoneNumber.replaceAll('-', '').contains(numericQuery);
        
        return nameMatch || companyMatch || addressMatch || phoneMatch;
      }).toList();
    });
  }

  void _showCustomerDetail(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Text('${customer.name} 様 詳細'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SizedBox(
          width: 700,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailItem('顧客氏名', customer.name),
                          _detailItem('ふりがな', customer.furigana),
                          _detailItem('所属企業', customer.companyName),
                          _detailItem('電話番号', customer.phoneNumber),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailItem('代表住所', customer.address),
                          _detailItem('位置座標', '${customer.latitude ?? "-"}, ${customer.longitude ?? "-"}'),
                          _detailItem('メール', customer.email),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 48, thickness: 1),
                const Text('【 配達先マスター・履歴 】', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey)),
                const SizedBox(height: 16),
                ...customer.deliveryAddresses.map((addr) {
                  // "施設名: 住所 (座標)" 形式を想定
                  final parts = addr.split(': ');
                  final facilityName = parts.length > 1 ? parts[0] : '名称なし';
                  final addressWithCoord = parts.length > 1 ? parts[1] : addr;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.business, size: 18, color: Colors.deepOrange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(facilityName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('住所: ${addressWithCoord.split(' (')[0]}', style: const TextStyle(color: Colors.black87)),
                              if (addressWithCoord.contains('('))
                                Text(
                                  '座標: ${addressWithCoord.substring(addressWithCoord.indexOf('('))}',
                                  style: const TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 48, thickness: 1),
                const Text('【 注文履歴（施設別サマリー） 】', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey)),
                const SizedBox(height: 16),
                if (customer.orderHistory.isEmpty)
                  const Text('履歴なし', style: TextStyle(color: Colors.grey))
                else
                  ...customer.orderHistory.map((history) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.history, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                history,
                                style: const TextStyle(fontSize: 15, fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showEditCustomerDialog(Customer customer) {
    final nameController = TextEditingController(text: customer.name);
    final companyController = TextEditingController(text: customer.companyName);
    final phoneController = TextEditingController(text: _formatPhone(customer.phoneNumber));
    final emailController = TextEditingController(text: customer.email);
    final addressController = TextEditingController(text: customer.address);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('顧客情報の編集'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '氏名'),
                ),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: '企業名'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: '電話番号'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                    _PhoneFormatter(_formatPhone),
                  ],
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'メールアドレス'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: '住所'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedCustomer = customer.copyWith(
                name: nameController.text,
                companyName: companyController.text,
                phoneNumber: phoneController.text,
                email: emailController.text,
                address: addressController.text,
              );
              await _customerService.updateCustomer(updatedCustomer);
              if (mounted) {
                Navigator.pop(context);
                _loadCustomers();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
            child: const Text('保存'),
          ),
        ],
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

  void _showDeleteConfirmDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('顧客データの削除'),
        content: Text('${customer.name} 様のデータを削除してもよろしいですか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _customerService.deleteCustomer(customer.id);
              if (mounted) {
                Navigator.pop(context);
                _loadCustomers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('顧客データを削除しました')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  void _showDeleteAllConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('全顧客データの一括削除'),
        content: const Text('システム内の全顧客データを削除してもよろしいですか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              await _customerService.deleteAllCustomers();
              if (mounted) {
                Navigator.pop(context);
                _loadCustomers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('全顧客データを削除しました')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('一括削除する'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('顧客管理システム'),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: const Text('全削除'),
            onPressed: _showDeleteAllConfirmDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text('ダミー生成'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
              foregroundColor: Colors.orange.shade900,
              elevation: 0,
            ),
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              try {
                await _customerService.regenerateDummyCustomers();
                if (mounted) Navigator.pop(context);
                _loadCustomers();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ダミーデータを生成しました（100件）')),
                  );
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('エラー: $e')),
                  );
                }
              }
            },
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '検索...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _filterCustomers('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _filterCustomers(value);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Scrollbar(
                            thumbVisibility: true,
                            notificationPredicate: (n) => n.depth == 1,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth - 48,
                                ),
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                                  dataRowMaxHeight: 60,
                                  columnSpacing: 24,
                                  columns: const [
                                    DataColumn(label: Text('氏名', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('企業名', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('電話番号', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('住所', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Center(child: Text('操作', style: TextStyle(fontWeight: FontWeight.bold)))),
                                  ],
                                  rows: _filteredCustomers.map((customer) {
                                    return DataRow(cells: [
                                      DataCell(
                                        Text(
                                          customer.name,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                          softWrap: false,
                                        ),
                                      ),
                                      DataCell(Text(customer.companyName, softWrap: false)),
                                      DataCell(Text(customer.phoneNumber, softWrap: false)),
                                      DataCell(
                                        Text(
                                          customer.address,
                                          softWrap: false,
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextButton.icon(
                                              icon: const Icon(Icons.info_outline, size: 18),
                                              label: const Text('詳細'),
                                              onPressed: () => _showCustomerDetail(customer),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.deepOrange,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton.icon(
                                              icon: const Icon(Icons.edit, size: 18),
                                              label: const Text('編集'),
                                              onPressed: () => _showEditCustomerDialog(customer),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.blue,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton.icon(
                                              icon: const Icon(Icons.delete_outline, size: 18),
                                              label: const Text('削除'),
                                              onPressed: () => _showDeleteConfirmDialog(customer),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _PhoneFormatter extends TextInputFormatter {
  final String Function(String) formatFunc;
  _PhoneFormatter(this.formatFunc);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final formatted = formatFunc(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }
}
