import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_model.dart';

class MenuService {
  final CollectionReference _menuCollection =
      FirebaseFirestore.instance.collection('menu');

  Future<List<MenuModel>> getAllMenus() async {
    final snapshot = await _menuCollection.orderBy('category').get();
    return snapshot.docs
        .map((doc) => MenuModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateMenu(MenuModel menu) async {
    await _menuCollection.doc(menu.id).set(menu.toMap(), SetOptions(merge: true));
  }

  Future<void> createMenu(MenuModel menu) async {
    final docId = menu.id.isEmpty ? _menuCollection.doc().id : menu.id;
    final finalMenu = menu.copyWith(id: docId);
    await _menuCollection.doc(docId).set(finalMenu.toMap());
  }

  Future<void> deleteMenu(String id) async {
    await _menuCollection.doc(id).delete();
  }

  Future<void> seedMenuData() async {
    final batch = FirebaseFirestore.instance.batch();
    
    final existing = await _menuCollection.get();
    for (var doc in existing.docs) {
      batch.delete(doc.reference);
    }

    final menus = [
      {
        'name': 'Bコンビ(特製ステーキ＆ハンバーグ)弁当',
        'category': 'お弁当',
        'price': 1800,
        'imageUrl': 'assets/img/b_combo.webp',
        'ingredients': {'牛ステーキ肉': '100g', 'ハンバーグ': '120g', '白米': '250g'}
      },
      {
        'name': 'Aコンビ(ローストビーフ＆特製ステーキ)弁当',
        'category': 'お弁当',
        'price': 1800,
        'imageUrl': 'assets/img/a_combo.webp',
        'ingredients': {'牛もも肉': '80g', '牛ステーキ肉': '100g', '白米': '250g'}
      },
      {
        'name': 'Cコンビ弁当',
        'category': 'お弁当',
        'price': 1800,
        'imageUrl': 'assets/img/c_combo.webp',
        'ingredients': {'牛ステーキ肉': '100g', '唐揚げ': '2個', '白米': '250g'}
      },
      {
        'name': '【限定】幻の蓬莱牛炙り焼き重',
        'category': '高級弁当',
        'price': 2500,
        'imageUrl': 'assets/img/hourai_beef.webp',
        'ingredients': {'蓬莱牛': '150g', '白米': '280g'}
      },
      {
        'name': '三河産牛フィレ弁当',
        'category': '高級弁当',
        'price': 4320,
        'imageUrl': 'assets/img/mikawa_fillet.webp',
        'ingredients': {'三河産牛フィレ肉': '150g', '白米': '250g'}
      },
      {
        'name': '特製ステーキ弁当',
        'category': '厳選牛ステーキ弁当',
        'price': 1620,
        'imageUrl': 'assets/img/special_steak.webp',
        'ingredients': {'牛ステーキ肉': '150g', '白米': '250g'}
      },
      {
        'name': 'ローストビーフ弁当',
        'category': 'お弁当',
        'price': 1620,
        'imageUrl': 'assets/img/roast_beef.webp',
        'ingredients': {'牛もも肉': '120g', '白米': '250g'}
      },
      {
        'name': 'オードブル【3名様用】',
        'category': 'オードブル',
        'price': 6480,
        'imageUrl': 'assets/img/hors_3.jpg',
        'ingredients': {'惣菜詰め合わせ': '3名分'}
      },
      {
        'name': 'オードブル【6名様用】',
        'category': 'オードブル',
        'price': 12960,
        'imageUrl': 'assets/img/hors_6.jpg',
        'ingredients': {'惣菜詰め合わせ': '6名分'}
      },
      {
        'name': '霜降りハンバーグ弁当',
        'category': 'お弁当',
        'price': 2160,
        'imageUrl': 'assets/img/shimofuri_hamburg.jpg',
        'ingredients': {'和牛ハンバーグ': '180g', '白米': '250g'}
      },
      {
        'name': 'テリヤキハンバーグ弁当',
        'category': 'お弁当',
        'price': 1620,
        'imageUrl': 'assets/img/teriyaki_hamburg.webp',
        'ingredients': {'ハンバーグ': '150g', '照り焼きソース': '20ml'}
      },
      {
        'name': '大人のステーキ丼',
        'category': '丼もの',
        'price': 1300,
        'imageUrl': 'assets/img/adult_steak.jpg',
        'ingredients': {'牛ステーキ': '120g', '白米': '300g'}
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
      );
      batch.set(docRef, menu.toMap());
    }
    await batch.commit();
  }
}
