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

  // 電話番号で検索（ハイフンの有無を問わず検索可能）
  Future<Customer?> findByPhoneNumber(String phone) async {
    // 入力された文字列から数字のみを抽出
    final cleanInput = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanInput.isEmpty) return null;

    // データベース側の形式が一定でない（ハイフンあり/なし混在）可能性があるため、
    // 全顧客を取得して数字のみでマッチングを行う（軽量システム向けの簡易実装）
    // ※顧客数が膨大な場合は、保存時に「数字のみのフィールド」を別途持たせる索引最適化が必要
    final allCustomers = await getAllCustomers();
    
    try {
      return allCustomers.firstWhere((customer) {
        final cleanDbPhone = customer.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
        return cleanDbPhone == cleanInput;
      });
    } catch (e) {
      return null;
    }
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

  // メニューマスタから情報を取得し、100名分の顧客ダミーデータを再生成
  Future<void> regenerateDummyCustomers() async {
    final random = Random();
    final batch = FirebaseFirestore.instance.batch();

    final menuSnapshot = await _menuCollection.get();
    final menuNames = menuSnapshot.docs.map((doc) => (doc.data() as Map)['name'] as String).toList();

    if (menuNames.isEmpty) {
      throw Exception('メニューマスタが空です。先にメニューを登録してください。');
    }

    final existingCustomers = await _customerCollection.get();
    for (var doc in existingCustomers.docs) {
      batch.delete(doc.reference);
    }

    final lastNames = ['佐藤', '鈴木', '高橋', '田中', '伊藤', '渡辺', '山本', '中村', '小林', '加藤'];
    final firstNames = ['太郎', '次郎', '三郎', '花子', '良子', '節子', '健一', '修', '直樹', '恵子'];
    final areas = [
      {'city': '愛知県岡崎市', 'streets': ['康生通南', '明大寺町', '欠町']},
      {'city': '愛知県名古屋市緑区', 'streets': ['鳴海町', '徳重', '有松']},
      {'city': '岐阜県岐阜市', 'streets': ['神田町', '柳ヶ瀬通', '加納桜道']},
    ];

    for (int i = 0; i < 100; i++) {
      final name = '${lastNames[random.nextInt(lastNames.length)]} ${firstNames[random.nextInt(firstNames.length)]}';
      final area = areas[random.nextInt(areas.length)];
      final street = (area['streets'] as List)[random.nextInt((area['streets'] as List).length)];
      final address = '${area['city']}$street ${random.nextInt(10)+1}-${random.nextInt(20)+1}';
      final phone = '0${random.nextInt(3) + 7}0-${random.nextInt(9000) + 1000}-${random.nextInt(9000) + 1000}';
      
      final history = List.generate(random.nextInt(2) + 1, (_) {
        final menuName = menuNames[random.nextInt(menuNames.length)];
        final date = '2023-${random.nextInt(2)+11}-${random.nextInt(28)+1}';
        return '$date: $menuName x${random.nextInt(3)+1}';
      });

      final docRef = _customerCollection.doc();
      final customer = Customer(
        id: docRef.id,
        name: name,
        companyName: random.nextDouble() > 0.3 ? '株式会社サンプルフーズ' : '個人・自宅',
        phoneNumber: phone,
        address: address,
        email: 'user${i+1}@example.com',
        orderHistory: history,
        deliveryAddresses: [address],
      );
      batch.set(docRef, customer.toMap());
    }

    await batch.commit();
  }
}
