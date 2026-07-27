import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import 'address_service.dart';
import 'google_maps_service.dart';
import 'package:flutter/foundation.dart';


class CustomerService {
  final CollectionReference _customerCollection =
      FirebaseFirestore.instance.collection('customers');
  final CollectionReference _menuCollection =
      FirebaseFirestore.instance.collection('menu');
  final _addressService = AddressService();
  final _googleMapsService = GoogleMapsService();

  AddressService getAddressService() => _addressService;
  GoogleMapsService getGoogleMapsService() => _googleMapsService;

  // 全顧客取得
  Future<List<Customer>> getAllCustomers() async {
    final snapshot = await _customerCollection.get();
    return snapshot.docs
        .map((doc) => Customer.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // 電話番号の下4桁で検索
  Future<List<Customer>> searchByPhoneSuffix(String suffix) async {
    final cleanSuffix = suffix.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanSuffix.length != 4) return [];

    final snapshot = await _customerCollection.get();
    return snapshot.docs
        .map((doc) => Customer.fromMap(doc.data() as Map<String, dynamic>))
        .where((c) {
          final cleanPhone = c.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
          return cleanPhone.endsWith(cleanSuffix);
        })
        .toList();
  }

  // 電話番号で検索
  Future<Customer?> findByPhoneNumber(String phone) async {
    final cleanInput = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanInput.isEmpty) return null;

    final snapshot = await _customerCollection
        .where('phoneNumber', isEqualTo: phone)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Customer.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
    }

    final snapshotAlt = await _customerCollection
        .where('phoneNumber', isEqualTo: cleanInput)
        .limit(1)
        .get();

    if (snapshotAlt.docs.isNotEmpty) {
      return Customer.fromMap(snapshotAlt.docs.first.data() as Map<String, dynamic>);
    }

    return null;
  }

  // 顧客情報の更新
  Future<void> updateCustomer(Customer updatedCustomer) async {
    await _customerCollection.doc(updatedCustomer.id).set(updatedCustomer.toMap(), SetOptions(merge: true));
  }

  // 新規顧客作成
  Future<void> createCustomer(Customer customer) async {
    final docId = customer.id.isEmpty 
        ? _customerCollection.doc().id 
        : customer.id;
    
    final finalCustomer = customer.id.isEmpty 
        ? customer.copyWith(id: docId) 
        : customer;

    await _customerCollection.doc(docId).set(finalCustomer.toMap());
  }

  // 顧客の削除
  Future<void> deleteCustomer(String id) async {
    await _customerCollection.doc(id).delete();
  }

  // 全顧客を一括削除
  Future<void> deleteAllCustomers() async {
    while (true) {
      final snapshot = await _customerCollection.limit(500).get();
      if (snapshot.docs.isEmpty) break;

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  // メニューマスタと住所DBから情報を取得し、岡崎市中心の高品質なダミーデータ100件を生成
  Future<void> regenerateDummyCustomers() async {
    try {
      final random = Random();
      
      // 高速削除実行
      await deleteAllCustomers();

      // メニュー情報の取得
      final menuSnapshot = await _menuCollection.get();
      final menus = menuSnapshot.docs.map((doc) {
        final data = doc.data() as Map;
        return {
          'id': doc.id,
          'name': data['name'] as String,
          'price': data['price'] as int,
        };
      }).toList();

      if (menus.isEmpty) {
        throw Exception('メニューマスタが空です。先にメニューを登録してください。');
      }

      // 岡崎市の実在施設データを取得（40件程度取得して100名に割り振る）
      final entities = await _addressService.getRandomOkazakiEntities(limit: 40);
      if (entities.isEmpty) {
        throw Exception('住所データベースから岡崎市のデータを取得できませんでした。');
      }

      // ジオコーディング結果のキャッシュ（API節約）
      final Map<String, Map<String, double>> geoCache = {};

      final branches = ['岡崎本店', '名古屋店', '岐阜店'];
      
      final lastNames = ['佐藤', '鈴木', '高橋', '田中', '伊藤', '渡辺', '山本', '中村', '小林', '加藤', '吉田', '山田', '佐々木', '山口', '松本', '井上', '木村', '林', '斎藤', '清水'];
      final firstNames = ['健一', '直樹', '恵子', '由美子', '和也', '大輔', '雅弘', '美穂', '沙織', '翔太', '陽子', '真一', '愛', '健太', '美咲', '大樹', '彩', '拓海', '七海', '駿'];

      final batch = FirebaseFirestore.instance.batch();
      final now = DateTime.now();

      // 100名生成するためのカウント管理
      int totalCreated = 0;
      int entityIdx = 0;

      while (totalCreated < 100) {
        final entity = entities[entityIdx % entities.length];
        final entityName = entity['name'] ?? '一般';
        final entityAddr = entity['address'] ?? '住所不明';

        // 座標の取得（施設名＋住所で精度を向上）
        if (!geoCache.containsKey(entityAddr)) {
          final query = "$entityName $entityAddr";
          debugPrint('Generating dummy coords for: $query');
          
          final latLng = await _googleMapsService.getLatLngFromAddress(query);
          if (latLng != null && latLng['lat'] != 0.0) {
            geoCache[entityAddr] = latLng;
            // SQLite DB に保存して永続化
            await _addressService.upsertKigyouEntity(
              name: entityName,
              address: entityAddr,
              lat: latLng['lat']!,
              lng: latLng['lng']!,
            );
          } else {
            // 失敗時は住所のみで再試行
            final fallbackLatLng = await _googleMapsService.getLatLngFromAddress(entityAddr);
            if (fallbackLatLng != null && fallbackLatLng['lat'] != 0.0) {
              geoCache[entityAddr] = fallbackLatLng;
            } else {
              debugPrint('CRITICAL FAIL: Could not resolve address for $entityName ($entityAddr)');
              geoCache[entityAddr] = {'lat': 0.0, 'lng': 0.0}; // 0.0で保存し、実行時に自己修復させる
            }
          }
          // 短いウェイトを置いてクォータを安定させる
          await Future.delayed(const Duration(milliseconds: 200));
        }
        
        final coords = geoCache[entityAddr]!;

        // 1つの企業に対し、1〜5人をランダムに割り当てる
        int staffCount = random.nextInt(5) + 1;
        if (totalCreated + staffCount > 100) staffCount = 100 - totalCreated;

        for (int s = 0; staffCount > s; s++) {
          final name = "${lastNames[random.nextInt(lastNames.length)]} ${firstNames[random.nextInt(firstNames.length)]}";
          final phone = '0${random.nextInt(3) + 7}0-${random.nextInt(9000) + 1000}-${random.nextInt(9000) + 1000}';
          
          List<String> history = [];
          for (int m = 0; m < 12; m++) {
            if (random.nextDouble() > 0.6) {
              final orderMonth = DateTime(now.year, m + 1, random.nextInt(28) + 1);
              if (orderMonth.isAfter(now)) continue;

              final dateStr = "${orderMonth.year}-${orderMonth.month.toString().padLeft(2, '0')}-${orderMonth.day.toString().padLeft(2, '0')}";
              final menu = menus[random.nextInt(menus.length)];
              final qty = random.nextInt(10) + 5;
              final branch = branches[random.nextInt(branches.length)];
              
              history.add('$dateStr: [$branch] [$entityName] ${menu['name']} x$qty');
            }
          }
          history.sort((a, b) => b.compareTo(a));

          final docRef = _customerCollection.doc();
          final String displayAddrWithGeo = '$entityName: $entityAddr (${coords['lat']}, ${coords['lng']})';
          
          final customer = Customer(
            id: docRef.id,
            name: name,
            companyName: entityName,
            phoneNumber: phone,
            address: entityAddr,
            latitude: coords['lat'],
            longitude: coords['lng'],
            orderHistory: history,
            deliveryAddresses: [displayAddrWithGeo],
            facilityReceivers: {entityName: [name]},
          );
          batch.set(docRef, customer.toMap());
          totalCreated++;
        }
        entityIdx++;
      }

      await batch.commit();
    } catch (e) {
      print('Error in regenerateDummyCustomers: $e');
      rethrow;
    }
  }
}
