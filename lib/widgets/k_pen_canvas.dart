import 'package:flutter/material.dart';

enum KPenTool { pen, eraser }

class DrawingPoint {
  final Offset offset;
  final Paint paint;
  final int timestamp;

  DrawingPoint({
    required this.offset, 
    required this.paint,
    required this.timestamp,
  });
}

class KPenCanvasController extends ChangeNotifier {
  final List<DrawingPoint?> _points = [];
  List<DrawingPoint?> get points => List.unmodifiable(_points);

  void addPoint(DrawingPoint? point) {
    _points.add(point);
    notifyListeners();
  }

  void setPoints(List<DrawingPoint?> newPoints) {
    _points.clear();
    _points.addAll(newPoints);
    notifyListeners();
  }

  void clear() {
    _points.clear();
    notifyListeners();
  }

  void undo() {
    if (_points.isEmpty) return;
    // 末尾がnull（ストロークの終わり）なら削除
    if (_points.last == null) {
      _points.removeLast();
    }
    // 次のnullにぶつかるかリストが空になるまで、直前のストロークの点を削除
    while (_points.isNotEmpty && _points.last != null) {
      _points.removeLast();
    }
    notifyListeners();
  }

  /// [position]から[radius]以内の点を消去する（消しゴム機能）。
  /// 消去箇所の前後で線がつながらないよう、必要に応じて区切り(null)を挿入する。
  void erase(Offset position, double radius) {
    if (_points.isEmpty) return;
    final List<DrawingPoint?> newPoints = [];
    for (final p in _points) {
      if (p == null) {
        newPoints.add(null);
        continue;
      }
      final bool hit = (p.offset - position).distance <= radius;
      if (hit) {
        if (newPoints.isNotEmpty && newPoints.last != null) {
          newPoints.add(null);
        }
        continue;
      }
      newPoints.add(p);
    }
    _points
      ..clear()
      ..addAll(newPoints);
    notifyListeners();
  }
}

class KPenCanvas extends StatefulWidget {
  final KPenCanvasController controller;
  final Color strokeColor;
  final double strokeWidth;
  final KPenTool tool;
  final double eraserRadius;
  final Function(Offset, int)? onPointDown;
  final Function(Offset, int)? onPointMove;
  final VoidCallback? onPointUp;

  const KPenCanvas({
    super.key,
    required this.controller,
    this.strokeColor = Colors.black,
    this.strokeWidth = 4.0,
    this.tool = KPenTool.pen,
    this.eraserRadius = 16.0,
    this.onPointDown,
    this.onPointMove,
    this.onPointUp,
  });

  @override
  State<KPenCanvas> createState() => _KPenCanvasState();
}

class _KPenCanvasState extends State<KPenCanvas> {
  Offset? _eraserPosition;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  bool get _isEraser => widget.tool == KPenTool.eraser;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        if (_isEraser) {
          setState(() => _eraserPosition = event.localPosition);
          widget.controller.erase(event.localPosition, widget.eraserRadius);
        } else {
          widget.controller.addPoint(
            DrawingPoint(
              offset: event.localPosition,
              timestamp: timestamp,
              paint: Paint()
                ..color = widget.strokeColor
                ..strokeCap = StrokeCap.round
                ..strokeWidth = widget.strokeWidth,
            ),
          );
        }
        widget.onPointDown?.call(event.localPosition, timestamp);
      },
      onPointerMove: (event) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        if (_isEraser) {
          setState(() => _eraserPosition = event.localPosition);
          widget.controller.erase(event.localPosition, widget.eraserRadius);
        } else {
          widget.controller.addPoint(
            DrawingPoint(
              offset: event.localPosition,
              timestamp: timestamp,
              paint: Paint()
                ..color = widget.strokeColor
                ..strokeCap = StrokeCap.round
                ..strokeWidth = widget.strokeWidth,
            ),
          );
        }
        widget.onPointMove?.call(event.localPosition, timestamp);
      },
      onPointerUp: (event) {
        if (_isEraser) {
          setState(() => _eraserPosition = null);
        } else {
          widget.controller.addPoint(null); // 線の切れ目
        }
        widget.onPointUp?.call();
      },
      child: CustomPaint(
        painter: _CanvasPainter(widget.controller.points, _eraserPosition, widget.eraserRadius),
        size: Size.infinite,
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<DrawingPoint?> points;
  final Offset? eraserPosition;
  final double eraserRadius;

  _CanvasPainter(this.points, this.eraserPosition, this.eraserRadius);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          points[i]!.offset,
          points[i + 1]!.offset,
          points[i]!.paint,
        );
      } else if (points[i] != null && points[i + 1] == null) {
        // 点の描画（タップのみの場合対応）
        canvas.drawCircle(points[i]!.offset, points[i]!.paint.strokeWidth / 2, points[i]!.paint);
      }
    }
    if (eraserPosition != null) {
      canvas.drawCircle(
        eraserPosition!,
        eraserRadius,
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        eraserPosition!,
        eraserRadius,
        Paint()
          ..color = Colors.grey.shade600
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) => true;
}
