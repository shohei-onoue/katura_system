import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as mlkit;
import 'k_responsive.dart';
import 'k_button.dart';
import 'k_pen_canvas.dart';

class KPenInputDialog extends StatefulWidget {
  final Function(String) onTextRecognized;

  const KPenInputDialog({
    super.key,
    required this.onTextRecognized,
  });

  @override
  State<KPenInputDialog> createState() => _KPenInputDialogState();
}

class _KPenInputDialogState extends State<KPenInputDialog> {
  final mlkit.Ink _ink = mlkit.Ink();
  final KPenCanvasController _canvasController = KPenCanvasController();
  List<mlkit.StrokePoint> _currentStrokePoints = [];
  String _recognizedText = "";
  bool _isRecognizing = false;
  bool _isModelReady = false;
  String _statusMessage = "";
  
  late final mlkit.DigitalInkRecognizer _recognizer;
  final _modelManager = mlkit.DigitalInkRecognizerModelManager();

  @override
  void initState() {
    super.initState();
    _recognizer = mlkit.DigitalInkRecognizer(languageCode: 'ja');
    _checkModel();
  }

  @override
  void dispose() {
    _recognizer.close();
    _canvasController.dispose();
    super.dispose();
  }

  Future<void> _checkModel() async {
    try {
      final isDownloaded = await _modelManager.isModelDownloaded('ja');
      if (!isDownloaded) {
        if (mounted) setState(() => _statusMessage = "システム準備中...");
        await _modelManager.downloadModel('ja');
      }
      if (mounted) {
        setState(() {
          _isModelReady = true;
          _statusMessage = "";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _statusMessage = "準備エラー: $e");
    }
  }

  void _handlePointDown(Offset offset, int timestamp) {
    _currentStrokePoints = [
      mlkit.StrokePoint(x: offset.dx, y: offset.dy, t: timestamp)
    ];
  }

  void _handlePointMove(Offset offset, int timestamp) {
    _currentStrokePoints.add(
      mlkit.StrokePoint(x: offset.dx, y: offset.dy, t: timestamp)
    );
  }

  void _handlePointUp() {
    if (!_isModelReady || _currentStrokePoints.isEmpty) return;

    final stroke = mlkit.Stroke();
    for (final p in _currentStrokePoints) {
      stroke.points.add(p);
    }
    
    setState(() {
      _ink.strokes.add(stroke);
      _currentStrokePoints = [];
      _isRecognizing = true;
    });
    _recognize();
  }

  Future<void> _recognize() async {
    try {
      final candidates = await _recognizer.recognize(_ink);
      if (mounted) {
        setState(() {
          if (candidates.isNotEmpty) {
            _recognizedText = candidates.first.text;
          }
          _isRecognizing = false;
        });
      }
    } catch (e) {
      debugPrint('Recognition error: $e');
      if (mounted) setState(() => _isRecognizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: rs(context, 800),
        height: rs(context, 750),
        padding: EdgeInsets.all(rs(context, 24)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('手書き入力（AI判定）', style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            // ステータス & プレビュー
            Container(
              height: rs(context, 100),
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade200, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    _statusMessage.isNotEmpty
                      ? _statusMessage
                      : (_isRecognizing 
                        ? '判定中...' 
                        : (_recognizedText.isEmpty ? 'ここに文字を書いてください' : _recognizedText)),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: rf(context, 36),
                      fontWeight: FontWeight.bold,
                      color: (_recognizedText.isEmpty || _isRecognizing || _statusMessage.isNotEmpty) 
                          ? Colors.grey : Colors.deepPurple.shade900,
                    ),
                  ),
                  if (_isRecognizing)
                    const Positioned(
                      right: 24,
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // 描画エリア
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: KPenCanvas(
                    controller: _canvasController,
                    onPointDown: _handlePointDown,
                    onPointMove: _handlePointMove,
                    onPointUp: _handlePointUp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: KButton(
                    label: 'すべてクリア',
                    color: Colors.grey.shade600,
                    onPressed: () {
                      setState(() {
                        _canvasController.clear();
                        _ink.strokes.clear();
                        _currentStrokePoints = [];
                        _recognizedText = "";
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: KButton(
                    label: '備考へ反映する',
                    color: Colors.deepPurple,
                    onPressed: () {
                      if (_recognizedText.isNotEmpty) {
                        widget.onTextRecognized(_recognizedText);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
