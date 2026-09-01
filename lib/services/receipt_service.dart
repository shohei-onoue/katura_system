import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// 領収書の発行数（通し番号）を管理する。
class ReceiptService {
  DocumentReference<Map<String, dynamic>> get _counterDoc =>
      FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'katura-system-database',
      ).collection('settings').doc('receipt_counter');

  /// これまでに発行した領収書の枚数（採番前・表示用）。
  Future<int> issuedCount() async {
    try {
      final snap = await _counterDoc.get();
      return (snap.data()?['count'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// 領収書を1枚発行し、採番した通し番号を返す（トランザクションで加算）。
  Future<int> issue() async {
    final db = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'katura-system-database',
    );
    return db.runTransaction<int>((tx) async {
      final snap = await tx.get(_counterDoc);
      final current = (snap.data()?['count'] as num?)?.toInt() ?? 0;
      final next = current + 1;
      tx.set(
        _counterDoc,
        {'count': next, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
      return next;
    });
  }
}
