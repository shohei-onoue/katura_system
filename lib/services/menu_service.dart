import 'dart:typed_data';
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
      debugPrint('MenuService: Fetching all menus from Firestore...');
      final snapshot = await _menuCollection.orderBy('category').get()
          .timeout(const Duration(seconds: 10), onTimeout: () {
            throw Exception('Firestoreからのデータ取得がタイムアウトしました。データベースが作成されていないか、ネットワークが非常に低速です。');
          });
      debugPrint('MenuService: Successfully fetched ${snapshot.docs.length} menus.');
      return snapshot.docs
          .map((doc) => MenuModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('MenuService Error (getAllMenus): $e');
      rethrow;
    }
  }

  Future<void> updateMenu(MenuModel menu, {Uint8List? imageBytes}) async {
    try {
      String imageUrl = menu.imageUrl;
      if (imageBytes != null) {
        debugPrint('MenuService: [UPLOAD] Starting image upload for menu ${menu.id}...');
        imageUrl = await uploadMenuImage(menu.id, imageBytes);
        debugPrint('MenuService: [UPLOAD] Image upload successful. URL: $imageUrl');
      }
      debugPrint('MenuService: [FIRESTORE] Writing to Firestore for menu ${menu.id}...');
      await _menuCollection.doc(menu.id).set(menu.copyWith(imageUrl: imageUrl).toMap(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 15), onTimeout: () {
            debugPrint('MenuService: [ERROR] Firestore write timed out for ${menu.id}');
            throw Exception('Firestoreへの書き込みがタイムアウトしました。Google Cloud ConsoleでFirestoreが有効化されているか確認してください。');
          });
      debugPrint('MenuService: [FIRESTORE] Firestore write successful.');
    } on FirebaseException catch (e) {
      debugPrint('MenuService: [FIREBASE_ERROR] Code: ${e.code}, Message: ${e.message}');
      throw Exception('Firebaseエラー (${e.code}): ${e.message}');
    } catch (e) {
      debugPrint('MenuService: [UNKNOWN_ERROR] $e');
      rethrow;
    }
  }

  Future<void> createMenu(MenuModel menu, {Uint8List? imageBytes}) async {
    try {
      final docId = menu.id.isEmpty ? _menuCollection.doc().id : menu.id;
      String imageUrl = menu.imageUrl;
      if (imageBytes != null) {
        debugPrint('MenuService: [UPLOAD] Starting image upload for NEW menu $docId...');
        imageUrl = await uploadMenuImage(docId, imageBytes);
        debugPrint('MenuService: [UPLOAD] Image upload successful. URL: $imageUrl');
      }
      final finalMenu = menu.copyWith(id: docId, imageUrl: imageUrl);
      debugPrint('MenuService: [FIRESTORE] Creating document in Firestore for $docId...');
      await _menuCollection.doc(docId).set(finalMenu.toMap())
          .timeout(const Duration(seconds: 15), onTimeout: () {
            debugPrint('MenuService: [ERROR] Firestore create timed out for $docId');
            throw Exception('Firestoreへの書き込みがタイムアウトしました。Google Cloud ConsoleでFirestoreが有効化されているか確認してください。');
          });
      debugPrint('MenuService: [FIRESTORE] Firestore create successful.');
    } on FirebaseException catch (e) {
      debugPrint('MenuService: [FIREBASE_ERROR] Code: ${e.code}, Message: ${e.message}');
      throw Exception('Firebaseエラー (${e.code}): ${e.message}');
    } catch (e) {
      debugPrint('MenuService: [UNKNOWN_ERROR] $e');
      rethrow;
    }
  }

  Future<void> deleteMenu(String id) async {
    try {
      debugPrint('MenuService: Deleting menu $id...');
      await _menuCollection.doc(id).delete();
      debugPrint('MenuService: Deletion successful.');
    } catch (e) {
      debugPrint('MenuService Error (deleteMenu): $e');
      rethrow;
    }
  }

  Future<String> uploadMenuImage(String menuId, Uint8List fileBytes) async {
    try {
      final ref = _storage.ref().child('menu_images/$menuId.jpg');
      debugPrint('MenuService: [STORAGE] Uploading ${fileBytes.length} bytes to ${ref.fullPath}...');
      
      final uploadTask = ref.putData(fileBytes, SettableMetadata(contentType: 'image/jpeg'));
      
      // 進捗監視
      uploadTask.snapshotEvents.listen((event) {
        debugPrint('MenuService: [STORAGE] Progress: ${event.bytesTransferred}/${event.totalBytes} (${event.state})');
      });

      await uploadTask.timeout(const Duration(seconds: 30), onTimeout: () {
        debugPrint('MenuService: [ERROR] Storage upload timed out');
        throw Exception('画像のアップロードがタイムアウトしました。Firebase Storageのルールを確認してください。');
      });
      
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      debugPrint('MenuService: [STORAGE_ERROR] Code: ${e.code}, Message: ${e.message}');
      throw Exception('ストレージエラー (${e.code}): ${e.message}');
    } catch (e) {
      debugPrint('MenuService: [UNKNOWN_STORAGE_ERROR] $e');
      rethrow;
    }
  }

  Future<void> migrateCategories() async {
    try {
      debugPrint('MenuService: Starting category migration...');
      final snapshot = await _menuCollection.get();
      final batch = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').batch();
      bool changed = false;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String category = data['category'] ?? '';
        String newCategory = category;

        if (category == '肉弁当' || category == 'お弁当') newCategory = '厳選牛ステーキ弁当';
        if (category == 'トッピング' || category == 'その他') newCategory = 'ドリンク・サイドメニュー';
        if (category == '丼・重') newCategory = '丼もの';

        if (newCategory != category) {
          batch.update(doc.reference, {'category': newCategory});
          changed = true;
        }
      }

      if (changed) {
        await batch.commit();
        debugPrint('MenuService: Migration completed.');
      } else {
        debugPrint('MenuService: No migration needed.');
      }
    } catch (e) {
      debugPrint('MenuService Error (migrateCategories): $e');
    }
  }

  Future<void> seedMenuData() async {
    try {
      debugPrint('MenuService: Seeding initial menu data...');
      final batch = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'katura-system-database').batch();
      
      final existing = await _menuCollection.get();
      for (var doc in existing.docs) {
        batch.delete(doc.reference);
      }

      final menus = [
        {
          'name': 'Bコンビ(特製ステーキ＆ハンバーグ)弁当',
          'category': '厳選牛ステーキ弁当',
          'price': 1800,
          'imageUrl': 'assets/img/b_combo.webp',
          'ingredients': {'牛ステーキ肉': '100g', 'ハンバーグ': '120g', '白米': '250g'}
        },
        {
          'name': 'Aコンビ(ローストビーフ＆特製ステーキ)弁当',
          'category': '厳選牛ステーキ弁当',
          'price': 1800,
          'imageUrl': 'assets/img/a_combo.webp',
          'ingredients': {'牛もも肉': '80g', '牛ステーキ肉': '100g', '白米': '250g'}
        },
        {
          'name': 'Cコンビ弁当',
          'category': '厳選牛ステーキ弁当',
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
          'category': '厳選牛ステーキ弁当',
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
          'category': '厳選牛ステーキ弁当',
          'price': 2160,
          'imageUrl': 'assets/img/shimofuri_hamburg.jpg',
          'ingredients': {'和牛ハンバーグ': '180g', '白米': '250g'}
        },
        {
          'name': 'テリヤキハンバーグ弁当',
          'category': '厳選牛ステーキ弁当',
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
      await batch.commit().timeout(const Duration(seconds: 15));
      debugPrint('MenuService: Seed successful.');
    } catch (e) {
      debugPrint('MenuService Error (seedMenuData): $e');
      rethrow;
    }
  }
}
