import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqlite3/common.dart';
import '../models/order_model.dart';
import 'database_factory.dart';

class OrderService {
  final CollectionReference _orderCollection =
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').collection('orders');

  CommonDatabase? _localDb;

  Future<void> _initLocalDb() async {
    if (_localDb != null) return;
    // 既存の navi_database.db とは別に、注文キャッシュ用のDBをオープンまたは作成
    _localDb = await DatabaseFactory.openProjectDatabase("assets/navi_database.db", "order_cache.db");
    
    // 注文テーブルの作成
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
    // Firestoreへ保存
    await _orderCollection.doc(order.id).set(order.toMap());
    
    // ローカルDBへも保存 (キャッシュ更新)
    await _initLocalDb();
    _localDb!.execute(
      'INSERT OR REPLACE INTO orders (id, data, deliveryDate, updatedAt) VALUES (?, ?, ?, ?)',
      [
        order.id, 
        jsonEncode(order.toMap()), 
        order.deliveryDate.toIso8601String(),
        DateTime.now().millisecondsSinceEpoch
      ]
    );
  }

  Future<List<OrderModel>> getAllOrders({bool forceRefresh = false}) async {
    await _initLocalDb();

    // 1. まずローカルDBから取得を試みる
    final results = _localDb!.select('SELECT data FROM orders ORDER BY deliveryDate DESC');
    
    if (results.isNotEmpty && !forceRefresh) {
      debugPrint('OrderService: Loading from Local Cache (${results.length} orders)');
      return results.map((row) => OrderModel.fromMap(jsonDecode(row['data'] as String))).toList();
    }

    // 2. キャッシュがない、または強制更新の場合はFirestoreから取得
    debugPrint('OrderService: Fetching from Firestore...');
    final snapshot = await _orderCollection.get();
    final list = snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    // 3. ローカルDBを最新データで一括更新 (バックグラウンド的に実行)
    final batch = _localDb!.prepare('INSERT OR REPLACE INTO orders (id, data, deliveryDate, updatedAt) VALUES (?, ?, ?, ?)');
    _localDb!.execute('BEGIN TRANSACTION');
    for (var order in list) {
      batch.execute([
        order.id, 
        jsonEncode(order.toMap()), 
        order.deliveryDate.toIso8601String(),
        DateTime.now().millisecondsSinceEpoch
      ]);
    }
    _localDb!.execute('COMMIT');
    batch.close();

    list.sort((a, b) => b.deliveryDate.compareTo(a.deliveryDate));
    return list;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orderCollection.doc(orderId).update({'status': status});
    
    // ローカルキャッシュも更新
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
    
    // ローカルキャッシュからも削除
    await _initLocalDb();
    _localDb!.execute('DELETE FROM orders WHERE id = ?', [orderId]);
  }
}
