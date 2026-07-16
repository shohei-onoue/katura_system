import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// 現場のスピードに耐えうるローカルSQLite（assets/post_addresses.db）ベースの住所検索サービス
class AddressService {
  // シングルトン化：現場で複数のインスタンスが乱立してDBをロックするのを防ぐ
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  Database? _db;
  Completer<void>? _initCompleter;

  // 現場のスピードを支える都道府県固定リスト（DBスキャンをゼロにし、起動直後のタップ反応を極限まで高める）
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

  Future<void> initDatabase() async {
    // すでに初期化中なら、その完了を待つ
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<void>();

    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, "post_addresses.db");

      if (!await File(path).exists()) {
        final data = await rootBundle.load("assets/post_addresses.db");
        final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);

        final db = await openDatabase(path);
        // インデックス作成を明示的に実行（初回のみ）
        // 市区町村検索と町域検索のどちらもカバリングインデックスで爆速化
        await db.execute("CREATE INDEX IF NOT EXISTS idx_pref_city ON addresses(prefecture, city_kana, city)");
        await db.execute("CREATE INDEX IF NOT EXISTS idx_pref_city_town ON addresses(prefecture, city, town_kana, town)");
        await db.close();
      }

      _db = await openDatabase(path, readOnly: true);
      _initCompleter!.complete();
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null; // 失敗時はリトライ可能にする
    }
  }

  /// 都道府県のカナ検索（メモリ内定数利用）
  Future<List<String>> getPrefecturesByInitial(String initialRow) async {
    final Map<String, List<String>> rowMap = _getKanaRowMap();
    final prefixes = rowMap[initialRow] ?? [];
    if (prefixes.isEmpty) return [];

    return _prefectures
        .where((p) => prefixes.any((pref) => p['kana']!.startsWith(pref)))
        .map((p) => p['state']!)
        .toList();
  }

  /// 全都道府県取得
  Future<List<String>> getPrefectures() async {
    return _prefectures.map((p) => p['state']!).toList();
  }

  /// 指定都道府県の市区町村取得（DB検索 - 負荷軽減のため制限付き）
  Future<List<String>> getCities(String state) async {
    await initDatabase();
    final List<Map<String, dynamic>> maps = await _db!.rawQuery(
      'SELECT DISTINCT city FROM addresses WHERE prefecture = ? ORDER BY city_kana LIMIT 100',
      [state]
    );
    return maps.map((m) => m['city'] as String).toList();
  }

  /// 指定都道府県内で、頭文字行（あ〜わ）に一致する市区町村を検索
  Future<List<String>> getCitiesByInitial(String state, String initialRow) async {
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

    final List<Map<String, dynamic>> maps = await _db!.rawQuery(
      'SELECT DISTINCT city FROM addresses WHERE prefecture = ? AND ($whereClause) ORDER BY city_kana',
      params
    );

    return maps.map((m) => m['city'] as String).toList();
  }

  /// 指定市区町村内の町域取得
  Future<List<String>> getTowns(String state, String city) async {
    await initDatabase();
    final List<Map<String, dynamic>> maps = await _db!.rawQuery(
      'SELECT DISTINCT town FROM addresses WHERE prefecture = ? AND city = ? ORDER BY town_kana LIMIT 100',
      [state, city]
    );
    return maps.map((m) => m['town'] as String).toList();
  }

  /// 指定市区町村内で、頭文字行（あ〜わ）に一致する町域を検索
  Future<List<String>> getTownsByInitial(String state, String city, String initialRow) async {
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

    final List<Map<String, dynamic>> maps = await _db!.rawQuery(
      'SELECT DISTINCT town FROM addresses WHERE prefecture = ? AND city = ? AND ($whereClause) ORDER BY town_kana',
      params
    );

    return maps.map((m) => m['town'] as String).toList();
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
