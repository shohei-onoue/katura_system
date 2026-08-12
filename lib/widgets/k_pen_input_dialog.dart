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
  final List<mlkit.Ink> _pagesInks = [mlkit.Ink()];
  final List<List<DrawingPoint?>> _pagesPoints = [[]];
  final List<String> _pagesTexts = [""];
  int _currentPageIndex = 0;

  final KPenCanvasController _canvasController = KPenCanvasController();
  List<mlkit.StrokePoint> _currentStrokePoints = [];
  
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
      _pagesInks[_currentPageIndex].strokes.add(stroke);
      _pagesPoints[_currentPageIndex] = List.from(_canvasController.points);
      _currentStrokePoints = [];
      _isRecognizing = true;
    });
    _recognize();
  }

  Future<void> _recognize() async {
    if (_pagesInks[_currentPageIndex].strokes.isEmpty) {
      setState(() {
        _pagesTexts[_currentPageIndex] = "";
        _isRecognizing = false;
      });
      return;
    }
    try {
      final candidates = await _recognizer.recognize(_pagesInks[_currentPageIndex]);
      if (mounted) {
        setState(() {
          if (candidates.isNotEmpty) {
            _pagesTexts[_currentPageIndex] = candidates.first.text;
          } else {
            _pagesTexts[_currentPageIndex] = "";
          }
          _isRecognizing = false;
        });
      }
    } catch (e) {
      debugPrint('Recognition error: $e');
      if (mounted) setState(() => _isRecognizing = false);
    }
  }

  void _undoStroke() {
    if (_pagesInks[_currentPageIndex].strokes.isNotEmpty) {
      setState(() {
        _pagesInks[_currentPageIndex].strokes.removeLast();
        _canvasController.undo();
        _pagesPoints[_currentPageIndex] = List.from(_canvasController.points);
        _isRecognizing = true;
      });
      _recognize();
    }
  }

  void _clearCanvas() {
    setState(() {
      _pagesInks[_currentPageIndex].strokes.clear();
      _canvasController.clear();
      _pagesPoints[_currentPageIndex] = [];
      _pagesTexts[_currentPageIndex] = "";
    });
  }

  void _goToNextPage() {
    setState(() {
      if (_currentPageIndex == _pagesInks.length - 1) {
        _pagesInks.add(mlkit.Ink());
        _pagesPoints.add([]);
        _pagesTexts.add("");
      }
      _currentPageIndex++;
      _canvasController.setPoints(_pagesPoints[_currentPageIndex]);
    });
  }

  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
        _canvasController.setPoints(_pagesPoints[_currentPageIndex]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullText = _pagesTexts.join("");
    final double sideBtnWidth = rav(context, 60);

    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.all(rav(context, 12)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rav(context, 16))),
      child: Container(
        width: wp(context, 0.98),
        height: hp(context, 0.98),
        padding: EdgeInsets.symmetric(vertical: rav(context, 16)),
        child: Column(
          children: [
            // ヘッダー (中央揃え)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sideBtnWidth),
              child: Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.deepPurple.shade300, size: rav(context, 24)),
                  const SizedBox(width: 8),
                  Text('手書き入力（AI判定）', 
                    style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, size: rav(context, 22), color: Colors.white), 
                    onPressed: () => Navigator.pop(context)
                  ),
                ],
              ),
            ),
            
            // テキストプレビューエリア (中央揃え)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sideBtnWidth),
              child: Container(
                height: rav(context, 80),
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: rav(context, 8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: rf(context, 22), height: 1.2),
                          children: [
                            for (int i = 0; i < _pagesTexts.length; i++)
                              TextSpan(
                                text: _pagesTexts[i],
                                style: TextStyle(
                                  color: i == _currentPageIndex ? Colors.deepPurple : Colors.black87,
                                  fontWeight: i == _currentPageIndex ? FontWeight.bold : FontWeight.normal,
                                  backgroundColor: i == _currentPageIndex ? Colors.deepPurple.withValues(alpha: 0.1) : null,
                                ),
                              ),
                            if (fullText.isEmpty && _statusMessage.isEmpty)
                              TextSpan(
                                text: 'ここにAIにより判定された文字が表示されます',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: rf(context, 18)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (_isRecognizing)
                      const Positioned(right: 0, top: 0, child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                  ],
                ),
              ),
            ),
            
            // 描画エリア (左右にページボタン)
            Expanded(
              child: Row(
                children: [
                  _buildPageSideBtn(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: _currentPageIndex > 0 ? _goToPreviousPage : null,
                    isLeft: true,
                    width: sideBtnWidth,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade400, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: KPenCanvas(
                          controller: _canvasController,
                          strokeWidth: 5.0,
                          onPointDown: _handlePointDown,
                          onPointMove: _handlePointMove,
                          onPointUp: _handlePointUp,
                        ),
                      ),
                    ),
                  ),
                  _buildPageSideBtn(
                    icon: Icons.arrow_forward_ios,
                    onPressed: _pagesInks[_currentPageIndex].strokes.isNotEmpty ? _goToNextPage : null,
                    isLeft: false,
                    width: sideBtnWidth,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: rav(context, 16)),
            
            // 下部アクションボタン (25% : 25% : 50%) (中央揃え)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sideBtnWidth),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: KButton(
                      label: '戻る',
                      color: Colors.orange,
                      onPressed: _pagesInks[_currentPageIndex].strokes.isNotEmpty ? _undoStroke : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: KButton(
                      label: '削除',
                      color: Colors.grey,
                      onPressed: _pagesInks[_currentPageIndex].strokes.isNotEmpty ? _clearCanvas : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: KButton(
                      label: '完了',
                      color: Colors.deepPurple,
                      onPressed: fullText.isNotEmpty ? () {
                        widget.onTextRecognized(fullText);
                        Navigator.pop(context);
                      } : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageSideBtn({
    required IconData icon, 
    required VoidCallback? onPressed, 
    required bool isLeft,
    required double width,
  }) {
    return Container(
      width: width,
      height: double.infinity,
      padding: EdgeInsets.only(
        left: isLeft ? 8 : 0,
        right: isLeft ? 0 : 8,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Icon(
            icon, 
            color: onPressed != null ? Colors.white : Colors.grey.shade800,
            size: rav(context, 32),
          ),
        ),
      ),
    );
  }
}
