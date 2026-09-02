import 'package:flutter/foundation.dart';
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

  final mlkit.DigitalInkRecognizer _recognizer =
      mlkit.DigitalInkRecognizer(languageCode: _lang);
  final mlkit.DigitalInkRecognizerModelManager _modelManager =
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
    return _recognizer.recognize(ink);
  }
}
