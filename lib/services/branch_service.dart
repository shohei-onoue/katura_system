import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/branch_model.dart';

class BranchService {
  final CollectionReference _branchCollection =
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').collection('branches');

  static const List<Map<String, Object>> _defaultBranches = [
    {'name': '岡崎本店', 'companyName': '株式会社 AXIS', 'address': '岡崎市井田南町3-5', 'phone': '0564-23-8861', 'latitude': 34.97596915388157, 'longitude': 137.16160761838935},
    {'name': '名古屋店', 'companyName': '株式会社 AXIS', 'address': '名古屋市緑区森の里1-93', 'phone': '050-1748-2670', 'latitude': 35.1815, 'longitude': 136.9066},
    {'name': '岐阜店', 'companyName': '株式会社 AXIS', 'address': '岐阜県岐阜市加納矢場町1-42-1', 'phone': '050-1748-2670', 'latitude': 35.399434, 'longitude': 136.756889},
  ];

  static const List<String> _displayOrder = ['岡崎本店', '名古屋店', '岐阜店'];

  Future<List<BranchModel>> getAllBranches() async {
    var snapshot = await _branchCollection.get();
    if (snapshot.docs.isEmpty) {
      await _seedDefaultBranches();
      snapshot = await _branchCollection.get();
    }
    var branches = snapshot.docs
        .map((doc) => BranchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    branches = await _backfillLegacyDefaults(branches);
    branches.sort((a, b) {
      final ai = _displayOrder.indexOf(a.name);
      final bi = _displayOrder.indexOf(b.name);
      return (ai == -1 ? _displayOrder.length : ai).compareTo(bi == -1 ? _displayOrder.length : bi);
    });
    return branches;
  }

  /// 以前のバージョンで住所・電話番号が空のまま登録されてしまった店舗を、
  /// 既知のデフォルト値で一度だけ補完する。
  Future<List<BranchModel>> _backfillLegacyDefaults(List<BranchModel> branches) async {
    final result = <BranchModel>[];
    for (final b in branches) {
      if (b.address.isEmpty || b.phone.isEmpty || b.companyName.isEmpty) {
        final fallback = _defaultBranches.firstWhere(
          (d) => d['name'] == b.name,
          orElse: () => const {},
        );
        if (fallback.isNotEmpty) {
          final fixed = b.copyWith(
            address: b.address.isEmpty ? fallback['address'] as String : null,
            phone: b.phone.isEmpty ? fallback['phone'] as String : null,
            companyName: b.companyName.isEmpty ? fallback['companyName'] as String : null,
          );
          await updateBranch(fixed);
          result.add(fixed);
          continue;
        }
      }
      result.add(b);
    }
    return result;
  }

  Future<void> updateBranch(BranchModel branch) async {
    await _branchCollection.doc(branch.id).set(branch.toMap(), SetOptions(merge: true));
  }

  Future<BranchModel> addBranch({
    required String name,
    required String address,
    required String phone,
    required double latitude,
    required double longitude,
    String companyName = '',
    String imageUrl = '',
  }) async {
    final doc = _branchCollection.doc();
    final branch = BranchModel(
        id: doc.id, name: name, companyName: companyName, address: address, phone: phone, latitude: latitude, longitude: longitude, imageUrl: imageUrl);
    await doc.set(branch.toMap());
    return branch;
  }

  Future<void> deleteBranch(String id) async {
    await _branchCollection.doc(id).delete();
  }

  Future<void> _seedDefaultBranches() async {
    final batch = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').batch();
    for (final b in _defaultBranches) {
      batch.set(_branchCollection.doc(b['name'] as String), b);
    }
    await batch.commit();
  }
}
