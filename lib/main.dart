import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/main_screen.dart';
import 'firebase_options.dart';
import 'services/settings_service.dart';
import 'services/ink_recognition_service.dart';
import 'package:katura_system/utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firestoreの設定
  // Web版は接続安定性のため従来どおり永続化を無効化。
  // モバイル(実機)はオフラインキャッシュを有効化し、画面再訪時の再取得を高速化する。
  FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'katura-system-database',
  ).settings = Settings(
    persistenceEnabled: !kIsWeb,
    sslEnabled: true,
  );

  // 日本語ロケールの初期化
  await initializeDateFormatting('ja_JP', null);

  // アプリ全体設定（文字入力方式など）の復元
  await SettingsService.load();

  // 手書き認識モデルを背景で準備（ペンタブ立ち上がりの遅延を解消）
  unawaited(InkRecognitionService.instance.prepare());

  runApp(const KaturaSystemApp());
}

class KaturaSystemApp extends StatelessWidget {
  const KaturaSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Katura System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.mainBackground,
      ),
      home: const MainScreen(),
    );
  }
}
