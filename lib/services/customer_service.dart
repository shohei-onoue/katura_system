import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerService {
  final CollectionReference _customerCollection =
      FirebaseFirestore.instance.collection('customers');
  final CollectionReference _menuCollection =
      FirebaseFirestore.instance.collection('menu');

  // 全顧客取得
  Future<List<Customer>> getAllCustomers() async {
    final snapshot = await _customerCollection.get();
    return snapshot.docs
        .map((doc) => Customer.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // 電話番号で検索（インデックスを利用した高速検索）
  Future<Customer?> findByPhoneNumber(String phone) async {
    final cleanInput = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanInput.isEmpty) return null;

    // 前方一致検索を可能にするため、ハイフンなしの完全一致でクエリを発行
    // 現場運用では受話器から番号を打ち込むため、正規化されたフィールドでの検索が必須
    final snapshot = await _customerCollection
        .where('phoneNumber', isEqualTo: phone) // 元の形式での検索
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Customer.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
    }

    // フォーマット違い（ハイフンなし等）への対応
    // 本来は保存時に正規化フィールド(normalizedPhone)を持つべきだが、
    // 現状のスキーマを尊重しつつ、最低限のクエリで対応
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

  // 全顧客を一括削除 (500件ずつのバッチ処理で高速化・制限回避)
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

  // メニューマスタから情報を取得し、実在する施設データに基づき30名分の顧客ダミーデータを再生成
  Future<void> regenerateDummyCustomers() async {
    final random = Random();
    
    // 高速削除実行
    await deleteAllCustomers();

    final batch = FirebaseFirestore.instance.batch();
    final menuSnapshot = await _menuCollection.get();
    final menuNames = menuSnapshot.docs.map((doc) => (doc.data() as Map)['name'] as String).toList();

    if (menuNames.isEmpty) {
      throw Exception('メニューマスタが空です。先にメニューを登録してください。');
    }

    // 配送先となる実在医療施設 (緯度経度付き)
    final medicalFacilities = [
      {'name': '岡崎市民病院', 'address': '愛知県岡崎市若松町1-1', 'lat': 34.9252, 'lng': 137.1755},
      {'name': '藤田医科大学 岡崎医療センター', 'address': '愛知県岡崎市針崎町五反田1', 'lat': 34.9189, 'lng': 137.1614},
      {'name': '宇野病院', 'address': '愛知県岡崎市中岡崎町1-10', 'lat': 34.9578, 'lng': 137.1512},
      {'name': '三河病院', 'address': '愛知県岡崎市欠町三田田北22', 'lat': 34.9534, 'lng': 137.1867},
      {'name': '岡崎共立病院', 'address': '愛知県岡崎市洞町西浦1', 'lat': 34.9498, 'lng': 137.1987},
      {'name': '岡崎東病院', 'address': '愛知県岡崎市洞町下荒永36-1', 'lat': 34.9512, 'lng': 137.2034},
      {'name': '中得医院', 'address': '愛知県岡崎市柱曙1-1-1', 'lat': 34.9268, 'lng': 137.1634},
      {'name': '杉浦内科クリニック', 'address': '愛知県岡崎市大西2-15-2', 'lat': 34.9412, 'lng': 137.1823},
      {'name': '加藤内科', 'address': '愛知県岡崎市明大寺町大圦62-1', 'lat': 34.9423, 'lng': 137.1712},
      {'name': '豊田厚生病院', 'address': '愛知県豊田市浄水町伊保原500-1', 'lat': 35.1234, 'lng': 137.1456},
      {'name': '安城更生病院', 'address': '愛知県安城市安城町東広畔28', 'lat': 34.9434, 'lng': 137.0912},
    ];

    // 発注元となる実在製薬会社等 (岡崎周辺の営業拠点、緯度経度付き)
    final pharmaCompanies = [
      {'name': '武田薬品工業 岡崎営業所', 'address': '愛知県岡崎市唐沢町1-5', 'lat': 34.9542, 'lng': 137.1691},
      {'name': '第一三共 岡崎第一営業所', 'address': '愛知県岡崎市明大寺本町1-2', 'lat': 34.9582, 'lng': 137.1652},
      {'name': 'アステラス製薬 岡崎営業所', 'address': '愛知県岡崎市六地蔵町1-1', 'lat': 34.9592, 'lng': 137.1681},
      {'name': 'エーザイ 岡崎コミュニケーション部', 'address': '愛知県岡崎市康生通南2-1', 'lat': 34.9572, 'lng': 137.1611},
      {'name': '中外製薬 岡崎オフィス', 'address': '愛知県岡崎市柱町下荒子', 'lat': 34.9252, 'lng': 137.1621},
      {'name': '大塚製薬 岡崎出張所', 'address': '愛知県岡崎市羽根町', 'lat': 34.9312, 'lng': 137.1591},
      {'name': '塩野義製薬 岡崎営業所', 'address': '愛知県岡崎市康生通東', 'lat': 34.9582, 'lng': 137.1691},
      {'name': 'MSD 岡崎営業所', 'address': '愛知県岡崎市明大寺本町', 'lat': 34.9592, 'lng': 137.1661},
      {'name': '小野薬品工業 岡崎営業所', 'address': '愛知県岡崎市唐沢町', 'lat': 34.9532, 'lng': 137.1681},
      {'name': '日本イーライリリー 岡崎営業所', 'address': '愛知県岡崎市康生通西', 'lat': 34.9602, 'lng': 137.1591},
      {'name': '三菱電機 岡崎工場', 'address': '愛知県岡崎市中松町', 'lat': 34.9752, 'lng': 137.1211},
      {'name': 'アイシン 岡崎工場', 'address': '愛知県岡崎市岡町', 'lat': 34.9182, 'lng': 137.2191},
    ];

    // 個人宅用住所 (岡崎市内の住宅街)
    final residentialAddresses = [
      {'address': '愛知県岡崎市康生通南3-1', 'lat': 34.9582, 'lng': 137.1623},
      {'address': '愛知県岡崎市明大寺町大圦12-5', 'lat': 34.9432, 'lng': 137.1701},
      {'address': '愛知県岡崎市欠町三田田1-1', 'lat': 34.9542, 'lng': 137.1852},
      {'address': '愛知県岡崎市六地蔵町1-10', 'lat': 34.9592, 'lng': 137.1682},
      {'address': '愛知県岡崎市柱町下荒子5-1', 'lat': 34.9242, 'lng': 137.1612},
      {'address': '愛知県岡崎市若松町2-5-1', 'lat': 34.9262, 'lng': 137.1762},
      {'address': '愛知県岡崎市羽根町字陣場', 'lat': 34.9312, 'lng': 137.1582},
      {'address': '愛知県岡崎市戸崎町牛転', 'lat': 34.9382, 'lng': 137.1722},
      {'address': '愛知県岡崎市竜美南1-1', 'lat': 34.9352, 'lng': 137.1792},
      {'address': '愛知県岡崎市上地3-1', 'lat': 34.9122, 'lng': 137.1752},
    ];

    final lastNames = [
      {'n': '佐藤', 'f': 'さとう'}, {'n': '鈴木', 'f': 'すずき'}, {'n': '高橋', 'f': 'たかはし'},
      {'n': '田中', 'f': 'たなか'}, {'n': '伊藤', 'f': 'いとう'}, {'n': '渡辺', 'f': 'わたなべ'},
      {'n': '山本', 'f': 'やまもと'}, {'n': '中村', 'f': 'なかむら'}, {'n': '小林', 'f': 'こばやし'},
      {'n': '加藤', 'f': 'かとう'}
    ];
    final firstNames = [
      {'n': '健一', 'f': 'けんいち'}, {'n': '直樹', 'f': 'なおき'}, {'n': '恵子', 'f': 'けいこ'},
      {'n': '由美子', 'f': 'ゆみこ'}, {'n': '和也', 'f': 'かずや'}, {'n': '大輔', 'f': 'だいすけ'},
      {'n': '雅弘', 'f': 'まさひろ'}, {'n': '美穂', 'f': 'みほ'}, {'n': '沙織', 'f': 'さおり'},
      {'n': '翔太', 'f': 'しょうた'}
    ];

    List<Map<String, String>> namePool = [];
    for (var ln in lastNames) {
      for (var fn in firstNames) {
        namePool.add({
          'name': '${ln['n']} ${fn['n']}',
          'furigana': '${ln['f']} ${fn['f']}'
        });
      }
    }
    namePool.shuffle(random);

    final branches = ['岡崎本店', '名古屋店', '岐阜店'];
    final now = DateTime.now();

    final receiverPool = ['佐藤 医師', '鈴木 教授', '高橋 部長', '田中 先生', '伊藤 博士', '渡辺 センター長', '山本 主任', '中村 先生'];

    // --- 1. 個人宅 10件 ---
    for (int i = 0; i < 10; i++) {
      final res = residentialAddresses[i];
      final historyCount = random.nextInt(3) + 1;
      List<String> history = [];
      for (int h = 0; h < historyCount; h++) {
        final orderDate = now.subtract(Duration(days: random.nextInt(180)));
        final dateStr = "${orderDate.year}-${orderDate.month.toString().padLeft(2,'0')}-${orderDate.day.toString().padLeft(2,'0')}";
        final menuName = menuNames[random.nextInt(menuNames.length)];
        final branch = branches[random.nextInt(branches.length)];
        history.add('$dateStr: [$branch] [自宅] $menuName x${random.nextInt(3)+1}');
      }
      history.sort((a, b) => b.compareTo(a));

      final docRef = _customerCollection.doc();
      final customer = Customer(
        id: docRef.id,
        name: namePool[i]['name']!,
        furigana: namePool[i]['furigana']!,
        companyName: '個人・自宅',
        phoneNumber: '0${random.nextInt(2) + 8}0-${random.nextInt(9000) + 1000}-${random.nextInt(9000) + 1000}',
        address: res['address'] as String,
        latitude: (res['lat'] as num).toDouble(),
        longitude: (res['lng'] as num).toDouble(),
        email: 'private${i+1}@example.com',
        orderHistory: history,
        deliveryAddresses: ['[自宅] ${res['address']} (${res['lat']}, ${res['lng']})'],
        facilityReceivers: {'自宅': [namePool[i]['name']!]},
      );
      batch.set(docRef, customer.toMap());
    }

    // --- 2. 法人・担当者 20件 ---
    // 8社に対して複数人を設定
    List<int> multiStaffCompanyIndices = (List.generate(pharmaCompanies.length, (i) => i)..shuffle(random)).take(8).toList();
    List<int> companyAssignment = [];
    // 8社に2人ずつ割り当て (16人)
    for (int idx in multiStaffCompanyIndices) {
      companyAssignment.add(idx);
      companyAssignment.add(idx);
    }
    // 残り4人を適当な会社に割り当て
    for (int j = 0; j < 4; j++) {
      companyAssignment.add(random.nextInt(pharmaCompanies.length));
    }
    companyAssignment.shuffle(random);

    for (int i = 0; i < 20; i++) {
      final companyIdx = companyAssignment[i];
      final company = pharmaCompanies[companyIdx];
      final companyName = company['name'] as String;

      // この担当者が担当する医療施設をランダムに2〜4箇所選定
      final myTargets = (List.from(medicalFacilities)..shuffle(random)).take(random.nextInt(3) + 2).toList();
      
      List<String> deliveryAddresses = [];
      List<String> history = [];
      Map<String, List<String>> facilityReceivers = {};

      for (var target in myTargets) {
        final targetName = target['name'] as String;
        final targetAddr = target['address'] as String;
        final lat = target['lat'];
        final lng = target['lng'];
        deliveryAddresses.add('$targetName: $targetAddr ($lat, $lng)');

        // 施設ごとの受取人を生成
        final receivers = (List<String>.from(receiverPool)..shuffle(random)).take(random.nextInt(3) + 1).toList();
        facilityReceivers[targetName] = receivers;

        for (int h = 0; h < (random.nextInt(3) + 1); h++) {
          final orderDate = now.subtract(Duration(days: random.nextInt(180)));
          final dateStr = "${orderDate.year}-${orderDate.month.toString().padLeft(2,'0')}-${orderDate.day.toString().padLeft(2,'0')}";
          final menuName = menuNames[random.nextInt(menuNames.length)];
          final branch = branches[random.nextInt(branches.length)];
          final receiver = receivers[random.nextInt(receivers.length)];
          history.add('$dateStr: [$branch] [$targetName] ($receiver) $menuName x${random.nextInt(10)+5}');
        }
      }
      history.sort((a, b) => b.compareTo(a));

      final nameIdx = i + 10;
      final docRef = _customerCollection.doc();
      final customer = Customer(
        id: docRef.id,
        name: namePool[nameIdx]['name']!,
        furigana: namePool[nameIdx]['furigana']!,
        companyName: companyName,
        phoneNumber: '0${random.nextInt(3) + 7}0-${random.nextInt(9000) + 1000}-${random.nextInt(9000) + 1000}',
        address: company['address'] as String,
        latitude: (company['lat'] as num).toDouble(),
        longitude: (company['lng'] as num).toDouble(),
        email: 'staff${i+1}@example.com',
        orderHistory: history,
        deliveryAddresses: deliveryAddresses,
        facilityReceivers: facilityReceivers,
      );
      batch.set(docRef, customer.toMap());
    }


    await batch.commit();
  }
}
