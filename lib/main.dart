import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/main_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firestoreの設定（Web版の接続安定化）
  FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'katura-system-database',
  ).settings = const Settings(
    persistenceEnabled: false,
    sslEnabled: true,
  );

  // 日本語ロケールの初期化
  await initializeDateFormatting('ja_JP', null);

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
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainScreen(),
    );
  }
}
