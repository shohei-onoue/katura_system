import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/menu_model.dart';

class MenuService {
  final CollectionReference _menuCollection =
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').collection('menu');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<MenuModel>> getAllMenus() async {
    try {
      final snapshot = await _menuCollection.orderBy('category').get();
      return snapshot.docs
          .map((doc) => MenuModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('MenuService Error: $e');
      rethrow;
    }
  }

  /// メニューシードデータの更新（材料・工程の拡充）
  Future<void> seedMenuData() async {
    try {
      final batch = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').batch();
      
      final existing = await _menuCollection.get();
      for (var doc in existing.docs) { batch.delete(doc.reference); }

      final menus = [
        {
          'name': 'Bコンビ(特製ステーキ＆ハンバーグ)弁当',
          'category': '厳選牛ステーキ弁当',
          'price': 1800,
          'imageUrl': 'assets/img/b_combo.webp',
          'ingredients': {'牛肩ロース': '120g', '和牛合挽肉': '150g', '白米': '250g', '自家製デミソース': '30ml'},
          'cookingSteps': ['ステーキ肉を常温に戻し強火で表面を焼く', 'ハンバーグは中心がふっくらするまで蒸し焼き', '肉汁を閉じ込めるためアルミホイルで3分休ませる']
        },
        {
          'name': '【限定】幻の蓬莱牛炙り焼き重',
          'category': '高級弁当',
          'price': 2500,
          'imageUrl': 'assets/img/hourai_beef.webp',
          'ingredients': {'蓬莱牛ロース': '150g', '特選米': '280g', '金粉': '少々', '秘伝の炙りダレ': '20ml'},
          'cookingSteps': ['蓬莱牛を極薄にスライスし低温調理', '提供直前にガスバーナーで脂を溶かし香りを出す', '重箱の隅々まで肉を敷き詰め豪華さを演出']
        },
        {
          'name': '特製ステーキ弁当',
          'category': '厳選牛ステーキ弁当',
          'price': 1620,
          'imageUrl': 'assets/img/special_steak.webp',
          'ingredients': {'厳選牛ステーキ肉': '180g', 'ガーリックチップ': '5g', '白米': '250g'},
          'cookingSteps': ['鉄板で一気に焼き上げ、香ばしい香りを付ける', '厚切りにして肉の食感を最大限に活かす']
        },
        {
          'name': 'ローストビーフ弁当',
          'category': '厳選牛ステーキ弁当',
          'price': 1620,
          'imageUrl': 'assets/img/roast_beef.webp',
          'ingredients': {'牛ももブロック': '150g', '赤ワインソース': '25ml', '季節の温野菜': '40g'},
          'cookingSteps': ['表面を焼いた後、オーブンでじっくり低温加熱', '一晩寝かせて旨味を凝縮させ、注文時にスライス']
        },
        {
          'name': 'オードブル【3名様用】',
          'category': 'オードブル',
          'price': 6480,
          'imageUrl': 'assets/img/hors_3.jpg',
          'ingredients': {'惣菜詰め合わせ': '3名分', 'ローストビーフ': '100g', '唐揚げ': '6個'},
          'cookingSteps': ['彩り豊かな12種類のおかずを配置', 'メインの肉料理を中心に、隙間なく豪華に盛り付ける']
        },
      ];

      for (var data in menus) {
        final docRef = _menuCollection.doc();
        final menu = MenuModel(
          id: docRef.id,
          name: data['name'] as String,
          category: data['category'] as String,
          price: data['price'] as int,
          imageUrl: data['imageUrl'] as String,
          ingredients: Map<String, String>.from(data['ingredients'] as Map),
          cookingSteps: List<String>.from(data['cookingSteps'] as List),
        );
        batch.set(docRef, menu.toMap());
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Seed Error: $e');
    }
  }

  Future<void> updateMenu(MenuModel menu, {Uint8List? imageBytes}) async {
    String imageUrl = menu.imageUrl;
    if (imageBytes != null) { imageUrl = await uploadMenuImage(menu.id, imageBytes); }
    await _menuCollection.doc(menu.id).set(menu.copyWith(imageUrl: imageUrl).toMap(), SetOptions(merge: true));
  }

  Future<void> createMenu(MenuModel menu, {Uint8List? imageBytes}) async {
    final docId = menu.id.isEmpty ? _menuCollection.doc().id : menu.id;
    String imageUrl = menu.imageUrl;
    if (imageBytes != null) { imageUrl = await uploadMenuImage(docId, imageBytes); }
    await _menuCollection.doc(docId).set(menu.copyWith(id: docId, imageUrl: imageUrl).toMap());
  }

  Future<void> deleteMenu(String id) async { await _menuCollection.doc(id).delete(); }

  Future<String> uploadMenuImage(String menuId, Uint8List fileBytes) async {
    final ref = _storage.ref().child('menu_images/$menuId.jpg');
    await ref.putData(fileBytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  Future<void> migrateCategories() async { /* 既存ロジック */ }
}
