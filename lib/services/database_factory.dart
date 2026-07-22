import 'package:sqlite3/common.dart';
import 'database_factory_mobile.dart'
    if (dart.library.html) 'database_factory_web.dart' as impl;

class DatabaseFactory {
  static Future<CommonDatabase> openProjectDatabase(String assetPath, String dbName) async {
    return impl.DatabaseFactory().openProjectDatabase(assetPath, dbName);
  }
}
