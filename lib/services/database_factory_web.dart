import 'package:flutter/services.dart';
import 'package:sqlite3/wasm.dart';
import 'database_factory_interface.dart';

class DatabaseFactory extends DatabaseFactoryImpl {
  @override
  Future<CommonDatabase> openProjectDatabase(String assetPath, String dbName) async {
    final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    final fs = await IndexedDbFileSystem.open(dbName: dbName);
    sqlite3.registerVirtualFileSystem(fs, makeDefault: true);
    
    final dbPath = '/$dbName';
    
    // ファイルが存在しない、またはサイズが0の場合のみアセットで初期化
    // これにより、保存された lat/lng などのデータが永続化される
    bool needsInitialization = false;
    try {
      if (fs.xAccess(dbPath, 0) != 0) {
        needsInitialization = true;
      }
    } catch (_) {
      needsInitialization = true;
    }

    if (needsInitialization) {
      final out = fs.xOpen(Sqlite3Filename(dbPath), SqlFlag.SQLITE_OPEN_CREATE | SqlFlag.SQLITE_OPEN_READWRITE);
      out.file.xWrite(bytes, 0);
      out.file.xClose();
    }

    return sqlite3.open(dbPath);
  }
}
