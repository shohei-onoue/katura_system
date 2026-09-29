import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// 予約枠（注文入力中に確保している「号車・日時」）。注文が確定するか取り消されると消える。
class ReservationSlot {
  final String id;
  final String branchName;
  final DateTime date; // 配達日（時刻なし）
  final String time; // "HH:mm"
  final int vehicleNumber; // 号車（1始まり）
  final DateTime createdAt;

  const ReservationSlot({
    required this.id,
    required this.branchName,
    required this.date,
    required this.time,
    required this.vehicleNumber,
    required this.createdAt,
  });
}

class ReservationService {
  /// 取り消されずに残った予約枠を無視するための有効時間
  static const Duration _ttl = Duration(hours: 3);

  final CollectionReference _col =
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').collection('reservations');

  static String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 予約枠を作る。作れなければ null（画面は止めない）。
  Future<String?> create({
    required String branchName,
    required DateTime date,
    required String time,
    required int vehicleNumber,
  }) async {
    try {
      final ref = await _col.add({
        'branchName': branchName,
        'dateStr': _dateStr(date),
        'time': time,
        'vehicleNumber': vehicleNumber,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return ref.id;
    } catch (e) {
      debugPrint('Reservation create error: $e');
      return null;
    }
  }

  Future<void> delete(String? id) async {
    if (id == null || id.isEmpty) return;
    try {
      await _col.doc(id).delete();
    } catch (e) {
      debugPrint('Reservation delete error: $e');
    }
  }

  /// その日・その店舗の有効な予約枠を取得する。
  Future<List<ReservationSlot>> listByDate(String branchName, DateTime date) async {
    try {
      final snap = await _col.where('dateStr', isEqualTo: _dateStr(date)).get();
      final now = DateTime.now();
      final result = <ReservationSlot>[];
      for (final doc in snap.docs) {
        final m = doc.data() as Map<String, dynamic>;
        if (m['branchName'] != branchName) continue;
        final created = DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? now;
        if (now.difference(created) > _ttl) continue;
        result.add(ReservationSlot(
          id: doc.id,
          branchName: branchName,
          date: DateTime(date.year, date.month, date.day),
          time: m['time']?.toString() ?? '',
          vehicleNumber: (m['vehicleNumber'] as num?)?.toInt() ?? 1,
          createdAt: created,
        ));
      }
      return result;
    } catch (e) {
      debugPrint('Reservation list error: $e');
      return const [];
    }
  }
}
