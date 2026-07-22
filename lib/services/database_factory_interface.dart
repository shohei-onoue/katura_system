import 'package:sqlite3/common.dart';

abstract class DatabaseFactoryImpl {
  Future<CommonDatabase> openProjectDatabase(String assetPath, String dbName);
}
