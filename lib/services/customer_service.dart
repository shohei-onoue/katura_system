import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import 'address_service.dart';
import 'google_maps_service.dart';


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

  // 電話番号の下N桁で検索（4文字以上）
  Future<List<Customer>> searchByPhoneSuffix(String suffix) async {
    final cleanSuffix = suffix.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanSuffix.length < 4) return [];

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
    // 顧客の削除
    while (true) {
      final snapshot = await _customerCollection.limit(500).get();
      if (snapshot.docs.isEmpty) break;
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) { batch.delete(doc.reference); }
      await batch.commit();
    }
    // 関連する注文データの削除（ダミー再生成時に一貫性を保つため）
    final orderCollection = FirebaseFirestore.instance.collection('orders');
    while (true) {
      final snapshot = await orderCollection.limit(500).get();
      if (snapshot.docs.isEmpty) break;
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) { batch.delete(doc.reference); }
      await batch.commit();
    }
  }

  // 住所の重複を防ぎながら綺麗に結合する
  String _buildSafeAddress({required String pref, required String city, required String town, required String addr}) {
    String result = "";
    
    // 正規化関数: 比較のために全角・半角・スペースの差異を吸収
    String normalize(String s) => s.replaceAll(RegExp(r'\s+'), '').replaceAll('　', '');

    void append(String component) {
      if (component.isEmpty) return;
      final normComp = normalize(component);
      final normResult = normalize(result);
      
      // 既に結果に含まれている場合は追加しない (例: 「岡崎市」が「愛知県岡崎市」に含まれていればスキップ)
      if (!normResult.contains(normComp)) {
        result += component;
      }
    }

    append(pref);
    append(city);
    append(town);
    
    // 番地データ (addr) の徹底的なクリーニング
    // addr 自体が「愛知県岡崎市...」とフル住所を持っているケースに対応
    String cleanAddr = addr;
    final List<String> partsToRemove = [pref, city, town];
    for (var p in partsToRemove) {
      if (p.isNotEmpty) {
        cleanAddr = cleanAddr.replaceAll(p, '');
      }
    }
    
    result += cleanAddr;
    
    // 最終的な多重重複の徹底排除 (例: 愛知県愛知県 -> 愛知県)
    // 正規表現を用いて、2回以上繰り返される住所要素を1つに絞る
    final List<String> targets = [pref, city, town].where((s) => s.length >= 2).toList();
    for (var t in targets) {
      // 連続重複だけでなく、間に何か挟まっていても「愛知県...愛知県」のようなパターンを前方のマッチで消す
      // (ただしこれは危険なので、シンプルに連続重複と、全体としての正規化を行う)
      while (result.contains('$t$t')) {
        result = result.replaceAll('$t$t', t);
      }
    }
    
    // 「愛知県岡崎市愛知県岡崎市」のような複合的な繰り返しを排除
    String finalResult = result;
    if (pref.isNotEmpty && city.isNotEmpty) {
      final combined = pref + city;
      while (finalResult.contains('$combined$combined')) {
        finalResult = finalResult.replaceAll('$combined$combined', combined);
      }
    }
    
    return finalResult;
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

      // 岡崎市の実在施設データを取得
      final entities = await _addressService.getRandomOkazakiEntities(limit: 40);
      if (entities.isEmpty) {
        throw Exception('住所データベースから岡崎市のデータを取得できませんでした。');
      }

      final Map<String, Map<String, double>> geoCache = {};
      final branches = ['岡崎本店', '名古屋店', '岐阜店'];
      final lastNames = ['佐藤', '鈴木', '高橋', '田中', '伊藤', '渡辺', '山本', '中村', '小林', '加藤', '吉田', '山田', '佐々木', '山口', '松本', '井上', '木村', '林', '斎藤', '清水'];
      final firstNames = ['健一', '直樹', '恵子', '由美子', '和也', '大輔', '雅弘', '美穂', '沙織', '翔太', '陽子', '真一', '愛', '健太', '美咲', '大樹', '彩', '拓海', '七海', '駿'];

      final orderCollection = FirebaseFirestore.instance.collection('orders');
      final now = DateTime.now();

      int totalCreated = 0;
      int entityIdx = 0;

      while (totalCreated < 100) {
        final entity = entities[entityIdx % entities.length];
        final entityName = entity['name'] ?? '一般';
        
        // 住所の重複を排除して結合
        final entityAddr = _buildSafeAddress(
          pref: entity['pref'] ?? '',
          city: entity['city'] ?? '',
          town: entity['town'] ?? '',
          addr: entity['addr'] ?? '',
        );

        if (!geoCache.containsKey(entityAddr)) {
          final latLng = await _googleMapsService.getLatLngFromAddress("$entityName $entityAddr");
          if (latLng != null && latLng['lat'] != 0.0) {
            geoCache[entityAddr] = latLng;
            await _addressService.upsertKigyouEntity(name: entityName, address: entityAddr, lat: latLng['lat']!, lng: latLng['lng']!);
          } else {
            geoCache[entityAddr] = {'lat': 0.0, 'lng': 0.0};
          }
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        final coords = geoCache[entityAddr]!;
        int staffCount = random.nextInt(4) + 1;
        if (totalCreated + staffCount > 100) staffCount = 100 - totalCreated;

        for (int s = 0; staffCount > s; s++) {
          final name = "${lastNames[random.nextInt(lastNames.length)]} ${firstNames[random.nextInt(firstNames.length)]}";
          final phone = '0${random.nextInt(3) + 7}0-${random.nextInt(9000) + 1000}-${random.nextInt(9000) + 1000}';
          
          List<String> historyStrings = [];
          int historyCount = random.nextInt(6) + 3;
          final batch = FirebaseFirestore.instance.batch();

          for (int h = 0; h < historyCount; h++) {
            final orderDate = now.subtract(Duration(days: random.nextInt(360)));
            final dateStr = "${orderDate.year}-${orderDate.month.toString().padLeft(2, '0')}-${orderDate.day.toString().padLeft(2, '0')}";
            
            final menu = menus[random.nextInt(menus.length)];
            final qty = random.nextInt(10) + 2;
            final branch = branches[random.nextInt(branches.length)];
            final time = "${11 + random.nextInt(2)}:${random.nextBool() ? '00' : '30'}";

            // 文字列履歴
            historyStrings.add('$dateStr: [$branch] [$entityName] ${menu['name']} x$qty');

            // 実際の受注データ生成
            final orderDocRef = orderCollection.doc();
            batch.set(orderDocRef, {
              'id': orderDocRef.id,
              'customerName': name,
              'facilityName': entityName,
              'address': entityAddr,
              'phoneNumber': phone,
              'receptionDate': orderDate.subtract(const Duration(days: 1)).toIso8601String(),
              'deliveryDate': orderDate.toIso8601String(),
              'deliveryTime': time,
              'deliveryType': '配送',
              'items': [{'id': menu['id'], 'name': menu['name'], 'price': menu['price'], 'quantity': qty}],
              'totalCount': qty,
              'packagingType': qty >= 20 ? 'ダンボール' : '紙袋',
              'paymentMethod': '現金',
              'status': '配送済み',
              'branchName': branch,
            });
          }
          historyStrings.sort((a, b) => b.compareTo(a));

          final docRef = _customerCollection.doc();
          final customer = Customer(
            id: docRef.id,
            name: name,
            companyName: entityName,
            phoneNumber: phone,
            address: entityAddr,
            latitude: coords['lat'],
            longitude: coords['lng'],
            orderHistory: historyStrings,
            deliveryAddresses: ['$entityName: $entityAddr (${coords['lat']}, ${coords['lng']})'],
            facilityReceivers: {entityName: [name]},
          );
          batch.set(docRef, customer.toMap());
          await batch.commit();
          totalCreated++;
        }
        entityIdx++;
      }
    } catch (e) {
      print('Error in regenerateDummyCustomers: $e');
      rethrow;
    }
  }
}
