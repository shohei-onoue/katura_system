import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_model.dart';

class IngredientService {
  final CollectionReference _col = FirebaseFirestore.instanceFor(
          app: Firebase.app(), databaseId: 'katura-system-database')
      .collection('ingredients');

  static const List<String> categoryPresets = ['肉類', '米', '野菜', 'ソース', '揚げ物', 'その他'];

  // 食材は変更頻度が低く、複数画面で開くたびに全件取得していたためプロセス内でキャッシュする。
  static List<IngredientModel>? _cache;

  static void invalidateCache() => _cache = null;

  Future<List<IngredientModel>> getAll({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;
    final snapshot = await _col.orderBy('name').get();
    final list = snapshot.docs
        .map((doc) => IngredientModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    _cache = list;
    return list;
  }

  Future<IngredientModel> add({
    required String name,
    String unit = 'g',
    String category = 'その他',
    String note = '',
  }) async {
    final doc = _col.doc();
    final ingredient =
        IngredientModel(id: doc.id, name: name, unit: unit, category: category, note: note);
    await doc.set(ingredient.toMap());
    invalidateCache();
    return ingredient;
  }

  Future<void> update(IngredientModel ingredient) async {
    await _col.doc(ingredient.id).set(ingredient.toMap(), SetOptions(merge: true));
    invalidateCache();
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
    invalidateCache();
  }

}
