import 'dart:math';
import '../models/customer_model.dart';
import '../models/menu_model.dart';
import '../models/order_model.dart';
import 'customer_service.dart';
import 'google_maps_service.dart';
import 'menu_service.dart';
import 'order_service.dart';

/// ダミーデータ（顧客・受注）の生成と全削除。顧客一覧画面のボタンから使う。
class DummyDataService {
  /// 「今日」の基準日（生成ルールで指定された日付）
  static final DateTime baseDate = DateTime(2026, 10, 13);

  static const int _customerCount = 100;
  static const int _dormantCount = 20; // 1年以上注文のない顧客
  static const int _reservationCount = 30; // 基準日から2週間の受注予約
  static const int _simplePhoneCount = 15; // 下4桁が1111などの顧客

  // 苗字（漢字:よみ）100件・すべて別
  static const _surnames = [
    '佐藤:さとう', '鈴木:すずき', '高橋:たかはし', '田中:たなか', '伊藤:いとう', '渡辺:わたなべ', '山本:やまもと', '中村:なかむら', '小林:こばやし', '加藤:かとう',
    '吉田:よしだ', '山田:やまだ', '佐々木:ささき', '山口:やまぐち', '松本:まつもと', '井上:いのうえ', '木村:きむら', '林:はやし', '斎藤:さいとう', '清水:しみず',
    '山崎:やまざき', '森:もり', '池田:いけだ', '橋本:はしもと', '阿部:あべ', '石川:いしかわ', '山下:やました', '中島:なかじま', '石井:いしい', '小川:おがわ',
    '前田:まえだ', '岡田:おかだ', '長谷川:はせがわ', '藤田:ふじた', '後藤:ごとう', '近藤:こんどう', '村上:むらかみ', '遠藤:えんどう', '青木:あおき', '坂本:さかもと',
    '福田:ふくだ', '太田:おおた', '西村:にしむら', '藤井:ふじい', '金子:かねこ', '岡本:おかもと', '藤原:ふじわら', '三浦:みうら', '中野:なかの', '原田:はらだ',
    '松田:まつだ', '竹内:たけうち', '小野:おの', '田村:たむら', '中山:なかやま', '和田:わだ', '石田:いしだ', '上田:うえだ', '森田:もりた', '原:はら',
    '柴田:しばた', '酒井:さかい', '工藤:くどう', '横山:よこやま', '宮崎:みやざき', '宮本:みやもと', '内田:うちだ', '高木:たかぎ', '安藤:あんどう', '谷口:たにぐち',
    '大野:おおの', '丸山:まるやま', '今井:いまい', '河野:こうの', '藤本:ふじもと', '村田:むらた', '武田:たけだ', '上野:うえの', '杉山:すぎやま', '増田:ますだ',
    '平野:ひらの', '大塚:おおつか', '千葉:ちば', '久保:くぼ', '松井:まつい', '小島:こじま', '岩崎:いわさき', '桜井:さくらい', '野口:のぐち', '松尾:まつお',
    '野村:のむら', '木下:きのした', '菊地:きくち', '佐野:さの', '大西:おおにし', '杉本:すぎもと', '新井:あらい', '浜田:はまだ', '菅原:すがわら', '水野:みずの',
  ];

  // 名前（漢字:よみ）100件・すべて別
  static const _givenNames = [
    '太郎:たろう', '一郎:いちろう', '健太:けんた', '大輔:だいすけ', '翔太:しょうた', '拓也:たくや', '直樹:なおき', '誠:まこと', '浩二:こうじ', '学:まなぶ',
    '隆:たかし', '剛:つよし', '修:おさむ', '豊:ゆたか', '勇:いさむ', '清:きよし', '茂:しげる', '稔:みのる', '進:すすむ', '守:まもる',
    '博:ひろし', '昭:あきら', '正男:まさお', '和夫:かずお', '幸雄:ゆきお', '秀樹:ひでき', '哲也:てつや', '雅彦:まさひこ', '光男:みつお', '義明:よしあき',
    '邦彦:くにひこ', '康平:こうへい', '駿:しゅん', '蓮:れん', '陽斗:はると', '悠真:ゆうま', '颯太:そうた', '優斗:ゆうと', '大地:だいち', '海斗:かいと',
    '花子:はなこ', '美咲:みさき', '陽子:ようこ', '恵子:けいこ', '久美子:くみこ', '智子:ともこ', '由美:ゆみ', '真理:まり', '裕子:ゆうこ', '京子:きょうこ',
    '明美:あけみ', '幸子:さちこ', '洋子:ひろこ', '節子:せつこ', '君子:きみこ', '千代:ちよ', '弥生:やよい', '澄子:すみこ', '春江:はるえ', '文子:ふみこ',
    '和子:かずこ', '友美:ともみ', '沙織:さおり', '麻衣:まい', '彩:あや', '愛:あい', '葵:あおい', '結衣:ゆい', '莉子:りこ', '美優:みゆ',
    '千尋:ちひろ', '詩織:しおり', '夏美:なつみ', '秋子:あきこ', '冬美:ふゆみ', '里奈:りな', '菜々子:ななこ', '純子:じゅんこ', '孝子:たかこ', '聡美:さとみ',
    '典子:のりこ', '靖子:やすこ', '佳代:かよ', '静香:しずか', '早苗:さなえ', '香織:かおり', '理恵:りえ', '晴美:はるみ', '奈緒:なお', '瞳:ひとみ',
    '良子:よしこ', '雅子:まさこ', '真由美:まゆみ', '悦子:えつこ', '俊介:しゅんすけ', '祐介:ゆうすけ', '大樹:だいき', '亮:りょう', '慎一:しんいち', '圭吾:けいご',
  ];

  // 所属企業30件：実在する寺院（住所はNAVITIME掲載の所在地）。10市×3件。
  // 座標は生成時にジオコーディングで求め、失敗したら市の中心付近の座標を使う。
  static const _companies = <_Company>[
    _Company('大樹寺', '愛知県岡崎市鴨田町字広元5-1', 34.9546, 137.1744),
    _Company('滝山寺', '愛知県岡崎市滝町字山籠107', 34.9546, 137.1744),
    _Company('松応寺', '愛知県岡崎市松本町42', 34.9546, 137.1744),
    _Company('普門寺', '愛知県豊橋市雲谷町ナベ山下7', 34.7692, 137.3914),
    _Company('龍拈寺', '愛知県豊橋市新吉町3', 34.7692, 137.3914),
    _Company('神宮寺', '愛知県豊橋市魚町79', 34.7692, 137.3914),
    _Company('豊川閣妙厳寺', '愛知県豊川市豊川町1', 34.8269, 137.3756),
    _Company('三明寺', '愛知県豊川市豊川町波通37', 34.8269, 137.3756),
    _Company('財賀寺', '愛知県豊川市財賀町観音山3', 34.8269, 137.3756),
    _Company('実相寺', '愛知県西尾市上町下屋敷15', 34.8613, 137.0614),
    _Company('浄名寺', '愛知県西尾市徳永町東側39', 34.8613, 137.0614),
    _Company('長円寺', '愛知県西尾市貝吹町入101', 34.8613, 137.0614),
    _Company('応春寺', '愛知県碧南市天神町5-2', 34.8845, 136.993),
    _Company('称名寺', '愛知県碧南市築山町2-66', 34.8845, 136.993),
    _Company('康順寺', '愛知県碧南市札木町2-87', 34.8845, 136.993),
    _Company('大徳寺', '愛知県蒲郡市三谷町黒別当40-1', 34.8266, 137.2194),
    _Company('源光寺', '愛知県蒲郡市鹿島町岡18', 34.8266, 137.2194),
    _Company('永向寺', '愛知県蒲郡市丸山町6-19', 34.8266, 137.2194),
    _Company('願照寺', '愛知県田原市波瀬町東郷77', 34.6694, 137.2661),
    _Company('慶雲寺', '愛知県田原市田原町稗田41-1', 34.6694, 137.2661),
    _Company('九清院', '愛知県田原市中山町成美41-2', 34.6694, 137.2661),
    _Company('正林寺', '愛知県高浜市呉竹町2丁目1-5', 34.9068, 136.993),
    _Company('恩任寺', '愛知県高浜市青木町2-1-33', 34.9068, 136.993),
    _Company('宝満寺', '愛知県高浜市屋敷町3丁目5-16', 34.9068, 136.993),
    _Company('金勝寺', '愛知県刈谷市高津波町5丁目67', 34.9889, 137.003),
    _Company('医王寺', '愛知県刈谷市高津波町2-93', 34.9889, 137.003),
    _Company('敬専寺', '愛知県刈谷市小山町6-111', 34.9889, 137.003),
    _Company('香積寺', '愛知県豊田市足助町飯盛39', 35.0828, 137.156),
    _Company('高月院', '愛知県豊田市松平町寒ケ入44', 35.0828, 137.156),
    _Company('三光寺', '愛知県豊田市金谷町5-63', 35.0828, 137.156),
  ];

  // 個人宅の住所（市＋町名）
  static const _homeTowns = <_Company>[
    _Company('', '愛知県岡崎市康生町', 34.9540, 137.1740),
    _Company('', '愛知県豊橋市花田町', 34.7690, 137.3910),
    _Company('', '愛知県豊川市諏訪', 34.8200, 137.3800),
    _Company('', '愛知県西尾市花ノ木町', 34.8620, 137.0610),
    _Company('', '愛知県碧南市松本町', 34.8850, 136.9930),
    _Company('', '愛知県蒲郡市旭町', 34.8260, 137.2190),
    _Company('', '愛知県田原市田原町', 34.6690, 137.2660),
    _Company('', '愛知県高浜市春日町', 34.9060, 136.9930),
    _Company('', '愛知県刈谷市桜町', 34.9880, 137.0020),
    _Company('', '愛知県豊田市西町', 35.0820, 137.1550),
  ];

  static const _simpleSuffixes = [
    '1111', '2222', '3333', '4444', '5555', '6666', '7777', '8888', '9999', '0000',
    '1234', '4321', '1212', '1010', '2020',
  ];

  static const _orderSources = ['直取', '直取', '直取', '結膳', 'デリカ'];
  static const _hours = [10, 11, 11, 12, 12, 13, 16, 17];

  final _customerService = CustomerService();
  final _orderService = OrderService();

  /// ダミーの顧客100名・過去1年の注文・2週間分の受注予約を作って保存する。
  Future<({int customers, int orders, int reservations})> generate() async {
    final rnd = Random(20261013);
    final menus = await _loadMenus();
    await _resolveCompanyCoords();
    final customers = _buildCustomers(rnd);

    // 1年以上注文のない顧客をランダムに選ぶ
    final idx = List.generate(customers.length, (i) => i)..shuffle(rnd);
    final dormant = idx.take(_dormantCount).toSet();

    final orders = <OrderModel>[];
    final history = <String, List<String>>{};
    var seq = 0;
    OrderModel make(Customer c, DateTime delivery, {required bool future}) {
      final id = 'dummy_o${(++seq).toString().padLeft(4, '0')}';
      (history[c.id] ??= []).add(id);
      final lines = _pickItems(rnd, menus);
      final facility = c.companyName;
      final reception = future
          ? baseDate.subtract(Duration(days: rnd.nextInt(8)))
          : delivery.subtract(Duration(days: 1 + rnd.nextInt(10)));
      final isCancel = !future && rnd.nextInt(100) < 3;
      return OrderModel(
        id: id,
        customerName: c.name,
        customerId: c.id,
        receiverName: c.name,
        facilityName: facility,
        address: c.address,
        phoneNumber: c.phoneNumber,
        receptionDate: reception,
        deliveryDate: delivery,
        deliveryTime: '${delivery.hour}:${delivery.minute.toString().padLeft(2, '0')}',
        deliveryType: rnd.nextInt(10) == 0 ? '引取' : '配達',
        items: lines,
        totalCount: lines.fold(0, (s, i) => s + (i['quantity'] as int)),
        orderSource: _orderSources[rnd.nextInt(_orderSources.length)],
        teaOption: rnd.nextBool() ? '込み' : '別',
        status: future ? '受注済み' : (isCancel ? 'キャンセル済み' : '配送済み'),
        latitude: c.latitude,
        longitude: c.longitude,
        vehicleNumber: 1 + rnd.nextInt(4),
      );
    }

    DateTime at(int daysFromBase) => DateTime(
          baseDate.year, baseDate.month, baseDate.day + daysFromBase,
          _hours[rnd.nextInt(_hours.length)], rnd.nextInt(4) * 15);

    final activeCustomers = <Customer>[];
    for (var i = 0; i < customers.length; i++) {
      final c = customers[i];
      if (dormant.contains(i)) {
        // 1年以上前（366〜900日前）の注文だけ
        for (var k = 1 + rnd.nextInt(3); k > 0; k--) {
          orders.add(make(c, at(-(366 + rnd.nextInt(535))), future: false));
        }
      } else {
        activeCustomers.add(c);
        // 過去1年（1〜365日前）の注文を1〜8件
        for (var k = 1 + rnd.nextInt(8); k > 0; k--) {
          orders.add(make(c, at(-(1 + rnd.nextInt(365))), future: false));
        }
      }
    }
    // 基準日から2週間（0〜13日後）の受注予約
    for (var k = 0; k < _reservationCount; k++) {
      final c = activeCustomers[rnd.nextInt(activeCustomers.length)];
      orders.add(make(c, at(rnd.nextInt(14)), future: true));
    }

    final saved = customers.map((c) => c.copyWith(orderHistory: history[c.id] ?? const [])).toList();
    await _customerService.saveAllCustomers(saved);
    await _orderService.saveAllOrders(orders);
    return (customers: saved.length, orders: orders.length - _reservationCount, reservations: _reservationCount);
  }

  /// 顧客と受注を全件削除する（ダミーかどうかは区別しない）。
  Future<void> deleteAll() async {
    await _orderService.deleteAllOrders();
    await _customerService.deleteAllCustomers();
  }

  // 企業住所→座標（ジオコーディング結果）
  final Map<String, (double, double)> _coords = {};

  Future<void> _resolveCompanyCoords() async {
    final maps = GoogleMapsService();
    for (final c in _companies) {
      try {
        final r = await maps.getLatLngFromAddress('${c.address} ${c.name}');
        if (r != null) _coords[c.address] = (r['lat'] as double, r['lng'] as double);
      } catch (_) {}
    }
  }

  List<Customer> _buildCustomers(Random rnd) {
    final surnames = _surnames.map((e) => e.split(':')).toList()..shuffle(rnd);
    final givens = _givenNames.map((e) => e.split(':')).toList()..shuffle(rnd);

    // 企業30件×3名＝90名、残り10名は個人宅
    final slots = <_Company?>[
      for (final c in _companies) ...[c, c, c],
      for (var i = 0; i < _customerCount - _companies.length * 3; i++) null,
    ]..shuffle(rnd);

    // 下4桁がシンプルな顧客15名
    final simpleAt = (List.generate(_customerCount, (i) => i)..shuffle(rnd)).take(_simplePhoneCount).toList();
    final usedPhones = <String>{};

    String phone(int i) {
      final simpleIdx = simpleAt.indexOf(i);
      while (true) {
        final head = ['090', '080', '070'][rnd.nextInt(3)];
        final mid = (1000 + rnd.nextInt(9000)).toString();
        final tail = simpleIdx >= 0
            ? _simpleSuffixes[simpleIdx]
            : (1000 + rnd.nextInt(9000)).toString();
        if (simpleIdx < 0 && _simpleSuffixes.contains(tail)) continue;
        final p = '$head-$mid-$tail';
        if (usedPhones.add(p)) return p;
      }
    }

    return [
      for (var i = 0; i < _customerCount; i++)
        () {
          final co = slots[i];
          final home = _homeTowns[rnd.nextInt(_homeTowns.length)];
          final place = co ?? home;
          return Customer(
            id: 'dummy_c${(i + 1).toString().padLeft(3, '0')}',
            name: '${surnames[i][0]} ${givens[i][0]}',
            furigana: '${surnames[i][1]} ${givens[i][1]}',
            companyName: co == null ? '個人宅' : co.name,
            phoneNumber: phone(i),
            address: place.address,
            latitude: _coords[place.address]?.$1 ?? place.lat,
            longitude: _coords[place.address]?.$2 ?? place.lng,
          );
        }(),
    ];
  }

  List<Map<String, dynamic>> _pickItems(Random rnd, List<MenuModel> menus) {
    final pool = List.of(menus)..shuffle(rnd);
    return [
      for (final m in pool.take(1 + rnd.nextInt(3)))
        {
          'id': m.id,
          'name': m.name,
          'price': m.price,
          'quantity': 5 + rnd.nextInt(36),
          'specialOrder': '',
          'specialOrderQuantity': 0,
          'topping': '',
          'teaOption': 'なし',
          'teaQuantity': 0,
        },
    ];
  }

  /// 登録済みメニューを使う。1件もなければ仮のメニューで代用する。
  Future<List<MenuModel>> _loadMenus() async {
    try {
      final menus = await MenuService().getAllMenus();
      if (menus.isNotEmpty) return menus;
    } catch (_) {}
    return [
      MenuModel(id: 'dummy_m1', name: '幕の内弁当', category: '弁当', price: 1000),
      MenuModel(id: 'dummy_m2', name: '唐揚げ弁当', category: '弁当', price: 900),
      MenuModel(id: 'dummy_m3', name: '特上うなぎ弁当', category: '弁当', price: 2200),
      MenuModel(id: 'dummy_m4', name: '精進弁当', category: '弁当', price: 1300),
    ];
  }
}

class _Company {
  final String name;
  final String address;
  final double lat;
  final double lng;
  const _Company(this.name, this.address, this.lat, this.lng);
}
