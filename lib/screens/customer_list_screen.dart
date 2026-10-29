import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';
import '../models/menu_model.dart';
import '../services/customer_service.dart';
import '../services/order_service.dart';
import '../services/menu_service.dart';
import '../services/dummy_data_service.dart';
import 'customer_list/widgets/customer_detail_dialog.dart';
import 'customer_list/widgets/customer_data_table.dart';
import 'order_form/widgets/sidebar/sidebar_ranking.dart';
import '../widgets/k_responsive.dart';
import '../widgets/k_multimodal_text_field.dart';
import 'package:katura_system/utils/app_colors.dart';
import 'package:katura_system/utils/name_format.dart';
import 'phone/phone_common.dart';
import 'phone/phone_customer_list.dart';
import 'phone/phone_customer_style.dart';
import 'phone/landscape/landscape_style.dart';
import 'phone/landscape/landscape_customer.dart';

class CustomerListScreen extends StatefulWidget {
  final VoidCallback? onOpenMenu;
  final void Function(int)? onNavigate;

  const CustomerListScreen({super.key, this.onOpenMenu, this.onNavigate});

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

  String _sortKey = 'name'; // 'name' | 'company' | 'elapsed'
  bool _sortAscending = true;

  static final _dateRe = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})');

  /// 顧客ID → 前回の配達日（注文データから求める。orderHistory は書き込まれていないため）
  Map<String, DateTime> _lastOrderDates = {};

  /// 前回注文からの経過日数（履歴なしは null）
  int? _elapsedDays(Customer c) {
    DateTime? latest = _lastOrderDates[c.id];
    for (final h in c.orderHistory) {
      final m = _dateRe.firstMatch(h);
      if (m == null) continue;
      final d = DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
      if (latest == null || d.isAfter(latest)) latest = d;
    }
    if (latest == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).difference(DateTime(latest.year, latest.month, latest.day)).inDays;
  }

  /// 各顧客の「今日以前で一番新しい配達日」を注文データから求める。
  Future<Map<String, DateTime>> _calcLastOrderDates(List<Customer> customers) async {
    try {
      final orders = await _orderService.getAllOrders(forceRefresh: true);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      String digits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');
      String norm(String s) => s.replaceAll(RegExp(r'\s+'), '');
      final result = <String, DateTime>{};
      for (final c in customers) {
        final p = digits(c.phoneNumber);
        final n = norm(c.name);
        DateTime? latest;
        for (final o in orders) {
          final same = o.customerId.isNotEmpty ? o.customerId == c.id : (digits(o.phoneNumber) == p && norm(o.customerName) == n);
          if (!same) continue;
          final d = DateTime(o.deliveryDate.year, o.deliveryDate.month, o.deliveryDate.day);
          if (d.isAfter(today)) continue;
          if (latest == null || d.isAfter(latest)) latest = d;
        }
        if (latest != null) result[c.id] = latest;
      }
      return result;
    } catch (e) {
      debugPrint('lastOrderDates error: $e');
      return {};
    }
  }

  Customer? _selectedCustomer;
  List<OrderModel> _selectedCustomerOrders = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(_applyView));
    _initData();
  }

  /// 検索フィルタ＋並び替えを適用して _filteredCustomers を更新する（setState 内で呼ぶ）
  void _applyView() {
    final query = _searchController.text;
    final lowerQuery = query.toLowerCase();
    final numericQuery = query.replaceAll('-', '');

    var list = _customers.where((c) {
      if (query.isEmpty) return true;
      final nameMatch = c.name.toLowerCase().contains(lowerQuery);
      final companyMatch = c.companyName.toLowerCase().contains(lowerQuery);
      final phoneMatch = c.phoneNumber.contains(lowerQuery) ||
          c.phoneNumber.replaceAll('-', '').contains(numericQuery);
      return nameMatch || companyMatch || phoneMatch;
    }).toList();

    int cmp(Customer a, Customer b) {
      if (_sortKey == 'company') {
        return a.companyName.compareTo(b.companyName);
      }
      if (_sortKey == 'elapsed') {
        final da = _elapsedDays(a) ?? (1 << 30);
        final db = _elapsedDays(b) ?? (1 << 30);
        return da.compareTo(db);
      }
      final ka = a.furigana.isNotEmpty ? a.furigana : a.name;
      final kb = b.furigana.isNotEmpty ? b.furigana : b.name;
      return ka.compareTo(kb);
    }

    list.sort((a, b) => _sortAscending ? cmp(a, b) : cmp(b, a));
    _filteredCustomers = list;
  }

  void _onSort(String key) {
    setState(() {
      if (_sortKey == key) {
        _sortAscending = !_sortAscending;
      } else {
        _sortKey = key;
        _sortAscending = true;
      }
      _applyView();
    });
  }

  void _openSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.popupBackground,
        title: const Text('名前・企業・電話番号で検索'),
        content: SizedBox(
          width: rs(context, 380),
          child: KMultimodalTextField(
            label: '',
            showLabel: false,
            controller: _searchController,
            maxLines: 1,
            height: rs(context, 56),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              Navigator.pop(context);
            },
            child: const Text('クリア'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
        ],
      ),
    );
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
      final lastDates = await _calcLastOrderDates(data);
      if (mounted) {
        setState(() {
          _customers = data;
          _lastOrderDates = lastDates;
          _applyView();
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

  void _showCustomerDetail(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => CustomerDetailDialog(
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
        backgroundColor: AppColors.popupBackground,
        title: const Text('顧客データの削除'),
        content: Text('${withHonorific(customer.name)}のデータを削除してもよろしいですか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              await _customerService.deleteCustomer(customer.id);
              if (!mounted) return;
              navigator.pop();
              _loadCustomers();
              messenger.showSnackBar(const SnackBar(content: Text('顧客データを削除しました')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: AppColors.mainBackground),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
  }

  /// 確認ダイアログを出し、OKなら処理中表示つきで [job] を実行して一覧を読み直す。
  Future<void> _runBulk({
    required String title,
    required String message,
    required String okLabel,
    required Color okColor,
    required Future<String> Function() job,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.popupBackground,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: okColor, foregroundColor: AppColors.mainBackground),
            child: Text(okLabel),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _isLoading = true);
    String result;
    try {
      result = await job();
    } catch (e) {
      result = '失敗しました: $e';
    }
    if (!mounted) return;
    _selectedCustomer = null;
    await _loadCustomers();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  void _deleteAllData() => _runBulk(
        title: '全データの一括削除',
        message: '顧客データと受注データを「すべて」削除します。\nダミーかどうかは区別せず、元に戻せません。',
        okLabel: 'すべて削除する',
        okColor: Colors.red,
        job: () async {
          await DummyDataService().deleteAll();
          return '顧客と受注のデータをすべて削除しました';
        },
      );

  // ---- スマホ版（幅600未満）----
  final Set<String> _checkedIds = {};

  void _toggleChecked(Customer c) => setState(() {
        if (!_checkedIds.remove(c.id)) _checkedIds.add(c.id);
      });

  /// 表示中の顧客が全部選択済みなら解除、そうでなければ全選択
  void _toggleSelectAll() => setState(() {
        final all = _filteredCustomers.every((c) => _checkedIds.contains(c.id));
        if (all) {
          _checkedIds.clear();
        } else {
          _checkedIds.addAll(_filteredCustomers.map((c) => c.id));
        }
      });

  Future<void> _deleteChecked() async {
    final ids = _checkedIds.toList();
    if (ids.isEmpty || !await showPhoneDeleteManyDialog(context, ids.length) || !mounted) return;
    for (final id in ids) {
      await _customerService.deleteCustomer(id);
    }
    if (!mounted) return;
    setState(() {
      _checkedIds.clear();
      if (_selectedCustomer != null && ids.contains(_selectedCustomer!.id)) _selectedCustomer = null;
    });
    await _loadCustomers();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${ids.length}件の顧客データを削除しました')));
  }

  Future<void> _phoneSearch() async {
    final r = await showPhoneCustomerSearchSheet(context, _searchController.text);
    if (r != null) _searchController.text = r;
  }

  Future<void> _phoneMenu(Customer c) async {
    final r = await showPhoneCustomerMenu(context, c);
    if (!mounted) return;
    if (r == 'detail') {
      _showCustomerDetail(c);
    } else if (r == 'delete') {
      await _phoneDelete(c);
    }
  }

  Future<void> _phoneDelete(Customer c) async {
    if (await showPhoneDeleteCustomerDialog(context, c) && mounted) {
      await _customerService.deleteCustomer(c.id);
      if (!mounted) return;
      if (_selectedCustomer?.id == c.id) _selectedCustomer = null;
      _loadCustomers();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('顧客データを削除しました')));
    }
  }

  /// 行タップ：所属企業があれば「所属顧客一覧」、なければ詳細を開く
  Future<void> _phoneTap(Customer c) async {
    setState(() => _selectedCustomer = c);
    if (c.companyName.isEmpty) {
      _showCustomerDetail(c);
      return;
    }
    final colleagues = _customers.where((x) => x.companyName == c.companyName && x.id != c.id).toList();
    final picked = await showPhoneColleaguesSheet(context, c.companyName, colleagues);
    if (picked != null && mounted) {
      setState(() => _selectedCustomer = picked);
      _showCustomerDetail(picked);
    }
  }

  Widget _buildPhoneLandscape() {
    return Scaffold(
      backgroundColor: LS.bg,
      resizeToAvoidBottomInset: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LandscapeCustomerView(
              customers: _filteredCustomers,
              elapsedDays: _elapsedDays,
              selected: _selectedCustomer,
              sortKey: _sortKey,
              sortAscending: _sortAscending,
              searchText: _searchController.text,
              onSort: _onSort,
              onSearch: _phoneSearch,
              onClearSearch: _searchController.clear,
              onTap: (c) => _checkedIds.isNotEmpty ? _toggleChecked(c) : setState(() => _selectedCustomer = c),
              onLongPress: _toggleChecked,
              checkedIds: _checkedIds,
              onCancelSelect: () => setState(_checkedIds.clear),
              onDeleteChecked: _deleteChecked,
              onDetail: _phoneTap,
              onDelete: _phoneDelete,
              onSelectAll: _toggleSelectAll,
              onNewOrder: () => widget.onNavigate?.call(0),
            ),
    );
  }

  Widget _buildPhone() {
    return Scaffold(
      backgroundColor: PcColors.bg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PhoneCustomerList(
              customers: _filteredCustomers,
              elapsedDays: _elapsedDays,
              selectedId: _selectedCustomer?.id,
              sortKey: _sortKey,
              sortAscending: _sortAscending,
              searchText: _searchController.text,
              onSort: _onSort,
              onSearch: _phoneSearch,
              onClearSearch: _searchController.clear,
              onTap: (c) => _checkedIds.isNotEmpty ? _toggleChecked(c) : _phoneTap(c),
              onMenu: _phoneMenu,
              checkedIds: _checkedIds,
              onLongPress: _toggleChecked,
              onSelectAll: _toggleSelectAll,
              onCancelSelect: () => setState(_checkedIds.clear),
              onDeleteChecked: _deleteChecked,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isPhoneLandscape(context)) return _buildPhoneLandscape();
    if (isPhoneWidth(context)) return _buildPhone();
    final bool hasQuery = _searchController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('顧客管理システム', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.mainBackground,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            tooltip: '全データを一括削除',
            onPressed: _deleteAllData,
          ),
          if (hasQuery)
            InkWell(
              onTap: _openSearchDialog,
              borderRadius: BorderRadius.circular(rs(context, 8)),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: rs(context, 8)),
                padding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rs(context, 6)),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(rs(context, 8)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: rs(context, 18), color: Colors.blueGrey),
                    SizedBox(width: rs(context, 6)),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: rs(context, 180)),
                      child: Text(
                        _searchController.text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: rs(context, 4)),
                    InkWell(
                      onTap: () => _searchController.clear(),
                      child: Icon(Icons.close, size: rs(context, 16), color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: '名前・企業・電話番号で検索',
              onPressed: _openSearchDialog,
            ),
          SizedBox(width: rs(context, 12)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // 左側: 顧客リスト
                Expanded(
                  flex: 2,
                  child: CustomerDataTable(
                    customers: _filteredCustomers,
                    lastOrderDates: _lastOrderDates,
                    selectedCustomerId: _selectedCustomer?.id,
                    onSelect: _onCustomerSelect,
                    onShowDetail: _showCustomerDetail,
                    onDelete: _showDeleteConfirmDialog,
                    sortKey: _sortKey,
                    sortAscending: _sortAscending,
                    onSort: _onSort,
                  ),
                ),
                // 右側: 詳細サイドバー
                Expanded(
                  flex: 1,
                  child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.mainBackground,
                    border: Border(left: BorderSide(color: Colors.grey.shade200)),
                    boxShadow: [BoxShadow(color: AppColors.primaryText.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: _selectedCustomer == null
                      ? const Center(child: Text('顧客を選択してください'))
                      : _buildDetailSidebar(_selectedCustomer!),
                  ),
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

          // 3. 人気メニュー
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
                    title: Text(withHonorific(c.name), style: const TextStyle(fontWeight: FontWeight.bold)),
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
