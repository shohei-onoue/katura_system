import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as mlkit;
import 'k_responsive.dart';
import 'k_button.dart';
import 'k_pen_canvas.dart';
import '../services/ink_recognition_service.dart';

class KPenInputDialog extends StatefulWidget {
  final Function(String) onTextRecognized;
  /// すでにフィールドへ反映済みのテキスト。AI判定表示エリアの先頭に表示する。
  final String initialText;

  const KPenInputDialog({
    super.key,
    required this.onTextRecognized,
    this.initialText = '',
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
  KPenTool _currentTool = KPenTool.pen;

  bool _isRecognizing = false;
  bool _isModelReady = false;
  String _statusMessage = "";

  /// すでに判定済み（フィールド反映済み）のテキスト。ここでも削除できるようにする。
  late String _baseText;

  final InkRecognitionService _ink = InkRecognitionService.instance;

  @override
  void initState() {
    super.initState();
    _baseText = widget.initialText;
    _checkModel();
  }

  @override
  void dispose() {
    _canvasController.dispose();
    super.dispose();
  }

  Future<void> _checkModel() async {
    if (_ink.isReady) {
      _isModelReady = true;
      return;
    }
    try {
      if (mounted) setState(() => _statusMessage = "システム準備中...");
      await _ink.prepare();
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
    if (_currentTool == KPenTool.eraser) return;
    _currentStrokePoints = [
      mlkit.StrokePoint(x: offset.dx, y: offset.dy, t: timestamp)
    ];
  }

  void _handlePointMove(Offset offset, int timestamp) {
    if (_currentTool == KPenTool.eraser) return;
    _currentStrokePoints.add(
      mlkit.StrokePoint(x: offset.dx, y: offset.dy, t: timestamp)
    );
  }

  void _handlePointUp() {
    if (_currentTool == KPenTool.eraser) {
      // 消しゴム操作の結果に合わせて認識用インクを再構築する
      setState(() {
        _pagesInks[_currentPageIndex] = _inkFromPoints(_canvasController.points);
        _pagesPoints[_currentPageIndex] = List.from(_canvasController.points);
        _isRecognizing = true;
      });
      _recognize();
      return;
    }

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

  /// ストローク間の区切り(null)で分割された点列から、ML Kit認識用のInkを再構築する。
  /// 消しゴムで一部が削除された後もキャンバスの点列とインクの内容を一致させるために使う。
  mlkit.Ink _inkFromPoints(List<DrawingPoint?> points) {
    final ink = mlkit.Ink();
    mlkit.Stroke? current;
    for (final p in points) {
      if (p == null) {
        current = null;
        continue;
      }
      if (current == null) {
        current = mlkit.Stroke();
        ink.strokes.add(current);
      }
      current.points.add(mlkit.StrokePoint(x: p.offset.dx, y: p.offset.dy, t: p.timestamp));
    }
    return ink;
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
      final candidates = await _ink.recognize(_pagesInks[_currentPageIndex]);
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

  /// 現在の手書き判定分を確定し、末尾に半角スペースを挿入する（スペースキー相当）。
  void _insertSpace() {
    setState(() {
      _baseText = '$_baseText${_pagesTexts.join("")} ';
      _pagesInks
        ..clear()
        ..add(mlkit.Ink());
      _pagesPoints
        ..clear()
        ..add(<DrawingPoint?>[]);
      _pagesTexts
        ..clear()
        ..add("");
      _currentPageIndex = 0;
      _canvasController.clear();
    });
  }

  /// 判定済みテキスト（フィールド反映済み分）を1文字削除する。
  void _backspaceBaseText() {
    if (_baseText.isEmpty) return;
    setState(() => _baseText = _baseText.substring(0, _baseText.length - 1));
  }

  /// 判定済みテキストをすべて削除する。
  void _clearBaseText() {
    if (_baseText.isEmpty) return;
    setState(() => _baseText = "");
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
    final newText = _pagesTexts.join("");
    final combinedText = _baseText + newText;
    final bool hasStrokes = _pagesInks[_currentPageIndex].strokes.isNotEmpty;
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
                  SizedBox(width: rs(context, 8)),
                  Text('手書き入力（AI判定）',
                    style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  _buildToolToggle(),
                  SizedBox(width: rs(context, 8)),
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
                padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rs(context, 8)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                  border: Border.all(color: Colors.grey.shade300, width: rs(context, 1)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(fontSize: rf(context, 22), height: rs(context, 1.2)),
                          children: [
                            if (_baseText.isNotEmpty)
                              TextSpan(
                                text: _baseText,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            for (int i = 0; i < _pagesTexts.length; i++)
                              TextSpan(
                                text: _pagesTexts[i],
                                style: TextStyle(
                                  color: i == _currentPageIndex ? Colors.deepPurple : Colors.black87,
                                  fontWeight: i == _currentPageIndex ? FontWeight.bold : FontWeight.normal,
                                  backgroundColor: i == _currentPageIndex ? Colors.deepPurple.withValues(alpha: 0.1) : null,
                                ),
                              ),
                            if (_baseText.isEmpty && newText.isEmpty && _statusMessage.isEmpty)
                              TextSpan(
                                text: 'ここにAIにより判定された文字が表示されます',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: rf(context, 18)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (_isRecognizing)
                      Positioned(right: 0, top: 0, child: SizedBox(width: rs(context, 16), height: rs(context, 16), child: CircularProgressIndicator(strokeWidth: 2))),
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
                        border: Border.all(color: Colors.grey.shade400, width: rs(context, 2)),
                        borderRadius: BorderRadius.circular(rs(context, 12)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(rs(context, 10)),
                        child: KPenCanvas(
                          controller: _canvasController,
                          strokeWidth: 5.0,
                          tool: _currentTool,
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
                      label: hasStrokes ? '戻る' : '1字削除',
                      color: Colors.orange,
                      onPressed: hasStrokes
                          ? _undoStroke
                          : (_baseText.isNotEmpty ? _backspaceBaseText : null),
                    ),
                  ),
                  SizedBox(width: rs(context, 12)),
                  Expanded(
                    flex: 1,
                    child: KButton(
                      label: '削除',
                      color: Colors.grey,
                      onPressed: hasStrokes
                          ? _clearCanvas
                          : (_baseText.isNotEmpty ? _clearBaseText : null),
                    ),
                  ),
                  SizedBox(width: rs(context, 12)),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: kFieldHeight(context),
                      child: ElevatedButton(
                        onPressed: combinedText.isNotEmpty ? _insertSpace : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(rav(context, 8)),
                          ),
                        ),
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Text(']',
                              style: TextStyle(fontSize: rf(context, 24), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: rs(context, 12)),
                  Expanded(
                    flex: 2,
                    child: KButton(
                      label: '完了',
                      color: Colors.deepPurple,
                      onPressed: combinedText != widget.initialText ? () {
                        widget.onTextRecognized(combinedText);
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

  Widget _buildToolToggle() {
    return Container(
      padding: EdgeInsets.all(rs(context, 4)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(rs(context, 10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolBtn(KPenTool.pen, Icons.edit, 'ペン'),
          SizedBox(width: rs(context, 4)),
          _buildToolBtn(KPenTool.eraser, Icons.auto_fix_normal, '消しゴム'),
        ],
      ),
    );
  }

  Widget _buildToolBtn(KPenTool tool, IconData icon, String label) {
    final bool isSelected = _currentTool == tool;
    return InkWell(
      onTap: () => setState(() => _currentTool = tool),
      borderRadius: BorderRadius.circular(rs(context, 8)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 8)),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade300 : Colors.transparent,
          borderRadius: BorderRadius.circular(rs(context, 8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: rs(context, 18), color: Colors.white),
            SizedBox(width: rs(context, 6)),
            Text(label, style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: Colors.white)),
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
          borderRadius: BorderRadius.circular(rs(context, 8)),
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
