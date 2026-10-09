import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as mlkit;
import 'k_responsive.dart';
import 'k_button.dart';
import 'k_pen_canvas.dart';
import '../services/ink_recognition_service.dart';
import 'package:katura_system/utils/app_colors.dart';
import 'package:katura_system/utils/platform_utils.dart';

/// 手書き入力ダイアログ。タブレットは手書き（AI判定）、PC（Web/デスクトップ）はキーボード直接入力に切り替える。
class KPenInputDialog extends StatelessWidget {
  final Function(String) onTextRecognized;
  /// すでにフィールドへ反映済みのテキスト。AI判定表示エリアの先頭に表示する。
  final String initialText;

  const KPenInputDialog({
    super.key,
    required this.onTextRecognized,
    this.initialText = '',
  });

  @override
  Widget build(BuildContext context) => useOnScreenKeyboard
      ? _PenInputBody(onTextRecognized: onTextRecognized, initialText: initialText)
      : _KeyboardInputDialog(onTextRecognized: onTextRecognized, initialText: initialText);
}

class _PenInputBody extends StatefulWidget {
  final Function(String) onTextRecognized;
  final String initialText;

  const _PenInputBody({required this.onTextRecognized, required this.initialText});

  @override
  State<_PenInputBody> createState() => _PenInputBodyState();
}

class _PenInputBodyState extends State<_PenInputBody> {
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

  /// 判定済みテキストの編集（表示エリアをタップした位置にカーソルを出して直す）
  final TextEditingController _editController = TextEditingController();
  final FocusNode _editFocus = FocusNode();
  bool _editing = false;

  final InkRecognitionService _ink = InkRecognitionService.instance;

  @override
  void initState() {
    super.initState();
    _baseText = widget.initialText;
    _editFocus.addListener(() {
      if (!_editFocus.hasFocus && _editing && mounted) setState(() => _editing = false);
    });
    _checkModel();
  }

  @override
  void dispose() {
    _canvasController.dispose();
    _editController.dispose();
    _editFocus.dispose();
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
    if (_editing) _editFocus.unfocus(); // 書き始めたら編集モードを終える
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
    _syncEditor();
  }

  /// 判定済みテキストをすべて削除する。
  void _clearBaseText() {
    if (_baseText.isEmpty) return;
    setState(() => _baseText = "");
    _syncEditor();
  }

  /// 編集中なら、入力欄の内容をボタン操作後の判定済みテキストに合わせる。
  void _syncEditor() {
    if (!_editing) return;
    _editController.value = TextEditingValue(
      text: _baseText,
      selection: TextSelection.collapsed(offset: _baseText.length),
    );
  }

  /// 表示エリアのタップ位置にカーソルを出して編集できるようにする。
  /// 手書き途中の判定分は先に確定し、タップした文字位置へカーソルを置く。
  void _startEditing(Offset local, Size box) {
    if (_isRecognizing) return;
    final span = _previewSpan();
    final tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr)
      ..layout(maxWidth: box.width);
    final origin = Offset((box.width - tp.width) / 2, (box.height - tp.height) / 2);
    final combined = _baseText + _pagesTexts.join("");
    final offset = tp.getPositionForOffset(local - origin).offset.clamp(0, combined.length);
    setState(() {
      _baseText = combined;
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
      _editing = true;
      _editController.value = TextEditingValue(
        text: combined,
        selection: TextSelection.collapsed(offset: offset),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _editFocus.requestFocus();
    });
  }

  /// 表示エリアの文字（判定済み＋手書き途中の判定分）。
  TextSpan _previewSpan() {
    final newText = _pagesTexts.join("");
    return TextSpan(
      style: TextStyle(fontSize: rf(context, 22), height: rs(context, 1.2)),
      children: [
        if (_baseText.isNotEmpty)
          TextSpan(text: _baseText, style: const TextStyle(color: Colors.black54)),
        for (int i = 0; i < _pagesTexts.length; i++)
          TextSpan(
            text: _pagesTexts[i],
            style: TextStyle(
              color: i == _currentPageIndex ? AppColors.accentPurple : Colors.black87,
              fontWeight: i == _currentPageIndex ? FontWeight.bold : FontWeight.normal,
              backgroundColor: i == _currentPageIndex ? AppColors.accentPurple.withValues(alpha: 0.1) : null,
            ),
          ),
        if (_baseText.isEmpty && newText.isEmpty && _statusMessage.isEmpty)
          TextSpan(
            text: 'ここにAIにより判定された文字が表示されます',
            style: TextStyle(color: Colors.grey.shade400, fontSize: rf(context, 18)),
          ),
      ],
    );
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
      backgroundColor: AppColors.primaryText,
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
                    style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold, color: AppColors.mainBackground)),
                  const Spacer(),
                  _buildToolToggle(),
                  SizedBox(width: rs(context, 8)),
                  IconButton(
                    icon: Icon(Icons.close, size: rav(context, 22), color: AppColors.mainBackground), 
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
                  color: AppColors.mainBackground,
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                  border: Border.all(color: Colors.grey.shade300, width: rs(context, 1)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    LayoutBuilder(
                      builder: (context, c) {
                        if (_editing) {
                          return Center(
                            child: TextField(
                              controller: _editController,
                              focusNode: _editFocus,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              minLines: 1,
                              style: TextStyle(fontSize: rf(context, 22), height: rs(context, 1.2), color: Colors.black87),
                              decoration: const InputDecoration.collapsed(hintText: ''),
                              onChanged: (v) => setState(() => _baseText = v),
                            ),
                          );
                        }
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (d) => _startEditing(d.localPosition, c.biggest),
                          child: Center(
                            child: RichText(textAlign: TextAlign.center, text: _previewSpan()),
                          ),
                        );
                      },
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
                        color: AppColors.mainBackground,
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
                      color: AppColors.accentOrange,
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
                          foregroundColor: AppColors.mainBackground,
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
                      color: AppColors.accentPurple,
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
        color: AppColors.mainBackground.withValues(alpha: 0.1),
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
            Icon(icon, size: rs(context, 18), color: AppColors.mainBackground),
            SizedBox(width: rs(context, 6)),
            Text(label, style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: AppColors.mainBackground)),
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
            color: onPressed != null ? AppColors.mainBackground : Colors.grey.shade800,
            size: rav(context, 32),
          ),
        ),
      ),
    );
  }
}

/// PC用：手書きの代わりにキーボードで直接入力するダイアログ。
class _KeyboardInputDialog extends StatefulWidget {
  final Function(String) onTextRecognized;
  final String initialText;

  const _KeyboardInputDialog({required this.onTextRecognized, required this.initialText});

  @override
  State<_KeyboardInputDialog> createState() => _KeyboardInputDialogState();
}

class _KeyboardInputDialogState extends State<_KeyboardInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _done() {
    widget.onTextRecognized(_controller.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.popupBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 16))),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: rs(context, 560)),
        child: Padding(
          padding: EdgeInsets.all(rs(context, 20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 1,
                maxLines: 3,
                style: TextStyle(fontSize: rf(context, 18)),
                onSubmitted: (_) => _done(),
                decoration: InputDecoration(
                  hintText: 'キーボードで入力してください',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
                ),
              ),
              SizedBox(height: rs(context, 16)),
              Row(
                children: [
                  Expanded(child: KButton(label: 'キャンセル', color: AppColors.cancelButton, onPressed: () => Navigator.pop(context))),
                  SizedBox(width: rs(context, 12)),
                  Expanded(child: KButton(label: '完了', color: AppColors.accentPurple, onPressed: _done)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
