import 'package:flutter/services.dart';
import 'package:sqlite3/wasm.dart';
import 'database_factory_interface.dart';

/// Web用: wasm本体・IndexedDBファイルシステムは1つだけ作り、全サービスで共有する。
/// 同じDBは1回だけ開き、同じFutureを返す(並行openによるIndexedDB競合を防ぐ)。
class DatabaseFactory extends DatabaseFactoryImpl {
  static Future<WasmSqlite3>? _sqliteFuture;
  static Future<IndexedDbFileSystem>? _fsFuture;
  static final Map<String, Future<CommonDatabase>> _dbs = {};
  // 初期化(ファイル作成)を1つずつ順番に行うための鎖
  static Future<void> _chain = Future.value();

  @override
  Future<CommonDatabase> openProjectDatabase(String assetPath, String dbName) {
    return _dbs.putIfAbsent(dbName, () {
      final completer = Future<CommonDatabase>(() => _open(assetPath, dbName));
      // 直列化: 前の初期化が終わってから次を開始
      final prev = _chain;
      _chain = prev.then((_) => completer).then((_) {}, onError: (_) {});
      return prev.then((_) => completer);
    }).catchError((Object e) {
      _dbs.remove(dbName); // 失敗時は次回やり直せるようにする
      throw e;
    });
  }

  Future<CommonDatabase> _open(String assetPath, String dbName) async {
    _sqliteFuture ??= WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
    final sqlite3 = await _sqliteFuture!;
    _fsFuture ??= IndexedDbFileSystem.open(dbName: 'katura_web_fs').then((fs) {
      sqlite3.registerVirtualFileSystem(fs, makeDefault: true);
      return fs;
    });
    final fs = await _fsFuture!;
    final dbPath = '/$dbName';

    bool needsInitialization = false;
    try {
      if (fs.xAccess(dbPath, 0) == 0) {
        needsInitialization = true;
      }
    } catch (_) {
      needsInitialization = true;
    }

    if (needsInitialization) {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      final out = fs.xOpen(Sqlite3Filename(dbPath), SqlFlag.SQLITE_OPEN_CREATE | SqlFlag.SQLITE_OPEN_READWRITE);
      out.file.xWrite(bytes, 0);
      out.file.xClose();
      await fs.flush();
    }

    return sqlite3.open(dbPath);
  }
}
