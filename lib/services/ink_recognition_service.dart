import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as mlkit;

/// 手書き認識(ML Kit Digital Ink)のリソースをアプリ全体で共有する。
///
/// これまでは [KPenInputDialog] を開くたびに `DigitalInkRecognizer` を生成し、
/// モデルのダウンロード確認(プラットフォームチャネル往復)とネイティブ初期化を
/// 毎回行っていたため、ダイヤログの立ち上がりが遅かった。
/// 生成・モデル確認・ウォームアップを起動時に一度だけ行い、以降は使い回す。
class InkRecognitionService {
  InkRecognitionService._();
  static final InkRecognitionService instance = InkRecognitionService._();

  static const String _lang = 'ja';

  // Webでは使えないため、使う時まで生成しない
  late final mlkit.DigitalInkRecognizer _recognizer =
      mlkit.DigitalInkRecognizer(languageCode: _lang);
  late final mlkit.DigitalInkRecognizerModelManager _modelManager =
      mlkit.DigitalInkRecognizerModelManager();

  Future<void>? _prepareFuture;
  bool _ready = false;

  /// モデル準備済みか(同期参照用。未準備なら [prepare] を待つ)
  bool get isReady => _ready;

  /// 起動時に一度呼び出し、モデルの確認/取得とネイティブ初期化を済ませる。
  /// 複数回呼ばれても実処理は一度だけ。
  Future<void> prepare() {
    return _prepareFuture ??= _prepareImpl();
  }

  Future<void> _prepareImpl() async {
    if (kIsWeb) {
      // Webは端末内モデルがないため準備不要（認識はネット経由）
      _ready = true;
      return;
    }
    try {
      final downloaded = await _modelManager.isModelDownloaded(_lang);
      if (!downloaded) {
        await _modelManager.downloadModel(_lang);
      }
      // ネイティブ認識エンジンをウォームアップし、初回 recognize の遅延をなくす
      final warmInk = mlkit.Ink()
        ..strokes.add(mlkit.Stroke()
          ..points.addAll([
            mlkit.StrokePoint(x: 0, y: 0, t: 0),
            mlkit.StrokePoint(x: 1, y: 1, t: 1),
          ]));
      try {
        await _recognizer.recognize(warmInk);
      } catch (_) {
        // ウォームアップ失敗は無視(本番の recognize で再試行される)
      }
      _ready = true;
    } catch (e) {
      debugPrint('InkRecognitionService prepare error: $e');
      rethrow;
    }
  }

  Future<List<mlkit.RecognitionCandidate>> recognize(mlkit.Ink ink) {
    if (kIsWeb) return _recognizeWeb(ink);
    return _recognizer.recognize(ink);
  }

  /// Web用：Googleの手書き認識(Input Tools)へ線の座標を送って候補を得る。
  Future<List<mlkit.RecognitionCandidate>> _recognizeWeb(mlkit.Ink ink) async {
    final strokes = <List<List<num>>>[];
    for (final st in ink.strokes) {
      if (st.points.isEmpty) continue;
      final t0 = st.points.first.t;
      strokes.add([
        st.points.map((p) => p.x).toList(),
        st.points.map((p) => p.y).toList(),
        st.points.map((p) => p.t - t0).toList(),
      ]);
    }
    if (strokes.isEmpty) return [];
    final res = await http.post(
      Uri.parse('https://inputtools.google.com/request?itc=ja-t-i0-handwrit&app=katura'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'options': 'enable_pre_space',
        'requests': [
          {
            'writing_guide': {'writing_area_width': 800, 'writing_area_height': 400},
            'ink': strokes,
            'language': 'ja',
          }
        ],
      }),
    );
    final data = jsonDecode(res.body);
    if (data is! List || data.isEmpty || data[0] != 'SUCCESS') return [];
    final list = (data[1][0][1] as List).cast<String>();
    return [for (final t in list) mlkit.RecognitionCandidate(text: t, score: 0)];
  }
}
