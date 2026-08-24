import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../constants/address_constants.dart';

class CategoryService {
  final CollectionReference _categoryCollection = FirebaseFirestore.instanceFor(
          app: Firebase.app(), databaseId: 'katura-system-database')
      .collection('custom_categories');

  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  Map<String, Map<String, List<String>>> _cachedHierarchy = {};

  Future<Map<String, Map<String, List<String>>>> getCategoryHierarchy() async {
    if (_cachedHierarchy.isNotEmpty) return _cachedHierarchy;

    // ベースのカテゴリ（ハードコード）をコピー
    final Map<String, Map<String, List<String>>> hierarchy = {};
    AddressConstants.categoryHierarchy.forEach((key, value) {
      hierarchy[key] = Map<String, List<String>>.from(value);
    });

    try {
      // Firestoreからカスタムカテゴリを取得してマージ
      final snapshot = await _categoryCollection.get();
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final parent = data['parent'] as String;
        final name = data['name'] as String;
        final keywords = List<String>.from(data['keywords'] ?? []);

        if (!hierarchy.containsKey(parent)) {
          hierarchy[parent] = {};
        }
        hierarchy[parent]![name] = keywords;
      }
    } catch (e) {
      print('Error fetching custom categories: $e');
    }

    _cachedHierarchy = hierarchy;
    return hierarchy;
  }

  Future<void> addCategory(String parent, String name, List<String> keywords) async {
    await _categoryCollection.add({
      'parent': parent,
      'name': name,
      'keywords': keywords,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _cachedHierarchy = {}; // キャッシュをクリア
  }

  void clearCache() {
    _cachedHierarchy = {};
  }
}
