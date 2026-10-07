import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqlite3/common.dart';
import 'database_factory.dart';
import '../constants/address_constants.dart';
import 'category_service.dart';

/// 現場のスピードに耐えうる SQLite（WASM/Native）ベースの住所検索サービス
class AddressService {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  CommonDatabase? _db;
  Completer<void>? _initCompleter;
  final _categoryService = CategoryService();

  Future<Map<String, Map<String, List<String>>>> getCategoryHierarchy() async {
    return await _categoryService.getCategoryHierarchy();
  }

  Future<void> initDatabase() async {
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }
    _initCompleter = Completer<void>();
    try {
      _db = await DatabaseFactory.openProjectDatabase("assets/navi_database.db", "navi_database.db");
      _db!.execute("CREATE INDEX IF NOT EXISTS idx_pref_city ON post_all(prefecture, city_kana, city)");
      _db!.execute("CREATE INDEX IF NOT EXISTS idx_pref_city_town ON post_all(prefecture, city, town_kana, town)");
      _addColumnIfNotExists('kigyou', 'lat', 'REAL');
      _addColumnIfNotExists('kigyou', 'lng', 'REAL');
      try {
        await _ensureAzaTable();
      } catch (e) {
        debugPrint('aza table error: $e');
        try { _db!.execute('ROLLBACK'); } catch (_) {}
      }
      _initCompleter!.complete();
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null;
    }
  }

  /// aza.tsv の中身を更新したら、この数字を上げる（端末のdbを作り直すための目印）。
  static const int _azaVersion = 2;

  /// 字・丁目などの細かい地名（e-Stat 町丁・字等）。端末のdbに無い・古いときは assets/aza.tsv から作り直す。
  Future<void> _ensureAzaTable() async {
    final hasVersion = _db!.select("SELECT name FROM sqlite_master WHERE type='table' AND name='aza_version'").isNotEmpty;
    final hasAza = _db!.select("SELECT name FROM sqlite_master WHERE type='table' AND name='aza'").isNotEmpty;
    if (hasVersion && hasAza) {
      final v = _db!.select('SELECT v FROM aza_version LIMIT 1');
      if (v.isNotEmpty && (v.first['v'] as int) >= _azaVersion) return;
    }
    final text = await rootBundle.loadString('assets/aza.tsv');
    _db!.execute('BEGIN');
    _db!.execute('DROP TABLE IF EXISTS aza');
    _db!.execute('DROP TABLE IF EXISTS aza_version');
    _db!.execute('CREATE TABLE aza(prefecture TEXT, city TEXT, town TEXT, detail TEXT)');
    final stmt = _db!.prepare('INSERT INTO aza VALUES (?, ?, ?, ?)');
    for (final line in text.split('\n')) {
      final c = line.split('\t');
      if (c.length == 4) stmt.execute(c);
    }
    stmt.close();
    _db!.execute('CREATE INDEX idx_aza ON aza(prefecture, city, town)');
    _db!.execute('CREATE TABLE aza_version(v INTEGER)');
    _db!.execute('INSERT INTO aza_version VALUES ($_azaVersion)');
    _db!.execute('COMMIT');
  }

  /// 選んだ町名の「字・丁目」候補（標準データ＋ユーザーが追加登録した分）。町名が空（すべて）のときは市区町村全体（町名つき）。
  Future<List<({String town, String detail})>> getAzaCandidates(String pref, String city, String town) async {
    await initDatabase();
    _db!.execute('CREATE TABLE IF NOT EXISTS aza_user(prefecture TEXT, city TEXT, town TEXT, detail TEXT)');
    final rows = town.isEmpty
        ? _db!.select(
            'SELECT DISTINCT town, detail FROM (SELECT town, detail FROM aza WHERE prefecture = ?1 AND city = ?2 '
            'UNION SELECT town, detail FROM aza_user WHERE prefecture = ?1 AND city = ?2) ORDER BY town, detail',
            [pref, city])
        : _db!.select(
            'SELECT DISTINCT town, detail FROM (SELECT town, detail FROM aza WHERE prefecture = ?1 AND city = ?2 AND town = ?3 '
            'UNION SELECT town, detail FROM aza_user WHERE prefecture = ?1 AND city = ?2 AND town = ?3) ORDER BY detail',
            [pref, city, town]);
    return [for (final r in rows) (town: r['town'] as String, detail: r['detail'] as String)];
  }

  /// 字・丁目などを追加登録する（端末のdbに保存。標準データを作り直しても消えない）。
  Future<void> addAzaUser(String pref, String city, String town, String detail) async {
    await initDatabase();
    _db!.execute('CREATE TABLE IF NOT EXISTS aza_user(prefecture TEXT, city TEXT, town TEXT, detail TEXT)');
    _db!.execute('INSERT INTO aza_user VALUES (?, ?, ?, ?)', [pref, city, town, detail]);
  }

  void _addColumnIfNotExists(String tableName, String columnName, String type) {
    final pragma = _db!.select("PRAGMA table_info($tableName)");
    final exists = pragma.any((row) => row['name'] == columnName);
    if (!exists) {
      _db!.execute("ALTER TABLE $tableName ADD COLUMN $columnName $type");
    }
  }

  Future<List<Map<String, dynamic>>> searchFacilityByName(String name) async {
    await initDatabase();
    final kigyouResults = _db!.select("SELECT company_name as name, COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address, lat, lng, '企業' as type FROM kigyou WHERE company_name LIKE ?", ['%$name%']);
    final medicalResults = _db!.select("SELECT name, COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address, NULL as lat, NULL as lng, '医療' as type FROM medical WHERE name LIKE ?", ['%$name%']);
    return [...kigyouResults, ...medicalResults].map((row) => {'name': row['name'], 'address': row['address'], 'lat': row['lat'], 'lng': row['lng'], 'type': row['type']}).toList();
  }

  Future<List<String>> getPrefecturesByInitial(String initial) async {
    await initDatabase();
    if (initial == 'すべて') {
      return _db!.select('SELECT DISTINCT prefecture FROM post_all ORDER BY prefecture_kana').map((row) => row['prefecture'] as String).toList();
    }
    final List<String> prefixes = _getPrefixes(initial);
    final String whereClause = prefixes.map((_) => 'prefecture_kana LIKE ?').join(' OR ');
    return _db!.select('SELECT DISTINCT prefecture FROM post_all WHERE $whereClause ORDER BY prefecture_kana', prefixes.map((p) => '$p%').toList()).map((row) => row['prefecture'] as String).toList();
  }

  Future<List<String>> getPrefectures() async => AddressConstants.prefectures.map((p) => p['state']!).toList();

  Future<List<String>> getCities(String state) async {
    await initDatabase();
    return _db!.select('SELECT DISTINCT city FROM post_all WHERE prefecture = ? ORDER BY city_kana', [state]).map((row) => row['city'] as String).toList();
  }

  Future<List<String>> getCitiesByInitial(String state, String initial) async {
    if (initial == 'すべて') {
      return getCities(state);
    }
    await initDatabase();
    final List<String> prefixes = _getPrefixes(initial);
    final String whereClause = prefixes.map((_) => 'city_kana LIKE ?').join(' OR ');
    return _db!.select('SELECT DISTINCT city FROM post_all WHERE prefecture = ? AND ($whereClause) ORDER BY city_kana', [state, ...prefixes.map((p) => '$p%')]).map((row) => row['city'] as String).toList();
  }

  Future<List<String>> getTowns(String state, String city) async {
    await initDatabase();
    return _db!.select('SELECT DISTINCT town FROM post_all WHERE prefecture = ? AND city = ? ORDER BY town_kana', [state, city]).map((row) => row['town'] as String).toList();
  }

  Future<List<String>> getTownsByInitial(String state, String city, String initial) async {
    if (initial == 'すべて') {
      return getTowns(state, city);
    }
    await initDatabase();
    final List<String> prefixes = _getPrefixes(initial);
    final String whereClause = prefixes.map((_) => 'town_kana LIKE ?').join(' OR ');
    return _db!.select('SELECT DISTINCT town FROM post_all WHERE prefecture = ? AND city = ? AND ($whereClause) ORDER BY town_kana', [state, city, ...prefixes.map((p) => '$p%')]).map((row) => row['town'] as String).toList();
  }

  Future<List<Map<String, String>>> getRandomOkazakiEntities({int limit = 10}) async {
    await initDatabase();
    final kigyouResults = _db!.select("SELECT company_name as name, COALESCE(prefecture, '') as pref, COALESCE(city, '') as city, COALESCE(town, '') as town, COALESCE(address, '') as addr FROM kigyou WHERE city = '岡崎市' ORDER BY RANDOM() LIMIT ?", [(limit / 2).ceil()]);
    final medicalResults = _db!.select("SELECT name, COALESCE(prefecture, '') as pref, COALESCE(city, '') as city, COALESCE(town, '') as town, COALESCE(address, '') as addr FROM medical WHERE city = '岡崎市' ORDER BY RANDOM() LIMIT ?", [(limit / 2).floor()]);
    final List<Map<String, String>> combined = [];
    for (var r in kigyouResults) {
      combined.add({'name': r['name'] as String, 'pref': r['pref'] as String, 'city': r['city'] as String, 'town': r['town'] as String, 'addr': r['addr'] as String, 'type': '企業'});
    }
    for (var r in medicalResults) {
      combined.add({'name': r['name'] as String, 'pref': r['pref'] as String, 'city': r['city'] as String, 'town': r['town'] as String, 'addr': r['addr'] as String, 'type': '医療'});
    }
    return combined..shuffle();
  }

  /// データベースにデータがない場合でも、指定された都市のリストから強制的にエンティティを生成する
  Future<List<Map<String, String>>> getRandomAichiEntities({int limit = 100}) async {
    await initDatabase();
    final targetCities = ['岡崎市', '名古屋市', '豊田市', '安城市', '一宮市', '春日井市', '刈谷市', '豊橋市', '西尾市', '知立市', '幸田町', '瀬戸市', '半田市', '東海市', '大府市'];
    final List<Map<String, String>> combined = [];
    
    final int perCityLimit = (limit / targetCities.length).ceil();

    for (var city in targetCities) {
      // まずはDBから取得を試みる
      final dbResults = _db!.select(
        "SELECT company_name as name, COALESCE(prefecture, '愛知県') as pref, COALESCE(city, ?) as city, COALESCE(town, '') as town, COALESCE(address, '1-1-1') as addr "
        "FROM kigyou WHERE city = ? LIMIT ?", 
        [city, city, perCityLimit]
      );

      if (dbResults.isNotEmpty) {
        for (var r in dbResults) {
          combined.add({
            'name': r['name'] as String, 
            'pref': r['pref'] as String, 
            'city': r['city'] as String, 
            'town': r['town'] as String, 
            'addr': r['addr'] as String, 
            'type': '企業'
          });
        }
      } else {
        // DBにデータがない場合は、ダミーの施設を捏造する（テスト/デモ用）
        final dummies = [
          '$city中央病院', '$city市役所', '$cityグランドホテル', '$city工業', '株式会社$cityフーズ'
        ];
        for (int i = 0; i < (perCityLimit > 5 ? 5 : perCityLimit); i++) {
          combined.add({
            'name': dummies[i % dummies.length],
            'pref': '愛知県',
            'city': city,
            'town': '中央町',
            'addr': '${i + 1}-10',
            'type': 'ダミー'
          });
        }
      }
    }
    
    return combined..shuffle();
  }

  Future<void> upsertKigyouEntity({
    required String name, 
    required String address, 
    required double lat, 
    required double lng,
    String? prefecture,
    String? city,
  }) async {
    await initDatabase();
    final pref = prefecture ?? '愛知県';
    final targetCity = city ?? '岡崎市';
    
    String street = address.replaceFirst(pref, '').replaceFirst(targetCity, '');
    final existing = _db!.select('SELECT rowid FROM kigyou WHERE company_name = ? AND (address LIKE ? OR address = ?) LIMIT 1', [name, '%$street%', street]);
    if (existing.isNotEmpty) {
      _db!.execute('UPDATE kigyou SET lat = ?, lng = ? WHERE rowid = ?', [lat, lng, existing.first['rowid']]);
    } else {
      _db!.execute('INSERT INTO kigyou (company_name, address, lat, lng, prefecture, city) VALUES (?, ?, ?, ?, ?, ?)', [name, street, lat, lng, pref, targetCity]);
    }
  }

  Future<List<Map<String, dynamic>>> searchByLocationAndCategory({
    required String prefecture, 
    required String city, 
    String town = '（すべて）', 
    required String category, 
    required String genre
  }) async {
    await initDatabase();
    final hierarchy = await getCategoryHierarchy();
    final keywords = hierarchy[category]?[genre] ?? [];
    if (keywords.isEmpty) {
      return [];
    }
    
    final String kigyouLike = keywords.map((_) => 'company_name LIKE ?').join(' OR ');
    final String medicalLike = keywords.map((_) => 'name LIKE ?').join(' OR ');
    
    String townFilter = "";
    List<String> townParams = [];
    if (town != '（すべて）' && town.isNotEmpty) {
      townFilter = " AND address LIKE ?";
      townParams = ['%$town%'];
    }

    final List<String> params = [
      ...keywords.map((k) => '%$k%'), 
      prefecture, 
      city, 
      ...townParams,
      ...keywords.map((k) => '%$k%'), 
      prefecture, 
      city,
      ...townParams
    ];

    final results = _db!.select(
      "SELECT company_name as name, COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address, lat, lng, '$genre' as type "
      "FROM kigyou WHERE ($kigyouLike) AND prefecture = ? AND city = ?$townFilter "
      "UNION ALL "
      "SELECT name, COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address, NULL as lat, NULL as lng, '$genre' as type "
      "FROM medical WHERE ($medicalLike) AND prefecture = ? AND city = ?$townFilter LIMIT 200", 
      params
    );
    return results.map((r) => {'name': r['name'], 'address': r['address'], 'lat': r['lat'], 'lng': r['lng'], 'type': r['type']}).toList();
  }

  Future<List<Map<String, dynamic>>> searchByAddressOrZip(String query) async {
    await initDatabase();
    final isZip = RegExp(r'^[0-9\-]+$').hasMatch(query);
    if (isZip) {
      final cleanZip = query.replaceAll('-', '');
      final postResults = _db!.select(
        "SELECT prefecture as name, city, town, prefecture || city || town as address, NULL as lat, NULL as lng, '郵便番号一致' as type "
        "FROM post_all WHERE zip_code = ? OR zip_code = ? LIMIT 100", 
        [cleanZip, query]
      );
      if (postResults.isNotEmpty) {
        return postResults.map((r) => {'name': r['name'], 'pref': r['name'], 'city': r['city'], 'town': r['town'], 'address': r['address'], 'lat': r['lat'], 'lng': r['lng'], 'type': r['type']}).toList();
      }

      return _db!.select("SELECT company_name as name, COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address, lat, lng, '郵便番号一致' as type FROM kigyou WHERE zip_code = ? OR zip_code = ? LIMIT 100", [cleanZip, query]).map((r) => {'name': r['name'], 'address': r['address'], 'lat': r['lat'], 'lng': r['lng'], 'type': r['type']}).toList();
    }
    return _db!.select("SELECT company_name as name, COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address, lat, lng, '住所検索' as type FROM kigyou WHERE address LIKE ? OR city LIKE ? OR town LIKE ? LIMIT 100", ['%$query%', '%$query%', '%$query%']).map((r) => {'name': r['name'], 'address': r['address'], 'lat': r['lat'], 'lng': r['lng'], 'type': r['type']}).toList();
  }

  Future<List<Map<String, dynamic>>> searchByLocationAndKeyword({
    required String prefecture, 
    required String city, 
    String town = '（すべて）', 
    required String keyword
  }) async {
    await initDatabase();
    String townFilter = "";
    List<String> params = ['%$keyword%', '%$keyword%', prefecture, city];
    if (town != '（すべて）' && town.isNotEmpty) {
      townFilter = " AND address LIKE ?";
      params.add('%$town%');
    }
    return _db!.select(
      "SELECT company_name as name, COALESCE(prefecture, '') || COALESCE(city, '') || COALESCE(town, '') || COALESCE(address, '') as address, lat, lng, 'キーワード検索' as type "
      "FROM kigyou WHERE (company_name LIKE ? OR address LIKE ?) AND prefecture = ? AND city = ?$townFilter LIMIT 100", 
      params
    ).map((r) => {'name': r['name'], 'address': r['address'], 'lat': r['lat'], 'lng': r['lng'], 'type': r['type']}).toList();
  }

  List<String> _getPrefixes(String initial) {
    // 全ての五十音に対して、対応する全角カタカナをマッピング (濁音・半濁音含む)
    final Map<String, List<String>> charMap = {
      'あ': ['ア'], 'い': ['イ'], 'う': ['ウ'], 'え': ['エ'], 'お': ['オ'],
      'か': ['カ', 'ガ'], 'き': ['キ', 'ギ'], 'く': ['ク', 'グ'], 'け': ['ケ', 'ゲ'], 'こ': ['コ', 'ゴ'],
      'さ': ['サ', 'ザ'], 'し': ['シ', 'ジ'], 'す': ['ス', 'ズ'], 'せ': ['セ', 'ゼ'], 'そ': ['ソ', 'ゾ'],
      'た': ['タ', 'ダ'], 'ち': ['チ', 'ヂ'], 'つ': ['ツ', 'ヅ'], 'て': ['テ', 'デ'], 'と': ['ト', 'ド'],
      'な': ['ナ'], 'に': ['ニ'], 'ぬ': ['ヌ'], 'ね': ['ネ'], 'の': ['ノ'],
      'は': ['ハ', 'バ', 'パ'], 'ひ': ['ヒ', 'ビ', 'ピ'], 'ふ': ['フ', 'ブ', 'プ'], 'へ': ['ヘ', 'ベ', 'ペ'], 'ほ': ['ホ', 'ボ', 'ポ'],
      'ま': ['マ'], 'み': ['ミ'], 'む': ['ム'], 'め': ['メ'], 'も': ['モ'],
      'や': ['ヤ'], 'ゆ': ['ユ'], 'よ': ['ヨ'],
      'ら': ['ラ'], 'り': ['リ'], 'る': ['ル'], 'れ': ['レ'], 'ろ': ['ロ'],
      'わ': ['ワ'], 'を': ['ヲ'], 'ん': ['ン'],
    };

    // 全角カタカナを半角カタカナへ変換するためのテーブル (濁点・半濁点対応)
    final Map<String, String> toHalf = {
      'ア': 'ｱ', 'イ': 'ｲ', 'ウ': 'ｳ', 'エ': 'ｴ', 'オ': 'ｵ',
      'カ': 'ｶ', 'キ': 'ｷ', 'ク': 'ｸ', 'ケ': 'ｹ', 'コ': 'ｺ',
      'サ': 'ｻ', 'シ': 'ｼ', 'ス': 'ｽ', 'セ': 'ｾ', 'ソ': 'ｿ',
      'タ': 'ﾀ', 'チ': 'ﾁ', 'ツ': 'ﾂ', 'テ': 'ﾃ', 'ト': 'ﾄ',
      'ナ': 'ﾅ', 'ニ': 'ﾆ', 'ヌ': 'ﾇ', 'ネ': 'ﾈ', 'ノ': 'ﾉ',
      'ハ': 'ﾊ', 'ヒ': 'ﾋ', 'フ': 'ﾌ', 'ヘ': 'ﾍ', 'ホ': 'ﾎ',
      'マ': 'ﾏ', 'ミ': 'ﾐ', 'ム': 'ﾑ', 'メ': 'ﾒ', 'モ': 'ﾓ',
      'ヤ': 'ﾔ', 'ユ': 'ﾕ', 'ヨ': 'ヨ',
      'ラ': 'ﾗ', 'リ': 'ﾘ', 'ル': 'ﾙ', 'レ': 'ﾚ', 'ロ': 'ﾛ',
      'わ': 'ﾜ', 'ヲ': 'ｦ', 'ン': 'ﾝ',
      'ガ': 'ｶﾞ', 'ギ': 'ｷﾞ', 'グ': 'ｸﾞ', 'ゲ': 'ｹﾞ', 'ゴ': 'ｺﾞ',
      'ザ': 'ｻﾞ', 'ジ': 'ｼﾞ', 'ズ': 'ｽﾞ', 'ゼ': 'ｾﾞ', 'ゾ': 'ｿﾞ',
      'ダ': 'ﾀﾞ', 'ヂ': 'ﾁﾞ', 'ヅ': 'ﾂﾞ', 'デ': 'ﾃﾞ', 'ド': 'ﾄﾞ',
      'バ': 'ﾊﾞ', 'ビ': 'ﾋﾞ', 'ブ': 'ﾌﾞ', 'ベ': 'ﾍﾞ', 'ボ': 'ﾎﾞ',
      'パ': 'ﾊﾟ', 'ピ': 'ﾋﾟ', 'プ': 'ﾌﾟ', 'ペ': 'ﾍﾟ', 'ポ': 'ﾎﾟ'
    };

    // あ行などのグループ検索も念のためサポート
    final Map<String, List<String>> rowMap = {
      'あ': ['ア', 'イ', 'ウ', 'エ', 'オ'], 'か': ['カ', 'キ', 'ク', 'ケ', 'コ', 'ガ', 'ギ', 'グ', 'ゲ', 'ゴ'], 
      'さ': ['サ', 'シ', 'ス', 'セ', 'ソ', 'ザ', 'ジ', 'ズ', 'ゼ', 'ゾ'], 'た': ['タ', 'チ', 'ツ', 'て', 'と', 'ダ', 'ヂ', 'ヅ', 'デ', 'ド'], 
      'な': ['ナ', 'ニ', 'ヌ', 'ネ', 'ノ'], 'は': ['ハ', 'ヒ', 'フ', 'ヘ', 'ホ', 'バ', 'ビ', 'ブ', 'ベ', 'ボ', 'パ', 'ピ', 'プ', 'ペ', 'ポ'], 
      'ま': ['マ', 'ミ', 'ム', 'メ', 'モ'], 'や': ['ヤ', 'ユ', 'ヨ'], 'ら': ['ら', 'り', 'る', 'れ', 'ろ'], 'わ': ['ワ', 'を', 'ん']
    };

    List<String> targets = charMap[initial] ?? rowMap[initial] ?? [];
    
    final List<String> result = [];
    for (var t in targets) {
      result.add(t);
      if (toHalf.containsKey(t)) {
        result.add(toHalf[t]!);
      }
    }
    return result;
  }
}
