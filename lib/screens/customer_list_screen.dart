import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';
import 'customer_list/widgets/customer_detail_dialog.dart';
import 'customer_list/widgets/customer_edit_dialog.dart';
import 'customer_list/widgets/customer_data_table.dart';

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
      setState(() => _isLoading = false);
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
        final phoneMatch = c.phoneNumber.contains(lowerQuery) || 
                          c.phoneNumber.replaceAll('-', '').contains(numericQuery);
        return nameMatch || companyMatch || addressMatch || phoneMatch;
      }).toList();
    });
  }

  void _showCustomerDetail(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => CustomerDetailDialog(customer: customer),
    );
  }

  void _showEditCustomerDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => CustomerEditDialog(
        customer: customer,
        customerService: _customerService,
        onSaved: _loadCustomers,
      ),
    );
  }

  void _showDeleteConfirmDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('顧客データの削除'),
        content: Text('${customer.name} 様のデータを削除してもよろしいですか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () async {
              await _customerService.deleteCustomer(customer.id);
              if (mounted) {
                Navigator.pop(context);
                _loadCustomers();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('顧客データを削除しました')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('削除する'),
          ),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
              await _customerService.deleteAllCustomers();
              if (mounted) {
                Navigator.pop(context);
                _loadCustomers();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('全顧客データを削除しました')));
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
        title: const Text('顧客管理システム', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: const Text('全削除'),
            onPressed: _showDeleteAllConfirmDialog,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red, elevation: 0),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text('ダミー生成'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade50, foregroundColor: Colors.orange.shade900, elevation: 0),
            onPressed: () async {
              showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
              try {
                await _customerService.regenerateDummyCustomers();
                if (mounted) Navigator.pop(context);
                _loadCustomers();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ダミーデータを生成しました（100件）')));
              } catch (e) {
                if (mounted) Navigator.pop(context);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
              }
            },
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '検索...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: () { _searchController.clear(); _filterCustomers(''); }) : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: _filterCustomers,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomerDataTable(
              customers: _filteredCustomers,
              onShowDetail: _showCustomerDetail,
              onEdit: _showEditCustomerDialog,
              onDelete: _showDeleteConfirmDialog,
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
