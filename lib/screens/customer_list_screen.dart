import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';
import '../models/menu_model.dart';
import '../services/customer_service.dart';
import '../services/order_service.dart';
import '../services/menu_service.dart';
import 'customer_list/widgets/customer_detail_dialog.dart';
import 'customer_list/widgets/customer_edit_dialog.dart';
import 'customer_list/widgets/customer_data_table.dart';
import 'order_form/widgets/sidebar/sidebar_analysis.dart';
import 'order_form/widgets/sidebar/sidebar_ranking.dart';
import '../widgets/k_responsive.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _customerService = CustomerService();
  final _orderService = OrderService();
  final _menuService = MenuService();
  
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  List<MenuModel> _allMenus = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  Customer? _selectedCustomer;
  List<OrderModel> _selectedCustomerOrders = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await Future.wait([
      _loadCustomers(),
      _loadMenus(),
    ]);
    if (_customers.isNotEmpty) {
      _onCustomerSelect(_customers.first);
    }
  }

  Future<void> _loadCustomers() async {
    try {
      final data = await _customerService.getAllCustomers();
      if (mounted) {
        setState(() {
          _customers = data;
          _filteredCustomers = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('顧客データの取得に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _loadMenus() async {
    try {
      final data = await _menuService.getAllMenus();
      if (mounted) {
        setState(() => _allMenus = data);
      }
    } catch (_) {}
  }

  void _onCustomerSelect(Customer customer) async {
    setState(() {
      _selectedCustomer = customer;
      _selectedCustomerOrders = []; // ロード中表示代わり
    });

    try {
      final allOrders = await _orderService.getAllOrders();
      if (!mounted) return;
      
      final customerOrders = allOrders.where((o) => 
        o.phoneNumber.replaceAll('-', '') == customer.phoneNumber.replaceAll('-', '') &&
        o.customerName.replaceAll(' ', '') == customer.name.replaceAll(' ', '')
      ).toList();

      setState(() {
        _selectedCustomerOrders = customerOrders;
      });
    } catch (e) {
      debugPrint('Error loading customer details: $e');
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      final lowerQuery = query.toLowerCase();
      final numericQuery = query.replaceAll('-', '');
      
      _filteredCustomers = _customers.where((c) {
        final nameMatch = c.name.toLowerCase().contains(lowerQuery);
        final companyMatch = c.companyName.toLowerCase().contains(lowerQuery);
        final phoneMatch = c.phoneNumber.contains(lowerQuery) || 
                          c.phoneNumber.replaceAll('-', '').contains(numericQuery);
        return nameMatch || companyMatch || phoneMatch;
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
              if (!mounted) return;
              Navigator.pop(context);
              _loadCustomers();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('顧客データを削除しました')));
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
              if (!mounted) return;
              Navigator.pop(context);
              _loadCustomers();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('全顧客データを削除しました')));
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
          SizedBox(width: rs(context, 12)),
          ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text('ダミー生成'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade50, foregroundColor: Colors.orange.shade900, elevation: 0),
            onPressed: () async {
              showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
              try {
                await _customerService.regenerateDummyCustomers();
                if (!mounted) return;
                Navigator.pop(context);
                _loadCustomers();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ダミーデータを生成しました（300件）')));
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
              }
            },
          ),
          SizedBox(width: rs(context, 12)),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: rs(context, 300)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: rs(context, 8)),
              child: Container(
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(rs(context, 8))),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '名前、企業、電話番号で検索...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: Icon(Icons.clear, size: rs(context, 20)), onPressed: () { _searchController.clear(); _filterCustomers(''); }) : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: rs(context, 12)),
                  ),
                  onChanged: _filterCustomers,
                ),
              ),
            ),
          ),
          SizedBox(width: rs(context, 16)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // 左側: 顧客リスト
                Expanded(
                  flex: 6,
                  child: CustomerDataTable(
                    customers: _filteredCustomers,
                    selectedCustomerId: _selectedCustomer?.id,
                    onSelect: _onCustomerSelect,
                    onShowDetail: _showCustomerDetail,
                    onEdit: _showEditCustomerDialog,
                    onDelete: _showDeleteConfirmDialog,
                  ),
                ),
                // 右側: 詳細サイドバー
                Container(
                  width: rs(context, 380),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(left: BorderSide(color: Colors.grey.shade200)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: _selectedCustomer == null
                      ? const Center(child: Text('顧客を選択してください'))
                      : _buildDetailSidebar(_selectedCustomer!),
                ),
              ],
            ),
    );
  }

  Widget _buildDetailSidebar(Customer customer) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(rs(context, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 基本情報
          _sidebarHeaderItem('顧客名', customer.name, isBold: true),
          _sidebarHeaderItem('企業名', customer.companyName.isEmpty ? '個人宅' : customer.companyName),
          _sidebarHeaderItem('電話番号', customer.phoneNumber),
          
          SizedBox(height: rs(context, 24)),

          // 2. 同じ会社の同僚 (ボタン化)
          if (customer.companyName.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(Icons.people_outline, size: rs(context, 18)),
                label: const Text('所属顧客リストを表示', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: rs(context, 12)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 8))),
                ),
                onPressed: () => _showColleaguesDialog(context, customer.companyName),
              ),
            ),
            SizedBox(height: rs(context, 32)),
          ],

          const Divider(),

          // 3. 売上分析
          SizedBox(
            height: rs(context, 250), // 高さを少し広げて視認性向上
            child: SidebarAnalysis(history: _selectedCustomerOrders),
          ),

          const Divider(),

          // 4. 人気メニュー
          SizedBox(
            height: rs(context, 280), // 高さを少し広げて視認性向上
            child: SidebarRanking(history: _selectedCustomerOrders, allMenus: _allMenus),
          ),
        ],
      ),
    );
  }

  void _showColleaguesDialog(BuildContext context, String companyName) {
    final colleagues = _customers.where((c) => 
      c.companyName == companyName && c.id != _selectedCustomer?.id
    ).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('「$companyName」の登録顧客一覧', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: rs(context, 400),
          child: colleagues.isEmpty 
            ? Padding(
                padding: EdgeInsets.all(rs(context, 24.0)),
                child: Center(child: Text('他の登録顧客はいません', style: TextStyle(color: Colors.grey))),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: colleagues.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, i) {
                  final c = colleagues[i];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(c.phoneNumber),
                    onTap: () {
                      Navigator.pop(context);
                      _onCustomerSelect(c);
                    },
                  );
                },
              ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
        ],
      ),
    );
  }

  Widget _sidebarHeaderItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rs(context, 4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('$label：', style: TextStyle(fontSize: rf(context, 13), color: Colors.grey, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isBold ? 18 : 15,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: Colors.black87
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
