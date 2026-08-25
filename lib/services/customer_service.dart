import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sqlite3/common.dart';
import '../models/customer_model.dart';
import 'address_service.dart';
import 'google_maps_service.dart';
import 'menu_service.dart';
import 'database_factory.dart';

class CustomerService {
  final CollectionReference _customerCollection =
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').collection('customers');
  final CollectionReference _menuCollection =
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').collection('menu');
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

  Future<void> deleteAllCustomers() async {
    // Firestore 削除
    final collections = [_customerCollection, FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').collection('orders')];
    for (var col in collections) {
      while (true) {
        final snapshot = await col.limit(500).get();
        if (snapshot.docs.isEmpty) break;
        final batch = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').batch();
        for (var doc in snapshot.docs) { batch.delete(doc.reference); }
        await batch.commit();
      }
    }
    // Local DB 削除
    await _initLocalDb();
    _localDb!.execute('DELETE FROM customers');
    _localDb!.execute('DELETE FROM orders'); 
  }

  Future<void> regenerateDummyCustomers() async {
    try {
      final random = Random();
      await deleteAllCustomers();

      var menuSnapshot = await _menuCollection.get();
      if (menuSnapshot.docs.isEmpty) {
        await MenuService().seedMenuData();
        menuSnapshot = await _menuCollection.get();
      }
      final menus = menuSnapshot.docs.map((doc) => {
        'id': doc.id, 'name': (doc.data() as Map)['name'] as String, 'price': (doc.data() as Map)['price'] as int,
      }).toList();

      final cityCoords = {
        '岡崎市': const LatLng(34.9563, 137.1685), '名古屋市': const LatLng(35.1815, 136.9066), '豊田市': const LatLng(35.0833, 137.1500),
        '安城市': const LatLng(34.9594, 137.0872), '一宮市': const LatLng(35.3015, 136.7963), '春日井市': const LatLng(35.2476, 136.9719),
        '刈谷市': const LatLng(34.9897, 137.0039), '豊橋市': const LatLng(34.7692, 137.3915), '西尾市': const LatLng(34.8633, 137.0542),
        '知立市': const LatLng(34.9856, 137.0425), '幸田町': const LatLng(34.8622, 137.1650),
      };

      final entities = await _addressService.getRandomAichiEntities(limit: 80);
      final branches = ['岡崎本店', '名古屋店', '岐阜店'];
      final lastNames = ['佐藤', '鈴木', '高橋', '田中', '伊藤', '渡辺', '山本', '中村', '小林', '加藤', '吉田', '山田', '佐々木', '山口', '松本', '井上', '木村', '林', '斎藤', '清水'];
      final firstNames = ['健一', '直樹', '恵子', '由美子', '和也', '大輔', '雅弘', '美穂', '沙織', '翔太', '陽子', '真一', '愛', '健太', '美咲', '大樹', '彩', '拓海', '七海', '駿'];

      final orderCollection = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').collection('orders');
      final now = DateTime.now();
      int totalCreated = 0;
      const int targetCount = 300;
      int entityIdx = 0;

      await _initLocalDb();
      _localDb!.execute('BEGIN TRANSACTION');
      final custStmt = _localDb!.prepare('INSERT OR REPLACE INTO customers (id, data, name, phoneNumber, companyName) VALUES (?, ?, ?, ?, ?)');
      final orderStmt = _localDb!.prepare('INSERT OR REPLACE INTO orders (id, data, deliveryDate, updatedAt) VALUES (?, ?, ?, ?)');

      // Firestore用の一括バッチ管理
      WriteBatch fbBatch = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').batch();
      int fbBatchCount = 0;

      while (totalCreated < targetCount) {
        final entity = entities[entityIdx % entities.length];
        final entityName = entity['name'] ?? '一般';
        final city = entity['city'] ?? '岡崎市';
        final entityAddr = "${entity['pref'] ?? '愛知県'}$city${entity['town'] ?? ''}${entity['addr'] ?? ''}";

        final latLng = await _googleMapsService.getLatLngFromAddress("$entityName $entityAddr");
        double lat = latLng?['lat'] ?? 0.0;
        double lng = latLng?['lng'] ?? 0.0;
        if (lat == 0 && cityCoords.containsKey(city)) {
          lat = cityCoords[city]!.latitude + (random.nextDouble() - 0.5) * 0.05;
          lng = cityCoords[city]!.longitude + (random.nextDouble() - 0.5) * 0.05;
        }

        int staffCount = random.nextInt(5) + 2;
        if (totalCreated + staffCount > targetCount) staffCount = targetCount - totalCreated;

        for (int s = 0; staffCount > s; s++) {
          final name = "${lastNames[random.nextInt(lastNames.length)]} ${firstNames[random.nextInt(firstNames.length)]}";
          final phone = '0${random.nextInt(3) + 7}0-${random.nextInt(9000) + 1000}-${random.nextInt(9000) + 1000}';
          final profile = random.nextDouble() < 0.2 ? 'new' : (random.nextDouble() < 0.4 ? 'churned' : 'active');

          List<String> historyStrings = [];
          int hCount = profile == 'new' ? random.nextInt(3) + 1 : random.nextInt(8) + 4;

          for (int h = 0; h < hCount; h++) {
            DateTime oDate = profile == 'new' ? now.subtract(Duration(days: random.nextInt(90))) 
                          : (profile == 'churned' ? now.subtract(Duration(days: random.nextInt(180) + 180)) 
                          : (h == 0 ? now.subtract(Duration(days: random.nextInt(30))) : now.subtract(Duration(days: random.nextInt(360)))));
            final dateStr = "${oDate.year}-${oDate.month.toString().padLeft(2, '0')}-${oDate.day.toString().padLeft(2, '0')}";
            final menu = menus[random.nextInt(menus.length)];
            final qty = random.nextInt(15) + 3;
            final branch = branches[random.nextInt(branches.length)];
            final orderDocRef = orderCollection.doc();
            final orderData = {
              'id': orderDocRef.id, 'customerName': name, 'facilityName': entityName, 'address': entityAddr, 'phoneNumber': phone,
              'receptionDate': oDate.subtract(const Duration(days: 1)).toIso8601String(), 'deliveryDate': oDate.toIso8601String(),
              'deliveryDateStr': dateStr, 'deliveryTime': "11:30", 'deliveryType': '配送',
              'items': [{'id': menu['id'], 'name': menu['name'], 'price': menu['price'], 'quantity': qty}],
              'totalCount': qty, 'totalPrice': (menu['price'] as int) * qty, 'branchName': branch, 'smsSent': true, 'preConfirmationMethod': 'SMS',
              'latitude': lat, 'longitude': lng,
            };
            
            fbBatch.set(orderDocRef, orderData);
            fbBatchCount++;
            
            orderStmt.execute([orderDocRef.id, jsonEncode(orderData), oDate.toIso8601String(), DateTime.now().millisecondsSinceEpoch]);
            historyStrings.add('$dateStr: [$branch] [$entityName] ${menu['name']} x$qty');

            if (fbBatchCount >= 450) {
              await fbBatch.commit();
              fbBatch = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').batch();
              fbBatchCount = 0;
            }
          }
          final docRef = _customerCollection.doc();
          final customer = Customer(
            id: docRef.id, name: name, companyName: entityName, phoneNumber: phone, address: entityAddr,
            latitude: lat, longitude: lng, orderHistory: historyStrings,
            deliveryAddresses: ['$entityName: $entityAddr ($lat, $lng)'], facilityReceivers: {entityName: [name]},
          );
          
          fbBatch.set(docRef, customer.toMap());
          fbBatchCount++;
          
          custStmt.execute([customer.id, jsonEncode(customer.toMap()), customer.name, customer.phoneNumber, customer.companyName]);
          totalCreated++;

          if (fbBatchCount >= 450) {
            await fbBatch.commit();
            fbBatch = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').batch();
            fbBatchCount = 0;
          }
        }
        entityIdx++;
      }
      
      if (fbBatchCount > 0) {
        await fbBatch.commit();
      }

      custStmt.close();
      orderStmt.close();
      _localDb!.execute('COMMIT');
      debugPrint('Generated $totalCreated dummy customers across Aichi.');
    } catch (e) {
      _localDb!.execute('ROLLBACK');
      debugPrint('Error: $e');
    }
  }
}
