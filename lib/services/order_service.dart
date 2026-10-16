import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqlite3/common.dart';
import '../models/order_model.dart';
import 'database_factory.dart';

class OrderService {
  // どの画面でも同じインスタンスを使い、DBの再オープンと全件の読み直しを防ぐ
  static final OrderService _instance = OrderService._();
  factory OrderService() => _instance;
  OrderService._();

  /// メモリ上の受注一覧（読み込み済みなら即返す）
  List<OrderModel>? _cache;
  final CollectionReference _orderCollection =
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').collection('orders');

  CommonDatabase? _localDb;

  /// 受注一覧・配達予定・配送ルートで共通の「有効な受注」の条件（配送済み・キャンセル系は除く）。
  static bool isActive(OrderModel o) =>
      o.status != '配送済み' && o.status != 'キャンセル済み' && o.status != '当日キャンセル';

  /// 事前連絡の対象（有効・配達日が明日・事前連絡方法あり）。
  static List<OrderModel> preContactTargets(List<OrderModel> all, DateTime now) {
    final t = DateTime(now.year, now.month, now.day + 1);
    return all.where((o) =>
        isActive(o) &&
        o.deliveryDate.year == t.year && o.deliveryDate.month == t.month && o.deliveryDate.day == t.day &&
        o.preConfirmationMethod.isNotEmpty).toList();
  }

  /// 事前連絡が未完了か（電話は常に未完了、SMSは未送信・承認以外の返信あり）。
  static bool isPreContactPending(OrderModel o) {
    if (o.preConfirmationMethod == '電話') return true;
    return !o.smsSent || (o.smsReply.isNotEmpty && o.smsReply != '承認');
  }

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
    _cache = null;
    await _initLocalDb();
    _localDb!.execute(
      'INSERT OR REPLACE INTO orders (id, data, deliveryDate, updatedAt) VALUES (?, ?, ?, ?)',
      [order.id, jsonEncode(order.toMap()), order.deliveryDate.toIso8601String(), DateTime.now().millisecondsSinceEpoch]
    );
  }

  Future<List<OrderModel>> getAllOrders({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return List.of(_cache!);
    await _initLocalDb();
    if (!forceRefresh) {
      final results = _localDb!.select('SELECT data FROM orders ORDER BY deliveryDate DESC');
      if (results.isNotEmpty) {
        return _cache = results.map((row) => OrderModel.fromMap(jsonDecode(row['data'] as String))).toList();
      }
    }
    final List<OrderModel> list;
    try {
      final snapshot = await _orderCollection.get();
      list = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (_) {
      final results = _localDb!.select('SELECT data FROM orders ORDER BY deliveryDate DESC');
      return results.map((row) => OrderModel.fromMap(jsonDecode(row['data'] as String))).toList();
    }
    
    _localDb!.execute('BEGIN TRANSACTION');
    final batch = _localDb!.prepare('INSERT OR REPLACE INTO orders (id, data, deliveryDate, updatedAt) VALUES (?, ?, ?, ?)');
    for (var order in list) {
      batch.execute([order.id, jsonEncode(order.toMap()), order.deliveryDate.toIso8601String(), DateTime.now().millisecondsSinceEpoch]);
    }
    batch.close();
    _localDb!.execute('COMMIT');

    list.sort((a, b) => b.deliveryDate.compareTo(a.deliveryDate));
    _cache = list;
    return List.of(list);
  }

  /// Firestoreの受注を監視し、変更のたびに全件を流す（ローカルキャッシュも同期）。
  Stream<List<OrderModel>> watchOrders() {
    final byId = <String, OrderModel>{};
    return _orderCollection.snapshots().asyncMap((snapshot) async {
      // 変わった分だけ反映する（毎回全件を消して入れ直さない）
      final changes = snapshot.docChanges;
      for (final c in changes) {
        if (c.type == DocumentChangeType.removed) {
          byId.remove(c.doc.id);
        } else {
          byId[c.doc.id] = OrderModel.fromMap(c.doc.data() as Map<String, dynamic>);
        }
      }
      try {
        await _initLocalDb();
        _localDb!.execute('BEGIN TRANSACTION');
        final upsert = _localDb!.prepare('INSERT OR REPLACE INTO orders (id, data, deliveryDate, updatedAt) VALUES (?, ?, ?, ?)');
        for (final c in changes) {
          if (c.type == DocumentChangeType.removed) {
            _localDb!.execute('DELETE FROM orders WHERE id = ?', [c.doc.id]);
          } else {
            final o = byId[c.doc.id]!;
            upsert.execute([o.id, jsonEncode(o.toMap()), o.deliveryDate.toIso8601String(), DateTime.now().millisecondsSinceEpoch]);
          }
        }
        upsert.close();
        _localDb!.execute('COMMIT');
      } catch (_) {}
      final list = byId.values.toList()..sort((a, b) => b.deliveryDate.compareTo(a.deliveryDate));
      _cache = list;
      return List.of(list);
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orderCollection.doc(orderId).update({'status': status});
    _cache = null;
    await _initLocalDb();
    final res = _localDb!.select('SELECT data FROM orders WHERE id = ?', [orderId]);
    if (res.isNotEmpty) {
      final map = jsonDecode(res.first['data'] as String) as Map<String, dynamic>;
      map['status'] = status;
      _localDb!.execute('UPDATE orders SET data = ? WHERE id = ?', [jsonEncode(map), orderId]);
    }
  }

  /// SMSを送信済みにする（スマホから手動でSMSを送ったとき用）。
  Future<void> markSmsSent(String orderId) async {
    await _orderCollection.doc(orderId).update({'smsSent': true, 'smsSentAt': FieldValue.serverTimestamp()});
    _cache = null;
    await _initLocalDb();
    final res = _localDb!.select('SELECT data FROM orders WHERE id = ?', [orderId]);
    if (res.isNotEmpty) {
      final map = jsonDecode(res.first['data'] as String) as Map<String, dynamic>;
      map['smsSent'] = true;
      _localDb!.execute('UPDATE orders SET data = ? WHERE id = ?', [jsonEncode(map), orderId]);
    }
  }

  /// 配送車両の号車だけを更新する（配達予定ダイアログのドラッグ&ドロップ用）。
  Future<void> updateVehicleNumber(String orderId, int vehicleNumber) async {
    await _orderCollection.doc(orderId).update({'vehicleNumber': vehicleNumber});
    _cache = null;
    await _initLocalDb();
    final res = _localDb!.select('SELECT data FROM orders WHERE id = ?', [orderId]);
    if (res.isNotEmpty) {
      final map = jsonDecode(res.first['data'] as String) as Map<String, dynamic>;
      map['vehicleNumber'] = vehicleNumber;
      _localDb!.execute('UPDATE orders SET data = ? WHERE id = ?', [jsonEncode(map), orderId]);
    }
  }

  /// 受注をまとめて保存する（ダミーデータ生成用）。
  Future<void> saveAllOrders(List<OrderModel> orders) async {
    final db = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database');
    for (var i = 0; i < orders.length; i += 400) {
      final batch = db.batch();
      for (final o in orders.skip(i).take(400)) {
        batch.set(_orderCollection.doc(o.id), o.toMap());
      }
      await batch.commit();
    }
    _cache = null;
    await _initLocalDb();
    _localDb!.execute('BEGIN TRANSACTION');
    final stmt = _localDb!.prepare('INSERT OR REPLACE INTO orders (id, data, deliveryDate, updatedAt) VALUES (?, ?, ?, ?)');
    for (final o in orders) {
      stmt.execute([o.id, jsonEncode(o.toMap()), o.deliveryDate.toIso8601String(), DateTime.now().millisecondsSinceEpoch]);
    }
    stmt.close();
    _localDb!.execute('COMMIT');
  }

  /// 受注を全件削除する（Firestore＋端末内キャッシュ）。
  Future<void> deleteAllOrders() async {
    final db = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database');
    final snap = await _orderCollection.get();
    for (var i = 0; i < snap.docs.length; i += 400) {
      final batch = db.batch();
      for (final d in snap.docs.skip(i).take(400)) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
    _cache = null;
    await _initLocalDb();
    _localDb!.execute('DELETE FROM orders');
  }

  Future<void> deleteOrder(String orderId) async {
    await _orderCollection.doc(orderId).delete();
    _cache = null;
    await _initLocalDb();
    _localDb!.execute('DELETE FROM orders WHERE id = ?', [orderId]);
  }
}
