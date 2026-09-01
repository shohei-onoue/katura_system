import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// SMS送信要求をFirestoreのアウトボックスに登録する。
/// バックエンド（Cloud Functions / SMS配信拡張）が `sms_outbox` を購読し、
/// status=='pending' のドキュメントを実送信して結果を書き戻す。
class SmsService {
  final CollectionReference _outbox = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'katura-system-database',
  ).collection('sms_outbox');

  /// 事前連絡（電話）用のSMSを送信キューへ登録する。
  Future<void> sendPreConfirmationCall({
    required String to,
    required String body,
    String? orderId,
  }) async {
    if (to.trim().isEmpty) return;
    await _outbox.add({
      'to': to.trim(),
      'body': body,
      'orderId': orderId,
      'type': 'pre_confirmation_call',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
