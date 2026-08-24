import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqlite3/common.dart';
import '../models/order_model.dart';
import 'database_factory.dart';

class OrderService {
  final CollectionReference _orderCollection =
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').collection('orders');

  CommonDatabase? _localDb;

  /// データベースの一本化 (katura_cache.db)
  Future<void> _initLocalDb() async {
    if (_localDb != null) return;
    _localDb = await DatabaseFactory.openProjectDatabase("assets/navi_database.db", "katura_cache.db");
    
    // 注文テーブルの作成 (存在しない場合)
    _localDb!.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id TEXT PRIMARY KEY,
        data TEXT,
        deliveryDate TEXT,
        updatedAt INTEGER
      )
    ''');
    _localDb!.execute('CREATE INDEX IF NOT EXISTS idx_delivery_date ON orders(deliveryDate)');
  }

  Future<void> saveOrder(OrderModel order) async {
    await _orderCollection.doc(order.id).set(order.toMap());
    await _initLocalDb();
    _localDb!.execute(
      'INSERT OR REPLACE INTO orders (id, data, deliveryDate, updatedAt) VALUES (?, ?, ?, ?)',
      [order.id, jsonEncode(order.toMap()), order.deliveryDate.toIso8601String(), DateTime.now().millisecondsSinceEpoch]
    );
  }

  Future<List<OrderModel>> getAllOrders({bool forceRefresh = false}) async {
    await _initLocalDb();
    if (!forceRefresh) {
      final results = _localDb!.select('SELECT data FROM orders ORDER BY deliveryDate DESC');
      if (results.isNotEmpty) {
        return results.map((row) => OrderModel.fromMap(jsonDecode(row['data'] as String))).toList();
      }
    }
    final snapshot = await _orderCollection.get();
    final list = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    
    _localDb!.execute('BEGIN TRANSACTION');
    final batch = _localDb!.prepare('INSERT OR REPLACE INTO orders (id, data, deliveryDate, updatedAt) VALUES (?, ?, ?, ?)');
    for (var order in list) {
      batch.execute([order.id, jsonEncode(order.toMap()), order.deliveryDate.toIso8601String(), DateTime.now().millisecondsSinceEpoch]);
    }
    batch.close();
    _localDb!.execute('COMMIT');

    list.sort((a, b) => b.deliveryDate.compareTo(a.deliveryDate));
    return list;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orderCollection.doc(orderId).update({'status': status});
    await _initLocalDb();
    final res = _localDb!.select('SELECT data FROM orders WHERE id = ?', [orderId]);
    if (res.isNotEmpty) {
      final map = jsonDecode(res.first['data'] as String) as Map<String, dynamic>;
      map['status'] = status;
      _localDb!.execute('UPDATE orders SET data = ? WHERE id = ?', [jsonEncode(map), orderId]);
    }
  }

  Future<void> deleteOrder(String orderId) async {
    await _orderCollection.doc(orderId).delete();
    await _initLocalDb();
    _localDb!.execute('DELETE FROM orders WHERE id = ?', [orderId]);
  }
}
