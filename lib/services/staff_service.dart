import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff_model.dart';

class StaffService {
  final CollectionReference _staffCollection =
      FirebaseFirestore.instance.collection('staff');

  Future<List<Staff>> getAllStaff() async {
    final snapshot = await _staffCollection.where('isActive', isEqualTo: true).get();
    if (snapshot.docs.isEmpty) {
      return _getDummyStaff();
    }
    return snapshot.docs
        .map((doc) => Staff.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  List<Staff> _getDummyStaff() {
    return [
      Staff(id: 's1', name: '佐藤 健一', role: '店長'),
      Staff(id: 's2', name: '鈴木 一郎', role: '社員'),
      Staff(id: 's3', name: '高橋 美咲', role: '事務'),
      Staff(id: 's4', name: '田中 太郎', role: '調理'),
      Staff(id: 's5', name: '伊藤 花子', role: '調理'),
      Staff(id: 's6', name: '渡辺 裕二', role: '配送'),
      Staff(id: 's7', name: '山本 隆', role: '配送'),
      Staff(id: 's8', name: '中村 恵子', role: '事務'),
      Staff(id: 's9', name: '小林 誠', role: 'アルバイト'),
      Staff(id: 's10', name: '加藤 智子', role: 'アルバイト'),
    ];
  }

  Future<void> seedStaffData() async {
    final dummy = _getDummyStaff();
    for (var staff in dummy) {
      await _staffCollection.doc(staff.id).set(staff.toMap());
    }
  }
}
