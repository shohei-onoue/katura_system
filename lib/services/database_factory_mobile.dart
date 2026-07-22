import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/common.dart';
import 'database_factory_interface.dart';

class DatabaseFactory extends DatabaseFactoryImpl {
  @override
  Future<CommonDatabase> openProjectDatabase(String assetPath, String dbName) async {
    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = join(dbDir.path, dbName);

    if (!await File(dbPath).exists()) {
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    return sqlite3.open(dbPath);
  }
}
