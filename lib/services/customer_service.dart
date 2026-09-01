import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqlite3/common.dart';
import '../models/customer_model.dart';
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
    final results = _localDb!.select('SELECT data FROM customers WHERE phoneNumber LIKE ?', ['%$cleanSuffix']);
    return results.map((row) => Customer.fromMap(jsonDecode(row['data'] as String))).toList();
  }

  Future<void> updateCustomer(Customer updatedCustomer) async {
    await _customerCollection.doc(updatedCustomer.id).set(updatedCustomer.toMap(), SetOptions(merge: true));
    await _initLocalDb();
    _localDb!.execute(
      'INSERT OR REPLACE INTO customers (id, data, name, phoneNumber, companyName) VALUES (?, ?, ?, ?, ?)',
      [updatedCustomer.id, jsonEncode(updatedCustomer.toMap()), updatedCustomer.name, updatedCustomer.phoneNumber, updatedCustomer.companyName]
    );
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
    return finalCustomer;
  }

  Future<void> deleteCustomer(String id) async {
    await _customerCollection.doc(id).delete();
    await _initLocalDb();
    _localDb!.execute('DELETE FROM customers WHERE id = ?', [id]);
  }

}
