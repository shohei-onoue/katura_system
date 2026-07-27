import 'dart:async';
import 'package:sqlite3/common.dart';
import 'database_factory.dart';

/// 現場のスピードに耐えうる SQLite（WASM/Native）ベースの住所検索サービス
class AddressService {
  // シングルトン化
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  CommonDatabase? _db;
  Completer<void>? _initCompleter;

  // 現場のスピードを支える都道府県固定リスト
  static const List<Map<String, String>> _prefectures = [
    {'state': '北海道', 'kana': 'ホッカイドウ'},
    {'state': '青森県', 'kana': 'アオモリケン'},
    {'state': '岩手県', 'kana': 'イワテケン'},
    {'state': '宮城県', 'kana': 'ミヤギケン'},
    {'state': '秋田県', 'kana': 'アキタケン'},
    {'state': '山形県', 'kana': 'ヤマガタケン'},
    {'state': '福島県', 'kana': 'フクシマケン'},
    {'state': '茨城県', 'kana': 'イバラキケン'},
    {'state': '栃木県', 'kana': 'トチギケン'},
    {'state': '群馬県', 'kana': 'グンマケン'},
    {'state': '埼玉県', 'kana': 'サイタマケン'},
    {'state': '千葉県', 'kana': 'チバケン'},
    {'state': '東京都', 'kana': 'トウキョウト'},
    {'state': '神奈川県', 'kana': 'カナガワケン'},
    {'state': '新潟県', 'kana': 'ニイガタケン'},
    {'state': '富山県', 'kana': 'トヤマケン'},
    {'state': '石川県', 'kana': 'イシカワケン'},
    {'state': '福井県', 'kana': 'フクイケン'},
    {'state': '山梨県', 'kana': 'ヤマナシケン'},
    {'state': '長野県', 'kana': 'ナガノケン'},
    {'state': '岐阜県', 'kana': 'ギフケン'},
    {'state': '静岡県', 'kana': 'シズオカケン'},
    {'state': '愛知県', 'kana': 'アイチケン'},
    {'state': '三重県', 'kana': 'ミエケン'},
    {'state': '滋賀県', 'kana': 'シガケン'},
    {'state': '京都府', 'kana': 'キョウトフ'},
    {'state': '大阪府', 'kana': 'オオサカフ'},
    {'state': '兵庫県', 'kana': 'ヒョウゴケン'},
    {'state': '奈良県', 'kana': 'ナラケン'},
    {'state': '和歌山県', 'kana': 'ワカヤマケン'},
    {'state': '鳥取県', 'kana': 'トットリケン'},
    {'state': '島根県', 'kana': 'シマネケン'},
    {'state': '岡山県', 'kana': 'オカヤマケン'},
    {'state': '広島県', 'kana': 'ヒロシマケン'},
    {'state': '山口県', 'kana': 'ヤマグチケン'},
    {'state': '徳島県', 'kana': 'トクシマケン'},
    {'state': '香川県', 'kana': 'カガワケン'},
    {'state': '愛媛県', 'kana': 'エヒメケン'},
    {'state': '高知県', 'kana': 'コウチケン'},
    {'state': '福岡県', 'kana': 'フクオカケン'},
    {'state': '佐賀県', 'kana': 'サガケン'},
    {'state': '長崎県', 'kana': 'ナガサキケン'},
    {'state': '熊本県', 'kana': 'クマモトケン'},
    {'state': '大分県', 'kana': 'オオイタケン'},
    {'state': '宮崎県', 'kana': 'ミヤザキケン'},
    {'state': '鹿児島県', 'kana': 'カゴシマケン'},
    {'state': '沖縄県', 'kana': 'オキナワケン'},
  ];

  /// カーナビ風カテゴリ定義
  static const Map<String, Map<String, List<String>>> categoryHierarchy = {
    '医療・介護': {
      '病院': ['病院'],
      '歯科医院': ['歯科', 'デンタル'],
      'クリニック': ['クリニック', '医院', '診療所'],
      '介護施設': ['介護', 'ケアセンター', '老人ホーム', 'デイサービス'],
    },
    '公共施設': {
      '役所・役場': ['役所', '役場', 'センター', '総合庁舎'],
      '警察署': ['警察', '交番'],
      '消防署': ['消防'],
      '学校': ['学校', '小学校', '中学校', '高校', '大学', '幼稚園', '保育園'],
      '公園': ['公園', '緑地'],
      '郵便局': ['郵便局'],
      '図書館': ['図書館'],
    },
    '商業・店舗': {
      'スーパー': ['スーパー'],
      'コンビニ': ['コンビニ', 'セブン', 'ローソン', 'ファミマ'],
      'デパート': ['デパート', '百貨店'],
      '飲食店': ['レストラン', '食', 'カフェ', '居酒屋', '弁当'],
      '銀行': ['銀行', '信用金庫', '信金'],
      '宿泊施設': ['ホテル', '旅館'],
    },
    '工場・工業': {
      '工場': ['工場'],
      '製作所': ['製作所'],
      '工業': ['工業'],
      '倉庫': ['倉庫', '流通', 'ロジ'],
    },
    '企業・オフィス': {
      '一般企業': ['株式会社', '有限会社', '合同会社', '商事'],
      '保険': ['保険'],
      '放送局': ['放送', 'テレビ', 'ラジオ', '新聞'],
      '寺社仏閣': ['寺', '神社', '教会'],
    },
  };

  Future<void> initDatabase() async {
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<void>();

    try {
      _db = await DatabaseFactory.openProjectDatabase(
        "assets/navi_database.db", 
        "navi_database.db"
      );

      // 高速化のためのインデックス作成
      _db!.execute("CREATE INDEX IF NOT EXISTS idx_pref_city ON post_all(prefecture, city_kana, city)");
      _db!.execute("CREATE INDEX IF NOT EXISTS idx_pref_city_town ON post_all(prefecture, city, town_kana, town)");

      // kigyouテーブルに座標カラムがない場合は追加
      _addColumnIfNotExists('kigyou', 'lat', 'REAL');
      _addColumnIfNotExists('kigyou', 'lng', 'REAL');

      _initCompleter!.complete();
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null;
    }
  }

  void _addColumnIfNotExists(String tableName, String columnName, String type) {
    final pragma = _db!.select("PRAGMA table_info($tableName)");
    final exists = pragma.any((row) => row['name'] == columnName);
    if (!exists) {
      _db!.execute("ALTER TABLE $tableName ADD COLUMN $columnName $type");
    }
  }

  /// 施設名による検索（kigyouとmedicalから検索）
  Future<List<Map<String, dynamic>>> searchFacilityByName(String name) async {
    await initDatabase();
    
    // kigyouテーブルからの検索
    final kigyouResults = _db!.select(
      "SELECT company_name as name, "
      "COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address, "
      "lat, lng, '企業' as type "
      "FROM kigyou WHERE company_name LIKE ?",
      ['%$name%']
    );

    // medicalテーブルからの検索（medicalにもlat, lngがあると仮定、なければNULLになる）
    final medicalResults = _db!.select(
      "SELECT name, "
      "COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address, "
      "NULL as lat, NULL as lng, '医療' as type " // medicalには現在座標がない可能性が高いのでNULL
      "FROM medical WHERE name LIKE ?",
      ['%$name%']
    );

    final List<Map<String, dynamic>> combined = [];
    for (var row in kigyouResults) {
      combined.add({
        'name': row['name'],
        'address': row['address'],
        'lat': row['lat'],
        'lng': row['lng'],
        'type': row['type'],
      });
    }
    for (var row in medicalResults) {
      combined.add({
        'name': row['name'],
        'address': row['address'],
        'lat': row['lat'],
        'lng': row['lng'],
        'type': row['type'],
      });
    }
    
    return combined;
  }

  /// 都道府県のカナ検索 (DBから取得版)
  Future<List<String>> getPrefecturesByInitial(String initialRow) async {
    if (initialRow == 'すべて') {
      await initDatabase();
      final results = _db!.select('SELECT DISTINCT prefecture FROM post_all ORDER BY prefecture_kana');
      return results.map((row) => row['prefecture'] as String).toList();
    }
    
    await initDatabase();
    final Map<String, String> toHalf = _getHalfKanaMap();
    final Map<String, List<String>> rowMap = _getKanaRowMap();

    final fullPrefixes = rowMap[initialRow] ?? [];
    if (fullPrefixes.isEmpty) return [];

    final List<String> allPrefixes = [];
    for (var p in fullPrefixes) {
      allPrefixes.add(p);
      if (toHalf.containsKey(p)) allPrefixes.add(toHalf[p]!);
    }

    final String whereClause = allPrefixes.map((_) => 'prefecture_kana LIKE ?').join(' OR ');
    final results = _db!.select(
      'SELECT DISTINCT prefecture FROM post_all WHERE $whereClause ORDER BY prefecture_kana',
      allPrefixes.map((p) => '$p%').toList()
    );

    return results.map((row) => row['prefecture'] as String).toList();
  }

  /// 全都道府県取得
  Future<List<String>> getPrefectures() async {
    return _prefectures.map((p) => p['state']!).toList();
  }

  /// 指定都道府県の市区町村取得
  Future<List<String>> getCities(String state) async {
    await initDatabase();
    final results = _db!.select(
      'SELECT DISTINCT city FROM post_all WHERE prefecture = ? ORDER BY city_kana',
      [state]
    );
    return results.map((row) => row['city'] as String).toList();
  }

  /// 指定都道府県内で、頭文字行（あ〜わ）に一致する市区町村を検索
  Future<List<String>> getCitiesByInitial(String state, String initialRow) async {
    if (initialRow == 'すべて') return getCities(state);
    
    await initDatabase();
    
    final Map<String, String> toHalf = _getHalfKanaMap();
    final Map<String, List<String>> rowMap = _getKanaRowMap();

    final fullPrefixes = rowMap[initialRow] ?? [];
    if (fullPrefixes.isEmpty) return [];

    final List<String> allPrefixes = [];
    for (var p in fullPrefixes) {
      allPrefixes.add(p);
      if (toHalf.containsKey(p)) allPrefixes.add(toHalf[p]!);
    }

    final String whereClause = allPrefixes.map((_) => 'city_kana LIKE ?').join(' OR ');
    final List<String> params = [state, ...allPrefixes.map((p) => '$p%')];

    final results = _db!.select(
      'SELECT DISTINCT city FROM post_all WHERE prefecture = ? AND ($whereClause) ORDER BY city_kana',
      params
    );

    return results.map((row) => row['city'] as String).toList();
  }

  /// 指定市区町村内の町域取得
  Future<List<String>> getTowns(String state, String city) async {
    await initDatabase();
    final results = _db!.select(
      'SELECT DISTINCT town FROM post_all WHERE prefecture = ? AND city = ? ORDER BY town_kana',
      [state, city]
    );
    return results.map((row) => row['town'] as String).toList();
  }

  /// 指定市区町村内で、頭文字行（あ〜わ）に一致する町域を検索
  Future<List<String>> getTownsByInitial(String state, String city, String initialRow) async {
    if (initialRow == 'すべて') return getTowns(state, city);
    
    await initDatabase();
    
    final Map<String, String> toHalf = _getHalfKanaMap();
    final Map<String, List<String>> rowMap = _getKanaRowMap();

    final fullPrefixes = rowMap[initialRow] ?? [];
    if (fullPrefixes.isEmpty) return [];

    final List<String> allPrefixes = [];
    for (var p in fullPrefixes) {
      allPrefixes.add(p);
      if (toHalf.containsKey(p)) allPrefixes.add(toHalf[p]!);
    }

    final String whereClause = allPrefixes.map((_) => 'town_kana LIKE ?').join(' OR ');
    final List<String> params = [state, city, ...allPrefixes.map((p) => '$p%')];

    final results = _db!.select(
      'SELECT DISTINCT town FROM post_all WHERE prefecture = ? AND city = ? AND ($whereClause) ORDER BY town_kana',
      params
    );

    return results.map((row) => row['town'] as String).toList();
  }

  /// 岡崎市の企業・施設データをランダムに取得（ダミー生成用）
  Future<List<Map<String, String>>> getRandomOkazakiEntities({int limit = 10}) async {
    await initDatabase();
    
    // 企業の取得（NULL対策としてCOALESCE、文字列定数はシングルクォートを使用）
    final kigyouResults = _db!.select(
      "SELECT company_name as name, "
      "COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address "
      "FROM kigyou WHERE city = '岡崎市' ORDER BY RANDOM() LIMIT ?",
      [(limit / 2).ceil()]
    );

    // 医療機関の取得
    final medicalResults = _db!.select(
      "SELECT name, "
      "COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address "
      "FROM medical WHERE city = '岡崎市' ORDER BY RANDOM() LIMIT ?",
      [(limit / 2).floor()]
    );

    final List<Map<String, String>> combined = [];
    for (var row in kigyouResults) {
      combined.add({'name': (row['name'] ?? '名称不明') as String, 'address': (row['address'] ?? '') as String, 'type': '企業'});
    }
    for (var row in medicalResults) {
      combined.add({'name': (row['name'] ?? '名称不明') as String, 'address': (row['address'] ?? '') as String, 'type': '医療'});
    }
    
    combined.shuffle();
    return combined;
  }

  /// 企業・施設情報の保存または更新（ジオコーディング結果のキャッシュ用）
  Future<void> upsertKigyouEntity({
    required String name,
    required String address,
    required double lat,
    required double lng,
  }) async {
    await initDatabase();

    // 住所の正規化（都道府県・市区町村を分離して保存を試みる）
    String pref = '愛知県';
    String city = '岡崎市';
    String street = address;

    if (address.startsWith('愛知県')) {
      street = street.replaceFirst('愛知県', '');
    }
    if (street.startsWith('岡崎市')) {
      street = street.replaceFirst('岡崎市', '');
    }

    // 施設名と住所の一部（正規化して比較）で既存データを検索
    final existing = _db!.select(
      'SELECT rowid FROM kigyou WHERE company_name = ? AND (address LIKE ? OR address = ?) LIMIT 1',
      [name, '%$street%', street]
    );

    if (existing.isNotEmpty) {
      // 存在すれば座標を更新
      _db!.execute(
        'UPDATE kigyou SET lat = ?, lng = ? WHERE rowid = ?',
        [lat, lng, existing.first['rowid']]
      );
    } else {
      // 存在しなければ新規追加
      _db!.execute(
        'INSERT INTO kigyou (company_name, address, lat, lng, prefecture, city) VALUES (?, ?, ?, ?, ?, ?)',
        [name, street, lat, lng, pref, city]
      );
    }
  }

  /// 地域とカテゴリによる詳細検索
  Future<List<Map<String, dynamic>>> searchByLocationAndCategory({
    required String prefecture,
    required String city,
    required String category,
    required String genre,
  }) async {
    await initDatabase();

    final keywords = categoryHierarchy[category]?[genre] ?? [];
    if (keywords.isEmpty) return [];

    final String kigyouLike = keywords.map((_) => 'company_name LIKE ?').join(' OR ');
    final String medicalLike = keywords.map((_) => 'name LIKE ?').join(' OR ');
    
    // パラメータの構成: [キーワード...] x 2, prefecture, city, [キーワード...] x 2, prefecture, city
    final List<String> params = [
      ...keywords.map((k) => '%$k%'),
      prefecture, city,
      ...keywords.map((k) => '%$k%'),
      prefecture, city,
    ];

    final results = _db!.select(
      "SELECT company_name as name, "
      "COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address, "
      "lat, lng, '$genre' as type "
      "FROM kigyou WHERE ($kigyouLike) AND prefecture = ? AND city = ? "
      "UNION ALL "
      "SELECT name, "
      "COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address, "
      "NULL as lat, NULL as lng, '$genre' as type "
      "FROM medical WHERE ($medicalLike) AND prefecture = ? AND city = ? "
      "LIMIT 200",
      params
    );

    return results.map((row) => {
      'name': row['name'],
      'address': row['address'],
      'lat': row['lat'],
      'lng': row['lng'],
      'type': row['type'],
    }).toList();
  }

  /// 住所または郵便番号による検索
  Future<List<Map<String, dynamic>>> searchByAddressOrZip(String query) async {
    await initDatabase();
    
    // 郵便番号形式かチェック (数字とハイフンのみ)
    final isZip = RegExp(r'^[0-9\-]+$').hasMatch(query);

    if (isZip) {
      final cleanZip = query.replaceAll('-', '');
      final results = _db!.select(
        "SELECT company_name as name, "
        "COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address, "
        "lat, lng, '郵便番号一致' as type "
        "FROM kigyou WHERE zip_code = ? OR zip_code = ? LIMIT 100",
        [cleanZip, query]
      );
      return results.map((row) => {
        'name': row['name'],
        'address': row['address'],
        'lat': row['lat'],
        'lng': row['lng'],
        'type': row['type'],
      }).toList();
    } else {
      // 住所部分一致
      final results = _db!.select(
        "SELECT company_name as name, "
        "COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address, "
        "lat, lng, '住所検索' as type "
        "FROM kigyou WHERE address LIKE ? OR city LIKE ? OR town LIKE ? LIMIT 100",
        ['%$query%', '%$query%', '%$query%']
      );
      return results.map((row) => {
        'name': row['name'],
        'address': row['address'],
        'lat': row['lat'],
        'lng': row['lng'],
        'type': row['type'],
      }).toList();
    }
  }

  /// 地域とキーワードによる検索
  Future<List<Map<String, dynamic>>> searchByLocationAndKeyword({
    required String prefecture,
    required String city,
    required String keyword,
  }) async {
    await initDatabase();

    final results = _db!.select(
      "SELECT company_name as name, "
      "COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address, "
      "lat, lng, 'キーワード検索' as type "
      "FROM kigyou WHERE (company_name LIKE ? OR address LIKE ?) AND prefecture = ? AND city = ? LIMIT 100",
      ['%$keyword%', '%$keyword%', prefecture, city]
    );

    return results.map((row) => {
      'name': row['name'],
      'address': row['address'],
      'lat': row['lat'],
      'lng': row['lng'],
      'type': row['type'],
    }).toList();
  }

  Map<String, String> _getHalfKanaMap() {
    return {
      'ア': 'ｱ', 'イ': 'ｲ', 'ウ': 'ｳ', 'エ': 'ｴ', 'オ': 'ｵ',
      'カ': 'ｶ', 'キ': 'ｷ', 'ク': 'ｸ', 'ケ': 'ｹ', 'コ': 'ｺ',
      'サ': 'ｻ', 'シ': 'ｼ', 'ス': 'ｽ', 'セ': 'ｾ', 'ソ': 'ｿ',
      'タ': 'ﾀ', 'チ': 'ﾁ', 'ツ': 'ﾂ', 'テ': 'ﾃ', 'ト': 'ﾄ',
      'ナ': 'ﾅ', 'ニ': 'ﾆ', 'ヌ': 'ﾇ', 'ネ': 'ﾈ', 'ノ': 'ﾉ',
      'ハ': 'ﾊ', 'ヒ': 'ﾋ', 'フ': 'ﾌ', 'ヘ': 'ﾍ', 'ホ': 'ﾎ',
      'マ': 'ﾏ', 'ミ': 'ﾐ', 'ム': 'ﾑ', 'メ': 'ﾒ', 'モ': 'ﾓ',
      'ヤ': 'ﾔ', 'ユ': 'ﾕ', 'ヨ': 'ﾖ',
      'ラ': 'ﾗ', 'リ': 'ﾘ', 'ル': 'ﾙ', 'レ': 'ﾚ', 'ロ': 'ﾛ',
      'ワ': 'ﾜ', 'ヲ': 'ｦ', 'ン': 'ﾝ',
      'ガ': 'ｶﾞ', 'ギ': 'ｷﾞ', 'グ': 'ｸﾞ', 'ゲ': 'ｹﾞ', 'ゴ': 'ｺﾞ',
      'ザ': 'ｻﾞ', 'ジ': 'ｼﾞ', 'ズ': 'ｽﾞ', 'ゼ': 'ｾﾞ', 'ゾ': 'ｿﾞ',
      'ダ': 'ﾀﾞ', 'ヂ': 'ﾁﾞ', 'ヅ': 'ﾂﾞ', 'デ': 'ﾃﾞ', 'ド': 'ﾄﾞ',
      'バ': 'ﾊﾞ', 'ビ': 'ﾋﾞ', 'ブ': 'ﾌﾞ', 'ベ': 'ﾍﾞ', 'ボ': 'ﾎﾞ',
      'パ': 'ﾊﾟ', 'ピ': 'ﾋﾟ', 'プ': 'ﾌﾟ', 'ペ': 'ﾍﾟ', 'ポ': 'ﾎﾟ',
    };
  }

  Map<String, List<String>> _getKanaRowMap() {
    return {
      'あ': ['ア', 'イ', 'ウ', 'エ', 'オ'],
      'か': ['カ', 'キ', 'ク', 'ケ', 'コ', 'ガ', 'ギ', 'グ', 'ゲ', 'ゴ'],
      'さ': ['サ', 'シ', 'ス', 'セ', 'ソ', 'ザ', 'ジ', 'ズ', 'ゼ', 'ゾ'],
      'た': ['タ', 'チ', 'ツ', 'テ', 'ト', 'ダ', 'ヂ', 'ヅ', 'デ', 'ド'],
      'な': ['ナ', 'ニ', 'ヌ', 'ネ', 'ノ'],
      'は': ['ハ', 'ヒ', 'フ', 'ヘ', 'ホ', 'バ', 'ビ', 'ブ', 'ベ', 'ボ', 'パ', 'ピ', 'プ', 'ペ', 'ポ'],
      'ま': ['マ', 'ミ', 'ム', 'メ', 'モ'],
      'や': ['ヤ', 'ユ', 'ヨ'],
      'ら': ['ラ', 'リ', 'ル', 'レ', 'ロ'],
      'わ': ['ワ', 'ヲ', 'ン'],
    };
  }
}
