import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/login/login_screen.dart';
import 'firebase_options.dart';
import 'services/settings_service.dart';
import 'services/ink_recognition_service.dart';
import 'package:katura_system/utils/app_colors.dart';
import 'widgets/k_responsive.dart';
import 'utils/screen_angle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // スマホ(画面の短い辺が600未満)は縦向き固定。タブレットは向き自由。Webは対象外
  if (!kIsWeb) {
    final v = WidgetsBinding.instance.platformDispatcher.views.first;
    if (v.physicalSize.shortestSide / v.devicePixelRatio < 600) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }
  
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
        primarySwatch: Colors.orange,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.mainBackground,
      ),
      // サイズ指定のない文字・アイコンも、画面比率に合わせて拡大縮小する（小さくなりすぎないよう下限0.8）
      builder: (context, child) {
        // スマホのWebブラウザは、横向きにしても縦向きのままのUIを維持する（画面を逆回転して縦に保つ）
        final mq = MediaQuery.of(context);
        final bool mobileBrowser = kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
        final int angle = mobileBrowser ? screenAngle() : 0;
        if (mobileBrowser && mq.size.shortestSide < 600 && (angle == 90 || angle == 270)) {
          child = RotatedBox(
            quarterTurns: angle == 90 ? 3 : 1,
            child: MediaQuery(
              data: mq.copyWith(size: Size(mq.size.height, mq.size.width), padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero, viewInsets: EdgeInsets.zero),
              child: child!,
            ),
          );
        }
        final f = KR.scale(context).clamp(0.8, 3.0).toDouble();
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.apply(fontSizeFactor: f),
            iconTheme: theme.iconTheme.copyWith(size: 24 * f),
            iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(iconSize: 24 * f)),
          ),
          child: child!,
        );
      },
      home: const LoginScreen(),
    );
  }
}
