import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_model.dart';
import '../models/menu_model.dart';

class IngredientService {
  final CollectionReference _col = FirebaseFirestore.instanceFor(
          app: Firebase.app(), databaseId: 'katura-system-database')
      .collection('ingredients');

  static const List<String> categoryPresets = ['肉類', '米', '野菜', 'ソース', '揚げ物', 'その他'];

  Future<List<IngredientModel>> getAll() async {
    final snapshot = await _col.orderBy('name').get();
    return snapshot.docs
        .map((doc) => IngredientModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
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
    return ingredient;
  }

  Future<void> update(IngredientModel ingredient) async {
    await _col.doc(ingredient.id).set(ingredient.toMap(), SetOptions(merge: true));
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  /// 既存メニューの材料欄から、未登録の材料を材料マスタへ自動生成する。
  /// 戻り値は新規登録した件数。
  Future<int> seedFromMenus(List<MenuModel> menus) async {
    final existing = await _col.get();
    final existingNames = existing.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String? ?? '')
        .toSet();

    final Map<String, String> found = {}; // 材料名 -> 既存の使用量サンプル
    for (final menu in menus) {
      menu.ingredients.forEach((name, value) {
        found.putIfAbsent(name, () => value);
      });
    }

    final batch = FirebaseFirestore.instanceFor(
            app: Firebase.app(), databaseId: 'katura-system-database')
        .batch();
    int count = 0;
    found.forEach((name, sample) {
      if (name.isEmpty || existingNames.contains(name)) return;
      final doc = _col.doc();
      batch.set(
        doc,
        IngredientModel(
          id: doc.id,
          name: name,
          unit: _guessUnit(sample),
          category: _guessCategory(name),
        ).toMap(),
      );
      count++;
    });
    if (count > 0) await batch.commit();
    return count;
  }

  String _guessUnit(String sample) {
    final match = RegExp(r'^\d+(?:\.\d+)?\s*(.*)$').firstMatch(sample.trim());
    final unit = match?.group(1)?.trim() ?? '';
    return unit.isEmpty ? '適量' : unit;
  }

  String _guessCategory(String name) {
    if (RegExp(r'牛|肉|ビーフ|ハンバーグ').hasMatch(name)) return '肉類';
    if (name.contains('米')) return '米';
    if (RegExp(r'ソース|ダレ|デミ').hasMatch(name)) return 'ソース';
    if (RegExp(r'唐揚げ|フライ|天ぷら').hasMatch(name)) return '揚げ物';
    if (RegExp(r'野菜|ガーリック|ねぎ|ネギ').hasMatch(name)) return '野菜';
    return 'その他';
  }
}
