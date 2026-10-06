import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqlite3/common.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';
import 'address_service.dart';
import 'google_maps_service.dart';
import 'database_factory.dart';

class CustomerService {
  final CollectionReference _customerCollection =
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').collection('customers');
  final _addressService = AddressService();
  final _googleMapsService = GoogleMapsService();

  CommonDatabase? _localDb;

  /// データベースの一本化 (katura_cache.db)
  Future<void> _initLocalDb() async {
    if (_localDb != null) return;
    _localDb = await DatabaseFactory.openProjectDatabase("assets/navi_database.db", "katura_cache.db");
    
    // 顧客テーブル
    _localDb!.execute('''
      CREATE TABLE IF NOT EXISTS customers (
        id TEXT PRIMARY KEY,
        data TEXT,
        name TEXT,
        phoneNumber TEXT,
        companyName TEXT
      )
    ''');
    
    // 注文テーブル
    _localDb!.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id TEXT PRIMARY KEY,
        data TEXT,
        deliveryDate TEXT,
        updatedAt INTEGER
      )
    ''');
    
    _localDb!.execute('CREATE INDEX IF NOT EXISTS idx_cust_phone ON customers(phoneNumber)');
    _localDb!.execute('CREATE INDEX IF NOT EXISTS idx_cust_name ON customers(name)');
    _localDb!.execute('CREATE INDEX IF NOT EXISTS idx_ord_date ON orders(deliveryDate)');
  }

  // customerId -> 顧客管理の最新名（取得失敗/未登録は null をキャッシュ）
  static final Map<String, Future<String?>> _nameCache = {};

  /// customers/{id}/name を返す。id空・未登録・失敗時は null（呼び出し側で受注保存名へフォールバック）。
  Future<String?> getCustomerNameById(String? customerId) {
    final id = customerId?.trim() ?? '';
    if (id.isEmpty) return Future.value(null);
    return _nameCache.putIfAbsent(id, () async {
      try {
        final doc = await _customerCollection.doc(id).get();
        final data = doc.data() as Map<String, dynamic>?;
        final name = data?['name'];
        if (name is String && name.trim().isNotEmpty) return name;
        // ふりがなのみで登録された顧客は、ふりがなを顧客名として扱う
        final furigana = data?['furigana'];
        return (furigana is String && furigana.trim().isNotEmpty) ? furigana : null;
      } catch (e) {
        debugPrint('CustomerService: name fetch failed ($id): $e');
        _nameCache.remove(id); // 失敗は次回再試行
        return null;
      }
    });
  }

  /// 複数IDを一括解決。結果は {customerId: name}（取得できたものだけ）。
  Future<Map<String, String>> getCustomerNamesByIds(Iterable<String?> ids) async {
    final unique = ids.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
    final result = <String, String>{};
    await Future.wait(unique.map((id) async {
      final n = await getCustomerNameById(id);
      if (n != null) result[id] = n;
    }));
    return result;
  }

  /// 受注ごとの表示用の顧客名を一括で解決する。結果は {受注ID: 顧客名}（解決できた受注だけ）。
  /// 顧客IDで顧客管理から引き、旧データ（顧客IDなし）は電話番号（数字のみ）で1件だけ一致した顧客を使う。
  /// 受注の顧客名を表示する画面は、受注に保存された名前ではなく必ずこれを使う。
  Future<Map<String, String>> resolveOrderNames(Iterable<OrderModel> orders) async {
    final customers = await getAllCustomers();
    String digits(String v) => v.replaceAll(RegExp(r'[^0-9]'), '');
    final byId = {for (final c in customers) c.id: c.name};
    final byPhone = <String, List<String>>{};
    for (final c in customers) {
      final d = digits(c.phoneNumber);
      if (d.isNotEmpty) byPhone.putIfAbsent(d, () => []).add(c.name);
    }
    final names = <String, String>{};
    for (final o in orders) {
      final byIdName = byId[o.customerId];
      final phoneMatches = byPhone[digits(o.phoneNumber)];
      if (byIdName != null && byIdName.isNotEmpty) {
        names[o.id] = byIdName;
      } else if (o.customerId.isEmpty && phoneMatches != null && phoneMatches.length == 1 && phoneMatches.first.isNotEmpty) {
        names[o.id] = phoneMatches.first;
      }
    }
    return names;
  }

  /// 顧客名変更時などにキャッシュを破棄する。
  static void clearCustomerNameCache([String? customerId]) =>
      customerId == null ? _nameCache.clear() : _nameCache.remove(customerId);

  AddressService getAddressService() => _addressService;
  GoogleMapsService getGoogleMapsService() => _googleMapsService;

  Future<List<Customer>> getAllCustomers({bool forceRefresh = false}) async {
    await _initLocalDb();
    if (!forceRefresh) {
      final results = _localDb!.select('SELECT data FROM customers ORDER BY name ASC');
      if (results.isNotEmpty) {
        debugPrint('CustomerService: Loading from Local DB (${results.length} customers)');
        return results.map((row) => Customer.fromMap(jsonDecode(row['data'] as String))).toList();
      }
    }
    debugPrint('CustomerService: Fetching from Firestore...');
    final snapshot = await _customerCollection.get();
    final list = snapshot.docs.map((doc) => Customer.fromMap(doc.data() as Map<String, dynamic>)).toList();
    _syncToLocalDb(list);
    return list;
  }

  void _syncToLocalDb(List<Customer> customers) {
    _localDb!.execute('BEGIN TRANSACTION');
    try {
      final stmt = _localDb!.prepare('INSERT OR REPLACE INTO customers (id, data, name, phoneNumber, companyName) VALUES (?, ?, ?, ?, ?)');
      for (var c in customers) {
        stmt.execute([c.id, jsonEncode(c.toMap()), c.name, c.phoneNumber, c.companyName]);
      }
      stmt.close();
      _localDb!.execute('COMMIT');
    } catch (e) {
      _localDb!.execute('ROLLBACK');
      debugPrint('Local DB Sync Error: $e');
    }
  }

  Future<List<Customer>> searchByPhoneSuffix(String suffix) async {
    await _initLocalDb();
    final cleanSuffix = suffix.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanSuffix.length < 4) return [];
    final results = _localDb!.select("SELECT data FROM customers WHERE REPLACE(REPLACE(phoneNumber, '-', ''), ' ', '') LIKE ?", ['%$cleanSuffix']);
    return results.map((row) => Customer.fromMap(jsonDecode(row['data'] as String))).toList();
  }

  Future<void> updateCustomer(Customer updatedCustomer) async {
    await _customerCollection.doc(updatedCustomer.id).set(updatedCustomer.toMap(), SetOptions(merge: true));
    await _initLocalDb();
    _localDb!.execute(
      'INSERT OR REPLACE INTO customers (id, data, name, phoneNumber, companyName) VALUES (?, ?, ?, ?, ?)',
      [updatedCustomer.id, jsonEncode(updatedCustomer.toMap()), updatedCustomer.name, updatedCustomer.phoneNumber, updatedCustomer.companyName]
    );
    clearCustomerNameCache(updatedCustomer.id);
  }

  Future<Customer> createCustomer(Customer customer) async {
    final docId = customer.id.isEmpty ? _customerCollection.doc().id : customer.id;
    final finalCustomer = customer.copyWith(id: docId);
    await _customerCollection.doc(docId).set(finalCustomer.toMap());
    await _initLocalDb();
    _localDb!.execute(
      'INSERT OR REPLACE INTO customers (id, data, name, phoneNumber, companyName) VALUES (?, ?, ?, ?, ?)',
      [docId, jsonEncode(finalCustomer.toMap()), finalCustomer.name, finalCustomer.phoneNumber, finalCustomer.companyName]
    );
    clearCustomerNameCache(docId);
    return finalCustomer;
  }

  Future<void> deleteCustomer(String id) async {
    await _customerCollection.doc(id).delete();
    await _initLocalDb();
    _localDb!.execute('DELETE FROM customers WHERE id = ?', [id]);
    clearCustomerNameCache(id);
  }

}
